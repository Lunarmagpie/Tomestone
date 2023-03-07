//// This module contains tools for working with async.

/// Represents the future result of a function.
/// This is a wrapper around `Task.Task` when using erlang, and `Promise`
/// when using javascript.
pub external type Awaitable(a)

/// Convert a value into an `Awaitable` that returns said value.
///
/// ```gleam
/// fn do_suff() -> task.Awaitable(Nil) {
///   use value <- task.await(task.lift("Hello World"))
///   io.println(value)
/// }
/// ```
///
pub fn lift(value: a) -> Awaitable(a) {
  do_lift(value)
}


/// Convert a function into an async function. This is useful for running a
/// syncronous function, such as `io.println`, in the event loop.
///
/// ```gleam
/// fn do_suff() -> task.Awaitable(Nil) {
///   use value <- task.await(task.async(fn() { "Hello World" }))
///   io.println(value)
/// }
/// ```
pub fn async(value: fn() -> a) -> Awaitable(a) {
  do_async(value)
}

/// Await a task.
///
/// ```gleam
/// fn open_file() -> task.Awaitable(String) {
///   use content <- task.await(fs.read_file("notes.txt"))
///   let assert Ok(content) = content
///   content
/// }
/// ```
pub fn await(task: Awaitable(a), callback: fn(a) -> b) -> Awaitable(b) {
  do_await(task, callback)
}

/// Await a list of tasks.
///
/// ```gleam
/// fn open_file() -> task.Awaitable(List(String)) {
///   use contents <- task.gather([
///     fs.read_file("notes1.txt"),
///     fs.read_file("notes2.txt"),
///   ])
///   use content <- list.map(contents)
///   content
///   |> result.unwrap("file not found")
/// }
/// ```
pub fn gather(
  tasks: List(Awaitable(a)),
  callback: fn(List(a)) -> b,
) -> Awaitable(b) {
  do_gather(tasks, callback)
}

/// Run a task until it is complete.
///
/// ```gleam
/// fn do_suff() -> task.Awaitable(Nil) {
///   task.lift(Nil)
/// }
/// 
/// pub fn main() {
///   task.await(do_suff(), fn(_) { io.println("I completed!") })
///   |> task.run_until_complete
/// }
/// ```
///
pub fn run_until_complete(task: Awaitable(a)) -> Nil {
  do_run_until_complete(task)
}

if erlang {
  pub external fn async_ex(fn() -> any) -> Awaitable(a) =
    "Elixir.Task" "async"

  external fn await_ex(Awaitable(a)) -> a =
    "Elixir.Task" "await"

  external fn await_many_ex(List(Awaitable(a))) -> List(a) =
    "Elixir.Task" "await_many"

  /// Escape from the async callstack by lifting the result of a `Awaitable`.
  ///
  /// > ⚠️ This function is only available when using BEAM.
  ///
  pub fn escape(task: Awaitable(a)) -> a {
    await_ex(task)
  }

  fn do_await(task: Awaitable(a), callback: fn(a) -> b) -> Awaitable(b) {
    let res = await_ex(task)
    async_ex(fn() { callback(res) })
  }

  fn do_gather(
    tasks: List(Awaitable(a)),
    callback: fn(List(a)) -> b,
  ) -> Awaitable(b) {
    let res = await_many_ex(tasks)
    async_ex(fn() { callback(res) })
  }

  fn do_run_until_complete(task: Awaitable(a)) -> Nil {
    await_ex(task)
    Nil
  }

  fn do_async(callback: fn() -> a) -> Awaitable(a) {
    async_ex(callback)
  }

  fn do_lift(value: a) -> Awaitable(a) {
    async_ex(fn() { value })
  }
}

if javascript {
  import gleam/dynamic
  import gleam/javascript/promise

  external fn await_js(task: Awaitable(a), callback: fn(a) -> b) -> Awaitable(b) =
    "../promise.mjs" "await_"

  external fn gather_js(
    tasks: List(Awaitable(a)),
    callback: fn(List(a)) -> b,
  ) -> Awaitable(b) =
    "../promise.mjs" "gather"

  external fn resolve_js(a) -> Awaitable(a) =
    "../promise.mjs" "resolve"

  /// Convert an `Awaitable` to a promise. This can be useful when working with
  /// a library with different types.
  ///
  /// > ⚠️ This function is only available when using javascript.
  ///
  pub fn awaitable2promise(task: Awaitable(a)) -> promise.Promise(a) {
    dynamic.unsafe_coerce(dynamic.from(task))
  }

  /// Convert a `Promise` to an `Awaitable`. This can be useful when working with
  /// a library with different types.
  ///
  /// > ⚠️ This function is only available when using javascript.
  ///
  pub fn promise2awaitable(promise: promise.Promise(a)) -> Awaitable(a) {
    dynamic.unsafe_coerce(dynamic.from(promise))
  }

  fn do_await(task: Awaitable(a), callback: fn(a) -> b) -> Awaitable(b) {
    await_js(task, fn(a) { callback(a) })
  }

  fn do_gather(
    tasks: List(Awaitable(a)),
    callback: fn(List(a)) -> b,
  ) -> Awaitable(b) {
    gather_js(tasks, callback)
  }

  fn do_run_until_complete(_task: Awaitable(a)) -> Nil {
    Nil
  }

  fn do_async(callback: fn() -> a) -> Awaitable(a) {
    await_js(lift(0), fn(_) {callback()})
  }

  fn do_lift(value: a) -> Awaitable(a) {
    resolve_js(value)
  }
}
