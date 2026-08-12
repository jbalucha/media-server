# Docker Media Server

A media server stack for the minipc (192.168.1.245) using Docker Compose,
with local DNS so every service is reachable by name instead of IP:port.

## 🚀 Features

- **Media**: Plex (streaming), Overseerr (requests)
- **Starr**: Sonarr, Radarr, Prowlarr
- **Downloads**: qBittorrent, FlareSolverr
- **Local DNS + proxy**: dnsmasq + Traefik — `http://plex.minipc.arpa` instead of `192.168.1.245:32400`
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

4. Point your network at the local DNS. In your router's DHCP settings set
   the DNS server to `192.168.1.245` (or set it per-device). After that,
   `minipc.arpa` and every `*.minipc.arpa` resolve to the minipc.

   > Port 53 must be free on the host. On Ubuntu with systemd-resolved this
   > usually coexists fine (it binds only 127.0.0.53), but if `docker compose up`
   > reports port 53 in use, disable the stub listener:
   > `DNSStubListener=no` in `/etc/systemd/resolved.conf`.

5. First-run setup of each app (create admin users, grab API keys), then put
   the API keys into `.env` and `docker compose up -d` again so the Homepage
   widgets pick them up.

## 🌐 Access

| Service | URL | Fallback |
| --- | --- | --- |
| Homepage | http://minipc.arpa | http://192.168.1.245:3000 |
| Plex | http://plex.minipc.arpa/web | :32400 |
| Overseerr | http://overseerr.minipc.arpa | :5055 |
| Radarr | http://radarr.minipc.arpa | :7878 |
| Sonarr | http://sonarr.minipc.arpa | :8989 |
| Prowlarr | http://prowlarr.minipc.arpa | :9696 |
| qBittorrent | http://qbittorrent.minipc.arpa | :8080 |
| Portainer | http://portainer.minipc.arpa | :9000 |
| Dozzle | http://dozzle.minipc.arpa | :8082 |
| File Browser | http://files.minipc.arpa | :8083 |
| Traefik dashboard | http://traefik.minipc.arpa | — |

Plex apps (TV, mobile) discover the server directly via port 32400 as usual;
the proxy hostname is for the web UI.

> **Note**: `.arpa` names never resolve on the public internet, so devices
> that don't use this DNS server simply fail to resolve these names — they
> can't accidentally land on a stranger's website (which is what happens
> with a hijacked real domain like `minipc.com`). The officially reserved
> home-network domain is `home.arpa` (RFC 8375); `minipc.arpa` is
> non-standard but behaves the same on a LAN.

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
- The Traefik dashboard (http://traefik.minipc.arpa) is read-only but
  unauthenticated — LAN only.
- Dozzle has no authentication — anyone on the LAN can read container logs.
  Keep that in mind for what gets logged, or add authentication
  (https://dozzle.dev/guide/authentication).
- Change all default passwords, keep containers updated.

## 📝 License

MIT
