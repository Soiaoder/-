STKSEG SEGMENT STACK
STKSEG ENDS

DATASEG SEGMENT
	QUESTION DB "WHAT IS THE DATE?(MM/DD/YY)$"
    MONTH DW 0
    DAY DW 0
    TEMP DW 0 
    YEAR DW 0
DATASEG ENDS

STACKSEG SEGMENT
STACKSEG ENDS
CODESEG SEGMENT
	ASSUME CS:CODESEG,DS:DATASEG,SS:STACKSEG
    
START:
    MOV AX,DATASEG
    MOV DS,AX
    MOV AX,STACKSEG
    MOV SS,AX
    ;打印问题
    MOV DX,OFFSET QUESTION
    MOV AH,9
    INT 21H
    MOV AH,2
    MOV DL,10
    INT 21H

    ;输出响铃字符
    MOV DL,7
    MOV AH,02H
    INT 21H

    ;调用GetNum，接受键入的月日年值
    CALL GetNum
    
    ;将year赋值给temp，让temp在disp中进行操作
    MOV AX,YEAR
    MOV TEMP,AX
    ;调用Disp显示年值
    CALL Disp
    ;打印-
    MOV DL,'-'
    MOV AH,02H
    INT 21H

    ;将MONTH赋值给temp，让temp在disp中进行操作
    MOV AX,MONTH
    MOV TEMP,AX
    ;调用Disp显示月值
    CALL Disp
    ;打印-
    MOV DL,'-'
    MOV AH,02H
    INT 21H

    ;将DAY赋值给temp，让temp在disp中进行操作
    MOV AX,DAY
    MOV TEMP,AX
    ;调用Disp显示日值
    CALL Disp

    MOV AX,4C00H
    int 21H
GetNum:
    ;记录月
    M:
    MOV AH,01H
    INT 21H
    MOV AH,0
    CMP AL,'/'
    JZ  D
    SUB AL,30H;因为输入是字符，要-30H,
    MOV CL,AL;将输入的值暂存在cl中
    MOV AX,MONTH;MONTH=MONTH*10+CL
    MOV BL,10
    MUL BL
    ADD AL,CL
    MOV MONTH,AX
    JMP M

    ;记录日
    D:
    MOV AH,01H
    INT 21H
    MOV AH,0
    CMP AL,'/'
    JZ  Y
    SUB AL,30H;因为输入是字符，要-30H,
    MOV CL,AL
    MOV AX,DAY
    MOV BL,10
    MUL BL
    ADD AL,CL
    MOV DAY,AX
    JMP D

    ;记录年
    Y:
    MOV AH,01H
    INT 21H
    MOV AH,0
    CMP AL,0DH
    JZ  OVER
    SUB AL,30H;因为输入是字符，要-30H,
    MOV CL,AL
    MOV AX,YEAR
    MOV BL,10
    MUL BL
    ADD AL,CL
    MOV YEAR,AX
    JMP Y

    OVER:
    RET

Disp:
    MOV BX,OFFSET TEMP
    MOV SI,1
    MOV AX,TEMP
    ;提取千位
    MOV DX,0
    MOV CX,1000
    DIV CX ;cx为16位，被除数为DXAX，商放在ax里，余数放在dx里
    MOV [BX][SI],AX
    INC SI

    ;提取百位  
    MOV AX,DX
    MOV DX,0
    MOV CX,100 ;cx为16位，被除数为DXax，商放在ax里，余数放在dx里
    DIV CX
    MOV [BX][SI],AX
    INC SI

    ;提取十位
    MOV AX,DX
    MOV DX,0
    MOV CX,10
    DIV CX;cx为16位，被除数为DXax，商放在ax里，余数放在dx里
    MOV [BX][SI],AX
    INC SI

    ;提取个位
    MOV [BX][SI],DX
 
    ;判断首位不为零
    MOV CX,4
    MOV SI,1
    L1:
    MOV DX,[BX][SI]
    CMP DL,0
    JNZ OUTPUT
    INC SI
    LOOP L1

    OUTPUT:
    MOV CX,5
    SUB CX,SI
    MOV AH,02H
    L2:
    MOV DX,[BX][SI]
    ADD DL,30H
    INT 21H
    INC SI
    LOOP L2

    RET

CODESEG ENDS
END START
