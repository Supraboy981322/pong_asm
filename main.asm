format ELF64

section '.text' executable
  public _start
  extrn InitWindow
  extrn CloseWindow

_start:
  mov rdi, 800
  mov rsi, 600
  mov rdx, title
  call InitWindow

  call CloseWindow

  mov rax, 231
  mov rdi, 0
  syscall

section '.data' writeable
  title: db "foo bar baz", 0
section '.note.GNU-stack'
