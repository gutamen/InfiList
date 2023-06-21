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
    
    arquivo : resq 1
    argv    : resq 1
    argc    : resq 1
  

    disassemble       	: resb 3		; offset 0
    OEMIdentifier     	: resb 8		; offset 3
    bytesPerSector    	: resb 2  	; offset 11
    sectorsPerCluster 	: resb 1  	; offset 13
    reservedSectors   	: resb 2  	; offset 14
    FATNumber         	: resb 1  	; offset 16
    directoryEntries  	: resb 2		; offset 17
    totalSectors      	: resb 2		; offset 19
    mediaDescriptor   	: resb 1  	; offset 21
    sectorsPerFAT     	: resb 2  	; offset 22
    sectorsPerTrack  	: resb 2  	; offset 24
    headsOfStorage   	: resb 2  	; offset 26
    hiddenSectors     	: resb 4		; offset 28
	largeTotalSectors 	: resb 4  	; offset 32

    rootDirectoryInit 	: resq 1  ; posição no arquivo
    dataClustersInit  	: resq 1  ; posição dos dados
    firstFATTable     	: resq 1  ; posição da primeira FAT
    readNow	          	: resq 1  ; qual arquivo está sendo lido
	stackPointerRead 	: resq 1  ; salvar onde estava a pilha no começo da leitura do diretório
	
	totalEntrances	  	: resq 1  ; entradas no diretório lido
	clusterSize	      	: resq 1  ; quantos bytes tem por cluster
	clusterCount	  		: resq 1
	clustersPointer	  	: resq 1
	bus				  		: resb 1
	fileSize		  			: resq 1
	suClusterPointer  	: resq 1
	
	commandType		: resb 1
	longI             		: resq 1

	searcher		  	: resb 128; leitor do terminal
	tempSearcher	: resb 128; reorganizar string lida
	
	sizedChars		: resb 32
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

