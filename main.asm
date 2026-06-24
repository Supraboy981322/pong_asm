format ELF64

; constants
  WINDOW_START_HEIGHT equ 600
  WINDOW_START_WIDTH equ 800
  KEY_W equ 87
  KEY_S equ 83
  KEY_UP equ 265
  KEY_DOWN equ 264
;

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
  extrn GetScreenWidth
  extrn SetTargetFPS

_start:
  mov rdi, WINDOW_START_WIDTH
  mov rsi, WINDOW_START_HEIGHT
  mov rdx, title
  call InitWindow

  mov rdi, 60
  call SetTargetFPS

  ; center paddles
    mov eax, [SCREEN_HEIGHT]
    sub eax, 50  ;sub paddle height
    xor edx, edx ;zero-out top of rax (eax is bottom)
    mov ecx, 2   ;div by 2
    div ecx
    mov dword [left_paddle + 4], eax
    mov dword [right_paddle + 4], eax
  ;

  ;game loop
  ze_loop:
  call WindowShouldClose
  test rax, rax
  jnz end_game

    ; setup frame
      call GetScreenHeight
      mov [SCREEN_HEIGHT], eax
      call GetScreenWidth
      mov [SCREEN_WIDTH], eax
    ;

    ; left paddle
      ;up
      mov rdi, [left_paddle + 10]
      call IsKeyDown
      test al, al
      jz left_up_ret
      mov rsi, left_paddle
      lea rax, [left_up_ret]
      jmp move_up
      left_up_ret:
      ;down
      mov rdi, [left_paddle + 14]
      call IsKeyDown
      test al, al
      jz left_down_ret
      mov rsi, left_paddle
      lea rax, [left_down_ret]
      jmp move_down
      left_down_ret:
    ;
    ; right paddle
      ;up
      mov rdi, [right_paddle + 10]
      call IsKeyDown
      test al, al
      jz right_up_ret
      mov rsi, right_paddle
      lea rax, [right_up_ret]
      jmp move_up
      right_up_ret:
      ;down
      mov rdi, [right_paddle + 14]
      call IsKeyDown
      test al, al
      jz right_down_ret
      mov rsi, right_paddle
      lea rax, [right_down_ret]
      jmp move_down
      right_down_ret:
      ;set x pos to right side
      mov edx, [SCREEN_WIDTH]
      sub edx, 10
      sub dl, byte [right_paddle + 9]
      mov dword [right_paddle], edx
    ;

    ; draw the frame
      call BeginDrawing

      mov rdi, [BLACK]
      call ClearBackground

      mov edi, [left_paddle]
      mov esi, [left_paddle + 4]
      mov dl, byte [left_paddle + 9]
      mov rcx, 50
      mov r8d, [WHITE]
      call DrawRectangle

      mov edi, [right_paddle]
      mov esi, [right_paddle + 4]
      mov dl, byte [left_paddle + 9]
      mov rcx, 50
      mov r8d, [WHITE]
      call DrawRectangle

      call EndDrawing
    ;

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
  jge move_down_ret
  sub edx, 50
  add edx, edi
  mov [rsi + 4], edx
  move_down_ret: jmp rax

end_game:
  call CloseWindow
  mov rax, 231 ;exit all spawned threads
  mov rdi, 0
  syscall

; game state
section '.data' writeable
  title: db "foo bar baz", 0
  SCREEN_HEIGHT: dd WINDOW_START_HEIGHT
  SCREEN_WIDTH: dd WINDOW_START_WIDTH
  left_paddle:
    dd 10 ;x
    dd 10 ;y
    db 5  ;move speed
    db 10 ;width
    dd KEY_W ;move up
    dd KEY_S ; move down
  right_paddle:
    dd 10 ;x
    dd 50 ;y
    db 5  ;move speed
    db 10 ;width
    dd KEY_UP   ;move up
    dd KEY_DOWN ; move down
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
  RED:
    db 0xFF ;r
    db 0x00 ;g
    db 0x00 ;b
    db 0xFF ;a
;

section '.note.GNU-stack'
