ENTRY(_ORIGEN)

SECTIONS { 

        .text 0x8000 : { inti_code_rom_start = . ; *(.text); _etext = . ;}
                
        
         gdt_idt : AT (  _etext )  { _sgdt_idt = . ; *(.gdt_idt) ;  _egdt_idt = . ;}
        
        .resto_del_kernel : AT (  _egdt_idt )  { _sresto_del_kernel = . ; *(.resto_del_kernel) ;  _eresto_del_kernel = . ;}

        .pilas_level_00 : AT (  _eresto_del_kernel )  { _ssatack = . ; *(.pilas_level_00) ;  _estack  = . ;}

        .data : AT (  _estack )  { _sdata = . ; *(.data) ;  _edata  = . ;}
        
        .data_readonly : AT (  _edata )  { _sdata_readonly = . ; *(.data_readonly) ;  _edata_readonly  = . ;}
        
        .tarea3_code : AT ( _edata_readonly ) { _starea3_code = . ; *(.tarea3_code) ;  _etarea3_code  = . ;}
        
        .tarea2_code : AT ( _etarea3_code ) { _starea2_code = . ; *(.tarea2_code) ;  _etarea2_code  = . ;}
        
        .tarea1_code : AT ( _etarea2_code ) { _starea1_code = . ; *(.tarea1_code) ;  _etarea1_code  = . ;}
                
        .tarea1_stack : AT ( _etarea1_code ) { _starea1_stack = . ; *(.tarea1_stack) ;  _etarea1_stack  = . ;}
        
        .tarea2_stack : AT ( _etarea1_stack ) { _starea2_stack = . ; *(.tarea2_stack) ;  _etarea2_stack  = . ;}
        
        .tarea3_stack : AT ( _etarea2_stack ) { _starea3_stack = . ; *(.tarea3_stack) ;  _etarea3_stack  = . ;}
        
         . = 0x100000;
                      
        .tablas 0x100000:  AT (  _etarea3_stack )  { _stablas = . ; *(.tablas) ;  _etablas  = . ;}
        
         _end = _etablas ; 


}


