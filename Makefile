# Standard Makefile for MoonBit Webserver
PROJECT_NAME=moon-web-relay
DOCKER_IMAGE=moon-web-relay:latest
PORT?=4000
RELAY?=false

.PHONY: all dev watch build fmt check update docker-build docker-run docker-stop help

# Default target
all: check fmt build

help:
	@echo "🔥 MoonBit Webserver + Relay Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make dev [RELAY=true]     Run server in native dev mode"
	@echo "  make watch [RELAY=true]   Run with hot-reload"
	@echo "  make build                Build native release binary"
	@echo "  make fmt                  Format source code"
	@echo "  make check                Type-check the project"
	@echo "  make update               Update dependencies"
	@echo "  make docker-build         Build Docker image"
	@echo "  make docker-run [PORT=]   Run inside Docker"
	@echo "  make docker-stop          Stop Docker containers"

dev:
	@echo "🚀 Starting server (Relay: $(RELAY))..."
	USE_RELAY=$(RELAY) moon run cmd/main --target native

watch:
	@echo "👀 Watching for changes..."
	watchexec -r -e mbt,mod.json,pkg.json "USE_RELAY=$(RELAY) moon run cmd/main --target native"

build:
	@echo "🔨 Building native release..."
	moon build --target native --release

fmt:
	@echo "🎨 Formatting code..."
	moon fmt

check:
	@echo "🔍 Checking project..."
	moon check --target native

update:
	@echo "📦 Updating dependencies..."
	moon update

docker-build:
	@echo "🐳 Building Docker image..."
	docker build -t $(DOCKER_IMAGE) .

docker-run:
	@echo "🚢 Running Docker container on port $(PORT) (Relay: $(RELAY))..."
	docker run --rm -it -e USE_RELAY=$(RELAY) -p $(PORT):4000 $(DOCKER_IMAGE)

docker-stop:
	@echo "🛑 Stopping Docker containers..."
	docker ps -q --filter ancestor=$(DOCKER_IMAGE) | xargs -r docker stop

clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf _build target