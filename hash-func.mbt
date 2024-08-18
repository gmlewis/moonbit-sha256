/// `HashFunc` represents a hash algorithm like `@sha256` or `@sha256`.
pub trait HashFunc {
  name(Self) -> String
  write(Self, Byte) -> Unit
  check_sum(Self) -> String
}
