---
description: Check this machine's connection to the MetriFi Intelligence server, and repair it if it's broken
---

This is the check-and-repair path. Most people never need it: the normal way to
connect is to sign in at https://intelligence.metrifi.com, open **Install**, and
paste the one command it gives you.

## 1. Check what's already there

```bash
ls -l ~/.config/metrifi-intelligence/env 2>/dev/null && \
  ( set -a; source ~/.config/metrifi-intelligence/env; set +a; \
    curl -s -o /tmp/metrifi-intel-check.json -w '%{http_code}' \
      -H "Authorization: Bearer $METRIFI_INTEL_TOKEN" -H "Accept: application/json" \
      "$METRIFI_INTEL_URL/api/domains" )
```

- **200** — they're connected. Say so, name the server URL, and report how many
  institutions the team has synced (count the `domains` array in the response).
  Suggest a first run — "build the read on gppfcu.com" — and **stop here**. Do
  not re-prompt for credentials that already work.
- **File missing, or 401/403** — go to step 2.
- **Connection refused / timeout** — the URL is wrong or the server is down.
  Report which, and don't overwrite a token that may be fine.

## 2. Point them at the Install page first

Tell them the easiest fix, in one line:

> Sign in at https://intelligence.metrifi.com with your @metrifi.com email
> (magic link, no password), open **Install**, and copy the one command on that
> page into a terminal. It writes your credentials and installs the plugin.

That page is always right and always current. Offer it before anything else,
including when the token is expired or was revoked.

## 3. Only if they'd rather do it by hand

Ask for two things, then write the file yourself:

- **Server URL** — default `https://intelligence.metrifi.com`. Accept the
  default unless they're on a local or dev server. Strip any trailing slash.
- **API token** — from the Install page, or from whoever operates the server
  (`php artisan intelligence:token <their @metrifi.com email>`).

Write `~/.config/metrifi-intelligence/env`, creating the directory and
`chmod 600` the file:

```
METRIFI_INTEL_URL='https://intelligence.metrifi.com'
METRIFI_INTEL_TOKEN='<token>'
```

**Single-quote both values.** Tokens contain a `|`, which an unquoted shell
`source` would read as a pipe.

Then re-run the check in step 1. A 200 means done — point at the
`credit-union-read` skill, suggest "build the read on gppfcu.com", and mention
the shared viewer lives at the same URL in a browser. On 401, the token is
wrong: say so and don't treat it as working.
