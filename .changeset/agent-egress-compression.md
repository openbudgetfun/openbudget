---
openbudget_server: security
---

# Agent requests never follow redirects, and compressed responses keep their promises

`ChatCompletionsClient.complete` now sends an explicit `POST` with
`followRedirects = false` and `maxRedirects = 0`. The provider URL is checked
by the egress guard before the call, so a redirect could carry the API key to
an address that was never checked; a 3xx now fails as an HTTP error instead.

`CompressionMiddleware` leaves `HEAD` responses alone, so the static handler's
file body is not consumed and cached as empty for the next `GET`. A gzipped
response with a strong `ETag` now advertises a weak one, because its bytes are
a different representation, and `Vary` names `Accept-Encoding` only once.
