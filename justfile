set shell := ["zsh", "-c"]

project_name := "moon-web-relay"
docker_image := "moon-web-relay:latest"

# Configuration (can be overridden via CLI: just relay=true dev)
relay := "false"
port := "4000"

# ------------------------------------------------------------------------------
# Development
# ------------------------------------------------------------------------------

# Run the webserver in development mode (Native)
# Usage: just relay=true dev
dev:
    @echo "🚀 Starting server (Relay: {{relay}})..."
    USE_RELAY={{relay}} moon run cmd/main --target native

# Watch for changes and restart automatically
# Usage: just relay=true watch
watch:
    @echo "👀 Watching for changes..."
    watchexec -r -e mbt,mod.json,pkg.json "USE_RELAY={{relay}} moon run cmd/main --target native"

# ------------------------------------------------------------------------------
# Build & Quality
# ------------------------------------------------------------------------------

# Build for production (Native Release)
build:
    @echo "🔨 Building native release..."
    moon build --target native --release

# Format all source files
fmt:
    @echo "🎨 Formatting code..."
    moon fmt

# Type-check the project
check:
    @echo "🔍 Checking project..."
    moon check --target native

# Update all dependencies from mooncakes.io
update:
    @echo "📦 Updating dependencies..."
    moon update

# ------------------------------------------------------------------------------
# Docker
# ------------------------------------------------------------------------------

# Build the multi-stage Docker image
docker-build:
	@echo "🐳 Building Docker image..."
	docker build -t {{docker_image}} .

# Run the server inside a Docker container
# Usage: just port=8080 relay=true docker-run
docker-run:
	@echo "🚢 Running Docker container on port {{port}} (Relay: {{relay}})..."
	docker run --rm -it -e USE_RELAY={{relay}} -p {{port}}:4000 {{docker_image}}

# Stop all running instances of the Docker image
docker-stop:
	@echo "🛑 Stopping Docker containers..."
	docker ps -q --filter ancestor={{docker_image}} | xargs -r docker stop

# ------------------------------------------------------------------------------
# Utility
# ------------------------------------------------------------------------------

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf _build target