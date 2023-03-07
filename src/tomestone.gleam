import gleam/io
import tomestone/fs
import tomestone/task
import tomestone/env

fn async_main() -> task.Awaitable(Nil) {
  use content <- task.await_many([
    fs.read_file(".gitignore"),
    fs.read_file("README.md"),
  ])
  io.debug(content)
  Nil
}

pub fn main() {
  let content = task.run_until_complete(async_main())
  io.debug(env.get_env("TERM"))
  io.debug(content)
}
