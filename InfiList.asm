; Sistema gerenciador de arquivos por lista encadeada
; arquivo: InfiList.asm
; objetivo: Gerenciar arquivos
; nasm -f elf64 InfiList.asm ; ld InfiList.o -o InfiList.x

%define _exit     60
%define _write    1
%define _open     2
%define _read     0
%define _seek     8
%define _close    3
%define readOnly  0o    		; flag open()
%define writeOnly 1o    			; flag open()
%define readwrite 2o    			; flag open()
%define openrw    102o  		; flag open()
%define userWR    644o  		; Read+Write+Execute
%define _cat	  	0x20544143
%define _ls		0x0000534c
%define _cd		0x00204443
%define _quit	0x54495551

section .data
    
	argErrorS : db "Erro: Quantidade de Parâmetros incorreta", 10, 0
	argErrorSL: equ $-argErrorS 

    arqErrorS : db "Erro: Arquivo não foi aberto", 10, 0
    arqErrorSL: equ $-arqErrorS
	
	argErrorC : db "Erro: Comando incorreto", 10, 0
    argErrorCL: equ $-argErrorC
	
	argErrorCAT: db "Erro: não é possível fazer CAT neste tipo", 10, 0
    argErrorCATL: equ $-argErrorCAT
	
	argErrorDIR: db "Erro: não é possível abrir diretório", 10, 0
    argErrorDIRL: equ $-argErrorDIR

	promptDialog: db 10, 10, "Pressione [Enter] para continuar", 10, 0
    promptDialogL: equ $-promptDialog
	
    strOla  : db "Testi", 10, 0
    strOlaL : equ $-strOla
	
	jumpLine : db 10, 0 
	
	limpaTerminal       : db   27,"[H",27,"[2J"    ; <ESC> [H <ESC> [2J
	limpaTerminalL      : equ  $-limpaTerminal         ; tamanho da string para limpar terminal
	
	caracterPonto : db 0x2e, 0

	tabChar	: db 0x09, 0
	
	trintaDois	: dq 32
	; moldura para print
	firstLine	: db "|", 0x09, "Nome", 0x09, 0x09, "|", 0x20, "Tipo", 0x20, "|", 0x09, "Tamanho", 0x09, 0x09, "|", 10 ,0 
	firstLineL	: equ $-firstLine
	
	initLine		: db "|", 0x09, 0
	initLineL	: equ $-initLine
	
	finishLine		: db "|", 0x0a, 0
	finishLineL	: equ $-finishLine
	
	typeSpace	: db 0x09,"|", 0x20, 0
	typeSpaceL	: equ $-typeSpace
	
	typeDir		: db "DIR", 0x20, 0
	typeArch	: db "ARCH", 0
	typeSize	: db 4
	
	typeFinish		: db 0x20, "|", 0x09, 0
	typeFinishL	: equ $-typeFinish
	
	dirSizeChar	: db "-------", 0x09, 0x09, "|", 10, 0
	dirSizeCharL	: equ $-dirSizeChar
	
	archFinish		: db 0x09, "|", 10, 0
	archFinishL	: equ $-archFinish

    testeArquivo    : db "./teste.txt", 0
    testeArquivoL   : equ $-testeArquivo 

	
	beep			: db 0x07, 0

    finalBlocos     : dq 0xffffffffffffffff, 0

section .bss
    
    tamanhoBloco            : resq 1 
    ponteiroRaiz            : resq 1
    ponteiroBlocosLimpos    : resq 1
    tamanhoArmazenamento    : resq 1
    quantidadeBlocos        : resb 6

    ponteiroDiretorioAtual  : resq 1
    tamanhoDiretorioAtual   : resq 1

    ponteiroDispositivo : resq 1
    argv                : resq 1
    argc                : resq 1
    buffer              : resq 1  

	
section .text

    global _start

_start:
	
	mov rax, _write
	mov rdi, 1
	lea rsi, [beep]
	mov rdx, 1
	syscall

    mov r8, [rsp]
	mov [argv], r8
	cmp QWORD[argv], 2        ; Verifica a quantidade de argumentos
	;jne _end
  
	mov r8, rsp
	add r8, 16
	mov r9, [r8]
	mov [argc], r9              ; Salvando endereço do argumento em variável

    mov QWORD[tamanhoBloco], 512    ; Teste de sistema

    ;%include "pushall.asm"
    ;mov rdi, [argc]
    ;mov rsi, 0
    ;mov rdx, 10
    ;call formatacao             ;int[rax] formatacao(long *ponteiroDispositivo[rdi], long tamanhoBloco[rsi], int quantidadeBlocos[rdx])
    ;%include "popall.asm"


    ;%include "pushall.asm"
    ;mov rdi, [argc]
    ;lea rsi, [tamanhoBloco]
    ;lea rdx, [ponteiroRaiz]
    ;lea rcx, [ponteiroBlocosLimpos]
    ;lea r8, [tamanhoArmazenamento]
    ;lea r9, [quantidadeBlocos]
    ;call iniciarSistema         ; *FILE iniciarSistema(long *dispositivo[rdi], long *tamanhoBloco[rsi], long *ponteiroRaiz[rdx], long *ponteiroBlocosLimpos[rcx], long *tamanhoArmazenamento[r8], long *quantidadeBlocos[r9])
    ;mov [ponteiroDispositivo], rax
    ;%include "popall.asm"


    %include "pushall.asm"
    lea rdi, [testeArquivo]
    mov rsi, 0
    call copiaParaDentro ; long copiaParaDentro(char *arquivoParaCopiar[rdi], long *pastaAtual[rsi]) 
    %include "popall.asm"


_end:
    mov rax, _exit
    mov rdi, 0
    syscall





formatacao: ;int[rax] formatacao(long *ponteiroDispositivo[rdi], long tamanhoBloco[rsi], int quantidadeBlocos[rdx])
	
    push rbp
	mov rbp, rsp

    cmp rsi, 7
    jg blocoSuperiorLimite
    
    cmp rdx, 10
    jl quantiadeBlocoMinima

    mov r13, rdi
    mov r14, rsi
    mov r15, rdx
    

    mov rax, _open
    ;mov rdi, rdi
    mov rsi, readwrite
    mov rdx, userWR
    syscall

    
    sub rsp, 8
    and QWORD[rbp-8], 0

    cmp rax, 0
    jle naoAbriu 
    mov [rbp-8], rax            ; Armazena o ponteiro para o arquivo

    sub rsp, 8
    and QWORD[rbp-16], 0
    mov rax, 512
    mov cl, r14b
    shl rax, cl 
    mov [rbp-16], rax           ; Armazena o tamanho do bloco
    
    mov rax, _seek
    mov rdi, [rbp-8]
    xor rsi, rsi
    xor rdx, rdx
    syscall

    mov rax, _write
    mov rdi, [rbp-8]
    mov [buffer], r14           ; Armazena no dispositivo a potência que define o bloco
    lea rsi, [buffer]
    mov rdx, 1
    syscall

    mov rax, _write
    mov rdi, [rbp-8]
    lea rsi, [rbp-16]           ; Armazena no dispositivo o ponteiro para o diretório raiz
    mov rdx, 8
    syscall

    mov rax, _write
    mov rdi, [rbp-8]
    mov rsi, [rbp-16]           ; Armazena no dispositivo o ponteiro para lista de blocos livres
    shl rsi, 1
    mov [buffer], rsi
    lea rsi, [buffer]
    mov rdx, 8
    syscall
    
    mov rax, r15
    mul QWORD[rbp-16]
    
    mov rsi, rax
    mov [buffer], rsi
    lea rsi, [buffer]
    mov rax, _write
    mov rdi, [rbp-8]            ; Armazena no dispositivo o tamanho real do armazenamento 
    mov rdx, 8
    syscall


    mov rax, _write
    mov rdi, [rbp-8]
    mov [buffer], r15d               ; armazenamento da quantidade de blocos formatadas no dispositivo
    lea rsi, [buffer]
    mov rdx, 4
    syscall
    mov rax, _write
    mov rdi, [rbp-8]
    mov [buffer], r15
    lea rsi, [buffer]
    shr rsi, 32
    mov rdx, 2
    syscall


    mov rax, [rbp-16]
    mov rsi, 2
    mul rsi
    mov rsi, rax
    mov rax, _seek
    mov rdi, [rbp-8]
    xor rdx, rdx
    syscall

    ;sub r15, 2
	mov r14, 2
    dec r15

    lacoCriaListaBlocosVagos:
        
		mov rax, _seek
		mov rdi, [rbp-8]
		mov rdx, 1
		mov rsi, [rbp-16]
		sub rsi, 8
		syscall
	
        inc r14		
		mov rax, [rbp-16]
		mul r14
		mov [buffer], rax
		mov rax, _write
		mov rdi, [rbp-8]
        lea rsi, [buffer]
		mov rdx, 8
		syscall

		cmp r14, r15
		jne lacoCriaListaBlocosVagos
	

	mov rax, _seek
	mov rdi, [rbp-8]
	mov rdx, 1
	mov rsi, [rbp-16]
	sub rsi, 8
	syscall

	mov rax, _write
	mov rdi, [rbp-8]
    lea rsi, [finalBlocos] 
	mov rdx, 8
	syscall

    mov rax, _close
    mov rdi, [rbp-8]
    syscall

    quantiadeBlocoMinima:
    blocoSuperiorLimite:
    naoAbriu:
    

    xor rax, rax        ; retorno de status sem erro
    mov rsp, rbp
	pop rbp
	ret

iniciarSistema:     ; *FILE iniciarSistema(long *dispositivo[rdi], long *tamanhoBloco[rsi], long *ponteiroRaiz[rdx], long *ponteiroBlocosLimpos[rcx], long *tamanhoArmazenamento[r8], long *quantidadeBlocos[r9])
    push rbp
	mov rbp, rsp
    
    sub rsp, 40
    mov [rbp-8], rsi
    mov [rbp-16], rdx
    mov [rbp-24], rcx
    mov [rbp-32], r8
    mov [rbp-40], r9
    
    

    mov rax, _open
    ;mov rdi, rdi
    mov rsi, readwrite
    mov rdx, userWR
    syscall

    cmp rax, 0
    jle naoIniciouSistema
    
    sub rsp, 8
    mov [rbp-48], rax            ; Salva ponteiro para o arquivo
    


    mov rax, _read
    mov rdi, [rbp-48]
    mov rsi, [rbp-8]
    mov rdx, 1
    syscall                     ; Lê a pontência do bloco 

    mov r15, [rbp-8]
    mov cl, [r15]
    and QWORD[r15], 0
    mov rax, 512
    shl rax, cl
    mov [r15], rax           ; Armazena tamanho dos setores

    mov rax, _read
    mov rdi, [rbp-48]
    mov rsi, [rbp-16]           
    mov rdx, 8
    syscall                     ; Armazena o ponteiro para o diretório raiz


    mov rax, _read
    mov rdi, [rbp-48]
    mov rsi, [rbp-24]
    mov rdx, 8
    syscall                     ; Armazena o ponteiro para os blocos livres

    mov rax, _read
    mov rdi, [rbp-48]
    mov rsi, [rbp-32]
    mov rdx, 8
    syscall                     ; Armazena o tamanho do dispositivo
    
    
    mov rax, _read
    mov rdi, [rbp-48]
    mov rsi, [rbp-40]
    mov rdx, 6
    syscall                     ; Armazena a quantidade de blocos
    

    mov rax, [rbp-48]           ; Retorno do ponteiro do arquivo  

    mov rsp, rbp
    pop rbp
    ret
    
    naoIniciouSistema:
    xor rax, rax
    dec rax

    mov rsp, rbp
    pop rbp
    ret
    
    
carregaDiretorio:  ; long carregaDiretorio(long *ponteiroArquivo[rdi], long modo[rsi], long *ponteiroDiretorio[rdx], long *tamanhoBloco[rcx]) retorna o ponteiro onde termina o diretório armazenado em pilha
    push rbp
	mov rbp, rsp    
    
    sub rsp, 32
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx



    cmp rsi, 0
    je carregaRoot

    cmp rsi, 1
    je carregaSubdiretorio 
    

    carregaRoot:
        sub rsp, [rbp-32]
        mov rax, _seek
        mov rdi, [rbp-8]
        mov rsi, [ponteiroRaiz]             ; Utiliza o ponteiro para o bloco raiz para acessá-lo DADO EXTERNO
        xor rdx, rdx
        syscall

        mov rax, _read
        mov rdi, [rbp-8]
        mov r8, [rbp-32]
        add r8, 32
        neg r8
        mov rsi, [rbp+r8]
        mov rdx, [rbp-32]
        syscall                             ; Armazena o bloco na pilha
        
        mov [ponteiroDiretorioAtual], rsp   ; Altera o ponteiro para a pilha com o diretório carregado
        mov r10, [tamanhoBloco]
        mov [tamanhoDiretorioAtual], r10    ; Altera o tamanho do diretório atual
        mov rsp, rbp
        pop rbp
        ret


    carregaSubdiretorio:
        mov rax, _seek
        mov rdi, [rbp-8]
        mov rsi, [rbp-24]
        xor rdx, rdx
        syscall

        and QWORD[tamanhoDiretorioAtual], 0

        mov rcx, [rbp-32]
        sub rcx, 64
        sub rsp, rcx
        
        add [tamanhoDiretorioAtual], rcx

        mov rdx, rcx
        mov rax, _read
        mov rdi, [rbp-8]
        add rcx, 32
        neg rcx
        mov rsi, [rbp+rcx]
        syscall                                 ; Lê as entradas do subdiretório

        mov rax, _seek
        mov rdi, [rbp-8]
        mov rsi, 56
        mov rdx, 1
        syscall                                 ; Avança até o ponto em que fica o ponteiro

        mov rax, _read
        mov rdi, [rbp-8]
        lea rsi, [buffer]
        mov rdx, 8
        syscall                                 ; Lê o ponteiro para próximo bloco

        cmp QWORD[buffer], -1
        jne lacoLeituraDiretorio
        jmp fimLeituraDiretorio

        lacoLeituraDiretorio:
            mov rax, _seek
            mov rdi, [rbp-8]
            mov rsi, [buffer]
            xor rdx, rdx
            syscall

            mov rcx, [rbp-32]
            sub rcx, 64
            sub rsp, rcx
            add [tamanhoDiretorioAtual], rcx

            mov rdx, rcx
            mov rax, _read
            mov rdi, [rbp-8]
            mov rcx, [tamanhoDiretorioAtual]
            add rcx, 32
            neg rcx
            mov rsi, [rbp+rcx]
            syscall                                 ; Lê as entradas do subdiretório

            mov rax, _seek
            mov rdi, [rbp-8]
            mov rsi, 56
            mov rdx, 1
            syscall                                 ; Avança até o ponto em que fica o ponteiro

            mov rax, _read
            mov rdi, [rbp-8]
            lea rsi, [buffer]
            mov rdx, 8
            syscall                                 ; Lê o ponteiro para próximo bloco

            cmp QWORD[buffer], -1
            jne lacoLeituraDiretorio
    
    fimLeituraDiretorio:
    mov [ponteiroDiretorioAtual], rsp   ; Altera o ponteiro para a pilha com o diretório carregado
    mov rsp, rbp
    pop rbp
    ret



imprimeDiretorio:  ; void imprimeDiretorio(long *ponteiroDiretorio[rdi], long *tamanhoDiretorio[rsi])
    push rbp
    mov rbp, rsp  
    
    sub rsp, 16    
    mov [rbp-8], rdi
    mov [rbp-16], rsi

    xor r15, r15

   	mov rax, _write
	mov rdi, 1
	lea rsi, [limpaTerminal]		
	mov rdx, limpaTerminalL
	syscall                     ; "Limpa" o terminal do programa

    lacoImpressaoEntrada:
        mov r14, [rbp-8]
        cmp BYTE[r14+r15], 0
        je proximaEntrada
        mov r13, r15
        add r13, 20
        cmp BYTE[r14+r13], 0
        jne proximaEntrada
    
        mov r13, r15
        xor r12, r12
        lacoImpressaoEntradaNome:
            mov rax, _write
            mov rdi, 1
            mov rsi, [r14+r13]
            mov rdx, 1
            syscall

            inc r13
            inc r12
            cmp r12, 16
            je imprimePonto
            cmp BYTE[r14+r13], 0x2e
            je nomeNaoMaximo
            jmp lacoImpressaoEntradaNome

        nomeNaoMaximo:
            mov r8, 16
            sub r8, r12 
            mov r12, 16
            add r13, r8 
        imprimePonto:
            mov rax, _write
            mov rdi, 1
            lea rsi, [caracterPonto]
            mov rdx, 1
            syscall
        lacoImpressaoEntradaExtensao:
            mov rax, _write
            mov rdi, 1
            mov rsi, [r14+r13]
            mov rdx, 1
            syscall

            inc r13
            inc r12
            cmp r12, 19
            je proximaEntrada
            cmp BYTE[r14+r13], 0x2e
            je proximaEntradaAjuste
            jmp lacoImpressaoEntradaExtensao

    proximaEntradaAjuste:
        mov r8, 19
        sub r8, r12
        add r13, r8
    proximaEntrada:



    mov rsp, rbp
    pop rbp
    ret

copiaParaDentro: ; long copiaParaDentro(char *arquivoParaCopiar[rdi], long *pastaAtual[rsi], long *ponteiroDispositivo[rdx], long *ponteiroBlocosLimpos[rcx]) 
    push rbp
    mov rbp, rsp  
    
    sub rsp, 32
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx

    mov rax, _open
    ;mov rdi, rdi
    mov rsi, readwrite
    mov rdx, userWR
    syscall                 ; Abre o arquivo a ser carregado

    cmp rax, 0
    jle erroCopiaParaDentroSemAbrir

    sub rsp, 8
    mov [rbp-40], rax

    sub rsp, 96

                            ; Obter informações do arquivo
    mov rax, 4              ; Número da chamada de sistema para "fstat"
    mov rbx, [rbp-40]       ; Descritor do arquivo
    lea rsi, [rbp-136]      ; Endereço da estrutura struct stat
    mov rdx, 88             ; Tamanho da estrutura struct stat
    syscall
                            ; Tamanho do arquivo fica em rbp-80
    mov r8, [rbp-88] 

    mov r15, [tamanhoBloco]
    sub r15, 8
    xor rdx, rdx
    mov rax, [rbp-88]
    div r15
    mov r12, rax
    cmp rdx, 0
    je verifcaEspaco
    inc r12

    mov r14, [rbp-32]
    cmp r14, -1
    je erroDispositivoSemEspacoSuficiente
    mov r13, 1
    verifcaEspaco:
        mov rax, _seek
        mov rdi, [rbp-24]
        mov rsi, r14
        add rsi, r15
        xor rdx, rdx
        syscall

        mov rax, _read
        mov rdi, [rbp-24]
        lea rsi, [buffer]
        mov rdx, 8
        syscall

        xor rbx, rbx
        dec rbx
        inc r13

        mov r14, [buffer]
        cmp r13, r12
        je espacoSufienteAlocavel

        cmp QWORD[buffer], rbx
        je erroDispositivoSemEspacoSuficiente
        
        jmp verifcaEspaco


    espacoSufienteAlocavel:
         



    erroDispositivoSemEspacoSuficiente:

    erroCopiaParaDentroSemAbrir:

    
    mov rsp, rbp
    pop rbp
    ret



