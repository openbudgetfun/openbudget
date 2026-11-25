// Measures how much a static build sends and how long it takes to show.
//
// Serves a build directory the way a CDN does (gzip or brotli when the
// browser accepts it), opens it in headless Chromium with an emulated mobile
// network, and prints one JSON object: requests, bytes on the wire, bytes
// after decoding, and paint timings. For a Flutter web build it also waits
// for the `flutter-first-frame` event, which Flutter fires once the first
// frame is on screen.
//
//   node tools/perf/web_load.mjs <build dir> [--path /] [--network 4g|none]
//     [--encoding br|gzip|identity] [--flutter] [--runs 3]
//
// Build the Flutter app with `--no-web-resources-cdn` so CanvasKit is served
// from the build too; requests to other hosts are blocked and listed.
//
// Chromium and Playwright come preinstalled in cloud sessions; elsewhere run
// `npm i -g playwright` first. Results feed docs/performance.md.

import { readFile, stat } from "node:fs/promises";
import { createServer } from "node:http";
import { createRequire } from "node:module";
import { extname, join, normalize } from "node:path";
import { brotliCompressSync, constants, gzipSync } from "node:zlib";

const require = createRequire(import.meta.url);
const { chromium } = require("playwright");

const args = process.argv.slice(2);
const root = args[0];
if (!root) {
  console.error("usage: node tools/perf/web_load.mjs <build dir> [options]");
  process.exit(2);
}
const option = (name, fallback) => {
  const index = args.indexOf(`--${name}`);
  return index === -1 ? fallback : args[index + 1];
};
const flutter = args.includes("--flutter");
const pagePath = option("path", "/");
const network = option("network", "4g");
const encoding = option("encoding", "br");
const runs = Number(option("runs", "3"));
const timeoutMs = Number(option("timeout", "180000"));

// Lighthouse's mobile preset ("slow 4G"): 150 ms RTT, 1.6 Mbps down.
const networks = {
  none: null,
  "4g": { latency: 150, downloadThroughput: (1.6 * 1024 * 1024) / 8, uploadThroughput: (750 * 1024) / 8 },
};

const types = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript",
  ".mjs": "text/javascript",
  ".css": "text/css",
  ".json": "application/json",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".wasm": "application/wasm",
  ".ttf": "font/ttf",
  ".otf": "font/otf",
  ".woff2": "font/woff2",
  ".xml": "application/xml",
  ".txt": "text/plain",
};
// On-the-fly levels, like a CDN compressing a response it has not cached.
// Formats that are already compressed gain nothing from another pass.
const precompressed = new Set([".png", ".woff2", ".jpg", ".webp"]);
const cache = new Map();

async function body(file, wanted) {
  const key = `${file}|${wanted}`;
  if (!cache.has(key)) {
    const raw = await readFile(file);
    let data = raw;
    if (wanted === "br") {
      data = brotliCompressSync(raw, { params: { [constants.BROTLI_PARAM_QUALITY]: 5 } });
    } else if (wanted === "gzip") {
      data = gzipSync(raw, { level: 6 });
    }
    cache.set(key, data);
  }
  return cache.get(key);
}

async function resolve(urlPath) {
  const clean = normalize(decodeURIComponent(urlPath.split("?")[0])).replace(/^(\.\.[/\\])+/, "");
  for (const candidate of [clean, join(clean, "index.html"), `${clean}.html`]) {
    const file = join(root, candidate);
    try {
      if ((await stat(file)).isFile()) return file;
    } catch {}
  }
  return null;
}

const server = createServer(async (req, res) => {
  const file = await resolve(req.url);
  if (!file) {
    res.writeHead(404).end();
    return;
  }
  const ext = extname(file);
  const accepts = req.headers["accept-encoding"] ?? "";
  let chosen = "identity";
  if (!precompressed.has(ext) && encoding !== "identity") {
    if (encoding === "br" && accepts.includes("br")) chosen = "br";
    else if (accepts.includes("gzip")) chosen = "gzip";
  }
  const data = await body(file, chosen);
  const headers = { "content-type": types[ext] ?? "application/octet-stream", "cache-control": "no-store" };
  if (chosen !== "identity") headers["content-encoding"] = chosen;
  res.writeHead(200, headers).end(data);
});
await new Promise((done) => server.listen(0, "127.0.0.1", done));
const origin = `http://127.0.0.1:${server.address().port}`;

async function measure() {
  const browser = await chromium.launch();
  const context = await browser.newContext({ viewport: { width: 412, height: 915 }, deviceScaleFactor: 1 });
  const page = await context.newPage();
  const cdp = await context.newCDPSession(page);
  await cdp.send("Network.enable");
  await cdp.send("Network.setCacheDisabled", { cacheDisabled: true });
  if (networks[network]) {
    await cdp.send("Network.emulateNetworkConditions", { offline: false, ...networks[network] });
  }

  // Third-party hosts are out of reach from a sandbox and outside what the
  // build controls; they are cut off and listed so the gap stays visible.
  const blocked = [];
  await page.route((url) => new URL(url).origin !== origin, (route) => {
    blocked.push(route.request().url());
    return route.abort();
  });

  const requests = new Map();
  cdp.on("Network.responseReceived", ({ requestId, response }) => {
    requests.set(requestId, { url: response.url, type: response.mimeType, encoded: 0, decoded: 0 });
  });
  cdp.on("Network.dataReceived", ({ requestId, dataLength }) => {
    const entry = requests.get(requestId);
    if (entry) entry.decoded += dataLength;
  });
  cdp.on("Network.loadingFinished", ({ requestId, encodedDataLength }) => {
    const entry = requests.get(requestId);
    if (entry) entry.encoded = encodedDataLength;
  });

  await page.addInitScript(() => {
    window.__perf = { lcp: 0 };
    new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) window.__perf.lcp = entry.startTime;
    }).observe({ type: "largest-contentful-paint", buffered: true });
    window.addEventListener("flutter-first-frame", () => {
      window.__perf.firstFrame = performance.now();
    });
  });

  await page.goto(origin + pagePath, { waitUntil: "load", timeout: timeoutMs });
  if (flutter) {
    await page.waitForFunction(() => window.__perf.firstFrame !== undefined, null, {
      timeout: timeoutMs,
      polling: 100,
    });
  }
  // Let late requests (fonts, lazy images) finish so the byte count is whole.
  await page.waitForLoadState("networkidle", { timeout: timeoutMs }).catch(() => {});

  const timings = await page.evaluate(() => {
    const nav = performance.getEntriesByType("navigation")[0];
    const fcp = performance.getEntriesByName("first-contentful-paint")[0];
    return {
      ttfbMs: nav.responseStart,
      domContentLoadedMs: nav.domContentLoadedEventEnd,
      loadMs: nav.loadEventEnd,
      fcpMs: fcp?.startTime ?? null,
      lcpMs: window.__perf.lcp || null,
      firstFrameMs: window.__perf.firstFrame ?? null,
    };
  });
  await browser.close();

  const all = [...requests.values()];
  const byKind = {};
  for (const r of all) {
    const path = new URL(r.url).pathname;
    const kind = /\.(ttf|otf|woff2?)$/.test(path)
      ? "font"
      : /\.wasm$/.test(path)
      ? "wasm"
      : /\.m?js$/.test(path)
      ? "js"
      : r.type.split("/")[1] ?? "other";
    byKind[kind] ??= { requests: 0, wireBytes: 0, bytes: 0 };
    byKind[kind].requests += 1;
    byKind[kind].wireBytes += r.encoded;
    byKind[kind].bytes += r.decoded;
  }
  return {
    ...Object.fromEntries(Object.entries(timings).map(([k, v]) => [k, v === null ? null : Math.round(v)])),
    requests: all.length,
    wireBytes: all.reduce((s, r) => s + r.encoded, 0),
    bytes: all.reduce((s, r) => s + r.decoded, 0),
    byKind,
    blocked,
  };
}

const results = [];
for (let i = 0; i < runs; i++) results.push(await measure());
server.close();

const median = (values) => {
  const sorted = values.filter((v) => v !== null).sort((a, b) => a - b);
  return sorted.length ? sorted[Math.floor(sorted.length / 2)] : null;
};
const keys = [
  "ttfbMs",
  "fcpMs",
  "lcpMs",
  "firstFrameMs",
  "domContentLoadedMs",
  "loadMs",
  "requests",
  "wireBytes",
  "bytes",
];
const summary = { path: pagePath, network, encoding, runs };
for (const key of keys) summary[key] = median(results.map((r) => r[key]));
summary.byKind = results[0].byKind;
summary.blockedThirdParty = results[0].blocked;
console.log(JSON.stringify(summary, null, 2));
