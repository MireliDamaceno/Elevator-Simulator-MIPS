#SIMULACAO DE 2 ELEVADORES
#Botoes de chamamada: 1-8
#Botoes de destino E1: qwertyui
#Botoes de destino E2: asdfghjk
#Botao de bloqueio E1: z
#Botao de desbloqueio E1: x
#Botao de bloqueio E2: c
#Botao de desbloqueio E2: v

.data
	arquivo: .asciiz "log.txt"  #arquivo pra gravacao de dados dos elevadores	
	conteudo_fim:
	#mensagens
	msgPulaLinha: .asciiz "\n"
	msgEspaco: .asciiz " "
	msgInicial: .asciiz "\n\nTem alguma requisição para os elevadores? Digite s ou n e pressione enter."
	msgRequisicao: .asciiz "\nDigite a requisição e pressione enter:"
	msgFim: .asciiz "\nFim das requisições."
	msgBloqueiaE1: "\nO elevador 1 foi bloqueado"
	msgBloqueiaE2:"\nO elevador 2 foi bloqueado"
	msgDesbloqueiaE1: "\nO elevador 1 foi desbloqueado"
	msgDesbloqueiaE2: "\nO elevador 2 foi desbloqueado"
	msgAlerta1: .asciiz "\nImpossível bloquear o elevador 1, pois o elevador 2 já está bloqueado"
	msgAlerta2: .asciiz "\nImpossível bloquear o elevador 2, pois o elevador 1 já está bloqueado"
	msgAviso1: .asciiz "\nO elevador 1 já está desbloqueado"
	msgAviso2: .asciiz "\nO elevador 2 já está desbloqueado"
	msgMovimentoFechada1: .asciiz "\nelevador 1 em movimento, porta fechada"
	msgMovimentoFechada2: .asciiz "\nelevador 2 em movimento, porta fechada"
	msgParadoAberta1: .asciiz "\nelevador 1 parado, porta aberta"
	msgParadoAberta2: .asciiz "\nelevador 2 parado, porta aberta"
	msgSubiu1: .asciiz "\nO elevador 1 subiu 1 andar"
	msgSubiu2: .asciiz "\nO elevador 2 subiu 1 andar"
	msgDesceu1: .asciiz "\nO elevador 1 desceu 1 andar"
	msgDesceu2:.asciiz "\nO elevador 2 desceu 1 andar"
	msgAndarAtual1: .asciiz "\nAndar atual do elevador 1: "
	msgAndarAtual2: .asciiz "\nAndar atual do elevador 2: "
	msgEmbDes1: .asciiz "\nsituação de embarque/desembarque do elevador 1"
	msgEmbDes2:.asciiz "\nsituação de embarque/desembarque do elevador 2"
	msgNaoPode1: .asciiz "\nO elevador 1 está bloqueado e não pode atender essa requisição"
	msgNaoPode2: .asciiz "\nO elevador 2 está bloqueado e não pode atender essa requisição"
	msgDesignado1: .asciiz "\nO elevador 1 vai atender essa requisicao"
	msgDesignado2: .asciiz "\nO elevador 2 vai atender essa requisicao"
	
	
	msg1: .asciiz "E1: "
	msg2: .asciiz "E2: "
	msg3: .asciiz "BE: "
	msg4: .asciiz "B1: "
	msg5: .asciiz "B2: "
	msg6: .asciiz "T: "
	
	
	#variaveis do programa
	e1Req: .word 0,0,0,0,0,0,0,0
	e2Req: .word 0,0,0,0,0,0,0,0	#1=térreo + 7 andares
	
	e1Atual: .byte '1'
	e1Destino: .byte '1'
	e2Atual: .byte '1'
	e2Destino: .byte '1'	
	e1A: .word 1
	e1D: .word 1
	e2A: .word 1
	e2D: .word 1
	
	cont: .word 0 #contador para verificar qual elevador atende uma determinada requisicao: Para cont par, o e1 atende. Para cont impar, o e2 atende
	k: .word 0 #auxiliar para saber se ainda ha destinos a serem buscados
	aux: .word 0 #auxiliar para saber se na primeira vez o usuario digita que nao tem requisicao
	req: .byte  # salva a requisicao
	
	#flags
	fMovimentoE1: .byte 'P'
	fMovimentoE2: .byte 'P'
	fPortaE1: .byte 'A'
	fPortaE2: .byte 'A'
	fBloqE1: .word 0
	fBloqE2: .word 0
	
	#Vetores auxiliares para o arquivo de log
	BE: .byte '0','0','0','0','0','0','0','0'
	B1: .byte '0','0','0','0','0','0','0','0'
	B2: .byte '0','0','0','0','0','0','0','0'
	
	
.text
	.glob main
main:
	#para abrir o arquivo para escrita
	file_open: 
		li   $v0, 13       # system call for open file
		la   $a0, arquivo     # output file name
		li   $a1, 1        # flag for writing
		li   $a2, 0        # mode is ignored
		syscall            # open a file 
		move $s0, $v0      # save the file descriptor  	
		
	
	inicio:
		
		#exibe mensagem inicial TEM ALGUMA REQUISICAO?
		la $a0, msgInicial
		jal console
			
	#Le se tem ou nao requisicao
	key_op:
	lw      $t0, 0xffff0000
	andi    $t0, $t0, 0x00000001  # Isolate ready bit
	beqz    $t0, key_op
	lbu     $a0, 0xffff0004  #tecla pressionada pelo usuario
	
	move $t0, $a0  #move o caractere de opcao para o registrador temporario
	
	beq $t0, 's', temRequisicao
	beq $t0, 'n', semRequisicao	

	
	
#le a requisicao
temRequisicao:		
	jal key_enter

	#exibe mensagem para pegar a requisicao
	la $a0, msgRequisicao
	jal console

	#le a requisicao
key_req:
	lw      $t0, 0xffff0000
	andi    $t0, $t0, 0x00000001  # Isolate ready bit
	beqz    $t0, key_req
	lbu     $a0, 0xffff0004  #tecla pressionada pelo usuario
		
	sb $a0, req #salva o caracter pego na variavel req
	lb $t1, req #salva a variavel req em um registrador temporario
	lb $s2, req
	
		
	jal key_enter	
	j analisa

#Funcao para pegar o caractere enter	
key_enter:
	lw      $t0, 0xffff0000
	andi    $t0, $t0, 0x00000001  # Isolate ready bit
	beqz    $t0, key_enter
	lbu     $a0, 0xffff0004  #tecla pressionada pelo usuario
	jr $ra
	
	
#verifica qual requisicao foi digitada (o que esta em $a0)	
analisa:	
	li $t6, 0 #CONTADOR para os vetores
	beq $t1, 'z', bloqueia
	beq $t1, 'x', desbloqueia
	beq $t1, 'c', bloqueia
	beq $t1, 'v', desbloqueia
	
	
	
	beq $t1, 'q', andar1E1
	beq $t1, 'w', andar2E1
	beq $t1, 'e', andar3E1
	beq $t1, 'r', andar4E1
	beq $t1, 't', andar5E1
	beq $t1, 'y', andar6E1
	beq $t1, 'u', andar7E1
	beq $t1, 'i', andar8E1
	
	beq $t1, 'a', andar1E2
	beq $t1, 's', andar2E2
	beq $t1, 'd', andar3E2
	beq $t1, 'f', andar4E2
	beq $t1, 'g', andar5E2
	beq $t1, 'h', andar6E2
	beq $t1, 'j', andar7E2
	beq $t1, 'k', andar8E2
	
	
	#Se a requisicao e externa verifica o cont para ver quem recebe essa requisicao (Se o cont e par, e1 atende. Se o cont e impar e2 atende)
	beq $t1, '1', verificaContador
	beq $t1, '2', verificaContador
	beq $t1, '3', verificaContador
	beq $t1, '4', verificaContador
	beq $t1, '5', verificaContador
	beq $t1, '6', verificaContador
	beq $t1, '7', verificaContador
	beq $t1, '8', verificaContador
	
	
	
	
semRequisicao:
	jal key_enter
	lw $t4, aux
	beq $t4, $zero, close_file
	la $t2, '-'
	sb $t2, req
	lb $s2, req
	j defineDestE1


bloqueia:
	lb $t4, req
	beq $t4, 'z', bloqE1
	beq $t4, 'c', bloqE2
	jr $ra
bloqE1:
	lw $t5, fBloqE2
	beq $t5, $zero, setFlagE1
	la $a0, msgAlerta1
	jal console
	jal printLog
	j inicio
bloqE2:
	lw $t5, fBloqE1
	beq $t5, $zero, setFlagE2
	la $a0, msgAlerta2
	jal console
	jal printLog
	j inicio
setFlagE1:
	li $t5, 1
	sw $t5, fBloqE1  #a flag de bloqueio do e1 recebe 1, entao ele e bloqueado
	la $a0, msgBloqueiaE1
	jal console
	jal printLog
	j inicio
	
setFlagE2:
	li $t5, 1
	sw $t5, fBloqE2  #a flag de bloqueio do e2 recebe 1, entao ele e bloqueado
	la $a0, msgBloqueiaE2
	jal console
	jal printLog
	j inicio
	
	
	
desbloqueia:
	lb $t4, req
	beq $t4, 'x', desbloqE1
	beq $t4, 'v', desbloqE2
	jr $ra

desbloqE1:
	lw $t5, fBloqE1
	bne $t5, $zero, setFlagE1_
	la $a0, msgAviso1
	jal console	
	jal printLog
	j inicio
	
desbloqE2:
	lw $t5, fBloqE2
	bne $t5, $zero, setFlagE2_
	la $a0, msgAviso2
	jal console	
	jal printLog
	j inicio

setFlagE1_: 
	li $t5, 0
	sw $t5, fBloqE1  #a flag de bloqueio do e1 recebe 0, entao ele e desbloqueado
	la $a0, msgDesbloqueiaE1
	jal console
	jal printLog
	j inicio
setFlagE2_:
	li $t5, 0
	sw $t5, fBloqE2  #a flag de bloqueio do e2 recebe 0, entao ele e desbloqueado	
	la $a0, msgDesbloqueiaE2
	jal console
	jal printLog
	j inicio
	
verificaContador:
	lw $v1, cont
	li $t2,2
	div $v1,$t2
	
	addi, $v1, $v1, 1  #incrementa o contador para usa-lo depois
	sw $v1, cont
	
	mfhi $t3
	beq $t3, $zero, par
	bne $t3, $zero, impar
	
#se o contador e par, verifica se e1 esta bloqueado	
par:
	lw $v1, fBloqE1 
	beq $v1, $zero, e1Recebe #se nao o elevador 1 nao estiver bloqueado, ele recebe a requisicao
	bne $v1, $zero, e2Recebe #se o elevador 1 estiver bloqueado, quem recebe a requisicao e o elevador 2


#se o contador e impar, verifica se e2 esta bloqueado
impar:
	lw $v1, fBloqE2 
	beq $v1, $zero, e2Recebe #se nao o elevador 1 nao estiver bloqueado, ele recebe a requisicao
	bne $v1, $zero, e1Recebe #se o elevador 1 estiver bloqueado, quem recebe a requisicao e o elevador 2
	
	
e1Recebe:
	la $a0, msgDesignado1
	jal console
	beq $t1, '1', andar1E1
	beq $t1, '2', andar2E1
	beq $t1, '3', andar3E1
	beq $t1, '4', andar4E1
	beq $t1, '5', andar5E1
	beq $t1, '6', andar6E1
	beq $t1, '7', andar7E1
	beq $t1, '8', andar8E1

e2Recebe:
	la $a0, msgDesignado2
	jal console
	beq $t1, '1', andar1E2
	beq $t1, '2', andar2E2
	beq $t1, '3', andar3E2
	beq $t1, '4', andar4E2
	beq $t1, '5', andar5E2
	beq $t1, '6', andar6E2
	beq $t1, '7', andar7E2
	beq $t1, '8', andar8E2
			
	#vetor e1Req (recebe 1, valor inteiro)
andar1E1:
	li $a3,1
	sw $a3, e1Req($t6)
	beq $t1, 'q', B1recebe #Para definir o caractere 1 no vetor de caracteres B1
	beq $t1, '1', BErecebe #Para definir o caractere 1 no vetor de caracteres BE
andar2E1:
	addi $t6, $t6, 4
	li $a3,1
	sw $a3, e1Req($t6)
	beq $t1, 'w', B1recebe
	beq $t1, '2', BErecebe 
andar3E1:
	addi $t6, $t6, 8
	li $a3,1
	sw $a3, e1Req($t6)
	beq $t1, 'e', B1recebe
	beq $t1, '3', BErecebe 
andar4E1:
	addi $t6, $t6, 12
	li $a3,1
	sw $a3, e1Req($t6)
	beq $t1, 'r', B1recebe
	beq $t1, '4', BErecebe 
	
andar5E1:
	addi $t6, $t6, 16
	lw $a3, e1Req($t6)
	li $a3,1
	sw $a3, e1Req($t6)
	beq $t1, 't', B1recebe
	beq $t1, '5', BErecebe 
andar6E1:
	addi $t6, $t6, 20
	li $a3,1
	sw $a3, e1Req($t6)
	beq $t1, 'y', B1recebe
	beq $t1, '6', BErecebe 
andar7E1:
	addi $t6, $t6, 24
	li $a3,1
	sw $a3, e1Req($t6)
	beq $t1, 'u', B1recebe
	beq $t1, '7', BErecebe 
	
andar8E1:
	addi $t6, $t6, 28
	li $a3,1
	sw $a3, e1Req($t6)
	beq $t1, 'i', B1recebe
	beq $t1, '8', BErecebe 
	
	#vetor e2Req
andar1E2:
	li $a3,1
	sw $a3, e2Req($t6)
	beq $t1, 'a', B2recebe
	beq $t1, '1', BErecebe 
andar2E2:
	addi $t6, $t6, 4
	li $a3,1
	sw $a3, e2Req($t6)
	beq $t1, 's', B2recebe
	beq $t1, '2', BErecebe 
	
andar3E2:
	addi $t6, $t6, 8
	li $a3,1
	sw $a3, e2Req($t6)
	beq $t1, 'd', B2recebe
	beq $t1, '3', BErecebe 
andar4E2:
	addi $t6, $t6, 12
	li $a3,1
	sw $a3, e2Req($t6)
	beq $t1, 'f', B2recebe
	beq $t1, '4', BErecebe 
andar5E2:
	addi $t6, $t6, 16
	li $a3,1
	sw $a3, e2Req($t6)
	beq $t1, 'g', B2recebe
	beq $t1, '5', BErecebe 
andar6E2:
	addi $t6, $t6, 20
	li $a3,1
	sw $a3, e2Req($t6)
	beq $t1, 'h', B2recebe
	beq $t1, '6', BErecebe 
andar7E2:
	addi $t6, $t6, 24
	li $a3,1
	sw $a3, e2Req($t6)
	beq $t1, 'j', B2recebe
	beq $t1, '7', BErecebe 
andar8E2:
	addi $t6, $t6, 28
	li $a3,1
	sw $a3, e2Req($t6)
	beq $t1, 'k', B2recebe
	beq $t1, '8', BErecebe 
	
B1recebe:
	beq $t1, 'q', B11
	beq $t1, 'w', B12
	beq $t1, 'e', B13
	beq $t1, 'r', B14
	beq $t1, 't', B15
	beq $t1, 'y', B16
	beq $t1, 'u', B17
	beq $t1, 'i', B18

B2recebe:
	beq $t1, 'a', B21
	beq $t1, 's', B22
	beq $t1, 'd', B23
	beq $t1, 'f', B24
	beq $t1, 'g', B25
	beq $t1, 'h', B26
	beq $t1, 'j', B27
	beq $t1, 'k', B28
	
BErecebe:
	beq $t1, '1', BE1
	beq $t1, '2', BE2
	beq $t1, '3', BE3
	beq $t1, '4', BE4
	beq $t1, '5', BE5
	beq $t1, '6', BE6
	beq $t1, '7', BE7
	beq $t1, '8', BE8

	#VETOR BE recebe caractere 1 na posicao onde houver requisicao
BE1:
	li $t6,0
	la $a3,'1'
	sb $a3, BE($t6)
	j defineDestE1
BE2:
	li $t6, 0
	addi $t6, $t6, 1
	la $a3,'1'
	sb $a3, BE($t6)	
	j defineDestE1
BE3:
	li $t6, 0
	addi $t6, $t6, 2
	la $a3,'1'
	sb $a3, BE($t6)	
	j defineDestE1
BE4:
	li $t6, 0
	addi $t6, $t6, 3
	la $a3,'1'
	sb $a3, BE($t6)	
	j defineDestE1
BE5:
	li $t6, 0
	addi $t6, $t6, 4
	la $a3,'1'
	sb $a3, BE($t6)	
	j defineDestE1
BE6:
	li $t6, 0
	addi $t6, $t6, 5
	la $a3,'1'
	sb $a3, BE($t6)	
	j defineDestE1
BE7:
	li $t6, 0
	addi $t6, $t6, 6
	la $a3,'1'
	sb $a3, BE($t6)	
	j defineDestE1
BE8:
	li $t6, 0
	addi $t6, $t6, 7
	la $a3,'1'
	sb $a3, BE($t6)		
	j defineDestE1
	
	#VETOR B1 recebe o caractere 1 na posicao onde houver requisicao
B11:	
	li $t6, 0
	la $a3,'1'
	sb $a3, B1($t6)		
	j defineDestE1
B12:	
	li $t6, 0
	addi $t6, $t6, 1
	la $a3,'1'
	sb $a3, B1($t6)	
	j defineDestE1
B13:	
	li $t6, 0
	addi $t6, $t6, 2
	la $a3,'1'
	sb $a3, B1($t6)	
	j defineDestE1
B14:	
	li $t6, 0
	addi $t6, $t6, 3
	la $a3,'1'
	sb $a3, B1($t6)	
	j defineDestE1
B15:	
	li $t6, 0
	addi $t6, $t6, 4
	la $a3,'1'
	sb $a3, B1($t6)
	j defineDestE1		
			
B16:	
	li $t6, 0
	addi $t6, $t6, 5
	la $a3,'1'
	sb $a3, B1($t6)	
	j defineDestE1
B17:	
	li $t6, 0
	addi $t6, $t6, 6
	la $a3,'1'
	sb $a3, B1($t6)	
	j defineDestE1
B18:	
	li $t6, 0
	addi $t6, $t6, 7
	la $a3,'1'
	sb $a3, B1($t6)	
	j defineDestE1

	#VETOR B2 recebe o caractere 1 na posicao onde houver requisicao
B21:	
	li $t6, 0
	la $a3,'1'
	sb $a3, B2($t6)	
	j defineDestE1
B22:	
	li $t6, 0
	addi $t6, $t6, 1
	la $a3,'1'
	sb $a3, B2($t6)	
	j defineDestE1
B23:	
	li $t6, 0
	addi $t6, $t6, 2
	la $a3,'1'
	sb $a3, B2($t6)	
	j defineDestE1
B24:	
	li $t6, 0
	addi $t6, $t6, 3
	la $a3,'1'
	sb $a3, B2($t6)	
	j defineDestE1
B25:	
	li $t6, 0
	addi $t6, $t6, 4
	la $a3,'1'
	sb $a3, B2($t6)	
	j defineDestE1
	
B26:	
	li $t6, 0
	addi $t6, $t6, 5
	la $a3,'1'
	sb $a3, B2($t6)	
	j defineDestE1
B27:	
	li $t6, 0
	addi $t6, $t6, 6
	la $a3,'1'
	sb $a3, B2($t6)	
	j defineDestE1
B28:	
	li $t6, 0
	addi $t6, $t6, 7
	la $a3,'1'
	sb $a3, B2($t6)	
	j defineDestE1


	
#para o vetor e1Req se e1Atual==e1Destino entra em uma estrutura de repeticao para verificar em que posicao do vetor tem 1

defineDestE1:

	lw $t9, aux
	addi $t9, $t9, 1
	sw $t9, aux
	
	
	li $t6, 0
	li $t7,0
	lb $t4,e1Atual
	lb $t5, e1Destino				
	beq $t4, $t5, loopIguais1
	bne $t4, $t5, defineDestE2
	
loopIguais1:	
	lw $a1, e1Req($t6)	
	beq $a1, 1, encontrouDest1	
	addi $t6, $t6, 4
	addi $t7, $t7, 1
	slti $t2, $t6, 32
	bne $t2, 1, defineDestE2
 	j loopIguais1

encontrouDest1:
	
	li $t8, 1
	sw $t8, k  #se ainda ha destinos, a variavel auxiliar k recebe 1 para que ainda haja movimento dos elevadores
	
	addi $t5, $t7, 1
	li $t6,32
	sw $t5, e1D
	la $t0, ($t5)
	addi $t0, $t0, 48
	sb $t0, e1Destino
	j defineDestE2
	
defineDestE2:
	li $t6, 0
	li $t7, 0
	lb $t4,e2Atual
	lb $t5, e2Destino		
	beq $t4, $t5, loopIguais2
	bne $t4, $t5, verificaFlagsE1
	
loopIguais2:	
	lw $a0, e2Req($t6)
	beq $a0, 1, encontrouDest2	
	addi $t6, $t6, 4
	addi $t7, $t7, 1
	slti $t2, $t6, 32
	bne $t2, 1, verificaFlagsE1
 	j loopIguais2


encontrouDest2:
	li $t8, 1
	sw $t8, k
	addi $t5, $t7, 1
	li $t6,32
	sw $t5, e2D
	la $t0, ($t5)
	addi $t0, $t0, 48
	sb $t0, e2Destino	
	j verificaFlagsE1


verificaFlagsE1: 
	move $t2, $s2
	beq $t2, '-', semReq
		
	lb $t4, e1Atual
	lb $t5, e1Destino
	beq $t4, $t5, ok1
	#Se o andar atual nao for o andar de destino, o elevador continua se movendo com a porta fechada
	la $t2, 'M'
	sb $t2, fMovimentoE1
	lb $s3, fMovimentoE1
	la $t3, 'F'
	sb $t3, fPortaE1
	la $a0, msgMovimentoFechada1
	jal console
	j verificaFlagsE2
	
semReq:
	lw $t4, k	
	beq $t4, $zero, close_file
	
	lb $t4, e1Atual
	lb $t5, e1Destino
	beq $t4, $t5, ok1
	#Se o andar atual nao for o andar de destino, o elevador continua se movendo com a porta fechada
	la $t2, 'M'
	sb $t2, fMovimentoE1
	lb $s3, fMovimentoE1
	la $t3, 'F'
	sb $t3, fPortaE1
	la $a0, msgMovimentoFechada1
	jal console
	j verificaFlagsE2
	

ok1: #Como o andar atual e igual ao andar de destino, o elevador para e abre a porta para que haja embarque/desembarque
	la $t2, 'P'
	sb $t2, fMovimentoE1
	lb $s3, fMovimentoE1
	
	la $t3, 'A'
	sb $t3, fPortaE1
	la $a0, msgParadoAberta1
	jal console
	la $a0, msgEmbDes1
	jal console
	j verificaFlagsE2

verificaFlagsE2:
	lb $t4, e2Atual
	lb $t5, e2Destino
	
	beq $t4, $t5, ok2
	#Se o andar atual nao for o andar de destino, o elevador continua se movendo com a porta fechada
	la $t2, 'M'
	sb $t2, fMovimentoE2
	la $t3, 'F'
	sb $t3, fPortaE2
	la $a0, msgMovimentoFechada2
	jal console
	jal printLog

ok2: #Como o andar atual e igual ao andar de destino, o elevador para e abre a porta para que haja embarque/desembarque
	la $t2, 'P'
	sb $t2, fMovimentoE2
	la $t3, 'A'
	sb $t3, fPortaE2
	la $a0, msgParadoAberta2
	jal console
	la $a0, msgEmbDes2
	jal console
	jal printLog
moverE1:
	lw $t1, fBloqE1
	beq $t1, $zero, E1desbloqueado
	la $a0, msgNaoPode1
	jal console
	j moverE2
	
E1desbloqueado:
	lw $t2, e1A
	lw $t3, e1D
	blt $t2, $t3, incrementaE1Atual
	bgt $t2, $t3, decrementaE1Atual
	beq $t2, $t3, print1
		
incrementaE1Atual:
	addi $t2, $t2, 1
	sw $t2, e1A
	
	
	la $t0, ($t2)
	addi $t0, $t0, 48
	sb $t0, e1Atual
	la $a0, msgSubiu1
	jal console
	la $a0, msgAndarAtual1
	jal console
	
	lw $a0, e1A
	li $v0, 1
	syscall
	
	j moverE2

decrementaE1Atual:
	subi $t2, $t2, 1
	sw $t2, e1A
	la $t0, ($t2)
	addi $t0, $t0, 48
	sb $t0, e1Atual
	la $a0, msgDesceu1
	jal console
	la $a0, msgAndarAtual1
	jal console
	
	lw $a0, e1A
	li $v0, 1
	syscall
	
	j moverE2

print1:
#	la $a0, msgParado1
#	jal console
	j moverE2

moverE2:
	lw $t1, fBloqE2
	beq $t1, $zero, E2desbloqueado
	la $a0, msgNaoPode2
	jal console
	j verifica1
E2desbloqueado:
	lw $t2, e2A
	lw $t3, e2D
	blt $t2, $t3, incrementaE2Atual
	bgt $t2, $t3, decrementaE2Atual
	beq $t2, $t3, print2

incrementaE2Atual:
	addi $t2, $t2, 1
	sw $t2, e2A
	la $t0, ($t2)
	addi $t0, $t0, 48
	sb $t0, e2Atual
	la $a0, msgSubiu2
	jal console
	la $a0, msgAndarAtual2
	jal console
	
	lw $a0, e2A
	li $v0, 1
	syscall
	
	j verifica1

decrementaE2Atual:
	subi $t2, $t2, 1
	sw $t2, e2A
	la $t0, ($t2)
	addi $t0, $t0, 48
	sb $t0, e2Atual
	la $a0, msgDesceu2
	jal console
	la $a0, msgAndarAtual2
	jal console
	
	lw $a0, e2A
	li $v0, 1
	syscall
	
	j verifica1

print2:
#	la $a0, msgParado2
#	jal console
	j verifica1

verifica1:
	lw $t0, e1A
	subi $t1, $t0, 1
	mul $t1, $t1 4
	
	lw $t3, e1Req($t1)
	bne $t3, 1,verifica2 
	jal chegou1
	j verifica2
	
verifica2:
	lw $t0, e2A
	subi $t1, $t0, 1, 
	mul $t1, $t1 4
	
	lw $t3, e2Req($t1)
	bne $t3, 1, printLogText
	jal chegou2
	jal printLog
	move $t2, $s2
	beq $t2, '-', noReq
	j inicio

printLogText:
	jal printLog
	move $t2, $s2
	beq $t2, '-', noReq
	j inicio	

noReq:
	
	li $t8, 0
	sw $t8, k   #a variavel auxiliar k e definida como 0, se houver algum destino a ser tomado por algum dos elevadores, ela recebe 1
	j defineDestE1	


chegou1:
	la $t4, 'P'
	sb $t4, fMovimentoE1
	lb $s3, fMovimentoE1
	
	la $t5, 'A'
	sb $t5, fPortaE1
	
	lw $t6, e1D
	subi $t6, $t6, 1
	
	lb $t7, B1($t6)
	beq $t7, '1', zeraAndarB1
	
back:	
	lb $t8, BE($t6)
	beq $t8, '1', zeraAndarBE
back2:
	j zeraAndarE1
back3:	
	jr $ra
	
zeraAndarB1:
	la $t7, '0'
	sb $t7, BE($t6)	
	j back
zeraAndarBE:
	la $t8, '0'
	sb $t8, BE($t6)	
	j back2			
zeraAndarE1:
	mul $t6, $t6, 4
	li $t9, 0             #zera a posicao no vetor e1Req
	sw $t9, e1Req($t6)	
	j back3	
chegou2:
	la $t4, 'P'
	sb $t4, fMovimentoE2
	la $t5, 'A'
	sb $t5, fPortaE2
	
	lw $t6, e2D
	subi $t6, $t6, 1
	
	lb $t7, B2($t6)
	beq $t7, '1', zeraAndarB2
	
	lb $t8, BE($t6)
	beq $t8, '1', zeraAndarBE
	
zeraAndarE2:
	mul $t6, $t6, 4
	li $t9, 0             #zera a posicao no vetor e1Req
	sw $t9, e2Req($t6)		
		
zeraAndarB2:
	la $t7, '0'
	sb $t7, B2($t6)	
	
printLog:
#escreve no arquivo
#e1atual, e1destino, fMovimentoE1, fPortaE1
#e2atual, e2destino, fMovimentoE2, fPortaE2
#BE
#B1
#B2
#req
	
	move $a0, $s0
	li   $v0, 15       # system call for write to file
	la $a1, msg1
    	li $a2,4
	syscall 

	
	
	
	li   $v0, 15       # system call for write to file
	la $a1, e1Atual
    	li $a2,1
	syscall 
	
	
	li   $v0, 15       # system call for write to file
	la $a1, msgEspaco
    	li $a2,1
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, e1Destino
    	li $a2,1
	syscall 
	

	li   $v0, 15       # system call for write to file
	la $a1, msgEspaco
    	li $a2,1
	syscall 
	
	
	li   $v0, 15       # system call for write to file
	la $a1, fMovimentoE1
    	li $a2,1
	syscall 
	

	li   $v0, 15       # system call for write to file
	la $a1, msgEspaco
    	li $a2,1
	syscall 
	

	li   $v0, 15       # system call for write to file
	la $a1, fPortaE1
    	li $a2,1
	syscall  
	
	li   $v0, 15       # system call for write to file
	la $a1, msgPulaLinha
    	li $a2,1
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, msg2
    	li $a2,4
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, e2Atual
    	li $a2,1
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, msgEspaco
    	li $a2,1
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, e2Destino
    	li $a2,1
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, msgEspaco
    	li $a2,1
	syscall 
	
			     # file descriptor 
	li   $v0, 15       # system call for write to file
	la $a1, fMovimentoE2
    	li $a2,1
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, msgEspaco
    	li $a2,1
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, fPortaE2
    	li $a2,1
	syscall  
	
	li   $v0, 15       # system call for write to file
	la $a1, msgPulaLinha
    	li $a2,1
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, msg3
    	li $a2,4
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, BE
    	li $a2,8
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, msgPulaLinha
    	li $a2,1
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, msg4
    	li $a2,4
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, B1
    	li $a2,8
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, msgPulaLinha
    	li $a2,1
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, msg5
    	li $a2,4
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, B2
    	li $a2,8
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, msgPulaLinha
    	li $a2,1
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, msg6
    	li $a2,3
	syscall 
	
	sb $s2, req
	li   $v0, 15       # system call for write to file
	la $a1, req
    	li $a2,1
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, msgPulaLinha
    	li $a2,1
	syscall 
	
	li   $v0, 15       # system call for write to file
	la $a1, msgPulaLinha
    	li $a2,1
	syscall 
	
	
	jr $ra     
	

console:
	li $v0,4
	syscall 
	jr $ra

close_file:
	
	 move $a0, $s0
	 li $v0, 16  # $a0 already has the file descriptor
    	 syscall
    	 j fim
    	 
fim:	

	la $a0, msgFim
	jal console
 	li $v0,10
 	syscall
