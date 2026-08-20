---
name: credit-union-read
description: "Produce the Read on a credit union — one synthesized picture of what the institution cares about right now, built from NCUA call-report financials, their Google ad activity, and what they promote on their own website. Use for any credit union or community bank lookup in this project: 'run the CLIs on gppfcu.com', 'sync and score this credit union', 'what are they promoting', 'what's most important to them right now', 'where are they advertising', 'look up this CU', 'build the read on <domain>'. Always produces a synthesis, never three separate data dumps."
allowed-tools: "Bash WebFetch Read"
---

# The Credit Union Read

The deliverable is **never** the raw output of a CLI. It is a **Read**: one
synthesized picture answering *what does this institution care about right now,
and what does that mean for the pitch?*

Gather all three legs, **even when one comes back empty**. An empty leg is
itself evidence — a CU running zero Google ads tells you acquisition is
offline and branch-driven.

## Binaries

| CLI | Path |
|---|---|
| `ncua-pp-cli` | `~/.local/bin/ncua-pp-cli` |
| `google-ads-transparency-pp-cli` | `~/.local/bin/google-ads-transparency-pp-cli` |

The plugin's `/setup` command installs both to `~/.local/bin/`; call them by
full path rather than assuming they are on `$PATH`. Add `--agent` to any command for
JSON output. Source for both lives in the private repo
`github.com/heyharmon/cli-library` under `library/marketing/`; this project is
the canonical home for how they get *used*.

## Leg 1 — NCUA

```bash
~/.local/bin/ncua-pp-cli whois <domain> --agent          # domain -> institution
~/.local/bin/ncua-pp-cli footprint <charter> --agent     # branches, states, ATMs
```

Then link the domain to its charter so the financials appear in the viewer:

```bash
~/.local/bin/google-ads-transparency-pp-cli link <domain>            # auto-match
~/.local/bin/google-ads-transparency-pp-cli link <domain> <charter>  # overrule
```

Auto-match runs exact domain → same name under another TLD → institution-name
similarity. **A name match is a guess** and the command says so on stderr;
verify it against `whois` and overrule with an explicit charter. Roughly half
of real domains do not match on website alone, so expect to link some by hand.

`whois` returns the charter number that `footprint` needs. Pull: assets, loans,
deposits, loan-to-share, net worth ratio, members, ROA, and the **4-quarter
growth rates**. The growth deltas and loan-to-share carry most of the signal —
a shrinking loan book against growing deposits is the single most actionable
pattern you will find.

Reference points: net worth ratio of 7% is "well capitalized," so anything near
15%+ is an institution sitting on money it cannot deploy. Loan-to-share below
~65% means the same thing from the other direction.

Flag data that looks like an artifact (e.g. a branch in a state the CU has no
business being in is usually shared-branching bleed) rather than silently
repeating it into a deck.

## Leg 2 — Google ads

```bash
~/.local/bin/google-ads-transparency-pp-cli sync <domain> --agent
~/.local/bin/google-ads-transparency-pp-cli prospect <domain> --agent   # score 0-100
~/.local/bin/google-ads-transparency-pp-cli landing <domain> --agent    # if creatives exist
```

**Also try alternate brand domains.** The advertising domain is often not the
marketing domain — check the hosts in their vendor URLs (online banking,
loan applications, membership forms) and sync those too. This is how you catch
a CU advertising under a legacy or legal name.

### Constraints — do not regress these

- **A bare display URL does NOT mean the ad lands on the homepage.** Google
  builds it from the final URL's domain plus optional path fields the
  advertiser types by hand. Report **"no path shown"**, never "homepage dump."
- **Destinations are only truly knowable for VIDEO ads**, via
  `--backend serpapi --resolve-video`. Text and image creatives return nothing
  usable — both tested.
- **Video resolution costs 1 SerpApi search per creative.** Auto-resolve up to
  **5 creatives**; above that, stop and ask before spending. Video creatives
  have not yet proven their worth — you cannot see the video or the creative,
  and often not the destination. If a resolved batch does yield something
  usable, say so explicitly in the Read so the value question gets settled.
- **Google has IP-blocked this machine before.** A cooldown guard refuses
  further requests after a block, storing state in
  `~/.local/state/google-ads-transparency-pp-cli/block-cooldown.json`; a
  successful request clears the file. **Never loop or retry past a block** —
  that is what caused the original ban. Prefer `--backend serpapi` at volume.
- **`SERPAPI_API_KEY` needs rotating** (the old key leaked into a chat
  transcript). If unset, `--backend serpapi` fails immediately — check before
  planning any resolve work.
- **Zero results are ambiguous by design.** The API cannot distinguish "runs no
  Google ads" from "not an advertised domain." Keep that caveat in the writeup,
  then give your honest reading of which it is.

## Leg 3 — Their own website

**Mandatory every time**, not a fallback for when ads come back empty.

Fetch the homepage and read it for promotional weight:

- hero / slider content
- which rate (if any) is quoted **on the homepage itself** — that's the one
  they most want you to see
- nav order under Loans and Savings
- where the CTAs actually point

Then **follow into the top promoted product's rate and product pages** to pull
real APR figures. That depth is what lets you corroborate promotion against the
balance sheet. Don't sweep every rate table unless asked.

Watch for conversion paths that leave their domain (third-party loan
applications, hosted membership forms, query-string CMS rate pages). Those are
pitch material.

## Record the Read

Always finish by writing the Read back, so it appears in the viewer and the
next session starts from it rather than re-deriving it:

```bash
~/.local/bin/google-ads-transparency-pp-cli read <domain> \
  --priority   'What they most need right now' \
  --promoting  'Ranked list from their own site, most prominent first' \
  --avoid      'What not to lead with' \
  --angle      'The pitch, with the numbers that prove it' \
  --note       'Conversion-path weaknesses, alternate domains, anything else'
```

`read <domain>` with no flags shows the whole picture: NCUA figures, computed
signals, what the ads promote by product, and the written half. The computed
parts recalculate on every run and cannot go stale; only the written half can,
so re-record it when the institution's site changes.

Fields merge rather than replace — passing only `--angle` leaves an existing
priority intact.

## The output

Lead with the conclusion, not the data.

1. **NCUA table** — compact, the figures above with growth rates.
2. **Ads** — what was found, under which domains, with the honest caveats.
3. **What they're promoting** — ranked by promotional weight, with real rate
   figures quoted.
4. **The Read** — the synthesis. State their **priority order explicitly**, say
   **what NOT to lead with**, and name the pitch angle plus any conversion-path
   weakness worth rebuilding.

The synthesis is the product; CLI output is the raw material. Any one leg is
ambiguous on its own — a homepage car-loan banner is just a banner until a 57%
loan-to-share ratio and a shrinking loan book prove they genuinely need loan
volume. Then it's a confirmed priority you can pitch against.
