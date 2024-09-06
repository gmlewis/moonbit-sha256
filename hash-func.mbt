/// `HashFunc` represents a hash algorithm like `@crc32`, `@md5`, or `@sha256`.
pub trait HashFunc {
  name(Self) -> String
  write(Self, Byte) -> Unit
  check_sum(Self) -> String
}
