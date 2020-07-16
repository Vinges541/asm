.686
.model flat,c


ExitProcess proto stdcall :dword

.data?

.data
.code
mainCRTStartup proc

    invoke ExitProcess,0

mainCRTStartup endp

end
