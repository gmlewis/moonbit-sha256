///|
/// `HashFunc` represents a hash algorithm like `@crc32`, `@md5`, or `@sha256`.
pub(open) trait HashFunc {
  fn name(Self) -> String
  fn write(Self, Byte) -> Unit
  fn check_sum(Self) -> String
}
