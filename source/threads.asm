nwcmdst:
	xor eax, eax
	mov esp, stackend
	mov [threadson], al
	mov [currentthread], eax
	add eax, 4
	mov [lastthread], eax
	sti
	jmp nwcmd
%ifdef threads.included
nomorethreadspace:
	mov esi, nmts
	call print
	mov byte [threadson], 0
	jmp nwcmd
nmts	db "Thread Overflow",10,0

nomorestackspace:
	mov esi, nmss
	call print
	jmp nwcmdst
nmss	db "Stack Overflow",10,0
	
threadswitch:
	pushad
	mov edi, threadlist
	mov eax, [currentthread]
	inc eax
	mov [currentthread], eax
	dec ax
	shl eax, 2
	add edi, eax
	mov [edi], esp
	;mov ebx, esp
	;sub ebx, 512
	;shr ebx, 4
	;shl ebx, 4
	;fxsave [ebx]
	add edi, 4
	cmp edi, threadlistend
	jae near nookespthread
	mov eax, [edi]
	cmp eax, 0
	jne near okespthread
nookespthread:
	mov edi, threadlist
	xor eax, eax
	mov [currentthread], eax
	mov eax, [edi]
	cmp eax, 0
	je near nwcmdst
okespthread:
	mov esp, eax
	;sub eax, 512
	;shr eax, 4
	;shl eax, 4
	;fxrstor [eax]
	mov al, 0x20
	out 0x20, al
	popad
	iret

%endif
	lastthread dd 4
	threadson db 0
	currentthread dd 0
