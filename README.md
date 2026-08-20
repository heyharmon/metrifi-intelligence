# MetriFi Intelligence

The intelligence layer for credit unions and community banks. Ask Claude to
"build the read on `<domain>`" and get one synthesized picture of an
institution — its NCUA call-report financials, its Google ad activity, and
what it promotes on its own website — instead of three data dumps.

Built by [MetriFi](https://metrifi.com), the AI platform for credit union and
bank websites, marketing, and landing pages.

## What you get

- **Two CLIs** (single static Go binaries, local SQLite mirrors, no accounts):
  - `ncua-pp-cli` — every federally insured US credit union, queryable by
    state, asset size, membership, charter age, or website domain.
  - `google-ads-transparency-pp-cli` — an advertiser's full Google ad census,
    prospect scoring, and a local web viewer (`serve`).
- **Two skills** that teach Claude to drive them correctly:
  - `credit-union-read` — the standard deliverable: one synthesized Read.
  - `ncua` — raw credit-union lookups and prospect lists.
- **A `/setup` command** that installs and verifies everything.

## Install

In Claude Code:

```
/plugin marketplace add heyharmon/metrifi-intelligence
/plugin install metrifi-intelligence
/setup
```

Or by hand: `scripts/install.sh` installs the binaries; run each CLI's
`doctor` to verify.

### Optional: SerpApi

Export `SERPAPI_API_KEY` to enable video-ad destination resolution and the
paid fallback backend used when Google rate-limits direct requests.
Everything else works without it.

## The viewer

`google-ads-transparency-pp-cli serve` opens a read-only local web UI over
everything you've synced: every advertiser, its qualification verdict, its
Read, and each ad's screenshot. A hosted, read-only copy of MetriFi's own
mirror lives at **intelligence.metrifi.com** (URL TBD).

## Data notes

- NCUA data is public; the CLI mirrors it locally on first sync.
- Ad mirrors are built per-machine by `sync <domain>`. Use `export`/`import`
  to move a mirror between machines.
- Direct Google requests are free but rate-limited; the CLI has a cooldown
  guard — never loop past a block. Details are in the skills.
