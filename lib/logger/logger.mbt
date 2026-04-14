///|
enum LogLevel {
  DEBUG
  INFO
  ERROR
}

///|
fn LogLevel::from_string(s : String) -> LogLevel {
  match s {
    "DEBUG" | "debug" => DEBUG
    "ERROR" | "error" => ERROR
    _ => INFO
  }
}

///|
fn LogLevel::to_int(self : LogLevel) -> Int {
  match self {
    DEBUG => 0
    INFO => 1
    ERROR => 2
  }
}

///|
fn get_current_level() -> LogLevel {
  @sys.get_env_var("LOG_LEVEL").map(LogLevel::from_string).unwrap_or(INFO)
}

///|
pub fn info(msg : String) -> Unit {
  if get_current_level().to_int() <= INFO.to_int() {
    log("INFO", msg)
  }
}

///|
pub fn error(msg : String) -> Unit {
  if get_current_level().to_int() <= ERROR.to_int() {
    log("ERROR", msg)
  }
}

///|
pub fn debug(msg : String) -> Unit {
  if get_current_level().to_int() <= DEBUG.to_int() {
    log("DEBUG", msg)
  }
}

///|
fn log(level : String, msg : String) -> Unit {
  let log_entry : Json = { "level": level, "message": msg, "timestamp": 0 }
  println(log_entry.stringify())
}
