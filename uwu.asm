format ELF64 executable 3
segment readable executable

BUFFER_SIZE equ 128

start:
    ; --- open("test.txt", O_RDONLY, 0) ---
    mov rax, 2          ; sys_open
    mov rdi, filename   ; pointer to filename
    xor rsi, rsi        ; O_RDONLY = 0
    xor rdx, rdx        ; mode (ignored)
    syscall
    mov r12, rax        ; save file descriptor

    xor r13, r13        ; r13 = bytes currently in buffer

read_loop:
    ; --- read(fd, buffer+r13, BUFFER_SIZE-r13) ---
    mov rax, 0          ; sys_read
    mov rdi, r12        ; fd
    lea rsi, [buffer + r13] ; address in buffer to read into
    mov rdx, BUFFER_SIZE
    sub rdx, r13        ; remaining space
    syscall
    cmp rax, 0
    je done             ; EOF
    add r13, rax        ; total bytes in buffer

    ; --- process buffer for lines ---
    xor rbx, rbx        ; rbx = current index in buffer
process_buffer:
    cmp rbx, r13
    je shift_buffer     ; done processing

    mov al, [buffer + rbx]
    cmp al, 10          ; newline?
    jne next_char

    ; --- write line to stdout ---
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    lea rsi, [buffer]   ; start of buffer
    mov rdx, rbx
    syscall

    ; --- remove written line from buffer ---
    mov rdx, r13
    sub rdx, rbx
    dec rdx              ; include newline
    mov rsi, buffer
    add rsi, rbx
    inc rsi
    mov rdi, buffer
shift_loop:
    cmp rdx, 0
    je end_shift
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec rdx
    jmp shift_loop
end_shift:
    mov r13, r13
    sub r13, rbx
    dec r13
    xor rbx, rbx
    jmp read_loop

next_char:
    inc rbx
    jmp process_buffer

shift_buffer:
    ; if buffer full but no newline, flush it
    cmp r13, BUFFER_SIZE
    jne read_loop

    mov rax, 1          ; sys_write
    mov rdi, 1
    mov rsi, buffer
    mov rdx, r13
    syscall
    xor r13, r13        ; buffer empty
    jmp read_loop

done:
    ; --- close(fd) ---
    mov rax, 3          ; sys_close
    mov rdi, r12
    syscall

    ; --- exit(0) ---
    mov rax, 60
    xor rdi, rdi
    syscall

segment readable writable
buffer: times BUFFER_SIZE db 0

segment readable
filename: db "test.txt", 0
