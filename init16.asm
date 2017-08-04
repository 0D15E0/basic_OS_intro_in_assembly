%ifndef MACROS_H
	%define STRUCTS_H
	%include "structs.asm"
%endif
[section .text]
;para ver el mapa de memoria
global _handler0,_handler1,_handler2,_handler3,_handler4,_handler5,_handler6,_handler7,_handler8,_handler9,_handler10,_handler11,_handler12,_handler13,_handler_14,_handler46,_handler33
global _handler14, _handler22,_handler32,_handler34,_handler35,_handler36,_handler37,_handler38,_handler39,_handler40,_handler41,_handler42,_handler43,_handler44,_handler45,_handler47 


EXTERN _PAGE_DIRECTORY, _PAGE_TABLE , GDT_INI ,SEL_CS ,SEL_DATOS ,SEL_CS_USER ,SEL_DATOS_USER ,IDT_INI ,GDTR ,IDTR , _PAGE_TABLE_PF
EXTERN _TSS1, _TSS2, _TSS3 , _TSS_kernel , TSS_kernel_index, TSS1, TSS2, TSS3
EXTERN main , tarea1 , tarea2 , tarea3, PILA3, PILA2, PILA1
EXTERN _TSS1_XMM0, _TSS1_XMM1, _TSS2_XMM0, _TSS2_XMM1, _TSS3_XMM0, _TSS3_XMM1

GLOBAL _ORIGEN

_ORIGEN:

		jmp 		_START

__SECT__
[section .data_readonly]
;STARTING_S	db		"S<-caracter incremental...",10 ; TP7
STARTING_S	db		"Starting...",10

MEM_VIDEO 	equ 		0xb8000
CANT_COLUMNAS 	equ 		25
CANT_FILAS 	equ 		80
PAGE_SIZE	EQU	0x1000	;4KB por pagina 
PCD		EQU	10000b
PWT		EQU	1000b
PT_PS		EQU	10000000b	;Sumar si quiero que sean páginas de 4M en lugar de 4K 
PT_A		EQU	100000b	;Sumar si quiero que esté como ACCEDIDO
PT_RW		EQU	10b	;Sumar si quiero que sea WRITEABLE además de READABLE
PT_P		EQU	1b	;Sumar si quiero que esté físicamente presente.
PT_U		EQU	100b;	; atributo de usuario
CR4_PSE		EQU	10000b	;Sumar si quiero habilitar PSE
PG_CR0		EQU	0x80000000	;El bit para activar paginación es el 31 del PR0.
__SECT__


[section .text]
BITS 16
_START:

;___________________________________________________A20 16 bit code_________________________________________________________________________________________

		call A20_Enable

		
;___________________________________________________cargo el lugar reservado de la GDT_________________________________________________________________________________________
;Nombre y numero de argumentos:|1= base| |2=limite| |3=8 bits de Propiedades | |4= 4 bits de prop| |5=Entrada en la tabla|

		gdtdescini 0x0, 	 0xFFFFF,	10011011b, 	1100b, 	GDT_vector(1); Codigo-> 32 bits code
		gdtdescini 0x0, 	 0xFFFFF,	10010011b, 	1100b, 	GDT_vector(2); Datos->  flat 4gb
		gdtdescini 0x0, 	 0xFFFFF,	11111011b, 	1100b, 	GDT_vector(3); Codigo-> 32 bits code user
		gdtdescini 0x0, 	 0xFFFFF,	11110011b, 	1100b, 	GDT_vector(4); Datos->  flat 4gb user


		lgdt		[GDTR]			;Cargo el registro GDTR
		mov 		eax,CR0 ;Muevo CR0 al registro(el prefijo es automatico para que mov mueva de a 32bits)
		or  		eax,0x01;Hago la mascara

;___________________________________________________modo protegido_________________________________________________________________________________________

		mov 		CR0,eax;Cargo el nuevo valor en CR0

		jmp		long SEL_CS:_MP		;Salto largo para entrar en MP y cargar la GDT

BITS 32
_MP:

		mov 		ax, SEL_DATOS
		mov 		ds,ax 		; DS va con  SI
		mov 		es,ax 		; EDI va con ES
		mov 		ss,ax 		; SS va con SP
		mov 		ax, PILA
		mov 		sp,ax;



		call 		_init_pant
		push	 	3		;color
		push		0		;fila
		push 		0		;columna
		push 		STARTING_S; 	* string
		call 		_print
		add 		esp, 16 	;quito del stack los parametros

;___________________________________________________cargo el lugar reservado de la IDT_________________________________________________________________________________________

		idt_ini _handler0,  SEL_CS, 1000111100000000b, IDT_vector(0)
		idt_ini _handler1,  SEL_CS, 1000111100000000b, IDT_vector(1)
		idt_ini _handler2,  SEL_CS, 1000111100000000b, IDT_vector(2) 
		idt_ini _handler3,  SEL_CS, 1000111100000000b, IDT_vector(3) 
		idt_ini _handler4,  SEL_CS, 1000111100000000b, IDT_vector(4) 
		idt_ini _handler5,  SEL_CS, 1000111100000000b, IDT_vector(5) 
		idt_ini _handler6,  SEL_CS, 1000111100000000b, IDT_vector(6) 
		idt_ini _handler7,  SEL_CS, 1000111100000000b, IDT_vector(7) 
		idt_ini _handler8,  SEL_CS, 1000111100000000b, IDT_vector(8) 
		idt_ini _handler9,  SEL_CS, 1000111100000000b, IDT_vector(9) 
		idt_ini _handler10, SEL_CS, 1000111100000000b, IDT_vector(10) 
		idt_ini _handler11, SEL_CS, 1000111100000000b, IDT_vector(11) 
		idt_ini _handler12, SEL_CS, 1000111100000000b, IDT_vector(12) 
		idt_ini _handler13, SEL_CS, 1000111100000000b, IDT_vector(13) 
		idt_ini _handler14, SEL_CS, 1000111100000000b, IDT_vector(14) 
		idt_ini _handler22, SEL_CS, 1000111100000000b, IDT_vector(22) 
		idt_ini _handler32, SEL_CS, 1000111000000000b, IDT_vector(32) 
		idt_ini _handler33, SEL_CS, 1000111000000000b, IDT_vector(33) 
		idt_ini _handler34, SEL_CS, 1000111000000000b, IDT_vector(34) 
		idt_ini _handler35, SEL_CS, 1000111000000000b, IDT_vector(35) 
		idt_ini _handler36, SEL_CS, 1000111000000000b, IDT_vector(36) 
		idt_ini _handler37, SEL_CS, 1000111000000000b, IDT_vector(37) 
		idt_ini _handler38, SEL_CS, 1000111000000000b, IDT_vector(38) 
		idt_ini _handler39, SEL_CS, 1000111000000000b, IDT_vector(39) 
		idt_ini _handler40, SEL_CS, 1000111000000000b, IDT_vector(40) 
		idt_ini _handler41, SEL_CS, 1000111000000000b, IDT_vector(41) 
		idt_ini _handler42, SEL_CS, 1000111000000000b, IDT_vector(42) 
		idt_ini _handler43, SEL_CS, 1000111000000000b, IDT_vector(43) 
		idt_ini _handler44, SEL_CS, 1000111000000000b, IDT_vector(44) 
		idt_ini _handler45, SEL_CS, 1000111000000000b, IDT_vector(45) 
		idt_ini _handler46, SEL_CS, 1000111000000000b, IDT_vector(46) 
		idt_ini _handler47, SEL_CS, 1000111000000000b, IDT_vector(47) 
		idt_ini _int80h, SEL_CS, 1110111000000000b, IDT_vector(128) ;80h 


		lidt [IDTR]			;cargo el IDTR con el valor limite y la direccion de inicio de la tabla      
		sti

;___________________________________________________configuro los PICs_________________________________________________________________________________________

		call		_Configurar_PICs 
		mov    		 al, 00h	; interrupciones del PIC 2
		out    		 0A1h, al

		mov al,00110100b 	;b0:	0:16bit binary 1: BCD four digit
						;b1~3:	000: mode 0 interrupt on terminal count
						;001: mode 1 hardware re-triggerable one-shot
						;010: mode 2 rate generator
						;011: mode 3	software wave generator
						;100: mode 4 software triggered strobe
						;101: mode 5 hardware triggered strobe
						;110: mode 6 rate generator, same as 010b
						;111: mode 7 square wave generator, same as 011b
						;b4~5:	00: latch count value command
						;01: access mode: lobyte only
						;10: access mode: hibyte only
						;11: access mode: lobyte/hibyte
						;b6~7:	00: channel 0
						;01: channel 1
						;10: channel 2
						;11: read-back command (8254 only)
		out 43h,al
		mov ax,11918		; 1ms
		out 40h,al
		mov al,ah
		out 40h,al	
		
		mov    		 al, 01h		;  interrupciones del PIC 1  - int timer tick 
		out    		 21h, al

;___________________________________________________INICIALIZACION DE TABLAS DE PAGINACION_________________________________________________________________________________________

;ABI32 void _zero_me(inicio, fin)
;pongo en cero la seccion ya que el handler correspondiente comprara las entradas contra 0 para saber si hay que asignar entradas en los
;distintos niveles o page tables nuevas...
push 0205000h; final
push 0200000h; inicio
call _zero_me
add esp, 8;quito del stack los parametros


 
		mov 		edi, 0200000h; dir fisica de mi directorio = a mi lineal por ahora
		mov 		cr3, edi; 
		mov 		dword [edi], 0201000h+PT_P+PT_RW+PT_A+PT_U; cargo la primer entrada 
		
		mov eax, 0x0
		mov ebx, 0x0
		.fill_table:
		      mov ecx, ebx
		      add ecx, PT_P+PT_RW+PT_A+PT_U
		      mov [0201000h+eax*4], ecx ; mapeo primeros 4mb
		      add ebx, 4096
		      inc eax
		      cmp eax, 1024
		      je .end
		      jmp .fill_table
		.end:


		  
push 0200000h
push 0100000h
call _page_me
add esp, 8;quito del stack los parametros



;activo paginacion
		xchg bx,bx

		mov eax, cr0
		or eax, 0x80000001
		mov cr0, eax


  
		





;___________________________________________________TASK SWITCHING AUTOMATICO______________________________________________________________________________________

;cargo tres task gate 
;Nombre y numero de argumentos:|1= base| |2=limite| |3=8 bits de Propiedades P- DP-010B1| |4= 4 bits de prop| |5=Entrada en la tabla|
		gdtdescini _TSS_kernel,  0x67,	10001001b, 	0001b, 	GDT_vector(5); 
		gdtdescini _TSS1, 	 0x67,	10001001b, 	0001b, 	GDT_vector(6); dpl 00 el kernel switchea
		gdtdescini _TSS2, 	 0x67,	10001001b, 	0001b, 	GDT_vector(7); dpl 00 el kernel switchea
		gdtdescini _TSS3, 	 0x67,	10001001b, 	0001b, 	GDT_vector(8); dpl 00 el kernel switchea


		;en TR cargar el TSS de la tarea actual, kernel (main) la cargo ahora antes de activar el timer tick
		xor		eax,eax
		mov		eax,TSS_kernel_index
			ltr	ax
		
		ini_tss_table  tss_vector(0) , SEL_DATOS , SEL_CS ,PILA , main , 0x246 , PILA;eflags con interrupciones

		
		mov eax , SEL_CS_USER
		or eax , 11b;
		
		mov ebx , SEL_DATOS_USER
		or ebx, 11b
		;1 y 2 de usuario
		;TAREA 1
		ini_tss_table  tss_vector(1) , bx , ax ,PILA1 , tarea1 , 0x246 , PILA1_00;eflags con interrupciones,lo lei del bochs

		;TAREA 2
		ini_tss_table  tss_vector(2) , bx , ax ,PILA2 , tarea2 , 0x246 , PILA2_00

		;3 nivel 00
		;TAREA 3
		ini_tss_table  tss_vector(3) , SEL_DATOS , SEL_CS ,PILA3_00 , tarea3 , 0x246, PILA3_00
		
		; activo la #NM para atender el switch de los registros XMM0 que usan las tareas
		mov eax, cr0
		and al, 11111011b; cr0.em=0;
		mov cr0, eax
		mov eax, cr4
		or ah, 00000010b; cr4.osfxsr=1;
		mov cr4, eax


;___________________________________________________ENTREGO CONTROL AL main______________________________________________________________________________________

control_to_main:;(KERNEL IDLE TASK)
		pushf
		mov 		eax, SEL_CS;
		push 		eax
		
		mov  		eax,main
		push 		eax
		mov    		 al, 00h		;  interrupciones del PIC 1  - int timer tick 
		out    		 21h, al
		iret

__SECT__


;RESERVO LUGAR PARA EL STACK
[section .pilas_level_00]
align 4096
_INI_PILA:
		times 1024 dd 0; 4k
PILA	equ	$

_INI_PILA1_00:
		times 1024 dd 0; 4k
PILA1_00	equ	$

_INI_PILA2_00:
		times 1024 dd 0; 4k
PILA2_00	equ	$

_INI_PILA3_00:
		times 1024 dd 0; 4k
PILA3_00	equ	$

__SECT__


[section .resto_del_kernel]

;***************
;void _ini_pant(void)
;32 bits
;ESTA FUNCION INICIALIZA LA PANTALLA, SIN PARAMETROS NI RETORNO: UNA VERSION MAS ELEMENTAL SIN PUSH NI POPS ES _kernel_clear_pant
;***************
_init_pant:
	pushfd
	push eax
	push ecx
	push edi
	cld; clear direction flag
	mov ax, 0x7020; fondo negro letra blanca
	mov edi, MEM_VIDEO;registro de destino
	mov ecx, CANT_COLUMNAS*CANT_FILAS
	rep stosw; va con ax , edi y ecx
	pop edi
	pop ecx
	pop eax
	popfd
ret


;***************
;ABI32 void _zero_me(inicio, fin)
;32 bits
;***************
_zero_me:
push ebp
mov ebp, esp
push eax
push edi
pushfd

cld;al derecho

mov eax, 0;
mov edi, [ebp+8];
.loop_:
stosw
cmp edi, [ebp+12]
js .loop_

popfd
pop edi
pop eax
pop ebp
ret


;***************
;ABI32 void _page_me(lineal, fisica)
;32 bits
;se llama antes de activar paginacion
;***************

_page_me:
    push ebp
    mov ebp, esp
    sub  esp, 8; lugar para 2 offset 
    push eax
    push edi
    push esi
    pushfd
    

;obtengo los offset de los 2 niveles
mov 	eax, [ebp+8];
shr 	eax, 22 ; offset en el level1
mov 	[ebp-4],eax;guardo el offset del segundo nivel

mov 	eax, [ebp+8];
shr 	eax, 12;offset del page_table nivel
and 	eax,01111111111b
mov 	[ebp-8],eax;
	    

;¿esta cargado el segundo nivel?
mov 	eax, [ebp-4];el offset del segundo nivel
mov 	edi,  [0200000h+4*eax]; 
mov 	ecx, edi
and	edi, 0xfffff000
or 	ecx,ecx;
jnz 	.level_1

;no existia, entonces hay que hacer la entrada en _PAGE_DIRECTORY
mov 	ebx, 0202000h ; desde aca agrego tablas de paginas
mov 	eax, [veces_directorio]
mov 	edx, 4096 ;miltiplica edx con eax y guarda en eax
mul 	edx; miltiplica edx con eax y guarda en eax
add 	ebx, eax; ebx=  _PAGE_TABLE_PF + veces_directorio * 4096
mov 	edi, ebx
add 	ebx, PT_P+PT_RW+PT_U
mov  	eax, [ebp-4];el offset del primer nivel
mov 	[0200000h+4*eax], ebx
add 	dword[veces_directorio],1;


.level_1:
		
		
		mov ebx, [ebp+12];fisica
		and ebx, 0xfffff000  ;alineada a 4k
		mov eax, [ebp-8]; offset del page_table nivel
		add ebx, PT_P+PT_RW+PT_U
		mov [edi+4*eax], ebx

	popfd
	pop esi
	pop edi	
	pop eax	
	mov esp, ebp; elimino varibles locales
	pop ebp;

ret
    




;***************
;ABI32 void _copy_me(principio, fin, destino)
;32 bits
;***************
_copy_me:
    push ebp
    mov ebp, esp
    push eax
    push edi
    push esi
    pushfd
    
    mov edi, [ebp+14];mi destino
    mov esi, [ebp+8];mi principio
    mov eax, [ebp+12];mi final
    .loop2:
      movsb
      cmp esi, eax
    js .loop2 
	popfd
	pop esi
	pop edi	
	pop eax	
	pop ebp;
ret
    

;***************
;ABI32 void _print(string, columna, fila, color)
;32 bits
;***************
		
_print:
    push ebp
    mov ebp, esp
  
    push edx
    push eax
    push ecx
    push edi
    push esi
    pushfd
    
    cld;al derecho
    mov esi, [ebp+8];mi string
    ;armo mi destino: [ MEM_VIDEO+2*[(fila)*80+(columna)]] inicio del word a escribir
    mov eax, [ebp+16];la fila
    mov edx,80
    mul edx; miltiplica edx con eax y guarda en eax
    mov edx,eax
    add edx,[ebp+12];el valor de la columna
    shl edx,1; multiplico por 2 porque son words
    add edx, MEM_VIDEO    
    mov edi, edx;



      mov ah,  [ebp+20]; el color en la parte alta
	.loop1:
  		mov al, byte [esi]; cargo el caracter en la parte baja
  		mov [edi], ax;guardo en el buffer de pantalla el caracter y su color
  		inc esi
		add edi, 2; el word que sigue
		cmp byte [esi],10; si es igual a null termino
        jne .loop1

    
    ;restauro valors
	popfd
	pop esi
	pop edi
	pop ecx
	pop eax
	pop edx
	mov esp, ebp; elimino locales
	pop ebp;
ret
__SECT__

[section .text]
_Configurar_PICs:

;ICW1 - PIC1
		  mov		al,011h          				;IRQs activas x flanco, cascada, y ICW4
		  out		020h,al  
;ICW2 - PIC1
		  mov     	al,020h           				;El PIC1 arranca en INT tipo (BH)
		  out     	021h,al
;ICW3 - PIC1
		  mov     	al,04h          				;PIC1 Master, Slave ingresa Int.x IRQ2
		  out     	021h,al
;ICW4 - PIC1
		  mov     	al,01h          				;Modo 8086
		  out     	021h,al

		  mov     	al,0FFh						;Deshabilito interrupciones del PIC1 antes de configurar el PIC2
		  out     	021h,al

;ICW1 - PIC2
		  mov     	al,011h          				;IRQs activas x flanco,cascada, y ICW4
		  out     	0A0h,al
;ICW2 - PIC2
		  mov    	al,028h           				;El PIC2 arranca en INT tipo (BL)
		  out     	0A1h,al
;ICW3 - PIC2
		  mov     	al,02h          				;PIC2 Slave, ingresa Int x IRQ2
		  out     	0A1h,al
;ICW4 - PIC2
		  mov     	al,01h          				;Modo 8086
		  out     	0A1h,al

		  mov     	al,0FFh						;Interrupciones del PIC2 Enmascaradas
		  out     	0A1h,al

		  mov     	al,0FDh						;Habilito las Interrupciones Deseadas: Teclado
		  out     	021h,al

		  ret
		  
__SECT__

[section .data]

COLOR_HANDLER equ 3 
P_MODE equ 0x1 ;define para realizar la mascara con el registro CR0
ESC_TECLA Equ 0x01;define de la tecla esc
BUFFER_TECLADO equ 0x60

;Mensajes de endtrada a Handlers
MSG1_HANDLER:
	db '___________________Bienvenido al handler_________________________',10
	
MSG_HANDLER_ESC:
	db '___________________ESCAPE PRESIONADA_____________________________',10
align 16;
MSG_HND_TABLE:
       db '____hnd: 00____',10
       db '____hnd: 01____',10
       db '____hnd: 02____',10
       db '____hnd: 03____',10
       db '____hnd: 04____',10
       db '____hnd: 05____',10
       db '____hnd: 06____',10
       db '____hnd: 07____',10
       db '____hnd: 08____',10
       db '____hnd: 09____',10
       db '____hnd: 10____',10
       db '____hnd: 11____',10
       db '____hnd: 12____',10
       db '____hnd: 13____',10
       db '____hnd: 14____',10

MSG_INT_TABLE:
       db '____irq: 00____',10
       db '____irq: 01____',10
       db '____irq: 02____',10
       db '____irq: 03____',10
       db '____irq: 04____',10
       db '____irq: 05____',10
       db '____irq: 06____',10
       db '____irq: 07____',10
       db '____irq: 08____',10
       db '____irq: 09____',10
       db '____irq: 10____',10
       db '____irq: 11____',10
       db '____irq: 12____',10
       db '____irq: 13____',10
       db '____irq: 14____',10
       db '____irq: 15____',10
__SECT__


[section .resto_del_kernel]

;____________________________________________________________________________________________________________________________________________________________________________
_handler0:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 

call _kernel_print

mov esi, MSG_HND_TABLE

call _kernel_print

hlt

iret
;____________________________________________________________________________________________________________________________________________________________________________
_handler1:

call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_HND_TABLE+16
call _kernel_print
hlt
iret



;____________________________________________________________________________________________________________________________________________________________________________
_handler2:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_HND_TABLE+32
call _kernel_print
hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________
_handler3:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_HND_TABLE+48
call _kernel_print
hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________
_handler4:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_HND_TABLE+64
call _kernel_print
hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________
_handler5:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_HND_TABLE+80
call _kernel_print
hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________
_handler6:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_HND_TABLE+96
call _kernel_print
hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________
_handler7:
;Hace uso de esta interrupcion, es decir que la tarea que uso ultima los MMX  los resguardo, si otra fuera a usar 
;estos registros entonces se haria el save and load correspondiente:
cli
push eax
push esi
    CLTS ; limpio el bit de task switch

    cmp byte[estado_tareas], 1
    jnz .go_on2

    movaps xmm0, [_TSS1_XMM0]   
    movaps xmm1, [_TSS1_XMM1]   
    jmp .salida
    
    
    .go_on2:
    cmp byte[estado_tareas], 2
    jnz .go_on3
  
    movaps xmm0, [_TSS2_XMM0]   
    movaps xmm1, [_TSS2_XMM1] 
    jmp .salida
    
    
    .go_on3:

  
    movaps xmm0, [_TSS3_XMM0]   
    movaps xmm1, [_TSS3_XMM1] 

   .salida:


pop esi
pop eax
sti
iret
;____________________________________________________________________________________________________________________________________________________________________________
_handler8:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_HND_TABLE+128
call _kernel_print
hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________
_handler9:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_HND_TABLE+144
call _kernel_print
hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________
_handler10:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_HND_TABLE+160
call _kernel_print
hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________
_handler11:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_HND_TABLE+176
call _kernel_print
hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________
_handler12:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_HND_TABLE+192
call _kernel_print

hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________
_handler13:

call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_HND_TABLE+208
call _kernel_print

hlt
iret
;___________________________________________________________________________________________________________________________________________________________________________
_handler14:

cli 
push 	ebp
mov  	ebp, esp
sub  	esp, 8; lugar para 2 offset 
;resguardo otros registros
push 	ebx
push 	eax
push 	edi
push 	esi
push 	ecx

call 	_fila;
mov 	edi, eax
mov 	esi, MSG1_HANDLER
mov 	ah,  COLOR_HANDLER; 

call 	_kernel_print;
mov 	esi, MSG_HND_TABLE+224
call 	_kernel_print;sigue donde quedo la impresion en pantalla anterior

mov	ebx, cr2;leo la direccion virtual requerida por el usuario por si cae otro page fault
mov	eax, [ebp+4];leo el code error

and	eax, 1;leo el bit de precencia del codigo
jnz	.no_presente; salta si el error no se tratase de pagina no presente


;obtengo los offset de los 2 niveles
mov 	eax, ebx;
shr 	eax, 22 ; offset en el level2
mov 	[ebp-4],eax;guardo el offset del segundo nivel

mov 	eax, ebx;
shr 	eax, 12;offset del page_table nivel
and 	eax,1111111111b
mov 	[ebp-8],eax;


;¿esta cargado el segundo nivel?
mov 	eax, [ebp-4];el offset del segundo nivel
mov 	edi,  [0200000h+4*eax]; se puede leer desde CR3 para hacerlo mas general
mov 	ecx, edi
sub	edi, PT_P+PT_RW+PT_U
or 	ecx,ecx;
jnz 	.level_1

;no existia, entonces hay que hacer la entrada en _PAGE_DIRECTORY
mov 	ebx, 0202000h ; desde aca agrego tablas de paginas
mov 	eax, [veces_directorio]
mov 	edx, 4096 ;miltiplica edx con eax y guarda en eax
mul 	edx; miltiplica edx con eax y guarda en eax
add 	ebx, eax; ebx=  _PAGE_TABLE_PF + veces_directorio * 4096
mov 	edi, ebx
add 	ebx, PT_P+PT_RW+PT_U
mov  	eax, [ebp-4];el offset del segundo nivel
mov 	[0200000h+4*eax], ebx
add 	dword[veces_directorio],1;


.level_1:
		
		
		mov ebx, 0400000h ; del TP asignar fisicas desde aca
		mov eax, [veces]
		mov edx, 4096 ;miltiplica edx con eax y guarda en eax
		mul edx; miltiplica edx con eax y guarda en eax
		add ebx, eax; ebx=  00400000h + veces * 4096
	
		mov eax, [ebp-8]; offset del page_table nivel
	
		add ebx, PT_P+PT_RW+PT_U
		mov [edi+4*eax], ebx
	
		add dword[veces],1;
jmp .go_on	


.no_presente:
call 	_fila;
mov 	edi, eax
mov 	esi, PRESENT_S
mov 	ah,  COLOR_HANDLER; 
call 	_kernel_print;



.go_on:

pop 	ecx
pop	esi
pop 	edi
pop 	eax
pop 	ebx
mov 	esp, ebp; elimino varibles locales
pop 	ebp;
add 	esp,4;quito el code error
sti
iret

__SECT__

[section .data_readonly]
	
PRESENT_S:
	db ' :Error Code de pagina presente',10
__SECT__


[section .data]
veces:
    dd 0;
veces_directorio:
    dd 0;
__SECT__


[section .resto_del_kernel]
;____________________________________________________________________________________________________________________________________________________________________________

_handler22:

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE
call _kernel_print

hlt
iret

;____________________________________________________________________________________________________________________________________________________________________________
_handler32:
    cli

    pushfd
    push eax

    mov al,byte[estado_tareas]

    add byte[estado_tareas],1;
    cmp byte[estado_tareas],4
    jnz .go_on
    mov byte[estado_tareas],0
    
    mov eax, cr0
    and eax, 1000b
     ; si es 0 limpio el bit TS entonces uso los XMM 
    jnz .go1

    movaps [_TSS3_XMM1], xmm1   
    movaps [_TSS3_XMM0], xmm0   
    
    .go1:
    
    mov al, 20h
    out 20h, al
    jmp TSS_kernel_index:0 ; la proxima vez que regrese esta tarea entrara por acá + 1
    jmp .salida
    
    
    .go_on:
    cmp byte[estado_tareas], 1
    jnz .go_on2
    ;kernel IDLE fue la anterior no usa XMM

    mov al, 20h
    out 20h, al
    jmp TSS1:0 ; la proxima vez que regrese esta tarea entrara por acá + 1
    jmp .salida
    
    
    .go_on2:
    cmp byte[estado_tareas], 2
    jnz .go_on3
    
    mov eax, cr0
    and eax, 1000b
    ; si es 0 limpio el bit TS entonces uso los XMM 
    jnz .go2

    movaps [_TSS1_XMM1], xmm1   
    movaps [_TSS1_XMM0], xmm0 
    
    .go2:
    
    mov al, 20h
    out 20h, al
    jmp TSS2:0 ; la proxima vez que regrese esta tarea entrara por acá + 1
    jmp .salida
    
    
    .go_on3:
    
     mov eax, cr0
    and eax, 1000b
    ; si es 0 limpio el bit TS entonces uso los XMM 
    jnz .go3
    movaps [_TSS2_XMM1], xmm1   
    movaps [_TSS2_XMM0], xmm0  
    
    .go3:
    
    mov al, 20h
    out 20h, al
    jmp TSS3:0 ; la proxima vez que regrese esta tarea entrara por acá + 1

   .salida:
    pop eax
    popfd

    sti
    iret
__SECT__
    
[section .data]
estado_tareas:
db 0;
__SECT__

;____________________________________________________________________________________________________________________________________________________________________________
[section .resto_del_kernel]


_handler33:
cli
push eax
push ebx
push esi
push edi
in al,BUFFER_TECLADO; Leo el Buffer en la parte baja de al



cmp byte [STATE], STAND_BY
jnz .next
;______________________________Tecla presionada cuando estaba en stand-by. Analizo las de interes y cambio de estado
cmp al,0x19;P make code	;|
jnz .stand1			;|
mov byte [STATE],P_PRESS	;|
jmp .go_on			;|
				;|
.stand1:			;|
cmp al,0x22;G make code	;|
jnz .stand2			;|
mov byte [STATE],G_PRESS	;|
jmp .go_on			;|
				;|
				;|
.stand2:			;|
cmp al,0x20;D make code	;|
jnz .stand3			;|
mov byte [STATE],D_PRESS	;|
jmp .go_on			;|
				;|
.stand3:			;|
cmp al,0x16;U make code	;|
jnz .stand4			;|
mov byte [STATE],U_PRESS	;|
jmp .go_on			;|
				;|
.stand4:			;|
cmp al,0x12;E make code	;|
jnz .next4_esc			;|
mov byte [STATE],E_PRESS	;|
jmp .go_on			;|
;_______________________________;|


.next:
cmp byte [STATE], P_PRESS
jnz .next0
				;|
cmp al,0x99;  relase		;|
jnz .go_on			;|
mov byte [STATE],STAND_BY	;|
mov eax,[0xc7d61191]	;|
jmp .go_on			;|
;__________________________________
.next0:
cmp byte [STATE], D_PRESS
jnz .next1

cmp al,0xA0;  relase
jnz .go_on
mov byte [STATE],STAND_BY	;|			;|
idt_ini _handler14, SEL_DATOS, 1000111100000000b, IDT_vector(14)  ;invalido el selector de segmento de la interrupcion de #PG
;atajala!!			;|
mov eax,[0x538f660e]	;|	Leo una posicion que aun no esta paginada				;|
jmp .go_on		
;______________________________________


.next1:
cmp byte [STATE], G_PRESS
jnz .next2
cmp al,0xA2;  relase
jnz .go_on
mov byte [STATE],STAND_BY	;|
mov 	eax,CR0 		;|
mov	ebx,P_MODE		;|
not	ebx			;|
and  	eax,ebx			;|
mov 	CR0,eax			;|		
jmp .go_on			;|
;__________________



.next2:
cmp byte [STATE], U_PRESS
jnz .next3
cmp al,0x96;  relase
jnz .go_on
mov byte [STATE],STAND_BY	;|
pushf
mov 		eax, SEL_CS;
push 		eax
mov  		eax, 0x00 ; invalido EIP
push 		eax
iret
jmp .go_on			;|
;__________________

.next3:
cmp byte [STATE], E_PRESS
jnz .next4_esc
cmp al,0x92;  relase
jnz .go_on
mov byte [STATE],STAND_BY	;|
mov eax, 1
mov ecx, 0
div ecx                        		
jmp .go_on			;|
;__________________



				
.next4_esc:
cmp al,ESC_TECLA;Lo comparo con la tecla esc
jne .go_on ;Si no es cero no se presiono esc entonces sigo leyendo el buffer
mov edi, MEM_VIDEO
mov esi, MSG_HANDLER_ESC
mov ah,  COLOR_HANDLER; 
call _kernel_print
hlt



.go_on:
mov al,20h
out 20h,al

pop edi
pop esi
pop ebx
pop eax
sti
iret
__SECT__

[section .data_readonly]
;Equs de la maquina de estados del teclado
STAND_BY 	EQU 0
D_PRESS		EQU 1
P_PRESS 	EQU 2
E_PRESS 	EQU 3
U_PRESS 	EQU 4	
G_PRESS 	EQU 5
__SECT__


[section .data]
STATE:
db	0
__SECT__


[section .resto_del_kernel]

;____________________________________________________________________________________________________________________________________________________________________________

_handler34:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE+32
call _kernel_print

hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________

_handler35:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE+48
call _kernel_print

hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________

_handler36:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE+64
call _kernel_print

hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________

_handler37:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE+80
call _kernel_print

hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________

_handler38:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE+96
call _kernel_print

hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________

_handler39:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE+112
call _kernel_print

hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________

_handler40:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE+128
call _kernel_print

hlt
iret
;___________________________________________________________________________________________________________________________________________________________________________

_handler41:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE+144
call _kernel_print

hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________

_handler42:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE+160
call _kernel_print

hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________

_handler43:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE+176
call _kernel_print

hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________

_handler44:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE+192
call _kernel_print

hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________

_handler45:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE+208
call _kernel_print

hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________

_handler46:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE+224
call _kernel_print

hlt
iret
;____________________________________________________________________________________________________________________________________________________________________________

_handler47:
call _clear_pant

mov edi, MEM_VIDEO
mov esi, MSG1_HANDLER
mov ah,  COLOR_HANDLER; 
call _kernel_print

mov esi, MSG_INT_TABLE+240
call _kernel_print

hlt
iret

;____________________________________________________________________________________________________________________________________________________________________________
;en eax envia el servicio que desea
;en ebx el parametro del servicio

_int80h:
pushfd
push eax
push edi
push esi

cmp eax, 0 ; servicio de impresion en pantalla con eax igual a 0
jne .salida
call 	_fila; me devuelve en eax la fila ultima que imprimio
mov 	edi, eax
mov 	esi, ebx  ;parametro en ebx puntero al mensaje
mov 	ah,  COLOR_HANDLER; 
call 	_kernel_print;
jmp .salida

;otros servicios acá


.salida:
pop esi
pop edi
pop eax
popfd
iret


;________________________________funciones del kernel auxiliares____________________________________________________________________________________________________________________________________________
_kernel_print:
  .loop:
    mov al, byte [esi]; cargo el caracter en la parte baja
    mov [edi],ax;guardo en el buffer de pantalla el caracter y su color
    inc esi
    add edi, 2; el word que sigue
    cmp byte [esi],10; si es igual a null termino
  jne .loop
ret





_fila:
pushfd
push ebx
cmp byte [LINE_INDEX],25
jne .next
  mov byte [LINE_INDEX],0
  
  push edi
  push ecx
  
  cld; clear direction flag
  mov ax, 0x7020; fondo negro letra blanca
  mov edi, MEM_VIDEO;registro de destino
  mov ecx, CANT_COLUMNAS*CANT_FILAS
  rep stosw; va con ax , edi y ecx
  
  pop ecx
  pop edi
  
.next:
xor eax,eax
xor ebx,ebx
mov bl, byte [LINE_INDEX]; retorno el numero de renglon
add byte [LINE_INDEX],1;
mov eax,CANT_FILAS*2;
mul ebx
add eax,MEM_VIDEO;retorno el offset en bytes dentro del buffer de video
pop ebx
popfd
ret
__SECT__

[section .data]
LINE_INDEX:
    dd 10;	:indice para el proximo renglon libre en la pantalla
__SECT__

[section .resto_del_kernel]
_clear_pant:
	pushfd
	push edi
	push ecx
	push eax
	
	cld; clear direction flag
	mov ax, 0x7020; fondo negro letra blanca
	mov edi, MEM_VIDEO;registro de destino
	mov ecx, CANT_COLUMNAS*CANT_FILAS
	rep stosw; va con ax , edi y ecx
	mov byte[LINE_INDEX],0; actualizo el flag de linea
	
	pop eax
	pop ecx
	pop edi
	popfd
ret
__SECT__

[section .text]
BITS 16

A20_Enable:
	mov		ax, 0FFFFh		
	mov		es, ax
	cmp		word [es:7E0Eh], 0AA55h	; Chequeo si 107E0Eh coincide con 7E0Eh
	je		GateA20_Disabled		; Si coincide entonces A20 esta deshabilitada
	rol		word [7DFEh], 1h		; Modifico word en 7E0Eh
	cmp		word [es:7E0Eh], 55AAh	; Cambio tambien 107E0Eh?
	jne		GateA20_Enabled			; Si no cambio entonces A20 esta habilitada
GateA20_Disabled:
	mov		al, 0DFh				; Comando de habilitacion de A20
	call	_Gate_A20				; Habilitar Gate A20
	cmp		al, 0					; OK?
	je		GateA20_Enabled			; Si es OK continuo
Fail:
	hlt								; De lo contrario detengo el procesador
	jmp		Fail
GateA20_Enabled:
	mov		word [7DFEh], 0AA55h	; Restituyo la firma del bootloader

	ret

_Gate_A20:
	cli							; Deshabilito interrupciones mientras usa el 8042

	call  	_8042_empty?		; Ve si el buffer del 8042 está vacío
	jnz     gate_a20_exit		; No lo está => retorna con AL=2

	mov     al, 0D1h			; Comando Write port del 8042
	out     064h, al	; ...se envia al port 64h

	call    _8042_empty?		; Espera se acepte el comando
	jnz     gate_a20_exit		; Si no se acepta, retorna con AL=2

	mov     al, ah				; Pone en AL el dato a escribir
	out    	060h, al		; Lo envia al 8042
	call   	_8042_empty?		; Espera se acepte el comando

gate_a20_exit:
	ret
	
_8042_empty?:
	push   	cx               	; Salva CX
	sub    	cx, cx           	; CX = 0 : valor de time out
empty_8042_01:  
	in      al, 064h  ; Lee port de estado del 8042
	and     al, 00000010b    	; si el bit 1 esta seteado o...
	loopnz  empty_8042_01    	; no alcanzó time out, espera.
	pop    	cx               	; recupera cx
	ret                      	; retorna con AL=0, si se limpió bit 1, o AL=2 si no.
	
__SECT__