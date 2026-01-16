org 0x0000
[bits 16]

mov ax, cs
mov ds, ax
mov es, ax

cld

jmp kernel_main

kernel_main:
	call display_clear

	mov si, welcome_msg
	call print
	
	call ln
	
	call print_prompt
	jmp get_input
; .hang:
	; jmp .hang

get_input:
	mov ah, 0x00
	int 0x16

	cmp al, 0x0D
	je finished_input
	
	cmp al, 0x08
	je backspace
	
	inc byte [cmd_count]
	mov [cmd_buffer + di], al
	inc di

	mov ah, 0x0E
	mov bl, 0x07
	int 0x10

	jmp get_input

finished_input:
	call ln
	mov [cmd_buffer + di], 0x00
	
	cmp byte[cmd_buffer], 0x00
	je enter

	jmp command

enter:
	call print_prompt
	mov byte [cmd_count], 0

	mov byte [cmd_buffer], 0x00
	mov di, 0

	jmp get_input

backspace:
	cmp byte [cmd_count], 0
	je get_input
	
	dec byte [cmd_count]
	dec di

	mov bl, 0x07

	mov ah, 0x0E
	mov al, 0x08
	int 0x10
	
	mov al, " "
	int 0x10

	mov al, 0x08
	int 0x10

	jmp get_input

command:
	call check_ver
	
	cmp ax, 1
	je .handle_invalid_cmd

	jmp enter

.handle_invalid_cmd:
	call invalid_cmd
	jmp enter

check_ver:
	mov si, cmd_buffer
	mov di, ver_cmd
	mov cx, 3

	repe cmpsb
	jne .ver_done
	
	cmp byte [si], 0
	jne .ver_done

	jmp ver
.ver_done:
	jmp check_clear

ver:
	mov si, ver_log
	call print
	call ln
	
	mov ax, 0
	ret

check_clear:
	mov si, cmd_buffer
	mov di, clear_cmd
	mov cx, 5

	repe cmpsb
	jne .clear_done
	
	cmp byte [si], 0
	jne .clear_done

	jmp clear
.clear_done:
	jmp check_exit

clear:
	call display_clear

	mov ax, 0
	ret

check_exit:
	mov si, cmd_buffer
	mov di, exit_cmd
	mov cx, 4
	
	repe cmpsb
	jne .exit_done
	
	cmp byte [si], 0
	jne .exit_done

	jmp exit
.exit_done:
	mov ax, 1
	ret

exit:
	call clear

	mov si, exit_log
	call print
	
	jmp .hlt_loop
.hlt_loop:
	cli
	hlt
	jmp .hlt_loop

invalid_cmd:
	mov si, invalid_cmd_msg
	call print
	mov si, cmd_buffer
	call print
	call ln
	ret

print_prompt:
	call ln

	mov si, work_dir
	call print
	mov si, prompt
	call print
	ret
display_clear:
	mov ah, 0x06
	mov al, 0x00
	mov bh, 0x07
	mov ch, 0x00
	mov cl, 0x00
	mov dh, 24
	mov dl, 79
	int 0x10
	
	mov ah, 0x02
	mov bh, 0x00
	mov dh, 0x00
	mov dl, 0x00
	int 0x10
	ret

print:
	lodsb
	cmp al, 0x00
	je .done
	
	mov ah, 0x0E
	mov bh, 0x00
	mov bl, 0x07
	int 0x10
	jmp print
.done:
	ret

ln:
	mov ah, 0x0E
	mov al, 0x0A
	int 0x10
	mov al, 0x0D
	int 0x10
	ret

welcome_msg db "Welcome to Paradise DOS!", 0x00
work_dir db "~", 0x00
prompt db " > ", 0x00
cmd_count db 0
cmd_buffer: times 64 db 0

ver_cmd: db "ver", 0x00
ver_log db "Paradise DOS v0.1", 0x00

clear_cmd: db "clear", 0x00

exit_cmd: db "exit", 0x00
exit_log db "It's now safe to turn off your computer.", 0x00

invalid_cmd_msg db "invalid command -> ", 0x00

times 1024-($-$$) db 0
