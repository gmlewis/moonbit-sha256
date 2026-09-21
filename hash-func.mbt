///|
/// `HashFunc` represents a hash algorithm like `@sha256`, `@md5`, or `@crc32`.
///
/// A `HashFunc` can be injected into other packages as a trait object
/// (`&HashFunc`), which lets a caller feed data to an algorithm it does not
/// know statically, reuse that algorithm across inputs via `reset`, and
/// identify it at runtime via `name`.
///
/// Implementers in other packages should declare the promotion explicitly.
/// Promoting a trait's methods to inherent methods is deprecated (moonc warns
/// `implicit_impl_as_method`), so a foreign implementation also needs a
/// declaration such as:
/// `pub extend MyDigest with @sha256.HashFunc::{name, reset, size, write, check_sum}`
pub(open) trait HashFunc {
  // `name` identifies the hash algorithm, e.g. `"sha256"`.
  fn name(Self) -> String
  // `reset` returns the digest to its initial state so the same instance can
  // hash another input.
  fn reset(Self) -> Unit
  // `size` is the digest size in bytes. `check_sum` renders these as two hex
  // characters per byte.
  fn size(Self) -> Int
  // `write` feeds a single byte to the digest.
  fn write(Self, Byte) -> Unit
  // `check_sum` returns the current digest as a hex string. Unlike Go's `Sum`,
  // it does not reset the digest; call `reset` for that.
  fn check_sum(Self) -> String
}
