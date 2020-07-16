.686
.model flat,c

ExitProcess proto stdcall :dword


.data?

.data

.code
main proc

    invoke ExitProcess,0

main endp

end