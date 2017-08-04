;estructuras---------------------------------------------------------------------------
;GDT
;defino una estructura con los elementos que describen cada segemento:
[SECTION .data]
struc   gdtd_t                   ;Definicion de la estructura denominada gdtd_t, la cual contiene los siguientes campos
       .limite:         resw 1   ;Limite del segmento bits 00-15.
       .base00_15:      resw 1   ;Direccion base del segmento bits 00-15.
       .base16_23:	resb 1   ;Direccion base del segmento bits 16-23.
       .prop:  		resb 1   ;Propiedades.
       .lim_prop:  	resb 1   ;Limite del segmento 16-19 y propiedades.
       .base24_31:	resb 1   ;Direccion base del segmento bits 24-31. 
endstruc

;***********************************************************************************************************

;IDT
;defino una estructura con los elementos que describen cada segemento:
struc   idt_t                   ;Definicion de la estructura denominada gdtd_t, la cual contiene los siguientes campos
       .offset0_15:     resw 1   ;Limite del segmento bits 00-15.
       .sel_seg:        resw 1   ;Direccion base del segmento bits 00-15.
       .prop:		resw 1   ;Direccion base del segmento bits 16-23.
       .offset16_31:	resw 1   ;Direccion base del segmento bits 24-31.
endstruc
;***********************************************************************************************************

STRUC	tss_struct      ;TSS-IA32
  .BL:		resd 1		; Back link.
  .ESP0:	resd 1		; ESP0
  .SS0:		resd 1		; SS0
  .ESP1:	resd 1		; ESP1
  .SS1:		resd 1		; SS1
  .ESP2:	resd 1		; ESP2
  .SS2:		resd 1		; SS2
  .CR3:		resd 1		; CR3
  .EIP:		resd 1		; EIP
  .EFLAGS:	resd 1		; EFLAGS
  .EAX:		resd 1		; EAX
  .ECX:		resd 1		; EBX
  .EDX:		resd 1		; ECX
  .EBX:		resd 1		; EDX
  .ESP:		resd 1		; ESP
  .EBP:		resd 1		; EBP
  .ESI:		resd 1		; ESI
  .EDI:		resd 1		; EDI
  .ES:		resd 1		; ES
  .CS:		resd 1		; CS
  .SS:		resd 1		; SS
  .DS:		resd 1		; DS
  .FS:		resd 1		; FS
  .GS:		resd 1		; GS
  .LDT		resd 1
  .IO		resd 1		;I/O MAP ADRESS - reserved - T
ENDSTRUC
__SECT__

[section .text]

;**************************************Macros*****************************************************************************************************************

;ini_tss_table  tss_vector(0) , SEL_DATOS  , SEL_CS ,PILA1 , tarea1, eflags , PILA level 00;  sola vez selectores porque son segmentos flat

%define tss_vector(x) _TSS_kernel+104*x ; regresa el componente x de la tabla

%macro ini_tss_table 7

		mov dword[%1+tss_struct.IO] ,  0xFFFF0000
		mov word[%1+tss_struct.DS]  ,  %2
		mov word[%1+tss_struct.ES]  ,  %2
		mov word[%1+tss_struct.GS]  ,  %2
		mov word[%1+tss_struct.FS]  ,  %2
		mov word[%1+tss_struct.CS]  ,  %3 
		mov dword[%1+tss_struct.ESP],  %4
		
		mov dword[%1+tss_struct.EAX],  0
		mov dword[%1+tss_struct.EBX],  0
		mov dword[%1+tss_struct.ECX],  0
		mov dword[%1+tss_struct.EDX],  0
		mov dword[%1+tss_struct.EFLAGS], %6

		mov dword[%1+tss_struct.EDI],  0
		mov dword[%1+tss_struct.ESI],  0

		mov dword[%1+tss_struct.EBP],  %4
		mov word[%1+tss_struct.SS],    %2
		mov dword[%1+tss_struct.EIP],  %5
		push eax
		mov eax, cr3
		mov [%1+tss_struct.CR3],  eax
		pop eax
		mov word[%1+tss_struct.SS2],   %2 ; mi selector de datos de nivel 0
		mov dword[%1+tss_struct.ESP2], %4 ; pila de nivel 0
		
		mov word[%1+tss_struct.SS0],   SEL_DATOS ; mi selector de datos de nivel 0
		mov dword[%1+tss_struct.ESP0], %7 ; pila de nivel 0

%endmacro





;***********GDT****************************
%define GDT_vector(x) GDT_INI+8*x ; regresa el componente x de la tabla
;Nombre y numero de argumentos:|1= base| |2=limite| |3=8 bits de Propiedades| |4= 4 bits de prop| |5=Entrada en la tabla|
%macro gdtdescini 5 
   xor ebx, ebx			   ;y se borrar para operar con el mismo
 
   mov ebx, %1			   ;Se carga EL PRIMER ARGUMENTO (la direccion) en ebx
   mov [%5+gdtd_t.base00_15], bx   ;y carga en la instancia indicada por EL QUINTO ARGUMENTO
   shr ebx, 16                             
   mov [%5+gdtd_t.base16_23], bl
   mov [%5+gdtd_t.base24_31], bh
 
   xor ebx, ebx
   mov ebx, %2			   ;Se carga EL SEGUNDO ARGUMENTO EN ebx
   mov [%5+gdtd_t.limite],bx	   ;del tamaño 
   shr ebx, 16                     ;Se adapta el restante nibble y
   mov [%5+gdtd_t.lim_prop],bl	   ;se carga en el descriptor    
 
   xor bl, bl
   mov bl, %3			   ;Se carga el primer byte
   mov [%5+gdtd_t.prop],bl	   ;de propiedades EL TERCER ARGUMENTO
 
   xor bl, bl
   mov bl, %4			   ;Se carga el nibble EL CUARTO ARGUMENTO
   shl bl, 4			   ;Se desplaza al nibble mas significativo
   or [%5+gdtd_t.lim_prop],bl	   ;Se carga en el descriptor

%endmacro
   
   
;***********************************************************************************************************


;**********IDT************************
%define IDT_vector(x) IDT_INI+8*x ; regresa el componente x de la tabla

;Nombre y numero de argumentos:1= offset 2=sel_seg 3=propierdades  4=Entrada en la tabla
%macro idt_ini 4 
   xor ebx, ebx			   ;y se borrar para operar con el mismo
 
   mov ebx, %1			   ;Se carga EL PRIMER ARGUMENTO el offset
   mov [%4+idt_t.offset0_15], bx   ;y carga en la instancia indicada por EL QUINTO ARGUMENTO
   shr ebx, 16                             
   mov [%4+idt_t.offset16_31], bx
 
   xor ebx, ebx
   mov ebx, %2			   ;Se carga EL SEGUNDO ARGUMENTO EN ebx
   mov [%4+idt_t.sel_seg],bx	   
 
   xor ebx, ebx
   mov ebx, %3
   mov [%4+idt_t.prop], bx  	   ;Cargo el word
%endmacro
;***********************************************************************************************************


__SECT__
