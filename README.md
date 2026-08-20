# MetriFi Intelligence

The intelligence layer for credit unions and community banks. Ask Claude to
"build the read on `<domain>`" and get one synthesized picture of an
institution — its NCUA call-report financials, its Google ad activity, and
what it promotes on its own website — instead of three data dumps.

Built by [MetriFi](https://metrifi.com), the AI platform for credit union and
bank websites, marketing, and landing pages.

## How it works

Data lives on the shared **MetriFi Intelligence server**
(`intelligence.metrifi.com`): a Laravel app whose fetch engine is a pair of Go
CLIs driving NCUA bulk data and the Google Ads Transparency Center. Your agent
talks to it over an authenticated API, so:

- everything anyone syncs is instantly visible to the whole team,
- nobody needs local binaries, SerpApi keys, or Google rate-limit worries,
- the browser viewer shows every institution, its verdict, its financial
  signals, each ad's screenshot, and the written Read.

This plugin gives your Claude the two things it needs: the **skill** that
teaches it the Read methodology, and a **`/setup`** command that connects it
to the server with your token.

## Install

In Claude Code:

```
/plugin marketplace add heyharmon/metrifi-intelligence
/plugin install metrifi-intelligence
/setup
```

`/setup` asks for the server URL and your API token (the server operator
issues one per teammate: `php artisan intelligence:token you@metrifi.com`).
Then try: **"build the read on gppfcu.com"**.

## The viewer

Open the server URL in a browser and sign in with your @metrifi.com email —
a magic link, no password. Access is limited to MetriFi email addresses; the
same gate applies to API tokens.

## For server operators

- `scripts/release.sh vX.Y.Z` cross-compiles the two Go CLIs from the private
  `cli-library` checkout and attaches binaries to this repo's GitHub release —
  that's how a server host gets its fetch engine.
- The server app lives in the (private) `metrifi-intelligence-app` repo:
  Laravel + the CLI mirrors + a queue worker. Set `INTEL_SYNC_BACKEND=serpapi`
  and a server-side `SERPAPI_API_KEY` for block-proof syncing at volume.
