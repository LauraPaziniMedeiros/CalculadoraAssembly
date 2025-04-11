# Dados utilizados no programa
		.data
		.align 0
linha_vazia:	.asciz "\n"
strNumero:  	.asciz "Digite um numero: "
strOperacao:  	.asciz "Escolha uma operacao: "
str_erroUndo:  	.asciz "Não existe valor anterior"
str_erroDivisao:.asciz "Sem dividir por 0, não sou bobinha(o)(e)"
str_op_invalida:.asciz "Operação inválida\n"
    		.align 2
ponteiro_lista: .word 0 			# Ponteiro da lista encadeada que aponta para o 1o elemento, inicializado em 0
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
		lw s2, opSoma			# Carrega o valor do caracter +
		lw s3, opSub			# Carrega o valor do caracter -
		lw s4, opMul			# Carrega o valor do caracter *
		lw s5, opDiv			# Carrega o valor do caracter /
		lw s6, opUndo			# Carrega o valor do caracter u
		lw s7, opSaida			# Carrega o valor do caracter f
    		addi s8, zero, 0  		# Flag para verificar de que loop vem a chamada
    		addi t3, zero, 0  		# Resultado da operação mais recente
    		jal ra, lista_criar
    		
# Início do programa	
leitura_inicio:
		# Exibe mensagem "Digite um numero: "
    		la a0,  strNumero		# a0 recebe endereço da string strNumero
    		addi a7, zero, 4		# Syscall 4 (imprime strNumero)
    		ecall			
		# Leitura do primeiro número da operação
    		addi a7, zero, 5		# Syscall 5 (leitura de inteiro)
		ecall
		add t0, zero, a0		# t0 recebe número lido (primeiro operando)
		# Exibe mensagem "Escolha uma operacao: "
    		addi a7, zero, 4		# Syscall 4 (imprime strOperacao)
    		la a0,  strOperacao		# a0 recebe endereço da string strOperacao
    		ecall			
		# Leitura do caracter da operacao
		addi a7, zero, 12		# Syscall 12 (leitura de caracter)
		ecall				# Lê a operacao
		add t1, a0, zero		# t1 recebe caracter da operacao
		beq t1, s6, undo		# Se operacao = 'u', pula para funcao undo
		beq t1, s7, saida		# Se operacao = 'f, pula para funcao saida
		# Imprime quebra de linha
    		la a0, linha_vazia  		# a0 recebe endereço para a string "\n"
    		addi a7, zero, 4		# Syscall 4 (imprime string)
    		ecall			
		# Exibe mensagem "Digite um numero: "
    		la a0,  strNumero   		# a0 recebe endereço da string strNumero
    		ecall				
		# Leitura do segundo número da operação
		addi a7, zero, 5		# Syscall 5 (leitura de inteiro)
		ecall
		add t2, zero, a0		# t2 recebe numero lido (segundo operando)
		
# Seleciona a operação a ser feita a partir do caracter selecionado	
selecao: 	
	 
		beq t1, s2, soma		# Se t1 = '+', pula para a função soma
		beq t1, s3, subtracao 		# Se t1 = '-' pula para a função subtração
		beq t1, s4, multiplicacao	# Se t1 = '*' pula para a função multiplicação
		beq t1, s5, divisao		# Se t1 = '/' pula para a função divisao
		la a0, str_op_invalida		# Se operação for inválida, a0 recebe endereço da str_op_invalida
		addi a7, zero, 4		# Syscall 4(imprime string "Operação inválida\n")
		ecall
		j seletor_loop			# Pula para função seletor_loop
	
# Realiza a soma dos operandos	
soma:
		add t3, t0, t2			# Armazena em t3 o resultado da soma t0 + t2
    		add a0, t3, zero		# a0 recebe o valor de t3
    		jal ra, lista_inserir		# Chama a função lista_inserir para armazenar resultado
		j loop_principal		# Pula para o loop principal
		

# Realiza a subtracao dos operandos	
subtracao:
		sub t3, t0, t2			# Armazena em t3 o resultado da subtração t0 - t2
    		add a0, t3, zero 		# a0 recebe o valor de t3
    		jal ra, lista_inserir		# Chama a função lista_inserir para armazenar resultado 
		j loop_principal		# Pula para o loop principal


# Realiza a multiplicacao dos operandos	
multiplicacao:
		mul t3, t0, t2			# Armazena em t3 o resultado da multiplicacao t0 * t2
    		add a0, t3, zero 		# a0 recebe o valor de t3
    		jal ra, lista_inserir		# Chama a função lista_inserir para armazenar resultado 
		j loop_principal		# Pula para o loop principal
		

# Realiza a divisao dos operandos	
divisao:
    		beq t2, zero, erroDivisao	# Se o divisor for nulo(t2 = 0), chama a função erroDivisao
		div  t3, t0, t2			# Armazena em t3 o resultado da divisao t0 / t2
    		add a0, t3, zero 		# a0 recebe o valor de t3
    		jal ra, lista_inserir		# Chama a função lista_inserir para armazenar resultado 
		

# Realiza a leitura das operações e operandos seguintes	
loop_principal:
		#Imprime resultado da última operação
    		beq s8, zero, attFlag		# Se s8 = 0(primeira passagem pelo loop principal),chama attFlag para atualizar valor da flag
    		addi a7, zero, 1    		# Syscall 1 (imprime inteiro)
    		add a0, zero, t3    		# Imprime o resultado da operação mais recente
    		ecall

    		add t0, t3, zero    		# atribuo o valor da operação mais recente para t0

		# Imprime uma quebra de linha e a mensagem "Escolha uma operacao: "
    		la a0, linha_vazia  		# a0 recebe endereço da string linha_vazia
    		addi a7, zero, 4		# Syscall 4 (imprime string linha_vazia)
    		ecall				# Imprime string apontada por a0
    		la a0, strOperacao  		# a0 recebe endereço da string strOperacao
    		ecall				# Imprime string apontada por a0

		# Faz a leitura da próxima operação
		addi a7, zero, 12		# Syscall 12 (leitura do caracter da operação)
		ecall
		add t1, a0, zero		# t1 recebe operação
		beq t1, s6, undo		# se t1 = 'u', pula para a função undo
		beq t1, s7, saida		# se t1 = 'f', pula para função saida

		# Imprime uma quebra de linha e a mensagem "Digite um numero: "
    		la a0, linha_vazia  		# a0 recebe endereço da string linha_vazia
    		addi a7, zero, 4		# Syscall 4 (imprime string linha_vazia)
    		ecall				# Imprime string apontada por a0
    		la a0,  strNumero   		# a0 recebe endereço da string strNumero
    		ecall				# Imprime string apontada por a0
    
    		# Faz a leitura do oróximo operando
    		addi a7, zero, 5		# Syscall 5 (leitura de inteiro)
		ecall
		add t2, zero, a0		# t2 recebe valor do próximo operando
    
    		# Pula para função selecao
    		j selecao

# Atualiza o valor da flag para 1 após a passagem pelo loop principal
attFlag:
    		addi s8, zero, 1    		# s8 = 1
    		j loop_principal		# Volta para a função loop_principal
    		
# Seleciona de onde continuar a execução
seletor_loop:
    		beq s8, zero, leitura_inicio # Se ainda não entramos no loop principal (s8 == 0), volta para leitura_inicio
    		j loop_principal # Caso contrário, continua no loop principal

# Realiza a operação undo: desfaz a última operação retirando o topo da pilha (último valor armazenado) e atualizando o valor atual.
undo:
		# Retorna topo da lista
    		jal ra, lista_topo		# Verifica se existe um elemento no topo da lista
    		bne a1, zero, erroUndo		# Se a1 != 0 (houve falha), pula para função erroUndo
		
		# Remove topo da lista e recupera em a0 o valor do novo topo
    		jal ra, lista_remover_topo	# Remove elemento no topo da lista
    		jal ra, lista_topo        	# Verifica se existe um elemento no topo da lista
    		bne a1, zero, auxErroUndo    	# Verifico se a operação foi um sucesso e, caso não, imprimo uma mensagem de erro
    
    		# Atribui a t3 o novo valor do topo
    		add t3, a0, zero    		# t3 <- a0(topo)

		# Imprime uma linha vazia
    		la a0, linha_vazia  		# a0 recebe endereço da string linha_vazia
    		addi a7, zero, 4		# Syscall 4(imprime string linha_vazia)
    		ecall

		# Retorno ao loop principal
    		j loop_principal   
    		 	
# Se a lista estiver vazia após o undo, insere de volta na lista o valor anterior 
auxErroUndo:
    		jal ra, lista_inserir   	# Chama lista_inserir para inserir novamente o topo anterior
    		
# Se a lista estiver vazia antes do undo, imprime mensagem de erro "Não existe valor anterior"
erroUndo:
		# Imprime uma quebra de linha
    		la a0, linha_vazia  		# a0 recebe endereço da string linha_vazia
    		addi a7, zero, 4		# Syscall 4 (imprime string linha_vazia)
    		ecall
		
		# Imprime mensagem de erro "Não existe valor anterior"
    		la a0, str_erroUndo		# a0 recebe endereço da string str_erroUndo
    		addi a7, zero, 4		# Syscall 4 (imprime string str_erroUndo)
    		ecall

		# Imprime uma quebra de linha
    		la a0, linha_vazia  		# a0 recebe endereço da string linha_vazia
    		ecall
    
    		# Retorna para seletor_loop para continuar a execução
    		j seletor_loop 

# Se o divisor da operação for 0, imprime mensagem de erro 
erroDivisao:
		# Imprime mensagem de erro "Sem dividir por 0, não sou bobinha(o)(e)"
    		la a0, str_erroDivisao 		# a0 recebe endereço da string str_erroDivisao
    		addi a7, zero, 4		# Syscall 4 (imprime string str_erroDivisao)
    		ecall
		
		# Imprime uma quebra de linha
    		la a0, linha_vazia		# a0 recebe endereço da string linha_vazia
    		ecall

		# Retorna para seletor_loop para continuar a execução
    		j seletor_loop
   
# Realiza a operação finalizar: Encerra a execução do programa
saida:
    		addi a7, zero, 10   		# Syscall 10 (saída do programa)
    		ecall


# FUNÇÕES REFERENTES A LISTA ENCADEADA

#-------------------------------------------------------------
# Função lista_criar
# Aloca memória para inicializar a lista
# Parâmetros: N/A
# Retornos:
# - a0: endereço do primeiro elemento da lista
#-------------------------------------------------------------
lista_criar: 
		# Aloca 8 bytes na memória heap
		li a7, 9			# Syscall 9 (aloca memória)
		li a0, 8			# Aloca 8 bytes
		ecall
	
		# Encerra o programa se a alocação não for bem sucedida
		beq a0, zero, saida 		# e a0 = 0 sai do programa
	
		# Guarda o endereço alocado em pointer (s0)
		la s0, ponteiro_lista		# s0 recebe endereço de ponteiro_lista
		sw a0, 0(s0) 			# Salva a memória alocada no endereço de ponteiro_lista
	
		# Guarda o número de elementos em s1 e retorna da função
		add s1, zero, zero		# Inicializa número de elementos na lista como 0
		jr ra				# Retorna da função

#-------------------------------------------------------------
# Função lista_inserir
# Insere um elemento no topo da lista
# Parâmetros:
# - a0: elemento a ser inserido
# Retornos: N/A
#-------------------------------------------------------------
lista_inserir: 
		# Inicializações
		lw t0, 0(s0)			# t0 recebe ponteiro para fim da lista
		beq t0, zero, retorno 		# Retorna da função se a lista não foi criada(t0 = 0)
		beq s1, zero, lista_vazia 	# Se tamanho da lista for nulo, chama função lista_vazia	
		add t1, zero, a0 		# Guarda o elemento a ser inserido em t1
	
		# Aloca memória para o novo elemento
		li a7, 9			# Syscall 9 (aloca memória)
		li a0, 8			# Aloca 8 bytes
		ecall
		beq a0, zero, saida 		# Se a alocação não foi bem sucedida, encerra programa
	
		# Insere elemento
		sw t1, 0(a0) 			# Guarda o elemento no endereço alocado
		sw t0, 4(a0) 			# Guarda o endereço do elemento anterior nos outros 4 bytes alocados
		sw a0, 0(s0) 			# Ponteiro s0 aponta para o elemento inserido
	
		addi s1, s1, 1 			# Incrementa o tamanho da lista
		jr ra				# Retorna da função

#-------------------------------------------------------------
# Função lista_vazia
# Faz a inserção do primeiro elemento.
# Não é necessária alocação de memória pois o espaço já foi alocado.
# Parâmetros:
# - a0: elemento a ser inserido
# Retornos: N/A
#-------------------------------------------------------------
lista_vazia:
		sw a0, 0(t0)			# Insere primeiro elemento da lista
		sw zero, 4(t0) 			# Não existe elemento anterior para ser endereçado, portanto armazena 0		
		addi s1, s1, 1			# Incrementa o tamanho da lista
		jr ra				# Retorna da função

#-------------------------------------------------------------
# Função lista_remover_topo
# Faz a remoção do elemento do topo da lista(ultimo elemento).
# Parâmetros: N/A
# Retornos: N/A
#-------------------------------------------------------------
lista_remover_topo: 
		# Retorna se a lista for vazia ou não criada
		beq zero, s1, retorno 		# Se não há elementos na lista, retorna
		lw t0, 0(s0)			# t0 recebe ponteiro para ultimo elemento da lista
		beq zero, t0, retorno		# Se ponteiro for nulo, retorna
		
		# Remove elemento no topo da lista
		lw t1, 4(t0) 			# t1 recebe o endereço do elemento anterior
		beq t1, zero, remover_aux	# Se t1 = 0, o elemento removido era o único elemento na lista
		sw t1, 0(s0) 			# Atualiza o ponteiro do topo da lista com o elemento anterior
		
		# Decrementa o tamanho da lista e retorna
		addi s1, s1, -1 		# Decrementa o tamanho da lista
		jr ra				# Retorna da função
		
# Impede a atualização do ponteiro do topo da lista com um endereço nulo
remover_aux:
		sw t1, 0(t0)			# t0 recebe valor nulo
		addi s1, s1, -1 		# Decrementa o tamanho da lista
		jr ra				# Retorna da função

#-------------------------------------------------------------
# Função lista_topo
# Retorna o elemento no topo da lista
# Parâmetros: N/A
# Retornos:
# - a0: elemento no topo da lista
# - a1: configura o sucesso da operação. 0 = sucesso, 1 = falha
#-------------------------------------------------------------
lista_topo: 
		# Retorna que a operação falhou (lista vazia ou não criada)
		beq zero, s1, falha 		# Se tamanho da lista for nulo, retorna que a operação falhou
		lw t0, 0(s0)			# t0 recebe ponteiro para topo da lista
		beq zero, t0, falha		# Se endereço for nulo, operação falhou
		
		# Retorna ponteiro para o topo da lista
		lw a0, 0(t0)			# a0 recebe ponteiro para o topo da lista
		add a1, zero, zero 		# a1 <- 0, indicando sucesso na operação
		jr ra				# Retorna da função
		
# Retorna que a operação lista_topo falhou
falha:
		li a1, 1			# a1 <- 1, indicando que a operação falhou
		jr ra				# Retorna da função
		
# Retorna da função
retorno:
		jr ra

# FIM DAS FUNÇÕES REFERENTES A LISTA
