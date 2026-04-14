# 🏮 MoonBit Production-Ready Webserver Template

A professional, high-performance webserver template built with **MoonBit**, leveraging **Crescent** for native routing and **Relay** for asynchronous background processing.

## 🏗 High-Level Architecture

This template provides a modular foundation for building scalable services:

- **`cmd/main/`**: The application entry point. Defines routes, attaches middleware, and coordinates the web server and background workers using structured concurrency (`with_task_group`).
- **`lib/config/`**: Centralized configuration management. Uses `@string.parse_int` for type-safe environment variable parsing.
- **`lib/logger/`**: Structured JSON logging with level-based filtering (`DEBUG`, `INFO`, `ERROR`). Optimized for modern observability stacks.
- **Relay Processing**: Pluggable background task system. Supports **InMemory** for local development and **Valkey/Redis** for persistent production workloads.

## 🚀 Getting Started

### Prerequisites

- [MoonBit](https://www.moonbitlang.com/install/) toolchain.
- [Docker](https://www.docker.com/) & [Docker Compose](https://docs.docker.com/compose/).

### Development (Local)

Run with standard settings (InMemory Relay, Info logs):

```bash
just relay=true dev
```

### Production Preview (Valkey)

Start the full stack with persistent messaging and debug logs enabled:

```bash
LOG_LEVEL=DEBUG docker compose up --build
```

## 📂 Design Implementation Details

### Configuration Logic

The `Config` struct in `lib/config` automatically resolves overrides from the environment. This ensures that the same binary can be deployed across multiple environments (staging, production) without modification.

### Structured Logging

Logs are emitted as JSON objects to standard output. This allows for easy parsing by agents like FluentBit or Datadog. The `LOG_LEVEL` toggle prevents noise in production while allowing deep visibility during debugging.

### Multi-Backend Relay

The server can be configured to use `Valkey` as a message backend. If the connection fails, the system gracefully fails back to an `InMemory` queue to prevent data loss or server crashes, while logging the incident as an `ERROR`.

## 🛠 environment Configuration

| Variable | Default | Description |
| :--- | :--- | :--- |
| `PORT` | `4000` | Server listening port |
| `USE_RELAY` | `false` | Enable/Disable Relay workers |
| `RELAY_BACKEND` | `memory` | `memory` or `valkey` |
| `VALKEY_URL` | `valkey://localhost:6379` | Connection string for Valkey |
| `LOG_LEVEL` | `INFO` | `DEBUG`, `INFO`, `ERROR` |

## 🐳 Deployment

The multi-stage `Dockerfile` produces a minimal (~2MB) native binary image based on `debian:slim`. It leverages the modern MoonBit build system to produce zero-dependency, high-performance artifacts.

## 🤖 CI/CD Foundations

Included in `.github/workflows/ci.yml` is an automated pipeline that:

1. Performs static analysis (`moon check`).
2. Runs the test suite (`moon test`).
3. Validates the container build.
