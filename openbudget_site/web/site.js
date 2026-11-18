// The OpenBudget landing page's only script. It makes the hero's envelope
// desk playable and draws the pencil underlines in as sections arrive.
// Everything it changes is already on the page without it.
(() => {
  "use strict";

  const root = document.documentElement;
  root.classList.add("js-ready");
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  // Scroll reveals ----------------------------------------------------------

  const revealed = document.querySelectorAll("[data-reveal], .section-title");
  if ("IntersectionObserver" in window) {
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (!entry.isIntersecting) continue;
          entry.target.classList.add("is-inview");
          observer.unobserve(entry.target);
        }
      },
      { rootMargin: "0px 0px -8% 0px" },
    );
    revealed.forEach((element) => observer.observe(element));
  } else {
    revealed.forEach((element) => element.classList.add("is-inview"));
  }

  // Doodles pencil themselves on as their entry scrolls in. Only stroked
  // paths draw; fills are already there.
  document.querySelectorAll("[data-reveal] svg path").forEach((path) => {
    const style = window.getComputedStyle(path);
    if (style.stroke === "none" || path.closest("a, button")) return;
    path.setAttribute("pathLength", "1");
    path.classList.add("doodle-ink");
  });

  // Ink bursts ----------------------------------------------------------------

  const inks = ["--pink", "--teal", "--sunflower", "--sky", "--tangerine", "--lilac"];

  // Throws a handful of spot-ink pieces out from (x, y) inside [host].
  function burst(host, x, y, { count = 14, reach = 70 } = {}) {
    if (reducedMotion.matches) return;
    const layer = document.createElement("span");
    layer.className = "ink-burst";
    layer.setAttribute("aria-hidden", "true");
    layer.style.left = `${x}px`;
    layer.style.top = `${y}px`;
    for (let i = 0; i < count; i++) {
      const piece = document.createElement("span");
      const angle = (i / count) * Math.PI * 2 + (Math.random() - 0.5) * 0.6;
      const distance = reach * (0.55 + Math.random() * 0.45);
      piece.className = "ink-piece";
      piece.dataset.shape = ["dot", "dash", "ring"][i % 3];
      piece.style.setProperty("--dx", `${Math.cos(angle) * distance}px`);
      piece.style.setProperty("--dy", `${Math.sin(angle) * distance}px`);
      piece.style.setProperty("--spin", `${Math.round((Math.random() - 0.5) * 540)}deg`);
      piece.style.setProperty("--piece", `var(${inks[i % inks.length]})`);
      piece.style.setProperty("--size", `${6 + Math.round(Math.random() * 5)}px`);
      piece.style.rotate = `${angle}rad`;
      layer.append(piece);
    }
    host.append(layer);
    window.setTimeout(() => layer.remove(), 1000);
  }

  // The envelope desk -------------------------------------------------------

  const desk = document.querySelector("[data-desk]");
  const source = document.getElementById("desk-data");
  if (!desk || !source) return;

  const data = JSON.parse(source.textContent);
  const messages = data.messages;
  const readyOutput = desk.querySelector("[data-ready]");
  const status = desk.querySelector("[data-status]");
  const announcer = desk.querySelector("[data-announce]");
  const word = document.querySelector("[data-word]");
  const envelopes = Array.from(desk.querySelectorAll("[data-envelope]"), (element, index) => ({
    element,
    body: element.querySelector("[data-envelope-body]"),
    input: element.querySelector(".envelope-input"),
    amount: element.querySelector("[data-amount]"),
    name: data.envelopes[index].name,
  }));

  let currency = data.currencies[0];
  let values = currency.start.slice();
  let touched = false;

  const sum = (numbers) => numbers.reduce((total, n) => total + n, 0);
  const fillIn = (template, fields) => template.replace(/\{(\w+)\}/g, (_, key) => fields[key] ?? "");
  // Matches DemoCurrency.format in lib/src/demo_budget.dart.
  const format = (amount) =>
    (amount < 0 ? "-" : "") + currency.symbol + String(Math.abs(amount)).replace(/\B(?=(\d{3})+(?!\d))/g, ",");

  function announce(text) {
    status.textContent = text;
    announcer.textContent = text;
  }

  function stamp(envelope) {
    if (reducedMotion.matches) return;
    envelope.element.classList.remove("is-stamping");
    void envelope.element.offsetWidth;
    envelope.element.classList.add("is-stamping");
    // Money landed: a small burst of ink around the seal.
    const deskRect = desk.getBoundingClientRect();
    const sealRect = envelope.element.querySelector(".envelope-seal")?.getBoundingClientRect();
    if (sealRect) {
      burst(
        desk,
        sealRect.left + sealRect.width / 2 - deskRect.left,
        sealRect.top + sealRect.height / 2 - deskRect.top,
        { count: 10, reach: 46 },
      );
    }
  }

  // Every envelope full: stamp the sheet and throw a bigger burst.
  let postmark = null;
  function celebrate(done, fromVisitor) {
    if (!done) {
      postmark?.remove();
      postmark = null;
      return;
    }
    if (postmark || !fromVisitor) return;
    postmark = document.createElement("span");
    postmark.className = "desk-postmark";
    postmark.setAttribute("aria-hidden", "true");
    postmark.textContent = data.messages.postmark;
    desk.querySelector(".desk-sheet")?.append(postmark);
    const deskRect = desk.getBoundingClientRect();
    const amountRect = readyOutput.getBoundingClientRect();
    burst(
      desk,
      amountRect.left + amountRect.width / 2 - deskRect.left,
      amountRect.top + amountRect.height / 2 - deskRect.top,
      { count: 22, reach: 120 },
    );
  }

  function render({ fromVisitor }) {
    const ready = sum(currency.targets) - sum(values);
    let sealedNow = null;

    envelopes.forEach((envelope, index) => {
      const target = currency.targets[index];
      const value = values[index];
      envelope.element.style.setProperty("--fill", (value / target).toFixed(3));
      envelope.input.max = String(target);
      envelope.input.step = String(currency.step);
      envelope.input.value = String(value);
      envelope.input.setAttribute(
        "aria-valuetext",
        fillIn(messages.valueText, { amount: format(value), target: format(target) }),
      );
      envelope.amount.textContent = format(value);

      const sealed = value === target;
      if (sealed && !envelope.element.hasAttribute("data-sealed") && fromVisitor) {
        sealedNow = envelope;
        stamp(envelope);
      }
      envelope.element.toggleAttribute("data-sealed", sealed);
    });

    readyOutput.textContent = format(ready);
    desk.toggleAttribute("data-done", ready === 0);
    celebrate(ready === 0, fromVisitor);

    if (ready === 0) {
      announce(fillIn(messages.done, { word: currency.word }));
    } else if (sealedNow) {
      announce(fillIn(messages.sealed, { name: sealedNow.name }));
    } else if (touched) {
      // The slider already speaks its own value; only update the visible line.
      status.textContent = fillIn(messages.left, { amount: format(ready) });
    }
  }

  function setValue(index, value) {
    const target = currency.targets[index];
    const ready = sum(currency.targets) - sum(values);
    const limit = Math.min(target, values[index] + ready);
    const next = Math.max(0, Math.min(limit, value));
    if (next === values[index]) return;
    values[index] = next;
    touched = true;
    render({ fromVisitor: true });
  }

  function setFromPointer(index, event) {
    const rect = envelopes[index].body.getBoundingClientRect();
    const share = 1 - (event.clientY - rect.top) / rect.height;
    const target = currency.targets[index];
    const step = currency.step;
    const value = share > 0.94 ? target : Math.round((Math.max(0, share) * target) / step) * step;
    setValue(index, value);
  }

  envelopes.forEach((envelope, index) => {
    // The envelope is a label for its slider; keep a click from scrolling to
    // the hidden input.
    envelope.body.addEventListener("click", (event) => event.preventDefault());

    envelope.body.addEventListener("pointerdown", (event) => {
      if (event.button !== 0) return;
      // A mouse or pen drags; a finger taps, so the page still scrolls.
      const drags = event.pointerType !== "touch";
      const startX = event.clientX;
      const startY = event.clientY;

      if (drags) {
        event.preventDefault();
        envelope.body.setPointerCapture(event.pointerId);
        desk.classList.add("is-dragging");
        setFromPointer(index, event);
      }

      const move = (moveEvent) => {
        if (drags) setFromPointer(index, moveEvent);
      };
      const finish = (endEvent) => {
        if (
          !drags && endEvent.type === "pointerup"
          && Math.hypot(endEvent.clientX - startX, endEvent.clientY - startY) < 10
        ) {
          setFromPointer(index, endEvent);
        }
        desk.classList.remove("is-dragging");
        envelope.body.removeEventListener("pointermove", move);
        envelope.body.removeEventListener("pointerup", finish);
        envelope.body.removeEventListener("pointercancel", finish);
      };
      envelope.body.addEventListener("pointermove", move);
      envelope.body.addEventListener("pointerup", finish);
      envelope.body.addEventListener("pointercancel", finish);
    });

    envelope.input.addEventListener("input", () => setValue(index, Number(envelope.input.value)));
  });

  // Switching currency keeps every envelope as full as it was and rewrites
  // the headline's word in pencil.
  let swapTimer = 0;
  function swapWord(next) {
    if (!word) return;
    window.clearTimeout(swapTimer);
    word.classList.remove("is-striking", "is-writing");
    if (reducedMotion.matches) {
      word.textContent = next;
      return;
    }
    void word.offsetWidth;
    word.classList.add("is-striking");
    swapTimer = window.setTimeout(() => {
      word.textContent = next;
      word.classList.remove("is-striking");
      word.classList.add("is-writing");
    }, 280);
  }

  if (word) {
    word.addEventListener("animationend", (event) => {
      if (event.animationName === "write") word.classList.remove("is-writing");
    });
  }

  desk.querySelectorAll("input[name=\"currency\"]").forEach((radio) => {
    radio.addEventListener("change", () => {
      const next = data.currencies.find((option) => option.code === radio.value);
      if (!next || next === currency) return;
      values = values.map((value, index) => {
        const share = value / currency.targets[index];
        return Math.round((share * next.targets[index]) / next.step) * next.step;
      });
      currency = next;
      render({ fromVisitor: false });
      swapWord(next.word);
    });
  });

  desk.addEventListener("animationend", (event) => {
    if (event.animationName !== "stamp") return;
    event.target.closest("[data-envelope]")?.classList.remove("is-stamping");
  });

  // On arrival, pencil each envelope in from empty, then stamp the full one.
  if (!reducedMotion.matches) {
    envelopes.forEach((envelope) => {
      envelope.element.style.setProperty("--fill", "0");
      envelope.element.removeAttribute("data-sealed");
    });
    window.requestAnimationFrame(() => {
      window.requestAnimationFrame(() => {
        envelopes.forEach((envelope, index) => {
          const fill = envelope.element.querySelector(".envelope-fill");
          fill.style.transitionDelay = `${0.45 + index * 0.09}s`;
          fill.style.transitionDuration = "0.9s";
          envelope.element.style.setProperty("--fill", (values[index] / currency.targets[index]).toFixed(3));
        });
        window.setTimeout(() => {
          envelopes.forEach((envelope, index) => {
            envelope.element.querySelector(".envelope-fill").removeAttribute("style");
            if (values[index] === currency.targets[index]) {
              envelope.element.setAttribute("data-sealed", "");
              stamp(envelope);
            }
          });
        }, 1500);
      });
    });
  }
})();
