# Hosting the Intelligence viewer

The viewer is one static Go binary + one SQLite file + a directory of cached
ad screenshots. Any small VPS works.

1. Copy `google-ads-transparency-pp-cli` (linux build from a release) to
   `/usr/local/bin/` on the host; create an `intelligence` user and
   `/var/lib/metrifi-intelligence/`.
2. Install `metrifi-intelligence.service` into `/etc/systemd/system/`,
   `systemctl enable --now metrifi-intelligence`.
3. Install Caddy, drop in `Caddyfile`, point the `intelligence.metrifi.com`
   DNS A record at the host. Caddy handles TLS.
4. From your workstation, publish data with `push.sh user@host` after any
   sync session (or on a cron).

The service binds loopback and Caddy fronts it, so the no-auth viewer is never
directly exposed. It's read-only by design — the public copy can't be written
through, only replaced by the next push.
