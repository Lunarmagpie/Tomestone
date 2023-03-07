//// This module contains tools for working with async.

pub external type Awaitable(a)

if erlang {
  pub external fn async(fn() -> any) -> Awaitable(a) =
    "Elixir.Task" "async"

  external fn await_ex(Awaitable(a)) -> a =
    "Elixir.Task" "await"

  external fn await_many_ex(List(Awaitable(a))) -> List(a) =
    "Elixir.Task" "await_many"

  pub fn await(task: Awaitable(a), callback: fn(a) -> b) -> Awaitable(b) {
    let res = await_ex(task)
    async(fn() { callback(res) })
  }

  pub fn await_many(
    tasks: List(Awaitable(a)),
    callback: fn(List(a)) -> b,
  ) -> Awaitable(b) {
    let res = await_many_ex(tasks)
    async(fn() { callback(res) })
  }

  pub fn run_until_complete(task: Awaitable(a)) -> Nil {
    await_ex(task)
    Nil
  }
}

if javascript {
  external fn await_js(task: Awaitable(a), callback: fn(a) -> b) -> Awaitable(b) =
    "../promise.mjs" "await_"

  external fn await_many_js(
    tasks: List(Awaitable(a)),
    callback: fn(List(a)) -> b,
  ) -> Awaitable(b) =
    "../promise.mjs" "awaitMany"

  pub fn await(task: Awaitable(a), callback: fn(a) -> b) -> Awaitable(b) {
    await_js(task, fn(a) { callback(a) })
  }

  pub fn await_many(
    tasks: List(Awaitable(a)),
    callback: fn(List(a)) -> b,
  ) -> Awaitable(b) {
    await_many_js(tasks, callback)
  }

  pub fn run_until_complete(_task: Awaitable(a)) -> Nil {
    Nil
  }
}
