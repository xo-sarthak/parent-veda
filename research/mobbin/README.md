# research/mobbin

Reference screenshots pulled through the Mobbin MCP, one folder per audit.
Images are gitignored (they expire on Mobbin's side in 30 days, and they are
Mobbin's to redistribute, not ours). What is committed is this file; the
index of what each image proves, with the permanent Mobbin link, lives in the
audit document for that folder:

| Folder | Audit |
|---|---|
| `onboarding/` | `docs/ONBOARDING-AUDIT.md` §8 |
| `reader/` | `docs/READER-AUDIT.md` §8 |

Re-download: run the flow / screen search again with the same query and save
each `image_url` (a `mobbin.com/api/mcp/short/...` link) with a TLS-1.2
`WebClient` — plain `curl` gets its connection reset by the CDN.
