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
	
	clearTerm   : db   27,"[H",27,"[2J"    ; <ESC> [H <ESC> [2J
	clearTermL : equ  $-clearTerm         ; tamanho da string para limpar terminal
	
	dotChar : db 0x2e, 0

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
	
	beep			: db 0x07, 0

section .bss
    
    potenciaBloco           : resb 1 
    ponteiroRaiz            : resq 1
    ponteiroBlocosLimpos    : resq 1
    tamanhoArmazenamento    : resq 1
    quantidadeBlocos        : resb 6



    ponteiroArquivo : resq 1
    argv            : resq 1
    argc            : resq 1
  

	
section .text

    global _start

_start:
	
	mov rax, _write
	mov rdi, 1
	lea rsi, [beep]
	mov rdx, 1
	syscall

_end:
    mov rax, _exit
    mov rdi, 0
    syscall





formatacao: ;int formatacao(long *dispositivo[rdi], long tamanhoBloco[rsi], int quantidadeBlocos[rdx])
	
    push rbp
	mov rbp, rsp

    cmp rsi, 7
    jg blocoSuperiorLimite
    
    mov r13, rdi
    mov r14, rsi
    mov r15, rdx
    

    mov rax, _open
    ;mov rdi, rdi
    mov rsi, readwrite
    mov rdx, userWR
    syscall

    
    sub rsp, 8
    and [rbp-8], 0

    cmp rax, 0
    jle naoAbriu 
    mov [rbp-8], rax        ; Armazena o ponteiro para o arquivo

    sub rsp, 8
    and [rbp-16], 0
    mov rax, 512
    shl rax, r14b 
    mov [rbp-16], rax       ; Armazena o tamanho do bloco
    
    mov rax, _seek
    mov rdi, [rbp-8]
    xor rsi, rsi
    xor rdx, rdx
    syscall

    mov rax, _write
    mov rdi, [rbp-8]
    mov rsi, r14
    mov rdx, 1
    syscall

    mov rax, _write
    mov rdi, [rbp-8]
    mov rsi, [rbp-16]
    mov rdx, 8
    syscall

    mov rax, _write
    mov rdi, [rbp-8]
    mov rsi, [rbp-16]
    shl rsi, 1
    mov rdx, 8
    syscall
    
    mov rax, r14
    mul QWORD[rbp-16]
    
    mov rsi, rax
    mov rax, _write
    mov rdi, [rbp-8]
    mov rdx, 8
    syscall


    mov rax, _write
    mov rdi, [rbp-8]
    mov rsi, r15d
    mov rdx, 4
    syscall

    mov rax, _write
    mov rdi, [rbp-8]
    mov rsi, r15
    shr rsi, 32
    mov rdx, 2
    syscall

    mov rax, [rbp-16]
    mov rsi, 3
    mul rsi
    mov rsi, rax
    mov rax, _seek
    mov rdi, [rbp-8]
    xor rdx, rdx
    syscall

    sub r15, 2
    lacoCriaListaBlocosVagos:
        



    blocoSuperiorLimite:
    naoAbriu:

    mov rsp, rbp
	pop rbp
	ret








