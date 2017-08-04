GLOBAL _PAGE_DIRECTORY, _PAGE_TABLE , GDT_INI ,SEL_CS ,SEL_DATOS ,SEL_CS_USER ,SEL_DATOS_USER ,IDT_INI ,GDTR ,IDTR , _PAGE_TABLE_PF , _TSS1, _TSS2, _TSS3, _TSS_kernel , TSS_kernel_index
GLOBAL TSS1, TSS2, TSS3

GLOBAL _TSS1_XMM0, _TSS1_XMM1, _TSS2_XMM0, _TSS2_XMM1, _TSS3_XMM0, _TSS3_XMM1


[section .data]
CANTIDAD_INT 	equ 128
__SECT__


;********************************************************************************
;* DATA																		 	*
;********************************************************************************
[section .tablas]
align 4096
_PAGE_DIRECTORY:
     times 1024 dd 0 

_PAGE_TABLE:
     times 1024 dd 0 

_PAGE_TABLE_PF:
     times 1024 dd 0
     ;considerar reservar mas para los #PF

     
   
__SECT__

[section .gdt_idt]
align 4
_TSS_kernel:

    times 26 dd 0;

_TSS1:
    times 26 dd 0;
    
_TSS2:
    times 26 dd 0;
    
_TSS3:
    times 26 dd 0;
;los registros XMM usare solo el xmm0 y el xmm2
align 16
_TSS1_XMM0:
	dd 4    ;xmmm0
align 16	
_TSS1_XMM1:
	dd 4    ;xmmm1
align 16	
_TSS2_XMM0:
	dd 4    ;xmmm0
align 16	
_TSS2_XMM1:
	dd 4    ;xmmm1
align 16	
_TSS3_XMM0:
	dd 4    ;xmmm0
align 16	
_TSS3_XMM1:
	dd 4    ;xmmm1
	  

align 8
dq 0
GDT_INI: 
    dq 0
    SEL_CS EQU $ - GDT_INI 
    dq 0
    SEL_DATOS EQU $ - GDT_INI 
    dq 0
    SEL_CS_USER EQU $ - GDT_INI 
    dq 0
    SEL_DATOS_USER EQU $ - GDT_INI 
    dq 0
    TSS_kernel_index EQU $ - GDT_INI 
    dq 0
    TSS1 EQU $ - GDT_INI 
    dq 0
    TSS2 EQU $ - GDT_INI 
    dq 0
    TSS3 EQU $ - GDT_INI 
    dq 0
GDT_LIM EQU $ - GDT_INI     ;obtengo el limite: direccion actual - inicio

align 8
dq 0
IDT_INI:
%rep CANTIDAD_INT
    dq 0
    dq 0
%endrep

IDT_LIM EQU $ - IDT_INI     ;obtengo el limite: direccion actual - inicio

align 4
dw 0
GDTR:
   dw GDT_LIM
   dd GDT_INI

align 4
dw 0
IDTR:
   dw IDT_LIM
   dd IDT_INI
__SECT__
