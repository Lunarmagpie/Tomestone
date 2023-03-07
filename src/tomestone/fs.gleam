import tomestone/task

// Reason struct from https://github.com/gleam-lang/erlang/blob/main/src/gleam/erlang/file.gleam
pub type Error {
  /// Permission denied.
  Eacces
  /// Resource temporarily unavailable.
  Eagain
  /// Bad file number
  Ebadf
  /// Bad message.
  Ebadmsg
  /// File busy.
  Ebusy
  /// Resource deadlock avoided.
  Edeadlk
  /// On most architectures, same as `Edeadlk`. On some architectures, it
  /// means "File locking deadlock error."
  Edeadlock
  /// Disk quota exceeded.
  Edquot
  /// File already exists.
  Eexist
  /// Bad address in system call argument.
  Efault
  /// File too large.
  Efbig
  /// Inappropriate file type or format. Usually caused by trying to set the
  /// "sticky bit" on a regular file (not a directory).
  Eftype
  /// Interrupted system call.
  Eintr
  /// Invalid argument.
  Einval
  /// I/O error.
  Eio
  /// Illegal operation on a directory.
  Eisdir
  /// Too many levels of symbolic links.
  Eloop
  /// Too many open files.
  Emfile
  /// Too many links.
  Emlink
  /// Multihop attempted.
  Emultihop
  /// Filename too long
  Enametoolong
  /// File table overflow
  Enfile
  /// No buffer space available.
  Enobufs
  /// No such device.
  Enodev
  /// No locks available.
  Enolck
  /// Link has been severed.
  Enolink
  /// No such file or directory.
  Enoent
  /// A directory was required to be fully empty but it was not.
  Enotempty
  /// Not enough memory.
  Enomem
  /// No space left on device.
  Enospc
  /// No STREAM resources.
  Enosr
  /// Not a STREAM.
  Enostr
  /// Function not implemented.
  Enosys
  /// Block device required.
  Enotblk
  /// Not a directory.
  Enotdir
  /// Operation not supported.
  Enotsup
  /// No such device or address.
  Enxio
  /// Operation not supported on socket.
  Eopnotsupp
  /// Value too large to be stored in data type.
  Eoverflow
  /// Not owner.
  Eperm
  /// Broken pipe.
  Epipe
  /// Result too large.
  Erange
  /// Read-only file system.
  Erofs
  /// Invalid seek.
  Espipe
  /// No such process.
  Esrch
  /// Stale remote file handle.
  Estale
  /// Text file busy.
  Etxtbsy
  /// Cross-domain link.
  Exdev
  /// File was requested to be read as UTF-8, but is not UTF-8 encoded.
  NotUtf8
  /// An OS error occoured for an unknown reason.
  Unknown
}

pub type FileAccessResult(a) =
  Result(a, Error)

if erlang {
  import gleam/erlang/file

  pub fn read_file(path: String) -> task.Awaitable(FileAccessResult(String)) {
    call_fs_callback(fn() { file.read(path) })
  }

  pub fn read_file_bits(
    path: String,
  ) -> task.Awaitable(FileAccessResult(BitString)) {
    call_fs_callback(fn() { file.read_bits(path) })
  }

  fn reason2error(reason: file.Reason) -> Error {
    case reason {
      file.Eacces -> Eacces
      file.Eagain -> Eagain
      file.Ebadf -> Ebadf
      file.Ebadmsg -> Ebadmsg
      file.Ebusy -> Ebusy
      file.Edeadlk -> Edeadlk
      file.Edeadlock -> Edeadlock
      file.Edquot -> Edquot
      file.Eexist -> Eexist
      file.Efault -> Efault
      file.Efbig -> Efbig
      file.Eftype -> Eftype
      file.Eintr -> Eintr
      file.Einval -> Einval
      file.Eio -> Eio
      file.Eisdir -> Eisdir
      file.Eloop -> Eloop
      file.Emfile -> Emfile
      file.Emlink -> Emlink
      file.Emultihop -> Emultihop
      file.Enametoolong -> Enametoolong
      file.Enfile -> Enfile
      file.Enobufs -> Enobufs
      file.Enodev -> Enodev
      file.Enolck -> Enolck
      file.Enolink -> Enolink
      file.Enoent -> Enoent
      file.Enomem -> Enomem
      file.Enospc -> Enospc
      file.Enosr -> Enosr
      file.Enostr -> Enostr
      file.Enosys -> Enosys
      file.Enotblk -> Enotblk
      file.Enotdir -> Enotdir
      file.Enotsup -> Enotsup
      file.Enxio -> Enxio
      file.Eopnotsupp -> Eopnotsupp
      file.Eoverflow -> Eoverflow
      file.Eperm -> Eperm
      file.Epipe -> Epipe
      file.Erange -> Erange
      file.Erofs -> Erofs
      file.Espipe -> Espipe
      file.Esrch -> Esrch
      file.Estale -> Estale
      file.Etxtbsy -> Etxtbsy
      file.Exdev -> Exdev
      file.NotUtf8 -> NotUtf8
    }
  }

  fn call_fs_callback(
    callback: fn() -> Result(a, file.Reason),
  ) -> task.Awaitable(FileAccessResult(a)) {
    // Creating a new task to proxy the other tasks allows the task to
    // optionally be awaited, like a promise in js.
    task.async(fn() {
      let res = callback()
      case res {
        Ok(v) -> Ok(v)
        Error(e) -> Error(reason2error(e))
      }
    })
  }
}

if javascript {
  external fn read_file_js(path: String) -> task.Awaitable(a) =
    "../files.mjs" "readFile"

  external fn read_file_bits_js(path: String) -> task.Awaitable(a) =
    "../files.mjs" "readFileBits"

  pub fn read_file(path: String) -> task.Awaitable(a) {
    read_file_js(path)
  }

  pub fn read_file_bits(path: String) -> task.Awaitable(a) {
    read_file_bits_js(path)
  }
}
