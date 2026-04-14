# MoonBit Webserver with Crescent & Relay

This project is a high-performance, native webserver built with **MoonBit**. It leverages **Crescent** for routing and **Relay** for asynchronous background task processing.

## 🏗 Architecture

The application is structured into a modern, native-compiled stack:

- **Core**: Written in [MoonBit](https://www.moonbitlang.com/), targeting **Native** for maximum performance.
- **HTTP Layer**: Powered by [Crescent v0.9.0](https://mooncakes.io/docs/bobzhang/crescent). It provides a robust routing system, group middleware, and ergonomic response handlers.
- **Message Queue**: Integrated with [Relay v0.1.0](https://mooncakes.io/docs/Metalymph/relay).
  - Supports asynchronous job processing.
  - Opt-in background workers for heavy tasks.
  - Defaulting to an efficient `InMemoryBackend`.
- **Infrastructure**: Distributed via a multi-stage **Docker** build that produces a minimal standalone binary (~1-2MB) running on `debian:slim`.

## 🚀 Getting Started

### Prerequisites

- [MoonBit](https://www.moonbitlang.com/install/) toolchain installed.
- [watchexec](https://github.com/watchexec/watchexec) (optional, for hot-reload).
- [just](https://github.com/casey/just) or `make` for command execution.

### Development

Run the server with the **Relay** architecture enabled or disabled:

```bash
# Default: Relay disabled
just dev

# Opt-in: Relay enabled (launches background workers)
just relay=true dev
```

Or using `make`:

```bash
make dev RELAY=true
```

### Features & Endpoints

- `GET /`: Basic heartbeat.
- `GET /hello/:name`: Dynamic routing.
- `GET /json`: High-performance JSON serialization.
- `GET /relay/push?payload=...`: (Only if Relay is enabled) Pushes a task to the background worker.

## 🐳 Docker Deployment

The project uses a serious multi-stage Dockerfile that builds the system from source and exports only the binary.

```bash
# Build the image
just docker-build

# Run the container
just relay=true docker-run
```

## 🛠 Project Structure

- `cmd/main/main.mbt`: Application entry point and route definitions.
- `moon.mod.json`: Project dependencies and metadata.
- `justfile` / `Makefile`: Ergonomic shortcuts for common tasks.
- `Dockerfile`: Production-ready multi-stage container build.
