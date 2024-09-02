# gmlewis/sha256
[![check](https://github.com/gmlewis/moonbit-sha256/actions/workflows/check.yml/badge.svg)](https://github.com/gmlewis/moonbit-sha256/actions/workflows/check.yml)

This is a simple sha256 hash algorithm based on Go's implementation:
https://cs.opensource.google/go/go/+/refs/tags/go1.23.0:src/crypto/sha256/sha256.go
which has the copyright notice:

```
// Copyright 2009 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
```

## Status

The code has been updated to support compiler:

```bash
$ moon version --all
moon 0.1.20240902 (23dcb39 2024-09-02) ~/.moon/bin/moon
moonc v0.1.20240902+a8d98d78a ~/.moon/bin/moonc
moonrun 0.1.20240902 (23dcb39 2024-09-02) ~/.moon/bin/moonrun
```

Use `moonup` to manage `moon` compiler versions:
https://github.com/chawyehsu/moonup
