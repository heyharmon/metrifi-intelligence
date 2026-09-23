---
name: credit-union-read
description: "Produce the Read on a credit union — one synthesized picture of what the institution cares about right now, built from NCUA call-report financials, their Google ad activity, and what they promote on their own website. Use for any credit union or community bank lookup: 'sync and score this credit union', 'what are they promoting', 'what's most important to them right now', 'where are they advertising', 'look up this CU', 'build the read on <domain>'. Always produces a synthesis, never three separate data dumps."
allowed-tools: "Bash WebFetch Read"
---

# The Credit Union Read

The deliverable is **never** raw API output. It is a **Read**: one synthesized
picture answering *what does this institution care about right now, and what
does that mean for the pitch?*

Gather all three legs, **even when one comes back empty**. An empty leg is
itself evidence — a CU running zero Google ads tells you acquisition is
offline and branch-driven.

## The API

All data lives on the shared MetriFi Intelligence server. You never run
Google, SerpApi, or NCUA calls yourself — you ask the server, and everything
you sync becomes visible to the whole team instantly.

Credentials come from `~/.config/metrifi-intelligence/env`, holding
`METRIFI_INTEL_URL` and `METRIFI_INTEL_TOKEN`. Every call looks like:

```bash
source ~/.config/metrifi-intelligence/env
curl -s -H "Authorization: Bearer $METRIFI_INTEL_TOKEN" -H "Accept: application/json" \
  "$METRIFI_INTEL_URL/api/..."
```

If the file is missing or a call returns 401, stop. Tell the user to sign in at
the server (`https://intelligence.metrifi.com`), open its **Install** page, and
paste the one command it gives them — that writes the credentials and installs
this plugin. If they'd rather not use the page, `/setup` does the same job by
hand. Endpoints:

| Endpoint | What it does |
|---|---|
| `GET  /api/domains` | `{"domains": [...]}` — every domain the team has synced |
| `POST /api/sync` `{"domain": "..."}` | queues a server-side census sync + landing read + NCUA link; returns `202` with `{"queued": "<domain>"}`. Poll `GET /api/read/<domain>` |
| `GET  /api/read/<domain>` | the whole picture: `domain`, `synced_at`, `profile` (ad posture), `ncua` (financials, `null` until linked), `signals`, `promoted`, `read` (the written half). `404` if never synced |
| `POST /api/read/<domain>` | record the written half — any of `priority`, `promoting`, `avoid`, `angle`, `note` (fields merge, never replace) |
| `POST /api/link/<domain>` `{"charter": "..."}` | tie a domain to its NCUA charter (charter optional = auto-match) |
| `GET  /api/whois/<domain>` | domain → NCUA institution, without syncing anything |

`POST /api/read`, `POST /api/link`, and `GET /api/whois` are the server driving
its Go CLIs synchronously, so they answer with that CLI's result envelope: an
`ok` flag on `200`, or `422` when the CLI itself failed. Check `ok` rather than
assuming a `200` means it worked.

## Leg 1 — NCUA financials

Check `GET /api/read/<domain>` first — if the domain is already synced and
linked, the `ncua` object is right there and this leg costs one call.

For a fresh domain, `GET /api/whois/<domain>` identifies the institution and
its charter number. After a sync, the server auto-links domain → charter.
**A name-similarity match is a guess** — the response says how it matched;
verify against whois and overrule with `POST /api/link/<domain>` and an
explicit charter. Roughly half of real domains do not match on website alone.

Pull from `ncua`: assets, loans, deposits, loan-to-share, net worth ratio,
members, ROA, and the **4-quarter growth rates**. The growth deltas and
loan-to-share carry most of the signal — a shrinking loan book against
growing deposits is the single most actionable pattern you will find.

Reference points: net worth ratio of 7% is "well capitalized," so anything
near 15%+ is an institution sitting on money it cannot deploy. Loan-to-share
below ~65% means the same thing from the other direction. The server computes
these as `signals` — read them, but reason past them.

Flag data that looks like an artifact (e.g. a branch in a state the CU has no
business being in is usually shared-branching bleed) rather than silently
repeating it into a deck.

## Leg 2 — Google ads

```bash
# queue the sync (server runs census -> landing read -> auto-link, in that order)
curl -s -X POST -H "Authorization: Bearer $METRIFI_INTEL_TOKEN" -H "Accept: application/json" \
  -H "Content-Type: application/json" -d '{"domain":"<domain>"}' "$METRIFI_INTEL_URL/api/sync"
# then poll until synced_at is fresh — syncs take a minute or two
curl -s -H "Authorization: Bearer $METRIFI_INTEL_TOKEN" -H "Accept: application/json" \
  "$METRIFI_INTEL_URL/api/read/<domain>"
```

A 404 from `/api/read` means never synced; a stale `synced_at` after several
minutes means the queued job may have hit Google's rate limit — report that
honestly rather than re-queuing in a loop.

**Also try alternate brand domains.** The advertising domain is often not the
marketing domain — check the hosts in their vendor URLs (online banking, loan
applications, membership forms) and sync those too. This is how you catch a CU
advertising under a legacy or legal name.

### Constraints — do not regress these

- **A bare display URL does NOT mean the ad lands on the homepage.** Google
  builds it from the final URL's domain plus optional path fields the
  advertiser types by hand. Report **"no path shown"**, never "homepage dump."
- **Destinations are only truly knowable for VIDEO ads**, and resolving them
  is a paid, server-side operation. Text and image creatives return nothing
  usable — both tested.
- **Zero results are ambiguous by design.** The API cannot distinguish "runs
  no Google ads" from "not an advertised domain." Keep that caveat in the
  writeup, then give your honest reading of which it is.
- Rate limits and backends are the server's problem, not yours — never try to
  work around a slow or failed sync by hammering the endpoint.

## Leg 3 — Their own website

**Mandatory every time**, not a fallback for when ads come back empty. This is
the one leg the server cannot do — it is your judgment.

Fetch the homepage and read it for promotional weight:

- hero / slider content
- which rate (if any) is quoted **on the homepage itself** — that's the one
  they most want you to see
- nav order under Loans and Savings
- where the CTAs actually point

Then **follow into the top promoted product's rate and product pages** to pull
real APR figures. That depth is what lets you corroborate promotion against
the balance sheet. Don't sweep every rate table unless asked.

Watch for conversion paths that leave their domain (third-party loan
applications, hosted membership forms, query-string CMS rate pages). Those are
pitch material.

## Record the Read

Always finish by writing the Read back, so it appears in the viewer and the
next person (or session) starts from it rather than re-deriving it:

```bash
curl -s -X POST -H "Authorization: Bearer $METRIFI_INTEL_TOKEN" -H "Accept: application/json" \
  -H "Content-Type: application/json" "$METRIFI_INTEL_URL/api/read/<domain>" -d '{
  "priority":  "What they most need right now",
  "promoting": "Ranked list from their own site, most prominent first",
  "avoid":     "What not to lead with",
  "angle":     "The pitch, with the numbers that prove it",
  "note":      "Conversion-path weaknesses, alternate domains, anything else"
}'
```

Fields merge rather than replace — sending only `angle` leaves an existing
priority intact. The computed parts (financials, signals, ad posture)
recalculate on every request and cannot go stale; only the written half can,
so re-record it when the institution's site changes.

## The output

Lead with the conclusion, not the data.

1. **NCUA table** — compact, the figures above with growth rates.
2. **Ads** — what was found, under which domains, with the honest caveats.
3. **What they're promoting** — ranked by promotional weight, with real rate
   figures quoted.
4. **The Read** — the synthesis. State their **priority order explicitly**,
   say **what NOT to lead with**, and name the pitch angle plus any
   conversion-path weakness worth rebuilding.

The synthesis is the product; API output is the raw material. Any one leg is
ambiguous on its own — a homepage car-loan banner is just a banner until a 57%
loan-to-share ratio and a shrinking loan book prove they genuinely need loan
volume. Then it's a confirmed priority you can pitch against.
