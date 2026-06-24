format ELF64

; constants
  WINDOW_START_HEIGHT equ 600
  WINDOW_START_WIDTH equ 800
  KEY_W equ 87
  KEY_S equ 83
  KEY_UP equ 265
  KEY_DOWN equ 264

  ;misc data (stuff that can't be a literal
  section '.rodata' align 16
    sign_mask_float: dd 0x80000000, 0x00000000, 0x00000000, 0x00000000

  section '.data'
    title: db "foo bar baz", 0
    BALL_SPEED_MULT: dd 15.0
    ZERO_FLOAT: dd 0.0
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
  extrn DrawCircle
  extrn GetFrameTime

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

  ; center ball
    cvtsi2ss xmm0, [SCREEN_HEIGHT]
    mov eax, 2
    cvtsi2ss xmm1, eax
    divss xmm0, xmm1
    movss [ball + 4], xmm0

    cvtsi2ss xmm0, [SCREEN_WIDTH]
    cvtsi2ss xmm1, eax
    divss xmm0, xmm1
    movss [ball], xmm0
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
      call GetFrameTime
      movss [DELTA_TIME], xmm0
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

    ; ball movement
      movss xmm0, [ball + 12]
      mulss xmm0, [DELTA_TIME]
      mulss xmm0, [BALL_SPEED_MULT]

      movss xmm2, [ball]
      addss xmm2, xmm0
      movss [ball], xmm2

      movss xmm1, [ball + 16]
      mulss xmm1, [DELTA_TIME]
      mulss xmm1, [BALL_SPEED_MULT]

      movss xmm2, [ball + 4]
      addss xmm2, xmm1
      movss [ball + 4], xmm2

      lea rdx, [done_bounce]
      jmp chk_ball_bounce
      done_bounce:
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

      cvttss2si edi, [ball]     ;centerX
      cvttss2si esi, [ball + 4] ;centerY
      movss xmm0, [ball + 8]    ;radius
      mov edx, [ball + 20]      ;color
      call DrawCircle

      call EndDrawing
    ;

  jmp ze_loop

;
chk_ball_bounce:
  ;expects:
  ;  - address of label to jmp back to when done in rdx
  mov al, 0 ;bounced?

  movss xmm0, [ball]
  movss xmm1, [ball + 8]
  subss xmm0, xmm1
  movss xmm1, [ZERO_FLOAT]
  ucomiss xmm0, xmm1
  jb bounce_horizontal
  je bounce_horizontal

  movss xmm0, [ball]
  movss xmm1, [ball + 8]
  addss xmm0, xmm1
  cvtsi2ss xmm1, [SCREEN_WIDTH]
  ucomiss xmm0, xmm1
  ja bounce_horizontal
  je bounce_horizontal

  jmp no_horizontal_bounce
  bounce_horizontal:
  mov al, 1
  movss xmm0, [ball + 12]
  xorps xmm0, [sign_mask_float]
  movss [ball + 12], xmm0
  no_horizontal_bounce:

  movss xmm0, [ball + 4]
  movss xmm1, [ball + 8]
  subss xmm0, xmm1
  movss xmm1, [ZERO_FLOAT]
  ucomiss xmm0, xmm1
  jb bounce_vertical
  je bounce_vertical

  movss xmm0, [ball + 4]
  movss xmm1, [ball + 8]
  addss xmm0, xmm1
  cvtsi2ss xmm1, [SCREEN_HEIGHT]
  ucomiss xmm0, xmm1
  ja bounce_vertical
  je bounce_vertical

  jmp no_vertical_bounce
  bounce_vertical:
  mov al, 1
  movss xmm0, [ball + 16]
  xorps xmm0, [sign_mask_float]
  movss [ball + 16], xmm0
  no_vertical_bounce:

  test al, al
  jz ball_white
  mov eax, [RED]
  jmp set_ball_color
  ball_white:
  mov eax, [WHITE]
  set_ball_color:
  mov [ball + 20], eax
  jmp rdx
;

; paddle movement helpers
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
;

end_game:
  call CloseWindow
  mov rax, 231 ;exit all spawned threads
  mov rdi, 0
  syscall

; game state
section '.data' writeable
  SCREEN_HEIGHT: dd WINDOW_START_HEIGHT
  SCREEN_WIDTH: dd WINDOW_START_WIDTH
  DELTA_TIME: dd 0
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
    dd 50.0 ;pos x
    dd 50.0 ;pos y
    dd 15.0 ;radius
    dd 15.0 ;vel x
    dd 10.0 ;vel y
    dd 0xFFFFFFFF ;color (white)
;

section '.note.GNU-stack'
