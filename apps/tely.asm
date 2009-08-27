%include "include.asm"
	tely:
		mov word [BASEADDRSERIAL], 3F8h
		cmp byte [edi], "1"
		je near nofix
		mov word [BASEADDRSERIAL], 2F8h
		cmp byte [edi], "2"
		je near nofix
		mov word [BASEADDRSERIAL], 3E8h
		cmp byte [edi], "3"
		je near nofix
		mov word [BASEADDRSERIAL], 2E8h
		cmp byte [edi], "4"
		je near nofix
		mov esi, noportnum
		call print
		jmp exit
	noportnum db "You must enter a port number from 1 to 4.",10,13,0
	nofix:
		mov ecx, 0
		mov edx, 0
		mov eax, 0
	      	mov dx, [BASEADDRSERIAL]
		mov al, 0
		add dx, 1
		out dx, al		;disable interrupts
	      	mov dx, [BASEADDRSERIAL]
		mov al, 80h
		add dx, 3
		out dx, al		;enable DLAB
	      	mov dx, [BASEADDRSERIAL]
		mov al, 1
		out dx, al
		add dx, 1
		mov al, 0
		out dx, al		;set divisor(buad=115200/divisor)
	      	mov dx, [BASEADDRSERIAL]
		mov al, 3
		add dx, 3
		out dx, al		;8 bits, no parity, one stop bit
	      	mov dx, [BASEADDRSERIAL]
		mov al, 0c7h
		add dx, 2
		out dx, al		;enable FIFO
	      	mov dx, [BASEADDRSERIAL]
		mov al, 0Bh
		add dx, 4
		out dx, al		;IRQs enabled, RTS/DSR set
	telyreceive:
		mov ax, 0
		mov dx, [BASEADDRSERIAL]		;;wait until char received or keyboard pressed
		add dx, 5
		in al, dx
		cmp al, 1
		je testin
		mov dx, [BASEADDRSERIAL]
		in al, dx
		cmp al, 0
		je testin
		mov bx, 7
		mov ah, 6
		int 30h
	testin:
		mov al, 23
		mov ah, 5
		int 30h
		cmp al, 0
		je near telyreceive
		mov ah, al
		mov al, 0
		mov cx, 100
		cmp ah, 10
		jne telysend
		mov ah, 13
		jmp telysend
	printline:
		mov esi, line
		call print
		jmp testin

	telysend:
		mov dx, [BASEADDRSERIAL]		;;wait until transmit is empty
		add dx, 5
		in al, dx
		cmp al, 20h
		jne telysend2
		loop telysend
	telysend2:
		mov al, ah
		cmp al, 0
		je near telyreceive
		mov dx, [BASEADDRSERIAL]
		out dx, al
		jmp telyreceive

BASEADDRSERIAL dw 03f8h
