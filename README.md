# Docker Media Server

A comprehensive media server stack using Docker Compose, featuring popular media management and automation tools.

## 🚀 Features

- **Media Management**: Plex for media streaming
- **Download Clients**: qBittorrent and SABnzbd
- **Media Organization**: Sonarr, Radarr, and Bazarr
- **Indexers**: Prowlarr for managing indexers
- **Request Management**: Overseerr for media requests
- **Monitoring**: Portainer for container management
- **Logs**: Dozzle for container log viewing
- **File Management**: Filebrowser for web-based file management
- **Homepage**: Customizable homepage for your services
- **Utilities**: FlareSolverr, Socket Proxy, and Docker GC

## 📦 Prerequisites

- Docker
- Docker Compose
- Basic knowledge of Docker and command line

## 🛠️ Setup

1. Clone this repository:
   ```bash
   git clone <your-repo-url>
   cd docker-media-server
   ```

2. Configure your environment:
   - Copy `.env.example` to `.env` and update the variables
   - Set up necessary volume mounts in the compose files

3. Start the services:
   ```bash
   docker-compose up -d
   ```

4. Configure services
    Go to http://localhost:80

    - Setup Plex
    - Setup qbittorrent (password should be in docker terminal)
    - Setup Sonarr
    - Setup Radarr
    - Setup Prowlarr
    - Setup Overseerr


5. Setup Homepage

   - Go to http://localhost:80
   - Fill your .env with each service api keys

## 🔧 Services

- **Plex**: Media server
- **qBittorrent**: Torrent client
- **SABnzbd**: Usenet client
- **Sonarr**: TV shows management
- **Radarr**: Movies management
- **Bazarr**: Subtitle management
- **Prowlarr**: Indexer manager
- **Overseerr**: Media request management
- **Portainer**: Container management
- **Dozzle**: Log viewer
- **Filebrowser**: Web file manager
- **Homepage**: Service dashboard
- **FlareSolverr**: Cloudflare bypass
- **Socket Proxy**: Network utilities
- **Docker GC**: Docker garbage collection

## 🌐 Access

All services should be accessible through the homepage.

## 🔒 Security Notes

- Change all default passwords
- Use strong credentials
- Configure proper firewall rules
- Regularly update containers

## 📝 License

MIT

## 🙏 Credits

- All the amazing open-source projects that make this stack possible
