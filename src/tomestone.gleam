import gleam/io
import tomestone/fs
import tomestone/task
import tomestone/env
import gleam/javascript/promise

fn async_main() -> promise.Promise(Nil) {
  task.awaitable2promise({
    use content <- task.await_many([
      fs.read_file(".gitignore"),
      fs.read_file("README.md"),
    ])
    io.debug(content)
    Nil
  })
}

pub fn main() {
  let content = task.run_until_complete(task.promise2awaitable(async_main()))
  io.debug(env.get_env("TERM"))
  io.debug(content)
}
