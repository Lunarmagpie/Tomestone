if erlang {
  import gleam/erlang/os

  pub fn get_env(string: String) -> Result(String, Nil) {
    os.get_env(string)
  }
}

if javascript {
  pub external fn get_env(string: String) -> Result(String, Nil) =
    "../environment.mjs" "getEnv"
}
