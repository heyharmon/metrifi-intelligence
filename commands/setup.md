---
description: Connect this machine to the MetriFi Intelligence server (URL + API token)
---

Connect this machine to the shared MetriFi Intelligence server. No binaries,
no API keys — just the server URL and a personal token.

1. Ask the user for two things:
   - The server URL (default `https://intelligence.metrifi.com` — accept it
     unless they run a local/dev server).
   - Their API token. If they don't have one, tell them to ask the server
     operator to run `php artisan intelligence:token <their @metrifi.com email>`
     and send them the result.
2. Write both to `~/.config/metrifi-intelligence/env` (create the directory,
   `chmod 600` the file):
   ```
   METRIFI_INTEL_URL='<url, no trailing slash>'
   METRIFI_INTEL_TOKEN='<token>'
   ```
   Quote both values — tokens contain a `|`, which an unquoted shell source
   would treat as a pipe.
3. Verify: `source` the file and call `GET $METRIFI_INTEL_URL/api/domains`
   with `Authorization: Bearer $METRIFI_INTEL_TOKEN`. A 200 with a `domains`
   array means they're in; show them how many institutions the team has
   already synced. On 401, the token is wrong — don't store it as working.
4. Finish by pointing at the `credit-union-read` skill and suggesting a first
   run: "build the read on <some credit union domain>". Mention the shared
   viewer lives at the server URL in a browser (magic-link sign-in with their
   @metrifi.com email).
