# MetriFi Intelligence

The intelligence layer for credit unions and community banks. Ask Claude to
"investigate Mountain America Credit Union" (a name or a website both work) and
get one synthesized picture of an institution — its NCUA call-report financials, its Google ad activity, and what
it promotes on its own website — instead of three data dumps.

Built by [MetriFi](https://metrifi.com), the AI platform for credit union and
bank websites, marketing, and landing pages.

Requires [Claude Code](https://claude.com/claude-code).

## Install

Paste this into Claude Code:

> Read the agent instructions here to get set up with the MetriFi Intelligence app: https://intelligence.metrifi.com/onboarding

Your agent does the rest. It will send you to
**https://intelligence.metrifi.com/install** to sign in with your @metrifi.com
email (magic link, no password) and generate a setup message to paste back. Then
it saves your credentials, installs this plugin, and asks you to restart Claude
Code. After that, say **"investigate Mountain America Credit Union"**.

<details>
<summary>Manual install</summary>

To install by hand, run these two commands in a terminal, then connect:

```
claude plugin marketplace add heyharmon/metrifi-intelligence
claude plugin install metrifi-intelligence@metrifi-intelligence --scope user
```

Then in Claude Code, run **`/setup`**. It checks whether this machine is already
connected and, if not, walks you through the server URL
(`https://intelligence.metrifi.com`) and your API token. `/setup` is also the
repair path if a token stops working.

</details>

## How it works

Data lives on the shared **MetriFi Intelligence server**
(`intelligence.metrifi.com`): a Laravel app whose fetch engine is a pair of Go
CLIs driving NCUA bulk data and the Google Ads Transparency Center. Your agent
talks to it over an authenticated API, so everything anyone syncs is instantly
visible to the whole team, and nobody needs local binaries, SerpApi keys, or
Google rate-limit worries.

This plugin gives your Claude the **skill** that teaches it the Read
methodology, plus **`/setup`** for checking and repairing the connection.

## The viewer

Open the server URL in a browser and sign in with your @metrifi.com email. It
shows every institution, its verdict, its financial signals, each ad's
screenshot, and the written Read. Access is limited to MetriFi email addresses;
the same gate applies to API tokens.

## For server operators

- Deployment, tokens, and queue setup are documented in the (private)
  `metrifi-intelligence-app` repo: `docs/deployment.md`.
- `scripts/release.sh vX.Y.Z` cross-compiles the two Go CLIs from the private
  `cli-library` checkout and attaches binaries to this repo's GitHub release —
  that's how a server host gets its fetch engine.
