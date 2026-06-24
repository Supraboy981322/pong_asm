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

     ; left paddle
      ;up
      mov rdi, [KEY_W]
      call IsKeyDown
      test al, al
      jz left_up_ret
      mov rsi, left_paddle
      lea rax, [left_up_ret]
      jmp move_up
      left_up_ret:
      ;down
      mov rdi, [KEY_S]
      call IsKeyDown
      test al, al
      jz left_down_ret
      mov rsi, left_paddle
      lea rax, [left_down_ret]
      jmp move_down
      left_down_ret:
    ;

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

    move_up:
      ;expects:
      ;  - paddle structure in rsi
      ;  - address of label to jmp back to in rax
      xor edi, edi ;zero-out rdi (dil is bottom byte of rdi)
      mov dil, [rsi + 8]  ;speed
      mov edx, [rsi + 4]  ;y pos
      test edx, edx
      jz move_up_ret
      sub edx, edi
      mov [rsi + 4], edx
      move_up_ret: jmp rax
    move_down:
      ;expects:
      ;  - paddle structure in rsi
      ;  - address of label to jmp back to in rax
      xor edi, edi ;zero-out rdi (dil is bottom byte of rdi)
      mov dil, [rsi + 8]  ;speed
      mov edx, [rsi + 4]  ;y pos
      add edx, 50
      cmp edx, [SCREEN_HEIGHT]
      jle move_down_ret
      sub edx, 50
      add edx, edi
      mov [rsi + 4], edx
      move_down_ret: jmp rax

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
  KEYS:
    KEY_W:    dd 87
    KEY_S:    dd 83
    KEY_UP:   dd 265
    KEY_DOWN: dd 264
  
section '.note.GNU-stack'
