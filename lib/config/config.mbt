///|
pub enum RelayBackend {
  InMemory
  Valkey
}

///|
pub struct Config {
  port : Int
  relay_enabled : Bool
  relay_backend : RelayBackend
  valkey_url : String
  log_level : String
}

///|
pub fn Config::load() -> Config {
  let port_str = @sys.get_env_var("PORT").unwrap_or("4000")
  let port = try {
    @string.parse_int(port_str)
  } catch {
    _ => 4000
  }
  let relay_enabled = @sys.get_env_var("USE_RELAY").unwrap_or("false") == "true"
  let relay_backend = match @sys.get_env_var("RELAY_BACKEND") {
    Some("valkey") => Valkey
    _ => InMemory
  }
  let valkey_url = @sys.get_env_var("VALKEY_URL").unwrap_or(
    "valkey://localhost:6379",
  )
  let log_level = @sys.get_env_var("LOG_LEVEL").unwrap_or("INFO")
  { port, relay_enabled, relay_backend, valkey_url, log_level }
}
