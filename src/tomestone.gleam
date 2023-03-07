import gleam/io
import tomestone/fs
import tomestone/task
import tomestone/env

fn open_file(path: String) -> task.Awaitable(String) {
  use resp <- task.await(fs.read_file(path))
  let assert Ok(content) = resp
  content
}

fn async_main() -> task.Awaitable(Nil) {
  use content <- task.await(open_file("README.md"))
  io.debug(content)
  Nil
}

pub fn main() {
  let content = task.run_until_complete(async_main())
  io.debug(env.get_env("TERM"))
  io.debug(content)
}
