# REQUIRES: aarch64

# RUN: llvm-mc -filetype=obj -triple=arm64-apple-darwin %s -o %t.o
# RUN: %lld -arch arm64 -lSystem -U _objc_msgSend -o %t.out %t.o
# RUN: llvm-otool -vs __TEXT __objc_stubs %t.out | FileCheck %s
# RUN: %lld -arch arm64 -lSystem -U _objc_msgSend -o %t.out %t.o -dead_strip
# RUN: llvm-otool -vs __TEXT __objc_stubs %t.out | FileCheck %s
# RUN: %lld -arch arm64 -lSystem -U _objc_msgSend -o %t.out %t.o -objc_stubs_fast
# RUN: llvm-otool -vs __TEXT __objc_stubs %t.out | FileCheck %s
# RUN: %lld -arch arm64 -lSystem -U _objc_msgSend -o %t.out %t.o -objc_stubs_small
# RUN: llvm-otool -vs __TEXT __stubs  %t.out | FileCheck %s --check-prefix=STUB
# RUN: llvm-otool -vs __TEXT __objc_stubs %t.out | FileCheck %s --check-prefix=SMALL

# Unlike arm64-objc-stubs.s, in this test, _objc_msgSend is not defined,
#  which usually binds with libobjc.dylib.
# 1. -objc_stubs_fast: No change as it uses GOT.
# 2. -objc_stubs_small: Create a (shared) stub to invoke _objc_msgSend, to minimize the size.

# CHECK: Contents of (__TEXT,__objc_stubs) section

# CHECK-NEXT: _objc_msgSend$foo:
# CHECK-NEXT: adrp    x1, 8 ; 0x100008000
# CHECK-NEXT: ldr     x1, [x1, #0x10]
# CHECK-NEXT: adrp    x16, 4 ; 0x100004000
# CHECK-NEXT: ldr     x16, [x16]
# CHECK-NEXT: br      x16
# CHECK-NEXT: brk     #0x1
# CHECK-NEXT: brk     #0x1
# CHECK-NEXT: brk     #0x1

# CHECK-NEXT: _objc_msgSend$length:
# CHECK-NEXT: adrp    x1, 8 ; 0x100008000
# CHECK-NEXT: ldr     x1, [x1, #0x18]
# CHECK-NEXT: adrp    x16, 4 ; 0x100004000
# CHECK-NEXT: ldr     x16, [x16]
# CHECK-NEXT: br      x16
# CHECK-NEXT: brk     #0x1
# CHECK-NEXT: brk     #0x1
# CHECK-NEXT: brk     #0x1

# CHECK-EMPTY:

# STUB: Contents of (__TEXT,__stubs) section
# STUB-NEXT:  adrp    x16, 8 ; 0x100008000
# STUB-NEXT:  ldr     x16, [x16]
# STUB-NEXT:  br      x16

# SMALL: Contents of (__TEXT,__objc_stubs) section
# SMALL-NEXT: _objc_msgSend$foo:
# SMALL-NEXT: adrp    x1, 8 ; 0x100008000
# SMALL-NEXT: ldr     x1, [x1, #0x18]
# SMALL-NEXT: b
# SMALL-NEXT: _objc_msgSend$length:
# SMALL-NEXT: adrp    x1, 8 ; 0x100008000
# SMALL-NEXT: ldr     x1, [x1, #0x20]
# SMALL-NEXT: b

.section  __TEXT,__objc_methname,cstring_literals
lselref1:
  .asciz  "foo"
lselref2:
  .asciz  "bar"

.section  __DATA,__objc_selrefs,literal_pointers,no_dead_strip
.p2align  3
.quad lselref1
.quad lselref2

.text

.globl _main
_main:
  bl  _objc_msgSend$length
  bl  _objc_msgSend$foo
  bl  _objc_msgSend$foo
  ret
