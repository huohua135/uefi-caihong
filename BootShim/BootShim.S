_Head:
  adr   x1, _Payload    /* Set _Entry address */
  b     _Start          /* Jump to the real code */

#if REQUIRES_KERNEL_HEADER == 1
_StackBase:
  .quad FD_BASE         /* Text Offset */

_StackSize:
  .quad FD_SIZE + (_Payload - _Head) /* Complete shim and payload */
  .quad 0               /* Flags */
  .quad 0               /* Reserved */
  .quad 0               /* Reserved */
  .quad 0               /* Reserved */
  .ascii "ARM\x64"      /* ARM64 Magic */
  .long 0               /* Reserved */
#endif

_Start:
  mov   x4, x1
  /* --- caihong bring-up heartbeat -------------------------------------
     Nothing on this tablet can report from the shim or from an early UEFI
     failure: there is no usable UART, the USB stack is not up yet and the
     panel shows a black screen. Paint the display reserved buffer before
     touching anything else, so a photo of the panel answers "did the shim
     run?" directly. The window is the one MemoryMapLib reserves for the
     panel (0xD5100000, 3000x2120, 32 bpp = 0x1842F00 bytes). It is painted
     only when the shim was built for caihong's FD window, so the other
     devices that share this file are unaffected. */
  ldr   x5, =FD_BASE
  ldr   x11, =0xA7100000
  cmp   x5, x11
  b.ne  _Copy
  ldr   x11, =0xD5100000
  ldr   x12, =0x00FF00FF          /* magenta, little-endian XRGB8888 */
  ldr   x13, =0x1842F00
_Heart:
  str   w12, [x11], #4
  subs  x13, x13, #4
  b.ne  _Heart
  /* Push the painted pixels out of the cache so the panel can scan them. */
  ldr   x11, =0xD5100000
  ldr   x13, =0x1842F00
  add   x13, x11, x13
  mrs   x9, ctr_el0
  ubfx  x9, x9, #16, #4
  mov   x10, #4
  lsl   x9, x10, x9
_HeartClean:
  dc    cvac, x11
  add   x11, x11, x9
  cmp   x11, x13
  b.lo  _HeartClean
  dsb   sy

_Copy:
  ldr   x5, =FD_BASE
  cmp   x4, x5
  beq   _Entry
  ldr   x6,  =FD_SIZE

_CopyLoop:
  ldp   x2, x3, [x4], #16
  stp   x2, x3, [x5], #16
  subs  x6, x6, #16
  b.ne  _CopyLoop
  ldr   x5, =FD_BASE

_Entry:
  /* Publish the copied instructions before executing them. */
  dsb   sy
  mrs   x9, ctr_el0
  ubfx  x9, x9, #16, #4
  mov   x10, #4
  lsl   x9, x10, x9
  sub   x10, x9, #1
  bic   x8, x5, x10
  ldr   x7, =FD_SIZE
  add   x7, x5, x7

_CleanLoop:
  dc    cvac, x8
  add   x8, x8, x9
  cmp   x8, x7
  b.lo  _CleanLoop
  dsb   sy
  ic    iallu
  dsb   sy
  isb
  br    x5

_Dead:
  b     _Dead

.text
.ltorg
.align 4

_Payload:
