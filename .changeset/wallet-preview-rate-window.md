---
openbudget_server: fix
---

# Keep the wallet preview limit across restarts and races

`WalletService.preview` now counts each user's hour in PostgreSQL
(`wallet_preview_rate_window`, unique on `userId`) instead of a static map. One
`INSERT ... ON CONFLICT DO UPDATE ... RETURNING "requestCount"` opens the
window, restarts it once an hour has passed, and spends a slot, so a restarted
server no longer hands out 20 more reads and two concurrent previews cannot
both take the last one. The 21st read still fails with
`WalletPreviewRateLimitedException`, an unsupported chain still costs nothing,
and each user keeps their own window. The table cascades from the auth user, so
account deletion removes it.
