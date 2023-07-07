converteParaCaractereNoTerminal: ; long converteParaCaractereNoTerminal( long valorParaConverter[rdi], long *ponteiroStringCovertida[rsi], long modo[rdx], <long quantosImprime[rcx]>) retorna o tamanho que a string de caracteres ficou
	push rbp
	mov rbp, rsp
	
	sub rsp, 32
	mov [rbp-8], rdi
	;mov [rbp-16], rsi
	mov r15, rsi
	mov [rbp-24], rdx
	mov [rbp-32], rcx
    dec QWORD[rbp-32]
	
	
	mov rax, [rbp-8]
	xor r13, r13
	xor r11, r11
	verificaNumeroParaCaractere:
	xor rdx, rdx
	cmp rax, 10
	jl fimCaraceteres
	mov r13, 10
	div r13
	add rdx, 48
	mov [r15 + r11], dl
	inc r11
	jmp verificaNumeroParaCaractere
			
	fimCaraceteres:
		add rax, 48
		mov [r15 + r11], al
		;inc r11

	
	mov rax, r11
	mov r13, r11
	mov rcx, [rbp-24]
	dec rcx
	jecxz imprimeNumeroDeLabel
	imprimeCaracteresConvertidos:
			mov rax, _write
			mov rdi, 1
			lea rsi, [r15 + r13]
			mov rdx, 1
			syscall
			dec r13
			cmp r13d, -1
			jne imprimeCaracteresConvertidos
			jmp fimDaConversao
	
	
	imprimeNumeroDeLabel:	
		cmp r11, [rbp-32]
		jl corrigeParaTamanhoDeStringSolicitado
		imprimeLabel:
			mov rax, _write
			mov rdi, 1
			lea rsi, [r15 + r13]
			mov rdx, 1
			syscall
			dec r13
			cmp r13d, -1
			jne imprimeLabel
			jmp fimDaConversao
			
	fimDaConversao:
	
	mov rax, r11
	mov rsp, rbp
	pop rbp
	ret
	
corrigeParaTamanhoDeStringSolicitado:
	inc r11
	inc r13
	mov BYTE[r15 + r11], 48
	jmp imprimeNumeroDeLabel
