	.global inicio

	@ defineções do teclado numérico 
	.set teclado_valor,	0x90010
	.set teclado_estado,	0x90011

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@		Subrotina 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
@ Imprime no console o que esta no R1 com o tamanho de R2
print:
	mov r0, #1	
	mov r7, #4
	svc #0x55
	mov pc, lr

@ Imprime no console o \n	
printBarraN:
	mov r11, r2
	mov r2, #1
	mov r12, lr
	ldr r1, =barraN
	bl print
	ldr r1, =mensagem
	mov r2, r11
	mov pc, r12
	
@ Monitora o teclado esperando um digito, quando pressionado o r3 tem o valor da tecla 
monitoraTeclado:
	ldr r3, =teclado_estado
	ldr r3, [r3]
	tst r3, #1
	beq monitoraTeclado
	ldr r3, =teclado_valor 	
	ldr r3, [r3]
	mov pc, lr

@ Le a chave do teclado no padrão começando *(10) e terminado com #(11)
@ r4 tem o tamanho da chave	
leChave:
	mov r6, lr
esperaAsterisco:	
	bl monitoraTeclado
	cmp r3, #10			
	bne esperaAsterisco		
	mov r4, #0
	ldr r5, =chave
esperaCerquilha:
	bl monitoraTeclado
	cmp r3, #11
	moveq pc, r6
	strb r3, [r5, r4]
	add r4, #1
	b esperaCerquilha
	
@ Criptografar e descriptografar a mensagem	
criptografia:
	ldr r3, =chave
	ldr r5, =mensagem
	mov r6, #0
	mov r7, #0
whileCriptografia:
	@ carrega um caracter da chave e outro da  mensagem, em r8 e r9 da posição r6 e r7 respectivamente
	ldrb r8, [r3, r6]
	ldrb r9, [r5, r7]

	@ flag r12, se 0 criptografar, senão descriptografar 
	cmp r12, #0
	addeq r9, r8
	subne r9, r8

	@ armazena o caracter r9, na mensagem(r5) na posição r7 
	strb r9, [r5, r7]

	add r6, #1
	add r7, #1

	@ se a mensagem terminou, volta para linha aonde foi chamada
	cmp r7, r2
	moveq pc, lr

	@ zera o contador r6, quando r6 é o tamanho da chave(r4) 
	cmp r6, r4
	moveq r6, #0
	
	b whileCriptografia

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
inicio:
	bl leChave

	@ flag 
	mov r10, #0	

	@ le a mensagem do console
	mov r0, #0
	ldr r1, =mensagem
	ldr r2, =tam
	mov r7, #3
	svc #0x55
	mov r2, r0

while:	
	mov r12, #0
	bl criptografia

	cmp r10, #0
	bleq print
	bleq printBarraN
	moveq r10, #1	

	@ le a chave, e mostra a descriptografar
	bl leChave
	mov r12, #1
	bl criptografia
	bl print
	bl printBarraN
	
	b while	
fim:
	
barraN:	.ascii "\n"
mensagem:	.skip 255
chave:	 .skip 255
tam= . -mensagem
