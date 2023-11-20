stack segment
  dw 32 dup(0)    ;64个字节.32个push位
stack ends
data segment
    ;以下是表示21年的21个字符串
    db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
    db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
    db '1993','1994','1995'
        
    ;以下是表示21年公司总收的21个dword型数据
    dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
    dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
        
    ;以下是表示21年公司雇员人数的21个word型数据
    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
    dw 11542,14430,45257,17800
data ends
str segment        
    dw 8 dup(0)    ;16个字节，将每一个数据转为十进制字符形式，存到这里
    dw 8 dup(0)    ;16个字节，存放指定的屏幕显示行号字节、列号字节、字符属性字节
str ends
table segment
    db 21 dup('year summ ne ?? ')
table ends

CODESEG SEGMENT
    ASSUME CS:CODESEG
START:
    mov ax,stack        ;设置栈顶
    mov ss,ax
    mov sp,40H
    MOV AX,DATA;段寄存器DS指向段data
    MOV DS,AX
    MOV AX,table;附加段寄存器ES指向段data
    MOV ES,AX
    mov si,0
	mov di,0
	mov bp,0
	mov cx,21
;第一问，将数据放入table中
S1:
    CALL MOVEYEAR ;移动年份
    CALL MOVESALARY ;移动工资
    CALL MOVECOUNT ;移动雇员人数
    CALL AVERAGE ;计算平均工资并放入对应数据段
    add si,4				;每次偏移4个字节从data段中取数据
	add di,2				;每次偏移2个字节从data段中取数据
	add bx,16				;每次偏移16个字节写入下一行数据
	loop S1
    
;第二问，输出信息
    call makeblack
    mov bx,str    ;设置ds指向str段
    mov ds,bx
    mov dl,03H    ;指定在屏幕上开始显示的行号
    mov ds:[10H],dl   ;存到str段中
    mov dl,05H    ;指定在屏幕上开始显示的列号
    mov ds:[11H],dl    ;存到str段中
    mov cl,2        ;显示的字符的属性字节 00000010b 绿色
    mov ds:[12H],cl    ;存到str段中
    mov bx,0        ;table段中当年数据的起始地址
    mov si,0        ;转换成字符后的数据从str哪个地址开始存
    MOV CX,21;以年为单位进行输出
S2:
    CALL PRINT
    loop S2

    MOV AX,4C00H
    int 21H



MOVEYEAR:
    mov ax,ds:[si]
	mov es:[bx],ax 			;先移动前两个字节
	mov ax,ds:[si+2]
	mov es:[bx+2],ax		;再移动后两个字节
    RET
MOVESALARY:
    mov ax,ds:[84+si]		;84是数据段中存放收入内存相对于存放年份的偏移	
	mov es:[bx+5],ax 		;5是表格段中存放收入内存相对于存放年份的偏移，先移动前两个字节
	mov ax,ds:[84+si+2]
	mov es:[bx+5+2],ax		;再移动后两个字节

    RET
MOVECOUNT:
    mov ax,ds:[168+di]		;168是数据段中存放收入内存相对于存放年份的偏移	
	mov es:[bx+10],ax		;10是表格段中存放收入内存相对于存放年份的偏移，每次处理两个字节
    RET
AVERAGE:
    mov ax,ds:[84+si]		;AX存放低16位
	mov dx,ds:[84+si+2]		;DX存放高16位
	div word ptr ds:[168+di];word ptr指定除法运算的数值为16位，且结果存放在AX中（不考虑余数）
	mov es:[bx+13],ax		;存入表格中
    RET

PRINT:
    push cx

    ;输出年份
    mov di,0        ;table段中当前该存每年第N个字节的数据
    mov ax,es:[bx+di]    ;取年份数据的前两个字节的数据  
    mov ds:[0],ax        ;将年份数据存入str段
    add di,2
    mov dx,es:[bx+di]    ;取年份数据的高两个字节的数据
    add di,2
    mov ds:[2],dx
    mov byte ptr ds:[4],0    ;以0作为结尾符

    mov dh,ds:[10H]    ;从str段中取出指定的显示起始行号
    mov dl,ds:[11H]    ;从str段中取出指定的显示起始列号
    mov cl,ds:[12H]    ;从str段中取出指定的显示字符的属性字节
    call show_str    ;调用子程序，将str段中的十进制数据显示在屏幕指定位置

    inc di

    ;输出总工资
    mov ax,es:[bx+di]    ;取年总收入的低16位数据
    add di,2
    mov dx,es:[bx+di]    ;取年总收入的高16位数据
    add di,2   
    call dtoc_dword    ;调用子程序，将dword型数据转为十进制，存入str段中指定位置
 
    mov dh,ds:[10H]    ;从str段中取出指定的显示起始行号
    mov dl,ds:[11H]    ;从str段中取出指定的显示起始列号
    add dl,0aH        ;上一项数据占10列
    mov cl,ds:[12H]    ;从str段中取出指定的显示字符的属性字节
    call show_str    ;调用子程序，将str段中的十进制数据显示在屏幕指定位置

    inc di
    ;输出雇员人数
    mov ax,es:[bx+di]
    add di,2
    mov dx,0
    call dtoc_dword    ;调用子程序，将dword型数据转为十进制，存入str段中指定位置
 
    mov dh,ds:[10H]    ;从str段中取出指定的显示起始行号
    mov dl,ds:[11H]    ;从str段中取出指定的显示起始列号
    add dl,14H        ;上一项数据再占10列
    mov cl,ds:[12H]    ;从str段中取出指定的显示字符的属性字节
    
    call show_str    ;调用子程序，将str段中的十进制数据显示在屏幕指定位置

    inc di            
    ;输出平均收入
    mov ax,es:[bx+di]
    add di,2
    mov dx,0
    call dtoc_dword    ;调用子程序，将dword型数据转为十进制，存入str段中指定位置
 
    mov dh,ds:[10H]    ;从str段中取出指定的显示起始行号
    mov dl,ds:[11H]    ;从str段中取出指定的显示起始列号
    add dl,1EH        ;上一项数据再占10列
    mov cl,ds:[12H]    ;从str段中取出指定的显示字符的属性字节
    call show_str    ;调用子程序，将str段中的十进制数据显示在屏幕指定位置

    add bx,0010H        ;切换到下一年，table段中的下一行
    mov cl,ds:[10H]        ;取出当前行号
    inc cl                ;将行号+1，因为要在屏幕下一行写下一年的数据
    mov ds:[10H],cl

    pop cx

    ret
;输出字符串功能
;参数：dh 行号， dl 列号 ，cl 颜色，
show_str:
    push dx        ;将子程序用到的寄存器压入栈
    push si
    push es
    push cx
    push ax
    push bx

    mov ax,0B800H    ;设置es为显示区段地址
    mov es,ax

    mov ax,00A0H    ;设置首字符显示的地址  每行占A0H  ax*dh为行号，再加上dl*2为列，最后bx就是偏移地址（每行160字节，可输出80字符，每个字符占2个字节）
    mul dh
    mov dh,0
    add ax,dx 
    add ax,dx
    mov bx,ax    ;bx是显示区的偏移地址
        
    mov al,cl    ;用al存储属性字节
    mov ch,0
    mov si,0
    
    show:                ;循环读取字符并显示
    mov cl,ds:[si]
    jcxz showpop            ;若读到0，就退出循环
    mov es:[bx],cl
    inc bx
    mov es:[bx],al
    inc bx
    inc si
    jmp show
 
    showpop:        ;将寄存器的值pop出来
    pop bx
    pop ax
    pop cx
    pop es
    pop si
    pop dx
    
    ret    ;返回


dtoc_dword:     ;功能：将dword型数据转为十进制，存入str段中
                    ;参数：ds指向str段，si指向在str段的哪个地址开始存
                    ;ax存放dword型数据的低16位，dx存放dword型数据的高16位  
                    ;返回：ds:si指向str段十进制数据的首地址                 
 
    push cx        ;将用到的寄存器压入栈
    push bx
    push si
    push ax
    push dx
    
    mov bx,0        ;bx = 压入栈的余数的个数
    pushrest:
    mov cx,000aH    ;cx = 除数 = 10
    call divdw        ;调用子程序进行除法计算，返回值：商低16位在ax，高16位在dx，余数在cx
    push cx        ;将余数压入栈
    inc bx            ;压入栈的余数个数+1
    mov cx,ax
    add cx,dx        ;商的高低16位必然都是非负数，如果和为0，那么说明商为0，则除法进行完毕
    jcxz poprest    ;若除法进行完毕，则转去将栈中余数倒序pop出来
    jmp pushrest    ;否则，就再进行一次除法
    
    poprest:        ;将栈中余数倒序pop出来，存入str段
    mov cx,bx        ;如果循环次数剩余0，就退出循环
    jcxz dtoc_over
    pop ax            ;取出一个余数
    add ax,30H        ;转为数字对应的字符
    mov ds:[si],ax    ;将该余数存入str段内存中
    inc si            
    dec bx            ;循环次数-1
    loop poprest     ;再继续取余数，转存到str段
 
    dtoc_over:
    inc si        ;都存完以后，再存个0到str段，作为结尾符
    mov byte ptr ds:[si],0  
    
    pop dx            ;将寄存器的值pop出来
    pop ax
    pop si
    pop bx
    pop cx
    
    ret

divdw:  ;功能：计算dword型被除数与word型除数的除法
        ;参数：  ax=被除数低16位，dx=被除数高16位，cx = 除数
        ;返回：  ax=商的低16位，dx=商的高16位，cx = 余数
 
        ;计算公式： X/N = int( H/N ) * 65536 + [rem( H/N) * 65536 + L]/N  
        ;其中X为被除数，N为除数，H为被除数的高16位，L为被除数的低16位，
        ;int()表示结果的商，rem()表示结果的余数。
 
        ;思路是分左右两项分别计算，然后再求和。
    
    push bx    ;bx是额外用到的寄存器，要压入栈
 
    mov bx,ax    ;bx=L
    mov ax,dx    ;ax = dx = H
    mov dx,0        ;要计算的是H/N，H和N都是16位，但CPU只能计算16/8位，因此让高位dx=0
    div cx        ;计算H/N，结果的商即int(H/N)保存在ax，余数即rem(H/N)保存在dx
                    
                    ;接下来要计算int(H/N)*65536，即ax * 65536
                    ;思考一下，65536就是0001 0000 H，
                    ;因此计算结果就是，高16位=int(H/N)=ax，低16位为0000H。
    
    push ax        ;将int(H/N)*65536结果的高16位，即int(H/N)，压入栈
    
    mov ax,0
    push ax        ;将int(H/N)*65536结果的低16位，即0000H，压入栈
                    
                    ;至此，左边项已计算完毕，且高低16位已先后入栈。
                    ;接下来要计算 rem(H/N)*65536 ，同理可得，
                    ;计算结果为 高16位=  rem(H/N) ，即此时dx的值，
                    ;低16位为 0000H。
    
    mov ax,bx        ;ax = bx = L ，而rem(H/N)*65536的低16位=0，
                    ;因此ax = bx = 即 [rem(H/N)*65536 + L]的低16位
                  ;此时dx = rem(H/N) = rem(H/N)*65536的高16位 = [rem(H/N)*65536 + L]高16位
    div cx        ;计算 [rem( H/N) * 65536 + L]/N ，结果的商保存在ax，余数保存在dx
 
                    ;至此，右边项计算完毕，商在ax中，余数在dx中。
                    ;接下来要将两项求和。  左边项的高、低16位都在栈中，
                    ;其中高16位就是最终结果的高16位，低16位是0000H。
                    ;右边项的商为16位，在ax中，也就是最终结果的低16位，
                    ;余数在dx中，也就是最终结果的余数。
    
    mov cx,dx    ;cx = 最终结果的余数
    
    pop bx        ;bx = int(H/N)*65536结果的低16位，即0000H。
    pop dx        ;dx = int(H/N)*65536结果的高16位，即最终结果的高16位
    
    pop bx    ;还原寄存器的值
 
    ret

makeblack:			;背景色黑白相间
		push cx
		push si
		push ax
		push ds
		push bx
		
		mov ax,0b800h
		mov ds,ax
		mov cx,10					;外层循环 循环10次 置为黑白相间
		mov bx,0
b1:		push cx						;放入栈中暂存这个数据
		mov cx,80					;25*160 共4000个字节
		mov si,0
		
		
b2:		mov byte ptr [bx+si],20h			;字符设置为空格
		mov byte ptr [bx+si+1],0000000b		;背景色设置为黑色
		mov byte ptr [bx+si+160],20h		;字符设置为空格
		mov byte ptr [bx+si+161],0000000b	;背景色设置为白色 01110000b
		add si,2
		loop b2
		
		add bx,320
		pop cx
		loop b1
		
		pop bx
		pop ds
		pop ax
		pop si
		pop cx
		ret				;子程序makeblack 背景色显示调整完毕
CODESEG ENDS
END START
