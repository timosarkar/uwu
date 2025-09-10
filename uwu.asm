format ELF64 executable 3
segment readable executable

BUFFER_SIZE equ 128

start:
    ; --- open("test.txt", O_RDONLY, 0) ---
    mov rax, 2
    mov rdi, filename
    xor rsi, rsi       ; O_RDONLY
    xor rdx, rdx       ; mode
    syscall
    mov r12, rax       ; save file descriptor

    xor r13, r13       ; r13 = buf_end (bytes in buffer)
    xor r14, r14       ; r14 = line_start index

read_loop:
    ; --- read into buffer at buf_end ---
    mov rax, 0         ; sys_read
    mov rdi, r12       ; fd
    mov rsi, buffer
    add rsi, r13       ; buffer + buf_end
    mov rdx, BUFFER_SIZE
    sub rdx, r13       ; remaining space
    syscall
    cmp rax, 0
    je flush_remaining
    add r13, rax       ; update buf_end

    xor rbx, rbx       ; rbx = line length counter
process_buffer:
    cmp r14, r13
    je read_loop       ; processed all bytes

    mov al, [buffer + r14]
    cmp al, 10         ; newline?
    jne next_char

    ; --- compute address of line ---
    mov rsi, buffer
    mov rax, r14
    sub rax, rbx       ; r14 - rbx
    add rsi, rax       ; rsi = buffer + (r14 - rbx)

    ; --- write the line to stdout ---
    mov rax, 1         ; sys_write
    mov rdi, 1
    mov rdx, rbx
    inc rdx             ; include newline
    syscall

    inc r14            ; move past newline
    xor rbx, rbx
    jmp process_buffer

next_char:
    inc r14
    inc rbx
    jmp process_buffer

flush_remaining:
    cmp r14, r13
    je close_file

    ; --- write leftover bytes ---
    mov rsi, buffer
    mov rax, r14
    sub rax, rbx
    add rsi, rax
    mov rdx, r13
    sub rdx, r14
    syscall

close_file:
    ; --- close file ---
    mov rax, 3
    mov rdi, r12
    syscall

    ; --- exit(0) ---
    mov rax, 60
    xor rdi, rdi
    syscall

segment readable writable
buffer: times BUFFER_SIZE db 0

segment readable
filename: db "test.txt",
