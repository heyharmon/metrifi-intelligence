# Changelog

## 0.4.0 — 2026-10-16

- Ask for an institution by name or website: "investigate Mountain America
  Credit Union" replaces "build the read on <domain>". The skill finds the
  official website, confirms it with `GET /api/whois`, and asks when a name
  fits more than one institution.
- Setup is an agent prompt. The handoff line points the agent at
  https://intelligence.metrifi.com/onboarding, and the server's Install page
  now gives a message to paste into Claude Code instead of a terminal command.
  `/setup` and the skill's missing-credentials note point there.

## 0.3.0 — 2026-09-22

- Install is one copied command. Sign in at
  https://intelligence.metrifi.com, open **Install**, paste the command: it
  writes `~/.config/metrifi-intelligence/env` and installs this plugin from the
  marketplace. No manual URL or token prompts.
- `/setup` is now check-and-repair. It tests the existing credentials against
  `GET /api/domains` and stops at "you're connected" on a 200; on a missing file
  or a 401 it points at the Install page, and only walks the manual prompts if
  asked.
- README rewritten around that flow, with the two `claude plugin` commands kept
  in a "Manual install" fold.
- `credit-union-read` skill's API reference corrected against the server's
  routes and controller: read's real response keys, sync's 202-and-poll
  contract, the writable Read fields, and the CLI `ok`/422 envelope.

## 0.2.0 — 2026-08-20

- The plugin drives the shared MetriFi Intelligence server over an
  authenticated API instead of running local Go binaries. No SerpApi key, no
  Google rate limits, and everything one teammate syncs is visible to all.
- `/setup` stores the server URL and a personal API token in
  `~/.config/metrifi-intelligence/env`.
- Skill rewritten around the server endpoints, and the browser viewer became
  the shared home for every institution's Read.

## 0.1.0 — 2026-08-19

- First release: the `credit-union-read` skill (NCUA financials + Google ad
  activity + website promotions, synthesized into one Read), a `/setup`
  command, and `scripts/release.sh` to cross-compile and publish the two Go
  CLIs a server host needs.
