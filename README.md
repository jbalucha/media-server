# Docker Media Server

A media server stack for the minipc (192.168.1.245) using Docker Compose,
with local DNS so every service is reachable by name instead of IP:port.

## 🚀 Features

- **Media**: Plex (streaming), Overseerr (requests)
- **Starr**: Sonarr, Radarr, Prowlarr
- **Downloads**: qBittorrent, FlareSolverr
- **Local DNS + proxy**: dnsmasq + Traefik — `http://plex.minipc-ms.duckdns.org` instead of `192.168.1.245:32400`
- **Dashboard**: Homepage
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

4. DNS: `minipc-ms.duckdns.org` is a public DuckDNS record pointing at the
   **private** LAN IP `192.168.1.245`, and DuckDNS resolves all subdomains
   (`plex.minipc-ms.duckdns.org`, ...) to the same IP. Every device on the
   LAN therefore resolves these names through whatever DNS it already uses —
   no router or per-device configuration needed. Requirements: the record's
   IP is maintained at duckdns.org, and the local resolver chain must not
   filter private-IP answers (rebind protection — verify once with
   `dig plex.minipc-ms.duckdns.org`).

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
| Homepage | http://minipc-ms.duckdns.org | http://192.168.1.245:3000 |
| Plex | http://plex.minipc-ms.duckdns.org/web | :32400 |
| Overseerr | http://overseerr.minipc-ms.duckdns.org | :5055 |
| Radarr | http://radarr.minipc-ms.duckdns.org | :7878 |
| Sonarr | http://sonarr.minipc-ms.duckdns.org | :8989 |
| Prowlarr | http://prowlarr.minipc-ms.duckdns.org | :9696 |
| qBittorrent | http://qbittorrent.minipc-ms.duckdns.org | :8080 |
| Portainer | http://portainer.minipc-ms.duckdns.org | :9000 |
| Dozzle | http://dozzle.minipc-ms.duckdns.org | :8082 |
| File Browser | http://files.minipc-ms.duckdns.org | :8083 |
| Traefik dashboard | http://traefik.minipc-ms.duckdns.org | — |

Plex apps (TV, mobile) discover the server directly via port 32400 as usual;
the proxy hostname is for the web UI.

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
- The Traefik dashboard (http://traefik.minipc-ms.duckdns.org) is read-only but
  unauthenticated — LAN only.
- Dozzle has no authentication — anyone on the LAN can read container logs.
  Keep that in mind for what gets logged, or add authentication
  (https://dozzle.dev/guide/authentication).
- Change all default passwords, keep containers updated.

## 📝 License

MIT
