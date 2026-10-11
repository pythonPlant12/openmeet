.PHONY: dev stop-dev build start stop logs clean help

# openmeet-admin is a private submodule; run its container only when it is checked out.
ADMIN_PROFILE = $(if $(wildcard openmeet-admin/package.json),--profile admin,)
DEV_COMPOSE = docker compose -f docker-compose.dev.yml $(ADMIN_PROFILE)
PROD_COMPOSE = docker compose -f docker-compose.yaml

build-dev: ## Build dev images
	$(DEV_COMPOSE) build --no-cache

dev: ## Start local development (frontend + SFU)
	$(DEV_COMPOSE) up -d

dev-logs:
	$(DEV_COMPOSE) up -d && $(DEV_COMPOSE) logs -f

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
