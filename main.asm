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
  extrn GetScreenHeight
  extrn SetTargetFPS

_start:
  mov rdi, 800
  mov rsi, 600
  mov rdx, title
  call InitWindow

  mov rdi, 60
  call SetTargetFPS
  
  ;game loop
  ze_loop:
  call WindowShouldClose
  test rax, rax
  jnz end_game

    call GetScreenHeight
    mov [SCREEN_HEIGHT], edx

    ;up arrow
    mov rdi, 265
    call IsKeyDown
    test al, al
    jnz up_arrow
    up_arrow_ret:

    ;down arrow
    mov rdi, 264
    call IsKeyDown
    test al, al
    jnz down_arrow
    down_arrow_ret:

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

    up_arrow:
      xor edi, edi ;zero-out rdi (dil is bottom byte of rdi)
      mov dil, [left_paddle + 8]  ;speed
      mov edx, [left_paddle + 4]  ;y pos
      test edx, edx
      jz up_arrow_ret
      sub edx, edi
      mov [left_paddle + 4], edx
      jmp up_arrow_ret
    down_arrow:
      xor edi, edi ;zero-out rdi (dil is bottom byte of rdi)
      mov dil, [left_paddle + 8]  ;speed
      mov edx, [left_paddle + 4]  ;y pos
      add edx, 50
      cmp edx, [SCREEN_HEIGHT]
      jle down_arrow_ret
      sub edx, 50
      add edx, edi
      mov [left_paddle + 4], edx
      jmp down_arrow_ret

end_game:
  call CloseWindow
  mov rax, 231 ;exit all spawned threads
  mov rdi, 0
  syscall

section '.data' writeable
  title: db "foo bar baz", 0
  SCREEN_HEIGHT: dw 0
  left_paddle:
    dd 10 ;x
    dd 10 ;y
    db 5  ;move speed
  right_paddle:
    dd 10 ;x
    dd 10 ;y
    db 5  ;move speed
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
