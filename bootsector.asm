ORG 7C00h	; posición en memoria a la que me copia la BIOS
BITS 16		; instrucciones de 16 bits

%macro print 3
; posición, origen, cantidad

mov di, 0B800h
mov es, di
mov cx, (%3)
mov bx, 0

%%print:
	mov dl, [(%2) + ebx] 
	mov [es:(ebx*2)], dl
	mov byte [es:(ebx*2+1)], 00000100b
	inc bx
	dec cx
	jne %%print
%endmacro

%macro floppy 5
; cilindro, cabeza, sector, #sectores a leer, dirección destino

mov word [pcylinder], (%1)
mov word [phead], (%2)
mov word [psector], (%3)

mov dl, 00h	; floppy A
mov ah, 02h	; lectura
mov al, (%4)	; cantidad de sectores a leer

; Leer cilindro %1 y sector %3
;
; cx       = ---ch--- ---cl---
; cylinder : 76543210 98
; sector   :            543210
;
; ((cylinder and 255) shl 8) or ((cylinder and 768) shr 2) or sector;

xor cx, cx
mov bx, [pcylinder]
and bx, 0FFh
mov ch, bl
mov bx, [pcylinder]
and bx, 300h
sar bx, 2
or bx, [psector]
mov cl, bl

mov dh, [phead]	; cabeza
mov bx, (%5)	; segmento de destino
mov es, bx	; asignación de segmento es
xor bx, bx	; offset de destino cero
int 13h
%endmacro

%macro fat 2
; direccion base de la FAT en memoria, índice a buscar

mov dx, (%2)
mov bx, dx	; |
add dx, dx	; |
add dx, bx	; v
sar dx, 1	; dx = floor(dx * 3/2)
mov al, [FATBASE + edx]
mov ah, [FATBASE + edx + 1]
and bx, 1h
je %%even	; si el último bit es cero, el número es par
; El número es impar
shr ax, 4
jmp %%done
%%even:
and ax, 0FFFh
%%done:
%endmacro

%macro cluster_to_chs 1
; número de cluster

xor dx, dx
mov ax, (%1)
add ax, 31
; 18 sectores por cabeza, ¿cuántas cabezas tengo que leer?
mov di, 18
div di
; Deja el cociente en ax, resto en dx
mov cx, dx
inc cx
xor dx, dx
; 2 cabezas por cilindro, ¿cuántos cilindros tengo que leer?
mov di, 2
div di
; Deja el cociente en ax, resto en dx
mov bx, dx
%endmacro

%define ROOTDIRBASE	1000h
%define FATBASE		1000h
%define KERNELDIR	8000h

%define FILENAME_OFFSET	0
%define FILEEXT_OFFSET	8
%define CLUSTER_OFFSET	26

; Header FAT12
; Primeros 11 bytes ignorados, pongo el jmp al byte 61

jmp short start

TIMES 0Bh - ($ - $$) DB 0	; primeros 11 bytes que FAT12 ignora
DW 200h				; sectores de 512 bytes
DB  1h				; 1 sector por cluster
DW 1h				; cantidad de sectores reservados 1
DB  2h				; cantidad de FATs
DW 0E0h				; cantidad de entradas en Root Directory 224
DW 0B40h			; cantidad de sectores totales en el disco 2880
DB 0F0h				; modelo de disco 3.5" 1.44MB
DW 9h				; cantidad de sectores por FAT
DW 12h				; cantidad de sectores por cabeza 18
DW 2h				; cantidad de cabezas por cilindro 2
DW 0				; sectores ocultos 0
DD 0				; cantidad de sectores si fuera FAT32, va en 0
DB 0				; número de unidad
DB 0				; flags
DB 29h				; firma
DD 0FFFFFFFFh			; número de serie
DB 'TPSH        '		; etiqueta, 12 bytes relleno con espacios
DB 'FAT12   '			; formato, 8 bytes relleno con espacios

start:
jmp short nextstart

name:
DB 'KERNEL  BIN'

error:
DB "File 'kernel.bin' not found!"
enderror:

lcluster:
DW 0
pcylinder:
DW 0
phead:
DW 0
psector:
DW 0

copydir:
DW KERNELDIR >> 4

nextstart:
mov sp,5000h
; Leo el Root Directory (cilindro 0 cabeza 1 sector 2)
; y copio sus 14 sectores a la dirección indicada
floppy 0h, 1h, 2h, 14, ROOTDIRBASE >> 4

xor ecx, ecx
xor edx,edx
; Leo la primera entrada del Root Directory,
; que debería ser el archivo 'kernel.bin'
mov cx, 11	; NOMBRE.EXT -> 8+3 = 11

test_name:
	mov al, [ROOTDIRBASE + ecx - 1]
	cmp al, [name + ecx - 1]
	jne fail_name
	dec cx
	jne test_name
	jmp ok_name

fail_name:
print 0, error, enderror - error
hlt

ok_name:

; Leo el índice del primer sector del archivo
mov dx, [ROOTDIRBASE + CLUSTER_OFFSET]
mov [lcluster], dx

; Leo la FAT (cilindro 0 cabeza 0 sector 2)
; y copio sus 9 sectores a la dirección indicada
floppy 0h, 0h, 2h, 9, FATBASE >> 4

file_copy:
	mov si, [lcluster]
	cluster_to_chs si
	mov di, [copydir]
	floppy ax, bx, cx, 1, di
	mov si, [lcluster]
	fat FATBASE, si
	; Tengo en ax la entrada de la FAT para lcluster
	cmp ax, 0xFF8
	jae done_copy	; si el valor de la FAT es >= 0xFF8,
			; el cluster es el último
	mov [lcluster], ax
	add word [copydir], 512 >> 4
	jmp file_copy
done_copy:
jmp KERNELDIR

TIMES 200h - 2 - ($ - $$) DB 0	; zerofill up to 510 bytes

DW 0AA55h	; Boot Sector signature
