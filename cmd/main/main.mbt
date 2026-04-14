// --- Webserver Template ---

///|
async fn main {
  // 1. Load Configuration
  let cfg = @config.Config::load()
  @logger.info("🚀 Starting server on port \{cfg.port}")

  @async.with_task_group(
    async fn(tg) {
      let app = @crescent.Mocket()

      // 2. Relay Setup (Opt-in & Multi-backend)
      if cfg.relay_enabled {
        @logger.info("🏮 Relay: Initializing background workers...")

        let queue = match cfg.relay_backend {
          InMemory => {
            @logger.info("📦 Using InMemory Relay backend")
            let backend : @relay.InMemoryBackend[String] = @relay.InMemoryBackend::new(
              1000,
            )
            backend.to_relay_queue()
          }
          Valkey => {
            @logger.info("🔌 Connecting to Valkey (localhost:6379)")
            try {
              // In production, you would parse cfg.valkey_url to get host/port
              let valkey_client = @valkey.Client::connect("localhost", 6379)
              let backend = @relay.RedisBackend::new(
                valkey_client,
                "relay-tasks",
                fn(s) { s },
                fn(s) { s },
              )
              backend.to_relay_queue()
            } catch {
              err => {
                @logger.error("❌ Failed to connect to Valkey: \{err}")
                @logger.info("⚠️ Falling back to InMemory Relay")
                let backend : @relay.InMemoryBackend[String] = @relay.InMemoryBackend::new(
                  1000,
                )
                backend.to_relay_queue()
              }
            }
          }
        }

        // Example worker: Process messages from the queue
        tg.spawn_bg(
          async fn() {
            try {
              @relay.start_worker(
                queue,
                fn(msg) {
                  @logger.info(
                    "👷 Relay Worker: Processing message \{msg.id} -> \{msg.payload}",
                  )
                },
              )
            } catch {
              _ => @logger.info("🛑 Relay Worker stopped.")
            }
          },
        )

        // Endpoint to push tasks to relay
        app.get(
          "/relay/push",
          async fn(event) {
            let payload = event.req.get_query("payload").unwrap_or("default-task")
            try {
              queue.push(payload)
              @logger.info("📥 Task queued: \{payload}")
            } catch {
              err => @logger.error("❌ Relay Push Error: \{err}")
            }
            "Task queued: \{payload}"
          },
        )
      }

      // 3. Middlewares
      app
      ..use_middleware(
        (event, next) => {
          @logger.debug("📝 Request: \{event.req.http_method} \{event.req.url}")
          next()
        },
      )
      // Example of adding security headers (custom middleware)
      ..use_middleware(
        (event, next) => {
          ignore(event.res.header("X-Content-Type-Options", "nosniff"))
          ignore(event.res.header("X-Frame-Options", "DENY"))
          next()
        },
      )

      // 4. Routes
      // Basic heartbeat
      ..get("/", _event => "⚡️ Welcome to the Production-Ready MoonBit Server!")

      // Health checks (Phase 3)
      ..get(
        "/healthz",
        _event => ({ "status": "ok", "version": "1.0.0" } : Json),
      )

      // Hello World
      ..get("/hello/:name", (event) => {
        let name = event.param("name").unwrap_or("World")
        "Hello, \{name}!"
      })

      // JSON example
      .get(
        "/api/user",
        _ => ({ "id": 1, "username": "moon_dev", "role": "admin" } : Json),
      )

      // 5. Server Startup
      @logger.info("📡 Routes initialized:")
      for path in app.routes() {
        @logger.info("   \{path.0} -> \{path.1}")
      }

      try {
        app.serve(port=cfg.port)
      } catch {
        err => @logger.error("🔥 Server Panic: \{err}")
      }
    },
  )
}
