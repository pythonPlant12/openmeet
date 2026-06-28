# Production Deployment

This guide describes how to deploy OpenMeet to a single VPS with Docker Compose, Nginx TLS termination, PostgreSQL, the Rust SFU/API server, the Vue frontend, and CoTURN.

The examples use the current production domains from the repository:

- Frontend: `openmeets.eu`
- SFU/API/WebSocket: `sfu.openmeets.eu`
- TURN: `turn.openmeets.eu`
- Grafana: `grafana.openmeets.eu`

Replace these with your own domain names if needed, and update `deployment/nginx/nginx.conf` when changing hostnames.

## 1. Prepare DNS

Create `A` records that point to the public IPv4 address of your VPS:

```text
openmeets.eu          A  <VPS_PUBLIC_IP>
www.openmeets.eu      A  <VPS_PUBLIC_IP>
sfu.openmeets.eu      A  <VPS_PUBLIC_IP>
turn.openmeets.eu     A  <VPS_PUBLIC_IP>
grafana.openmeets.eu  A  <VPS_PUBLIC_IP>
```

Wait for DNS propagation before requesting certificates.

## 2. Configure The VPS Firewall

Open these inbound ports on the VPS provider firewall and the OS firewall:

```text
22/tcp              SSH
80/tcp              HTTP and Let's Encrypt ACME challenge
443/tcp             HTTPS frontend, SFU WebSocket/API, Grafana
3478/udp            TURN/STUN over UDP
3478/tcp            TURN/STUN over TCP fallback
5349/tcp            TURN over TLS, if enabled by the TURN config
50000-51000/udp     Direct SFU media ports
51001-52000/udp     CoTURN relay media ports
```

The SFU and CoTURN ranges must not overlap when they run on the same VPS.

Example with `ufw`:

```sh
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3478/udp
sudo ufw allow 3478/tcp
sudo ufw allow 5349/tcp
sudo ufw allow 50000:51000/udp
sudo ufw allow 51001:52000/udp
sudo ufw enable
sudo ufw status verbose
```

## 3. Install Runtime Dependencies

Install Docker and the Docker Compose plugin on the VPS.

On Debian/Ubuntu:

```sh
sudo apt-get update
sudo apt-get install -y ca-certificates curl git
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
```

Allow your deploy user to run Docker without `sudo` if desired:

```sh
sudo usermod -aG docker "$USER"
```

Log out and back in after changing Docker group membership.

## 4. Clone The Repository

```sh
git clone --recurse-submodules git@github.com:pythonPlant12/openmeet.git /home/debian/openmeet
cd /home/debian/openmeet
```

If the repository was cloned without submodules:

```sh
git submodule update --init --recursive
```

## 5. Create Production Env Files

Production requires three env files. Real secrets must stay on the VPS and must not be committed.

### Root `.env`

Create `/home/debian/openmeet/.env`:

```sh
cp .env.example .env
```

Example production values:

```env
DOMAIN=openmeets.eu
SSL_EMAIL=admin@openmeets.eu

POSTGRES_USER=openmeet
POSTGRES_PASSWORD=replace_with_a_long_random_database_password
POSTGRES_DB=openmeet

TURN_USER=openmeet
TURN_PASSWORD=replace_with_a_long_random_turn_password
TURN_REALM=openmeets.eu

VPS_IP=<VPS_PUBLIC_IP>
PUBLIC_IP=<VPS_PUBLIC_IP>

SSL_CERT_PATH=/etc/letsencrypt/live/openmeets.eu/fullchain.pem
SSL_KEY_PATH=/etc/letsencrypt/live/openmeets.eu/privkey.pem
```

Generate strong secrets with a password manager or commands such as:

```sh
openssl rand -base64 32
```

### Client `openmeet-client/.env`

Create `/home/debian/openmeet/openmeet-client/.env`:

```sh
cp openmeet-client/.env.example openmeet-client/.env
```

Example production values:

```env
VITE_LANDING_PAGE=true

VITE_API_URL=https://sfu.openmeets.eu
VITE_SFU_WSS_URL=wss://sfu.openmeets.eu/ws

VITE_APP_NAME=OpenMeet
VITE_APP_TAGLINE=Secure Video Conferencing
VITE_COMPANY_NAME=OpenMeet
VITE_LOGO_TEXT=OM

VITE_THEME_PRIMARY=154 94% 40%
VITE_THEME_PRIMARY_FOREGROUND=0 0% 100%

VITE_TURN_URL=turn:turn.openmeets.eu:3478
VITE_TURN_USER=openmeet
VITE_TURN_PASSWORD=replace_with_the_same_turn_password_as_root_env
VITE_STUN_URL=stun:stun.l.google.com:19302
```

These values are compiled into the frontend image at build time. Rebuild the frontend after changing them.

### Server `openmeet-server/.env`

Create `/home/debian/openmeet/openmeet-server/.env`:

```sh
cp openmeet-server/.env.example openmeet-server/.env
```

Example production values:

```env
RUST_LOG=info
BIND_ADDRESS=0.0.0.0:8081

DATABASE_URL=postgres://openmeet:replace_with_the_database_password@postgres:5432/openmeet

JWT_SECRET=replace_with_a_long_random_jwt_secret
ACCESS_TOKEN_MINUTES=15
REFRESH_TOKEN_DAYS=7

USE_TLS=false
SSL_CERT_PATH=../certs/localhost+3.pem
SSL_KEY_PATH=../certs/localhost+3-key.pem

TURN_URL=turn:turn.openmeets.eu:3478
TURN_USER=openmeet
TURN_PASSWORD=replace_with_the_same_turn_password_as_root_env
STUN_URL=stun:stun.l.google.com:19302

PUBLIC_IP=<VPS_PUBLIC_IP>
UDP_PORT_MIN=50000
UDP_PORT_MAX=51000
```

`USE_TLS=false` is intentional for this Docker Compose setup because Nginx terminates HTTPS and proxies plain HTTP/WebSocket traffic to the SFU container.

## 6. Review Nginx Hostnames

`deployment/nginx/nginx.conf` currently contains fixed hostnames. If you use different domains, update every `server_name` and Let's Encrypt certificate path in that file before deploying.

The current config routes:

```text
openmeets.eu, www.openmeets.eu  -> frontend container
sfu.openmeets.eu                -> SFU `/ws`, `/health`, and `/auth/*`
grafana.openmeets.eu            -> Grafana container
```

## 7. Request TLS Certificates And Deploy

Run the deployment script from the repository root:

```sh
chmod +x deploy.sh
./deploy.sh
```

The script checks for required env files, creates Certbot directories, requests certificates when missing, builds images, starts services, and prints container status.

If certificate issuance fails, check:

- DNS records point to the VPS public IP.
- Ports `80/tcp` and `443/tcp` are reachable from the internet.
- `deployment/nginx/nginx.conf` contains the domains you requested.
- No other process is already bound to ports `80` or `443`.

## 8. Start, Stop, And Update Production

### Automatic GitHub Deployment

GitHub Actions deploys only from the root `openmeet` repository's `master` branch:

```text
push to root master -> Build workflow -> Test workflow -> Deploy workflow
```

Pushing only to `openmeet-client` or `openmeet-server` does not deploy production. Those repositories are submodules, so production updates after the root repository commits the new submodule pointers and that root commit lands on `master`.

Pushing a feature branch in the root repository also does not deploy automatically. Merge the branch to `master`, or run the `Deploy` workflow manually from the GitHub Actions tab.

Required GitHub repository secrets for deployment:

```text
SSH_PRIVATE_KEY
VPS_HOST
VPS_PORT
VPS_USERNAME
```

The `production` environment in GitHub may also require manual approval before the job starts, depending on repository settings.

### Manual VPS Commands

Start production manually:

```sh
docker compose -f docker-compose.yaml up -d --build
```

View logs:

```sh
docker compose -f docker-compose.yaml logs -f
```

Stop production:

```sh
docker compose -f docker-compose.yaml down
```

Update an existing VPS checkout:

```sh
git pull
git submodule update --init --recursive
docker compose -f docker-compose.yaml up -d --build
```

## 9. Verify Deployment

Check containers:

```sh
docker compose -f docker-compose.yaml ps
```

Check public health endpoints:

```sh
curl -i https://openmeets.eu/health
curl -i https://sfu.openmeets.eu/health
```

Check TURN reachability from another machine:

```sh
nc -vz turn.openmeets.eu 3478
```

For UDP/TURN verification, use a WebRTC TURN test page or a dedicated TURN client from a network outside the VPS.

Finally, run a product-level media check:

1. Open `https://openmeets.eu` in two different browser profiles or devices.
2. Join the same meeting room from both browsers.
3. Confirm both participants see local preview and remote video.
4. Confirm both participants can hear remote audio.
5. Disconnect one participant and confirm the other participant stays connected.

## 10. Troubleshooting

Inspect SFU logs:

```sh
docker compose -f docker-compose.yaml logs -f sfu
```

Inspect Nginx logs:

```sh
docker compose -f docker-compose.yaml logs -f nginx
```

Inspect CoTURN logs:

```sh
docker compose -f docker-compose.yaml logs -f coturn
```

Common issues:

- Camera or microphone is unavailable: use HTTPS, not plain HTTP, except for `localhost`.
- WebSocket fails: verify `VITE_SFU_WSS_URL=wss://sfu.openmeets.eu/ws`, Nginx `/ws` proxying, and the SFU container health.
- Login/auth requests fail: verify `VITE_API_URL=https://sfu.openmeets.eu` and Nginx `/auth/` proxying.
- Remote video never appears: verify TURN credentials match in all three env files and that `3478/udp` plus `49152-65535/udp` are open.
- ICE connects locally but not across networks: verify `VPS_IP`, `PUBLIC_IP`, DNS, and VPS provider firewall rules.
- Certificates fail to renew: verify the Certbot container is running and `/.well-known/acme-challenge/` can be served over HTTP.
