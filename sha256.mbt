///|
/// This package is based on the Go implementation found here:
/// https://cs.opensource.google/go/go/+/refs/tags/go1.23.0:src/crypto/sha256/sha256.go
/// which has the copyright notice:
/// Copyright 2009 The Go Authors. All rights reserved.
/// Use of this source code is governed by a BSD-style
/// license that can be found in the LICENSE file.

// The size of a sha256 checksum in bytes.
let size = 32

///|
// The blocksize of sha256 in bytes.
let block_size = 64

///|
let chunk = 64

///|
let init0 = 0x6A09E667U

///|
let init1 = 0xBB67AE85U

///|
let init2 = 0x3C6EF372U

///|
let init3 = 0xA54FF53AU

///|
let init4 = 0x510E527FU

///|
let init5 = 0x9B05688CU

///|
let init6 = 0x1F83D9ABU

///|
let init7 = 0x5BE0CD19U

///|
/// `Digest` represents the partial evaluation of a checksum.
struct Digest {
  h : FixedArray[UInt] // 8
  x : FixedArray[Byte] // chunk
  mut nx : Int
  mut len : UInt64
  // workaround to get rid of compiler warning:
  // See: https://discord.com/channels/1135479745207869510/1272985768498958387/1275082247484997693
  name : String
}

///|
/// `Digest::new` returns a new, reset Digest, ready to sum.
pub fn Digest::new() -> Digest {
  {
    h: FixedArray::from_array([
      init0, init1, init2, init3, init4, init5, init6, init7,
    ]),
    x: FixedArray::make(chunk, b'\x00'),
    nx: 0,
    len: 0,
    // workaround to get rid of compiler warning:
    name: "sha256",
  }
}

///|
let _trait : &HashFunc = Digest::new()

///|
pub impl HashFunc for Digest with name(self) {
  self.name
}

///|
/// `check_sum` returns the final sha256sum as a hex string.
pub impl HashFunc for Digest with check_sum(self) {
  let digest = self.sum()
  let result = @buffer.new(size_hint=2 * size)
  for b in digest {
    result.write_char(to_hex((b.to_int() >> 4) & 0xf))
    result.write_char(to_hex(b.to_int() & 0xf))
  }
  result.contents().to_unchecked_string()
}

///|
/// `sum` returns the final sha256sum as a `FixedArray[Byte]`.
fn sum(self : Digest) -> FixedArray[Byte] {
  // Padding. Add a 1 bit and 0 bits until 56 bytes mod 64.
  let tmp = FixedArray::make(64 + 8, b'\x00')
  tmp[0] = b'\x80'
  let t = if self.len % 64 < 56 {
    (56UL - self.len % 64).to_int()
  } else {
    (64UL + 56UL - self.len % 64).to_int()
  }

  // Length in bits.
  let len = self.len << 3
  be_put_uint64(tmp, t, len) // append length in bits
  for i = 0; i < t + 8; i = i + 1 {
    self.write(tmp[i])
  }

  // The previous write ensures that a whole number of
  // blocks (i.e. a multiple of 64 bytes) have been hashed.
  if self.nx != 0 {
    panic()
  }

  // Generate digest
  let digest = FixedArray::make(size, b'\x00')
  be_put_uint32(digest, 0, self.h[0])
  be_put_uint32(digest, 4, self.h[1])
  be_put_uint32(digest, 8, self.h[2])
  be_put_uint32(digest, 12, self.h[3])
  be_put_uint32(digest, 16, self.h[4])
  be_put_uint32(digest, 20, self.h[5])
  be_put_uint32(digest, 24, self.h[6])
  be_put_uint32(digest, 28, self.h[7])
  digest
}

///|
/// `reset` resets a digest for re-use.
pub fn reset(self : Digest) -> Unit {
  self.h[0] = init0
  self.h[1] = init1
  self.h[2] = init2
  self.h[3] = init3
  self.h[4] = init4
  self.h[5] = init5
  self.h[6] = init6
  self.h[7] = init7
  self.nx = 0
  self.len = 0
}

///|
/// `write` writes a byte to the digest.
pub impl HashFunc for Digest with write(self, b) {
  self.len += 1
  self.x[self.nx] = b
  self.nx += 1
  if self.nx == block_size {
    self.block_generic()
    self.nx = 0
  }
}

///|
let _K = [
  0x428a2f98U, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4,
  0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe,
  0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f,
  0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
  0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc,
  0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
  0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116,
  0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7,
  0xc67178f2,
]

///|
fn block_generic(self : Digest) -> Unit {
  let w = FixedArray::make(64, 0U)

  //
  let p = self.x
  for i = 0; i < 16; i = i + 1 {
    let j = i * 4
    w[i] = (p[j].to_uint() << 24) |
      (p[j + 1].to_uint() << 16) |
      (p[j + 2].to_uint() << 8) |
      p[j + 3].to_uint()
  }
  for i = 16; i < 64; i = i + 1 {
    let v1 = w[i - 2]
    let t1 = rotl(v1, -17) ^ rotl(v1, -19) ^ (v1 >> 10)
    let v2 = w[i - 15]
    let t2 = rotl(v2, -7) ^ rotl(v2, -18) ^ (v2 >> 3)
    w[i] = t1 + w[i - 7] + t2 + w[i - 16]
  }
  //
  let mut a = self.h[0]
  let mut b = self.h[1]
  let mut c = self.h[2]
  let mut d = self.h[3]
  let mut e = self.h[4]
  let mut f = self.h[5]
  let mut g = self.h[6]
  let mut h = self.h[7]
  //
  for i = 0; i < 64; i = i + 1 {
    let t1 = h +
      (rotl(e, -6) ^ rotl(e, -11) ^ rotl(e, -25)) +
      ((e & f) ^ (e.lnot() & g)) +
      _K[i] +
      w[i]
    let t2 = (rotl(a, -2) ^ rotl(a, -13) ^ rotl(a, -22)) +
      ((a & b) ^ (a & c) ^ (b & c))
    h = g
    g = f
    f = e
    e = d + t1
    d = c
    c = b
    b = a
    a = t1 + t2
  }

  // save state
  self.h[0] += a
  self.h[1] += b
  self.h[2] += c
  self.h[3] += d
  self.h[4] += e
  self.h[5] += f
  self.h[6] += g
  self.h[7] += h
}

///|
fn be_put_uint32(b : FixedArray[Byte], offset : Int, value : UInt) -> Unit {
  b[offset + 3] = (value & 0xff).to_byte()
  b[offset + 2] = ((value >> 8) & 0xff).to_byte()
  b[offset + 1] = ((value >> 16) & 0xff).to_byte()
  b[offset] = ((value >> 24) & 0xff).to_byte()
}

///|
fn be_put_uint64(b : FixedArray[Byte], offset : Int, value : UInt64) -> Unit {
  be_put_uint32(b, offset + 4, (value & 0xffffffff).to_uint())
  be_put_uint32(b, offset, ((value >> 32) & 0xffffffff).to_uint())
}

///|
fn rotl(x : UInt, r : Int) -> UInt {
  (x << r) | (x >> (32 - r))
}

///|
fn to_hex(v : Int) -> Char {
  if v < 10 {
    Int::unsafe_to_char(v + b'0'.to_int())
  } else {
    Int::unsafe_to_char(v - 10 + b'a'.to_int())
  }
}
