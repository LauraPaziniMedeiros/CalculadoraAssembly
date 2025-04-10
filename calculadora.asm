		.data
		.align 0
linha_vazia:	.asciz "\n"
strNumero:  	.asciz "Digite um numero: "
strOperacao:  	.asciz "Escolha uma operacao: "
str_erroUndo:  	.asciz "Não existe valor anterior"
str_erroDivisao:.asciz "Sem dividir por 0 bobinha(o)(e)"
    		.align 2
ponteiro_lista: .word 0 			# Ponteiro da lista encadeada que aponta para o 1o elemento. Inicializado em 0
opSoma:		.word 43			# "+"
opSub:		.word 45			# "-"
opMul:		.word 42			# "*"
opDiv:		.word 47    			# "/"
opUndo:		.word 117   			# "u"
opSaida:	.word 102   			# "f"

		.text
		.align 2
		.globl _main
_main:
		lw s2, opSoma			# carrega o valor do caracter +
		lw s3, opSub			# carrega o valor do caracter -
		lw s4, opMul			# carrega o valor do caracter *
		lw s5, opDiv			# carrega o valor do caracter /
		lw s6, opUndo			# carrega o valor do caracter u
		lw s7, opSaida			# carrega o valor do caracter f
    		addi s8, zero, 0  		# flag para verificar de que loop vem a chamada
    		addi t3, zero, 0  		# valor da operação mais recente
    		jal ra, lista_criar
		
leitura_inicio:
    		la a0,  strNumero   		# imprimir mensagem para leitura de um numero
    		addi a7, zero, 4
    		ecall

    		addi a7, zero, 5		# ler inteiro
		ecall
		add t0, zero, a0		# primeiro operando para t0
		
    		
    		addi a7, zero, 4
    		la a0,  strOperacao 		 # imprimir mensagem para leitura de uma operacao
    		ecall

		addi a7, zero, 12
		ecall
		add t1, a0, zero		 # operação para t1
		beq t1, s6, undo
		beq t1, s7, saida	

    		la a0, linha_vazia  		# imprimir \n
    		addi a7, zero, 4
    		ecall

    		la a0,  strNumero   		# imprimir mensagem para leitura de um numero
    		ecall
		
		addi a7, zero, 5
		ecall
		add t2, zero, a0		# segundo operando para t2
		
selecao:
		beq t1, s2, soma
		beq t1, s3, subtracao
		beq t1, s4, multiplicacao
		beq t1, s5, divisao
		
soma:
		add t3, t0, t2
    		add a0, t3, zero 
    		jal ra, lista_inserir
		j loop_principal
	
subtracao:
		sub t3, t0, t2
    		add a0, t3, zero 
    		jal ra, lista_inserir
		j loop_principal

multiplicacao:
		mul t3, t0, t2
    		add a0, t3, zero 
    		jal ra, lista_inserir
		j loop_principal
		
divisao:
    		beq t2, zero, erroDivisao
		div  t3, t0, t2
    		add a0, t3, zero 
    		jal ra, lista_inserir
		
loop_principal:
    		beq s8, zero, attFlag
    		addi a7, zero, 1    		# imprimir inteiro
    		add a0, zero, t3    		# imprimir o resultado da operação mais recente
    		ecall

    		add t0, t3, zero    		# atribuo o valor da operação mais recente para t0

    		la a0, linha_vazia  		# imprimir \n
    		addi a7, zero, 4
    		ecall
    
    		la a0,  strOperacao  		# imprimir mensagem para leitura de uma operacao
    		ecall

		addi a7, zero, 12
		ecall
		add t1, a0, zero		# operação para t1
		beq t1, s6, undo
		beq t1, s7, saida	

    		la a0, linha_vazia  		# imprimir \n
    		addi a7, zero, 4
    		ecall

    		la a0,  strNumero   		# imprimir mensagem para leitura de um numero
    		ecall
    
    		addi a7, zero, 5
		ecall
		add t2, zero, a0		# segundo operando para t2
    
    		j selecao

attFlag:
    		addi s8, zero, 1    		# significa que chegamos no loop_principal
    		j loop_principal

seletor_loop:
    		beq s8, zero, leitura_inicio
    		j loop_principal

undo:

    		jal ra, lista_topo
    		bne a1, zero, erroUndo

    		jal ra, lista_remover_topo
    		jal ra, lista_topo        	# verificar se o elemento no topo da lista
    		bne a1, zero, auxErroUndo    	# verifico se a operação foi um sucesso e caso não, imprimo uma mensagem de erro
    

    		add t3, a0, zero    		# atribuo o valor que estava no topo da lista para o meu resultado atual

    		la a0, linha_vazia  		# imprimir \n
    		addi a7, zero, 4
    		ecall

    		j loop_principal    		# se tudo deu certo, posso voltar para o loop_principal

auxErroUndo:
    		jal ra, lista_inserir   	# insere novamente o topo anterior
erroUndo:
    		la a0, linha_vazia  		# imprimir \n
    		addi a7, zero, 4
    		ecall

    		la a0, str_erroUndo
    		addi a7, zero, 4
    		ecall

    		la a0, linha_vazia  		# imprimir \n
    		ecall
    
    		j seletor_loop 

erroDivisao:
    		la a0, str_erroDivisao
    		addi a7, zero, 4
    		ecall

    		la a0, linha_vazia
    		ecall

    		j seletor_loop
    
saida:
    		addi a7, zero, 10   # saida do programa
    		ecall

# FUNÇÕES REFERENTES A LISTA ENCADEADA

lista_criar: # Aloca memória para inicializar a lista
		# Parâmetros: N/A
		# Retornos:
		# - a0: endereço do primeiro elemento da lista
	
		# Aloca 8 bytes na memória heap
		li a7, 9
		li a0, 8
		ecall
	
		# Encerra o programa se a alocação não for bem sucedida
		beq a0, zero, saida 
	
		# Guarda o endereço alocado em pointer (s0)
		la s0, ponteiro_lista
		sw a0, 0(s0) 
	
		# Guarda o número de elementos em s1
		add s1, zero, zero
		jr ra
	
lista_inserir: # Insere um elemento no topo da lista
		# Parâmetros:
		# - a0: elemento a ser inserido
		# Retornos: N/A
	
		lw t0, 0(s0)
		beq t0, zero, retorno 		# Retorna da função se a lista não foi criada
		beq s1, zero, lista_vazia 	# Caso especial da inserção para lista vazia	
		add t1, zero, a0 		# Guarda o elemento em t1
	
		# Aloca memória para o novo elemento
		li a7, 9
		li a0, 8
		ecall
	
		# Encerra o programa se a alocação não for bem sucedida
		beq a0, zero, saida 
	
		sw t1, 0(a0) 		# Guarda o elemento no endereço alocado
		sw t0, 4(a0) 		# Guarda o endereço do elemento anterior nos outros 4 bytes alocados
		sw a0, 0(s0) 		# Pointer aponta para o novo elemento
	
		addi s1, s1, 1 		# Incrementa o tamanho da lista
		jr ra

lista_vazia: # Não há necessidade de alocar memória para inserção do elemento
		sw a0, 0(t0)
		sw zero, 4(t0) 		# Não existe elemento anterior para ser endereçado
		addi s1, s1, 1
		jr ra
	
lista_remover_topo: # Remove um elemento no topo da lista
		# Parâmetros: N/A
		# Retornos: N/A
	
		# Retorna se a lista for vazia ou não criada
		beq zero, s1, retorno
		lw t0, 0(s0)
		beq zero, t0, retorno
	
		lw t1, 4(t0) 		# t1 recebe o endereço do elemento anterior
		# Se t1 for 0, o elemento removido era o único elemento na lista
		# Retorna da função para não atualizar o pointer com um endereço nulo
		beq t1, zero, remover_aux
		sw t1, 0(s0) 		# Atualiza o endereço apontado pelo pointer
	
		addi s1, s1, -1 	# Decrementa o tamanho da lista
		jr ra
remover_aux:
		sw t1, 0(t0)
		addi s1, s1, -1 	# Decrementa o tamanho da lista
		jr ra
	
lista_topo: # Retorna o elemento no topo da lista
		# Parâmetros: N/A
		# Retornos:
		# - a0: elemento no topo da lista
		# - a1: configura o sucesso da operação. 0 = sucesso, 1 = falha
	
		# Retorna que a operação falhou (lista vazia ou não criada)
		beq zero, s1, falha 
		lw t0, 0(s0)
		beq zero, t0, falha
	
		lw a0, 0(t0)
		add a1, zero, zero 	# Sucesso na operação
	
		jr ra
	
falha:
		li a1, 1
		jr ra	
		
retorno:
		jr ra

# FIM DAS FUNÇÕES REFERENTES A LISTA
