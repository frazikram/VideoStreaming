.PHONY: up down logs fmt lint test build

up: ; docker compose -f infra/docker-compose.yml up -d
down: ; docker compose -f infra/docker-compose.yml down
logs: ; docker compose -f infra/docker-compose.yml logs -f --tail=200

fmt: ; go fmt ./...
lint: ; golangci-lint run ./... || true
test: ; go test ./...

build:
	(cd backend/services/api && go build ./cmd/api)
	(cd backend/services/worker-transcode && go build ./cmd/worker)
