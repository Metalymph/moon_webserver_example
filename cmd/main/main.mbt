///|
async fn main {
  @async.with_task_group(
    async fn(tg) {
      let app = @crescent.Mocket()

      // --- Relay Setup (Opt-in) ---
      let use_relay = @sys.get_env_var("USE_RELAY").unwrap_or("false") == "true"
      if use_relay {
        println("🏮 Relay: Initializing background workers...")
        let backend : @relay.InMemoryBackend[String] = @relay.InMemoryBackend::new(
          1000,
        )
        let queue = backend.to_relay_queue()

        // Example worker: Process messages from the queue
        tg.spawn_bg(
          async fn() {
            try {
              @relay.start_worker(
                queue,
                fn(msg) {
                  println(
                    "👷 Relay Worker: Processing message \{msg.id} -> \{msg.payload}",
                  )
                },
              )
            } catch {
              _ => println("🛑 Relay Worker stopped.")
            }
          },
        )

        // Add endpoint to push tasks to relay
        app.get(
          "/relay/push",
          async fn(event) {
            let payload = event.req.get_query("payload").unwrap_or("default-task")
            try {
              queue.push(payload)
            } catch {
              err => println("❌ Relay Push Error: \{err}")
            }
            "Task pushed to Relay: \{payload}"
          },
        )
      }

      // Register global middleware
      app
      ..use_middleware(
        (event, next) => {
          println("📝 Request: \{event.req.http_method} \{event.req.url}")
          next()
        },
      )

      // Text Response
      ..get("/", _event => "⚡️ Tadaa!")

      // Hello World
      ..on("GET", "/hello", _ => "Hello world!")
      .group(
        "/api",
        (group) => {
          // 添加组级中间件
          group.use_middleware(
            (event, next) => {
              println(
                "🔒 API Group Middleware: \{event.req.http_method} \{event.req.url}",
              )
              next()
            },
          )
          group.get("/hello", _ => "Hello world!")
          group.get(
            "/json",
            _ => ({ "name": "John Doe", "age": 30, "city": "New York" } : Json),
          )
        },
      )

      // JSON Response
      app
      ..get(
        "/json",
        _event => ({ "name": "John Doe", "age": 30, "city": "New York" } : Json),
      )

      // Async Response
      ..get(
        "/async_data",
        _event => ({ "name": "John Doe", "age": 30, "city": "New York" } : Json),
      )

      // Dynamic Routes
      // /hello2/World = Hello, World!
      ..get(
        "/hello/:name",
        (event) => {
          let name = event.param("name").unwrap_or("World")
          "Hello, \{name}!"
        },
      )
      // /hello2/World = Hello, World!
      ..get(
        "/hello2/*",
        (event) => {
          let name = event.param("_").unwrap_or("World")
          "Hello, \{name}!"
        },
      )

      // Wildcard Routes
      // /hello3/World/World = Hello, World/World!
      ..get(
        "/hello3/**",
        (event) => {
          let name = event.param("_").unwrap_or("World")
          "Hello, \{name}!"
        },
      )

      // Echo Server
      ..post(
        "/echo",
        (e) => {
          let body : Bytes = e.req.body()
          body
        },
      )

      // 404 Page
      .get(
        "/404",
        (e) => {
          e.res.status_code = @crescent.StatusCode::from_int(404)
          @crescent.html(
            (
              #|<html>
              #|<body>
              #|  <h1>404</h1>
              #|</body>
              #|</html>
            ),
          )
        },
      )

      // Print Server URL
      for path in app.routes() {
        println("\{path.0} http://localhost:4000\{path.1}")
      }

      // Serve
      println("🚀 Server active on http://localhost:4000")
      try {
        app.serve(port=4000)
      } catch {
        err => println("Server error: \{err}")
      }
    },
  )
}
