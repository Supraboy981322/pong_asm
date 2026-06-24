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
  extrn IsKeyDown

_start:
  mov rdi, 800
  mov rsi, 600
  mov rdx, title
  call InitWindow
  
  ;game loop
  ze_loop:
  call WindowShouldClose
  test rax, rax
  jnz end_game

    mov rdi, 265
    call IsKeyDown
    test al, al
    jne end_game

    call BeginDrawing

      mov rdi, [BLACK]
      call ClearBackground

      mov edi, [left_paddle]
      mov esi, [left_paddle + 4]
      mov rdx, 10
      mov rcx, 50
      mov r8d, [WHITE]
      call DrawRectangle

    call EndDrawing

  jmp ze_loop

end_game:
  call CloseWindow
  mov rax, 231 ;exit all spawned threads
  mov rdi, 0
  syscall

section '.data' writeable
  title: db "foo bar baz", 0
  left_paddle:
    dd 10 ;x
    dd 10 ;y
    db 0  ;input (0=none, 1=up, 2=down)
  right_paddle:
    dd 10 ;x
    dd 10 ;y
    db 0  ;input (0=none, 1=up, 2=down)
  ball:
    dd 10 ;pos x
    dd 10 ;pos y
    dd 10 ;vel x
    dd 10 ;vel y

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
