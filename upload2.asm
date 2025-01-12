.model small
.186
.stack 100h

maxSize                 EQU     256
cr                      EQU     0Dh
lf                      EQU     0Ah
NUMBER_WORD_TO_STORE    EQU      4
REVERSED_WORD_NUMBER    EQU      6

.data
    file                db      'RES.TXT', 0
    size_limit          db      cr, lf, 'More than 256 chars. Proccessing output.$'  
    output_message      db      cr, lf, '___OUTPUT___', cr, lf, "$"
    too_short           db      cr, lf, 'Not enough words to convert string. Exiting.$'
    input_message       db      'Enter text: ', '$'
    buffer              db      maxSize DUP(?)
.code
start:
    mov     ax, @data
    mov     ds, ax
    mov     es, ax 
    mov     ax, 3
    int     10h
    mov     ah, 9
    mov     dx, offset input_message
    int     21h  
    mov     si, OFFSET buffer
    mov     bp, si          
    mov     di, si            
    mov     al, " "
    mov     cx, maxSize+1
    mov     bl, REVERSED_WORD_NUMBER
store_byte:
    dec     cx             
    cmp     al, " "      
    je      bios_input     
    stosb
bios_input:
    mov     dh, al      
key_input:
    xor     ah, ah      
    int     16h           
    cmp     al, cr         
    je      end_of_line      
    cmp     al, " "       
    jb      key_input    
    jne     not_space     
    cmp     dh, al 
    je      bios_input    
    inc     bh 
not_space:
    mov     ah, 0Eh
    int     10h
    cmp     bh, NUMBER_WORD_TO_STORE 
    jb      to_loop 
    je      store_byte 
    stosb 
    xor     bh, bh
    dec     bl
    jnz     to_loop
    mov     si, di
to_loop:
    loop    bios_input  
    mov     ah, 9
    mov     dx, offset size_limit
    int     21h
end_of_line:
    cmp     bp, di
    jne     no_short_string
    mov     ah, 9
    mov     dx, offset too_short
    int     21h
    jmp     exit
no_short_string:
    mov     al, " "        
    cmp     byte ptr [di-1], al
    je      last_space
    stosb
last_space:
    cmp     [si], al
    jbe     output
    cmp     si, bp
    je      output
    mov     di, si
    mov     cx, FFFFh
    repne   scasb               
    dec     di
reversing:
    dec     di
    cmp     si, di
    jz      output
    lodsb
    mov     ah, [di]
    mov     [si-1], ah
    mov     [di], al
    cmp     si, di
    jne     reversing
output:
    mov     ah, 09h 
    mov     dx, offset output_message
    int     21h
    mov     ah, 3Ch
    mov     dx, offset file
    xor     cx, cx
    int     21h
    mov     bx, ax
    mov     ax, 4000h
    mov     dx, bp
    mov     di, dx
    mov     cx, 0ffffh
    repne   scasb
    not     cx
    dec     cx
    dec     cx
    int     21h   
    mov     ah, 3Eh
    int     21h
    mov     ah, 40h
    mov     bx, 1 
    int     21h  
exit:
    xor     ah, ah
    int     16h 
    mov     ax, 4C00h      
    int     21h
    END     start
