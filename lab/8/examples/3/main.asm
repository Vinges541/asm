;
; Модуль main.asm.
;
; Пример порождения потоков с помощью Win API
;
; Маткин Илья Александрович 09.10.2013
;

.686
.model flat, stdcall
option casemap:none

include c:\masm32\include\kernel32.inc
include c:\masm32\include\windows.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\msvcrt.inc

include Strings.mac


.data

glEvent1	dd 0
glEvent2	dd 0
glExit	dd 0
glStr	dd 0

.data?

.const

.code

ThreadStartupProc1 proc param:DWORD

	invoke crt_puts, $CTA0("thread1 start\n")
	
	.while 1
		invoke WaitForSingleObject, [glEvent1], INFINITE
		
		invoke crt_puts, $CTA0("thread1 enter string:\n")
		invoke crt_gets, [glStr]

		invoke crt_strcmp, [glStr], $CTA0("quit")
		.if eax == 0
			invoke crt_puts, $CTA0("thread1 quit loop\n")
			mov [glExit],1
			invoke SetEvent, [glEvent2]
			.break
		.endif

		invoke SetEvent, [glEvent2]
	.endw

	xor eax,eax
	ret

ThreadStartupProc1 endp



ThreadStartupProc2 proc param:DWORD

	invoke crt_puts, $CTA0("thread2 start\n")

	.while 1
		invoke WaitForSingleObject, [glEvent2], INFINITE
		.if [glExit] == 1
			invoke crt_puts, $CTA0("thread2 guit loop\n");
			.break
		.endif
		
		invoke crt_printf, $CTA0("thread2 string from thread1: %s\n"), [glStr]
		
		invoke SetEvent, [glEvent1]
	.endw

	xor eax,eax
	ret

ThreadStartupProc2 endp



main proc c argc:DWORD, argv:DWORD, envp:DWORD

	local threadId1:DWORD
	local threadId2:DWORD
	local threadHandle1:DWORD
	local threadHandle2:DWORD
	local heapHandle:DWORD
	
	invoke GetProcessHeap
	mov [heapHandle], eax
	
	invoke HeapAlloc, [heapHandle], HEAP_ZERO_MEMORY, 100
	mov [glStr], eax
	
	.if [glStr] == 0
		invoke crt_puts, $CTA0("error alloc memory\n")
		xor eax,eax
		ret
	.endif
	
	invoke CreateEvent, NULL, FALSE, FALSE, NULL
	mov [glEvent1], eax
	
	invoke CreateEvent, NULL, FALSE, FALSE, NULL
	mov [glEvent2], eax
	
	invoke CreateThread, NULL, 0, ThreadStartupProc1, 0, 0, addr [threadId1]
	mov [threadHandle1], eax
	invoke crt_printf, $CTA0("create thread1 %d\n"), [threadId1]
	
	invoke CreateThread, NULL, 0, ThreadStartupProc2, 0, 0, addr [threadId2]
	mov [threadHandle2], eax
	invoke crt_printf, $CTA0("create thread2 %d\n"), [threadId2]
	
	invoke SetEvent, [glEvent1]
	
	invoke WaitForSingleObject, [threadHandle1], INFINITE
	invoke WaitForSingleObject, [threadHandle2], INFINITE
	
	invoke crt_puts, $CTA0("end process\n")

	;invoke ExitThread, 0
	
	mov eax, 0
	ret

main endp

end
