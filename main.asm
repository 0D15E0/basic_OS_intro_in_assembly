%ifndef MACROS_H
	%define STRUCTS_H
	%include "structs.asm"
%endif

global main , tarea1 , tarea2 , tarea3, PILA3, PILA2, PILA1
extern TSS1, TSS2, TSS3 ; selectores de las puertas de tarea



BITS 32
;___________________________________________________________________________________________________________________
[section .tarea1_code]
;tarea de nivel 11
tarea1:    
    movaps xmm0, [v1]   ;load v1 into xmm0
    movaps xmm1, [v2]   ;load v2 into xmm1
.loop:
    
    addps  xmm0, xmm1
    movaps [v3], xmm0   ;store v1 in v3
jmp .loop

__SECT__

[section .data]
align 16
    v1: dd 1.1, 2.2, 3.3, 4.4    ;first set of 4 numbers
    v2: dd 5.5, 6.6, 7.7, 8.8    ;second set
    v3: times 4 dd 0    ;result
__SECT__



[section .tarea1_stack]
align 4
_INI_PILA1:
		times 32 dd 0; 
PILA1	equ	$

__SECT__


;___________________________________________________________________________________________________________________





;tarea de nivel 11
[section .tarea2_code]
tarea2:
;quitar comentarios para probar el handler 14
;  mov eax,[0xbff2f887]
; mov eax,[0xeb6a0a6c]
;  mov eax,[0x704583ec]
  mov ecx,5
.loop:  
  mov eax, 0
  mov ebx, print
  int 80h
loop .loop
    movaps xmm0, [v4]   ;load v1 into xmm0
    movaps xmm1, [v5]   ;load v2 into xmm1

   
.loop2:

    mulps xmm0, xmm1
    movaps [v6], xmm0
jmp .loop2




__SECT__

[section .data]
print:
	db 'tarea 2 print mediante servicio INT80h 5 veces',10
align 16
    v4: dd 1.1, 2.2, 3.3, 4.4    ;first set of 4 numbers
    v5: dd 5.5, 6.6, 7.7, 8.8    ;second set
    v6: times 4 dd 0    ;result

__SECT__

[section .tarea2_stack]
align 4
_INI_PILA2:
		times 32 dd 0; 
PILA2	equ	$

__SECT__



;___________________________________________________________________________________________________________________

;tarea de nivel 00
[section .tarea3_code]
tarea3:

.loop:  
  call _waiting
jmp .loop

__SECT__


[section .tarea3_stack]
align 4
_INI_PILA3:
		times 32 dd 0; 
PILA3	equ	$

__SECT__





;___________________________________________________________________________________________________________________
[section .resto_del_kernel]
main:
.loop:
    hlt
jmp .loop



;TP7 lo que sigue
;.loop:  
;  call _waiting
  
  ;https://www.random.org/cgi-bin/randbyte?nbytes=100&format=h
  ;58 4a a5 14 a8 fd c1 92 98 5f 2c 5e e5 57 9f b7 
  ;a5 cf 3b e6 4d 4b da 94 18 a1 c9 ff de 7c d3 00 
  ;56 5c b5 75 52 15 db 68 50 02 53 8f 66 0e 5a 6e 
  ;00 77 ec 0e 0f 9b 5d d3 89 c7 d6 11 91 9e df 1a 
  ;b8 c1 5f 3c 5f c3 8f a1 c2 d8 47 bc 00 cf 99 07 
  ;99 9a 65 5f 
;  mov eax,[0xbff2f887]
;  mov eax,[0xeb6a0a6c]
;  mov eax,[0x704583ec]
;  mov eax,[0xd2c2148d]
;  mov eax,[0x9b5dd389]
;  mov eax,[0xa1c2d847]
;  mov eax,[0x77ec0e0f]
;  mov eax,[0x919edf1a]
;  mov eax,[0x8fa1c2d8]
;  mov eax,[0xdb685002]

 
;jmp .loop

;hlt


_waiting:
pushfd
push esi
push edi
push eax

mov eax, dword[slow_down]
cmp eax, 0x10ff
jnz .aun_no

mov dword[slow_down],0
mov esi, waiting
mov edi,0xb8E60
mov ah,8
.print:
  mov al, byte [esi]; cargo el caracter en la parte baja
  mov [edi], ax;guardo en el buffer de pantalla el caracter y su color
  inc esi
  add edi, 2; el word que sigue
  cmp byte [esi],10; si es igual a null termino
jne .print


mov edi, 0xb8F00 ; ultima linea
add edi, dword [count]
cmp edi,0xb8f4f
jnz .go
mov edi, 0xb8F00 ; ultima linea
mov dword[count],0
.go:
mov ah, 8; color
mov al, [dot];
mov [edi],ax
sub byte[count],2
mov edi, 0xb8f00 ; ultima linea
add edi, dword [count]
mov ah, 8; color
mov al, [line];
mov [edi],ax
add byte[count],4

.aun_no:
add eax,1
mov [slow_down],eax
pop eax
pop edi
pop esi
popfd

ret

[section .data]
waiting:
db 'NOW WAITING...',10

slow_down:
dd 0;

count:
dd 2

dot:
db 'X'

line:
db '-'
__SECT__


