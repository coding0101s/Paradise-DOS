org 0x7c00
[bits 16]

xor ax, ax
mov ds, ax
mov ss, ax
mov sp, 0x7c00

mov ax, 0x1000
mov es, ax

mov si, msg

call print

kernel_read:
	mov ah, 0x02
	mov al, 2
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov dl, 0x00
	mov bx, 0x0000
	int 0x13
	jc disk_error
kernel_load:
	jmp 0x1000:0x0000
	mov si, test_msg
	call print

disk_error:	
	mov si, disk_error_msg
	
	call print
	; jmp hang

; hang:
	; jmp hang

print:
	lodsb
	cmp al, 0
	je done

	mov ah, 0x0E
	mov bh, 0x00
	mov bl, 0x07
	int 0x10
	jmp print
done:
	ret

msg db "boot sucessful", 0x00
disk_error_msg db "kernel read failed", 0x00
test_msg db "test", 0x00

times 510-($-$$) db 0
dw 0xAA55
