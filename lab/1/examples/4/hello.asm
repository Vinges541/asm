.686
.model flat,c

ExitProcess proto stdcall :dword
MessageBoxA proto stdcall :dword,:dword,:dword,:dword
printf proto c :dword,:dword,:dword

.data?

.data
msg1 db "Hello",0
msg2 db "test",0
format db "%s %s",13,10,0

.code
main proc

    invoke printf,offset format,offset msg1,offset msg2
	;push offset msg2
	;push offset msg1
	;push offset format
	;call printf
	;add esp,0ch
    invoke MessageBoxA,0,offset msg1,offset msg2,0
    invoke ExitProcess,0
	;ret

main endp

end
