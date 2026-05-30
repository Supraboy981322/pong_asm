format ELF64

section '.text' executable
  public _start
  extrn InitWindow
  extrn CloseWindow
  extrn WindowShouldClose
  extrn BeginDrawing
  extrn EndDrawing

_start:
  mov rdi, 800
  mov rsi, 600
  mov rdx, title
  call InitWindow


  ze_loop:
  call BeginDrawing
  call EndDrawing
  call WindowShouldClose
  test rax, rax
  jz ze_loop

  call CloseWindow

  mov rax, 231 ;exit all spawned threads
  mov rdi, 0
  syscall

section '.data' writeable
  title: db "foo bar baz", 0
section '.note.GNU-stack'
