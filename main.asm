format ELF64

section '.text' executable
  public _start
  extrn InitWindow
  extrn CloseWindow
  extrn WindowShouldClose
  extrn BeginDrawing
  extrn EndDrawing
  extrn DrawRectangle
  extrn ClearBackground

_start:
  mov rdi, 800
  mov rsi, 600
  mov rdx, title
  call InitWindow
  
  ;game loop
  ze_loop:

    call BeginDrawing

      mov rdi, [BLACK]
      call ClearBackground

      mov edi, [pos]
      mov esi, [pos + 4]
      mov rdx, 10
      mov rcx, 50
      mov r8d, [WHITE]
      call DrawRectangle

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
  pos:
    dd 10
    dd 10
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
