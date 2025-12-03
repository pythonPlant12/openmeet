.PHONY: dev stop-dev build start stop logs clean help

DEV_COMPOSE = docker compose -f docker-compose.dev.yml
PROD_COMPOSE = docker compose -f docker-compose.yaml

build-dev: ## Build dev images
	$(DEV_COMPOSE) build --no-cache

dev: ## Start local development (frontend + SFU)
	$(DEV_COMPOSE) up -d

restart: 
	$(DEV_COMPOSE) down
	$(DEV_COMPOSE) up -d

stop: ## Stop dev containers
	$(DEV_COMPOSE) down

logs: ## Show dev logs
	$(DEV_COMPOSE) logs -f

rm:
	## Remove dev containers and volumes	
	$(DEV_COMPOSE) down -v --remove-orphans 2>/dev/null || true
