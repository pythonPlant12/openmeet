# OpenMeet Documentation

OpenMeet is a **self-hosted, open-source video conferencing platform** built with modern web technologies. It provides real-time audio and video communication using WebRTC and a Selective Forwarding Unit (SFU) architecture.

## Overview

OpenMeet is designed for privacy-conscious organizations and individuals who want full control over their video conferencing infrastructure. The platform consists of two main components working together to deliver a seamless video conferencing experience.

### Key Features

- **Real-time Video Conferencing**: Multi-party video calls with audio and video support
- **SFU Architecture**: Efficient media routing using Selective Forwarding Unit pattern
- **WebRTC Technology**: Browser-based, no plugins required
- **TURN/STUN Support**: NAT traversal for reliable connectivity across networks
- **User Authentication**: JWT-based authentication with refresh tokens
- **Responsive UI**: Modern, mobile-friendly interface built with Vue 3
- **Self-Hosted**: Full control over your data and infrastructure
- **Observability**: Built-in metrics and logging with Prometheus and Grafana

## Architecture

OpenMeet follows a client-server architecture with two separate repositories:

```
openmeet/
├── openmeet-client/     # Frontend web application (Vue 3 + TypeScript)
├── openmeet-server/     # Backend SFU server (Rust + Axum)
├── observability/       # Monitoring configuration (Prometheus, Grafana, Loki)
├── docker-compose.yml   # Production deployment
└── docker-compose.dev.yml # Development environment
```

### Components

1. **[OpenMeet Client](../openmeet-client/docs/README.md)**
   - Vue 3 single-page application
   - WebRTC client implementation
   - Real-time UI for video calls, chat, and controls
   - Responsive design with Tailwind CSS

2. **[OpenMeet Server](../openmeet-server/docs/README.md)**
   - Rust-based SFU (Selective Forwarding Unit)
   - WebSocket signaling server
   - WebRTC media routing
   - User authentication and session management
   - PostgreSQL database for user data

3. **Observability Stack**
   - Prometheus for metrics collection
   - Grafana for visualization
   - Loki for log aggregation
   - Promtail for log forwarding

4. **TURN/STUN Server**
   - Coturn for NAT traversal
   - Relay server for clients behind restrictive firewalls

## Technology Stack

### Frontend
- **Vue 3**: Progressive JavaScript framework
- **TypeScript**: Type-safe development
- **Vite**: Fast build tool and dev server
- **Tailwind CSS**: Utility-first CSS framework
- **WebRTC API**: Real-time communication

### Backend
- **Rust**: Systems programming language
- **Axum**: Modern web framework
- **WebRTC**: Media streaming library
- **Tokio**: Async runtime
- **Diesel**: Type-safe ORM
- **PostgreSQL**: Relational database

### DevOps
- **Docker**: Containerization
- **Docker Compose**: Multi-container orchestration
- **Coturn**: TURN/STUN server
- **Nginx**: Reverse proxy (production)

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Node.js 22+ (for local frontend development)
- Rust 1.70+ (for local backend development)

### Quick Start with Docker

1. Clone the repository:
```bash
git clone <repository-url>
cd openmeet
```

2. Copy environment files:
```bash
cp .env.example .env
cd openmeet-client && cp .env.example .env.development && cd ..
cd openmeet-server && cp .env.example .env && cd ..
```

3. Start the development environment:
```bash
docker-compose -f docker-compose.dev.yml up -d
```

4. Access the application:
- Frontend: http://localhost:5173
- Backend API: http://localhost:8081
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090

### Development Setup

For detailed development setup instructions, see:
- [Client Development Guide](../openmeet-client/docs/README.md)
- [Server Development Guide](../openmeet-server/docs/README.md)

## Project Structure

```
openmeet/
├── openmeet-client/           # Frontend application
│   ├── src/
│   │   ├── components/        # Vue components
│   │   ├── composables/       # Vue composables
│   │   ├── pages/             # Page components
│   │   ├── services/          # WebRTC and API services
│   │   └── main.ts            # Application entry point
│   └── docs/                  # Client documentation
│
├── openmeet-server/           # Backend SFU server
│   ├── src/
│   │   ├── auth/              # Authentication module
│   │   ├── db/                # Database configuration
│   │   ├── sfu/               # SFU media routing
│   │   ├── signaling/         # WebSocket signaling
│   │   └── main.rs            # Server entry point
│   └── docs/                  # Server documentation
│
├── observability/             # Monitoring configuration
│   ├── grafana/               # Grafana dashboards
│   ├── loki-config.yaml       # Loki configuration
│   ├── prometheus.yaml        # Prometheus scrape config
│   └── promtail-config.yaml   # Promtail configuration
│
├── deployment/                # Deployment scripts
├── certs/                     # TLS certificates (development)
├── docker-compose.yml         # Production deployment
├── docker-compose.dev.yml     # Development environment
└── docs/                      # Main documentation
```

## Deployment

### Production Deployment

For production deployment, use `docker-compose.yml`:

```bash
docker-compose up -d
```

Make sure to:
1. Configure proper SSL certificates
2. Set strong JWT secrets
3. Configure firewall rules for TURN server
4. Set up proper database backups
5. Configure resource limits

See `deploy.sh` for automated deployment script.

## Monitoring

Access monitoring dashboards:
- **Grafana**: http://localhost:3000 - Metrics visualization
- **Prometheus**: http://localhost:9090 - Metrics storage
- **Loki**: http://localhost:3100 - Log aggregation

Default Grafana credentials: `admin/admin` (change in production)

## Contributing

Contributions are welcome! Please see individual component documentation for development guidelines.

## License

[Add your license information here]

## Support

For issues, questions, or contributions, please refer to the individual component documentation:
- [Client Documentation](../openmeet-client/docs/README.md)
- [Server Documentation](../openmeet-server/docs/README.md)
