---
description: Install the MetriFi Intelligence CLIs, verify them, and seed the NCUA mirror
---

Set up the MetriFi Intelligence harness on this machine:

1. Run `${CLAUDE_PLUGIN_ROOT}/scripts/install.sh` and show the user its output.
   It installs `ncua-pp-cli` and `google-ads-transparency-pp-cli` into
   `~/.local/bin/` for this platform.
2. Verify both binaries with `~/.local/bin/ncua-pp-cli doctor` and
   `~/.local/bin/google-ads-transparency-pp-cli doctor`. Both must report the
   API as reachable before continuing.
3. If the NCUA mirror is empty, run the ncua CLI's sync to seed it (see the
   ncua skill for the command). This is public NCUA data; it takes a few
   minutes on first run.
4. Ask the user whether they have a SerpApi key. If yes, tell them to export
   `SERPAPI_API_KEY` in their shell profile. If no, note that everything works
   except video-ad destination resolution and the `--backend serpapi`
   fallback used when Google IP-blocks direct requests.
5. Finish by pointing them at the two skills this plugin installed:
   `credit-union-read` (the standard deliverable — one synthesized Read) and
   `ncua` (raw credit-union lookups). Suggest a first run:
   "build the read on <some credit union domain>".
