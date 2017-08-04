Bienvenido al repositorio!
===================
This was a Uni. projecto for learning some basics in O.S. and assambly lenguage.  
You will need BOCHS virtual machine for running it.  
It starts the machine and run different tasks on it.  

----------

# Contenidos
1. [Settings](#1)
2. [Archivos](#2)
3. [Tablas](#3)
4. [scheduler](#4)
5. [funciones de ordenamiento](#5)



**Settings** <a name="1"></a>
------------------------------------------------------
```
// desde consola
user@user:$ make   //usa nasm y ensambla  con ld arma el floppy se necesita SUDO
user@user:$ make clean   //limpia
user@user:$ bochs -q   // o tambien make bochs corre el bochs

``` 

Archivos<a name="2"></a>
-------------
archivos  | descripcion
-------- | ---
init16.asm    | codigo de inicializacion + codigo de kernel con sus repectivos handlers
main.asm    | codigo de las respectivas tareas
sys_tables.asm    | tablas del sistema: GDT, IDT , TSSs
bochsrc    | configuracion del bochs
bootsector.asm    | conf boot sector bochs
struct.asm    | estrucuras de tablas y macros de inicializacion
script.lds    | archivo para el linker LD



GDT<a name="3"></a>
-------------
Entrada  | descripcion
-------- | ---
0    | NULL SELECTOR
1    | CODIGO 32 bit DPL 00  FLAT
2    | DATOS DLP 00 FLAT
3    | CODIGO 32 bit DPL 11  FLAT
4    | DATOS bit DPL 11  FLAT
5    | TSS de Kernel IDLE
6    | TSS TAREA 1 tarea de usuario
7    | TSS TAREA 2 tarea de usuario
8    | TSS TAREA 3 tares PL 00

> **Nota:**

> - LOS DPL de las entradas de los TSS son "00" el kernel unicamente puede cambiar el contexto
> - Los selectores 6 y 7 apuntan a estructuras de TSS donde el CS y DS corresponden a 3 y 4 respectivamente. Con RPL 11


IDT
-------------

La IDT se genera con 128 entradas de las cuales las mas relevantes son, se encuentran en init16.asm

-------------
Entrada  | descripcion
-------- | ---
7    | **_handler7** #NM para atender los registros XMM
14    | **_handler14** #PF Atiende y realiza la paginacion arriva de 0400000h
32    | **_handler32** atiende la **IRQ0** del timer tick cada 1ms configurada Se coloca el scheduler ahí
33    | **_handler33** atiende la **IRQ1** buffer de teclado. Maquina de estados para generar excepciones, ECS genera HLT
128    | **_int80h** DPL 11, servicio. EAX selector de servicio. EBX parametro (ej. puntero a string a imprimir)



Scheduler<a name="4"></a>
-------------

El scheduler esta diseñado de forma muy simple, trabaja despachando tareas una atras de la otra. Hace uso del task switch automatico
que existe en modo protegido 32 bit.
El mismo scheduler controla el bit **TS** del **CR0** para saber si la tarea hizo uso de los XMM, en tal caso los resguarda.
*Soporta tres tareas +   Kernel IDLE* de forma equitativa, sin prioridad.

> **Nota:**

> - guarda los pocos XMM que usa sin necesidad de FXSAVE
> - cada tarea tiene su propio stack de nivel 00 y de nivel 11 de ser necesario


funciones de ordenamiento<a name="5"></a>
-------------

-------------
protoripo  | descripcion
-------- | ---
void _copy_me(principio, fin, destino)    | copia el contenido de un lugar de memoria a otro con tamaño = fin - principio
void _page_me(lineal, fisica)    | pagina la direccion lineal en la direccion fisica solicitada
void _zero_me(inicio, fin)    | llena de ceros el lugar en memoria desde inicio a fin. tamaño = fin - inicio
