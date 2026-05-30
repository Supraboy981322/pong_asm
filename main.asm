format ELF64

section '.text' executable
  public _start
  extrn InitWindow
  extrn CloseWindow
  extrn WindowShouldClose
  extrn BeginDrawing
  extrn EndDrawing
  extrn DrawText
  extrn ClearBackground

_start:
  mov rdi, 800
  mov rsi, 600
  mov rdx, title
  call InitWindow


  ze_loop:
  call BeginDrawing
    mov rdi, [BLACK]
    call ClearBackground
    mov rdi, title
    mov rsi, 400
    mov rdx, 300
    mov rcx, 20
    mov r8d, [WHITE]
    call DrawText
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
  BLACK:
    db 0x00 ;r
    db 0x00 ;g
    db 0x00 ;b
    db 0xFF ;a
  WHITE:
    db 0xFF ;r
    db 0xFF ;g
    db 0xFF ;b
    db 0xFF ;a

section '.note.GNU-stack'
