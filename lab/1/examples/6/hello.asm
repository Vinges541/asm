.686
.model flat,c

fun1 proto c :dword, :dword
printf proto c :vararg

.data?

.data
msg1 db "Hello",0
msg2 db "world",0
format db "%s %s",13,10,0

.code
main proc

    invoke printf,offset format,offset msg1,offset msg2
	invoke fun1, 57, 113

	ret
	
main endp

fun2 proc

fun2 endp

end