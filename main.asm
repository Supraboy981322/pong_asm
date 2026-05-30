section .text
  global _start

_start:
  mov rdi, 255
  mov rax, 60
  syscall
