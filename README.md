# Docker Media Server

A media server stack for the minipc (192.168.1.245) using Docker Compose,
with local DNS so every service is reachable by name instead of IP:port.

## 🚀 Features

- **Media**: Plex (streaming), Seerr (requests)
- **Starr**: Sonarr, Radarr, Prowlarr
- **Downloads**: qBittorrent, FlareSolverr
- **Local DNS + proxy**: dnsmasq + Traefik — `http://plex.janba-minipc.duckdns.org` instead of `192.168.1.245:32400`
- **Dashboard**: Homepage
- **Monitoring**: Grafana + Loki/Alloy (logs) + Prometheus/cAdvisor/node-exporter (metrics), 7-day retention
- **Ops**: Portainer, Dozzle, File Browser, Docker Socket Proxy
- Disabled but ready to re-enable: SABnzbd, Bazarr, Tdarr, n8n (+ Postgres/Redis), Docker GC

## 🛠️ Setup

1. Clone and configure:

   ```bash
   git clone <your-repo-url> && cd media-server
   cp .env.example .env   # then fill it in - DOCKERDIR, media paths, etc.
   ```

   `.env` already contains `COMPOSE_PROFILES=all` — without it no services
   start, because every service is gated behind a profile.

2. Plex claim code (optional, for first-time server claiming): put the code
   from https://plex.tv/claim into `secrets/plex_claim`. The file must exist
   even if empty:

   ```bash
   touch secrets/plex_claim && chmod 600 secrets/plex_claim
   ```

3. Start:

   ```bash
   docker compose up -d
   ```

4. DNS: `janba-minipc.duckdns.org` is a public DuckDNS record pointing at the
   **private** LAN IP `192.168.1.245`, and DuckDNS resolves all subdomains
   (`plex.janba-minipc.duckdns.org`, ...) to the same IP. Every device on the
   LAN therefore resolves these names through whatever DNS it already uses —
   no router or per-device configuration needed. Requirements: the record's
   IP is maintained at duckdns.org, and the local resolver chain must not
   filter private-IP answers (rebind protection — verify once with
   `dig plex.janba-minipc.duckdns.org`).

   The bundled dnsmasq is an optional extra: point a device's DNS at
   `192.168.1.245` and the names keep resolving even without internet
   (it also serves `*.minipc.arpa` as an offline-only alias).

   > dnsmasq binds port 53 on the LAN IP only, so it coexists with
   > systemd-resolved's stub listener on 127.0.0.53.

5. First-run setup of each app (create admin users, grab API keys), then put
   the API keys into `.env` and `docker compose up -d` again so the Homepage
   widgets pick them up.

## 🌐 Access

| Service | URL | Fallback |
| --- | --- | --- |
| Homepage | http://janba-minipc.duckdns.org | http://192.168.1.245:3000 |
| Plex | http://plex.janba-minipc.duckdns.org/web | :32400 |
| Seerr (requests) | http://seerr.janba-minipc.duckdns.org (alias: overseerr.) | :5055 |
| Radarr | http://radarr.janba-minipc.duckdns.org | :7878 |
| Sonarr | http://sonarr.janba-minipc.duckdns.org | :8989 |
| Prowlarr | http://prowlarr.janba-minipc.duckdns.org | :9696 |
| qBittorrent | http://qbittorrent.janba-minipc.duckdns.org | :8080 |
| Portainer | http://portainer.janba-minipc.duckdns.org | :9000 |
| Dozzle | http://dozzle.janba-minipc.duckdns.org | :8082 |
| File Browser | http://files.janba-minipc.duckdns.org | :8083 |
| Traefik dashboard | http://traefik.janba-minipc.duckdns.org | — |
| Grafana | http://grafana.janba-minipc.duckdns.org | :3001 |
| Prometheus | http://prometheus.janba-minipc.duckdns.org | — |

Plex apps (TV, mobile) discover the server directly via port 32400 as usual;
the proxy hostname is for the web UI.

## 🛰 Remote access (Tailscale)

The stack includes Tailscale as a **subnet router**: it advertises the LAN
(`192.168.1.0/24`) into your tailnet, so devices running Tailscale reach the
minipc's LAN IP from anywhere — and all the URLs above keep working
unchanged. Nothing is exposed to the public internet.

One-time setup:

1. Enable IP forwarding on the host (sudo):
   `printf 'net.ipv4.ip_forward = 1\nnet.ipv6.conf.all.forwarding = 1\n' | sudo tee /etc/sysctl.d/99-tailscale.conf && sudo sysctl -p /etc/sysctl.d/99-tailscale.conf`
2. Authenticate the node: set `TS_AUTHKEY` in `.env` before first start, or
   open the login URL from `docker logs tailscale`.
3. In the [admin console](https://login.tailscale.com/admin/machines):
   approve the advertised `192.168.1.0/24` route and **disable key expiry**
   for the machine.
4. On your remote devices, make sure "Use subnet routes" is enabled.

Do not use Tailscale Funnel with these services — several of them
(Dozzle, Prowlarr, the Traefik dashboard) have no authentication.

> **Note**: the DuckDNS record intentionally holds a private IP — it makes
> the names resolve *inside* the LAN only. Nothing is exposed to the
> internet: no ports are forwarded, and outsiders resolving the name just
> get an unroutable 192.168.x address. Anyone can see the hostname exists
> in public DNS, which is harmless for a homelab.

## 🔒 Security notes

- **Never commit `.env` or `secrets/`** — both are gitignored. All API keys
  and passwords live only there.
- Homepage widget credentials are injected as `HOMEPAGE_VAR_*` environment
  variables on the homepage container only — do not put keys into
  `appdata/homepage/*.yaml` (those files are committed) and do not add
  `homepage.widget.*` docker labels (labels are readable by anything with
  docker socket access). Traefik routing labels are fine — they contain no
  secrets.
- The Docker socket proxy is reachable **only** from the internal
  `socket_proxy` network. Never publish port 2375 to the host. Traefik
  discovers routes through it (`traefik.*` labels on each service).
- The Traefik dashboard (http://traefik.janba-minipc.duckdns.org) is read-only but
  unauthenticated — LAN only.
- Dozzle has no authentication — anyone on the LAN can read container logs.
  Keep that in mind for what gets logged, or add authentication
  (https://dozzle.dev/guide/authentication).
- Change all default passwords, keep containers updated.

## 📝 License

MIT
