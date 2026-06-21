# OpenMeet

OpenMeet is a browser-based video meeting application with a Vue 3 client and a Rust Axum/WebRTC SFU backend.

## Repository Layout

- `openmeet-client/` - Vue 3 frontend.
- `openmeet-server/` - Rust API, auth, signaling, and SFU server.
- `docker-compose.dev.yml` - local development stack.
- `docker-compose.yaml` - production stack.
- `deployment/` - Nginx and CoTURN production configuration.
- `observability/` - Prometheus, Grafana, Loki, and Promtail configuration.

## Local Development

Start the local development stack:

```sh
make dev
```

Stop it:

```sh
make stop
```

View logs:

```sh
make logs
```

When testing local meetings from another device on the same network, set `OPENMEET_DEV_HOST_IP` to your host LAN IP so the SFU and TURN server advertise reachable candidates:

```sh
OPENMEET_DEV_HOST_IP=192.168.1.50 docker compose -f docker-compose.dev.yml up -d --force-recreate coturn sfu frontend
```

Browsers require a secure origin for camera and microphone access. `http://localhost` works for local testing, but `http://<LAN-IP>` usually does not unless the browser is explicitly configured to treat that origin as secure or you use HTTPS.

## Production Deployment

For VPS setup, production `.env` files, firewall rules, DNS, TLS, and deployment steps, see:

- [`docs/PRODUCTION_DEPLOYMENT.md`](docs/PRODUCTION_DEPLOYMENT.md)

## Required Production Env Files

Production uses three env files:

- Root `.env` for Docker Compose, PostgreSQL, CoTURN, domain, and VPS-level settings.
- `openmeet-client/.env` for build-time frontend URLs and branding.
- `openmeet-server/.env` for runtime server, auth, WebRTC, and TURN/STUN settings.

Never commit real `.env` files. Use the examples in `.env.example`, `openmeet-client/.env.example`, and `openmeet-server/.env.example` as templates.

## Quick Health Checks

After deployment:

```sh
curl -i https://openmeets.eu/health
curl -i https://sfu.openmeets.eu/health
docker compose ps
```

Then verify the product path with at least two browser participants in the same room and confirm both participants receive remote audio/video.
