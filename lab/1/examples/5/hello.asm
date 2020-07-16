.686
.model flat,c

include c:\masm32\include\msvcrt.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc



.data
db 1

.const
msg1 db "Hello",0
msg2 db "test",0
format db "%s %s",13,10,0

.code
main proc

    invoke crt_printf,offset format,offset msg1,offset msg2
    invoke MessageBoxA,0,offset msg1,offset msg2,0
    invoke ExitProcess,0

main endp

end