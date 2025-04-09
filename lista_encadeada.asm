	.data
	.align 2
pointer: .word 0 # Ponteiro da lista encadeada que aponta para o 1o elemento. Inicializado em 0
	
	.text
	.align 2
	.globl main
	
main: # Só pra testar a lista
	jal ra, lista_criar
	jal ra, lista_topo
	jal ra, lista_remover_topo
	addi a0, zero, 1
	jal ra, lista_inserir
	jal ra ,lista_remover_topo
	jal ra, lista_remover_topo
	jal ra, lista_topo
	
	
	li a7, 1
	add a0, a1, zero
	ecall
	
	j the_end
	
lista_criar: # Aloca memória para inicializar a lista
	# Parâmetros: N/A
	# Retornos:
	# - a0: endereço do primeiro elemento da lista
	
	# Aloca 8 bytes na memória heap
	li a7, 9
	li a0, 8
	ecall
	
	# Encerra o programa se a alocação não for bem sucedida
	beq a0, zero, the_end
	
	# Guarda o endereço alocado em pointer (s0)
	la s0, pointer
	sw a0, 0(s0) 
	
	# Guarda o número de elementos em s1
	add s1, zero, zero
	jr ra
	
lista_inserir: # Insere um elemento no topo da lista
	# Parâmetros:
	# - a0: elemento a ser inserido
	# Retornos: N/A
	
	lw t0, 0(s0)
	beq t0, zero, retorno # Retorna da função se a lista não foi criada
	beq s1, zero, lista_vazia # Caso especial da inserção para lista vazia
	
	add t1, zero, a0 # Guarda o elemento em t1
	
	# Aloca memória para o novo elemento
	li a7, 9
	li a0, 8
	ecall
	
	# Encerra o programa se a alocação não for bem sucedida
	beq a0, zero, the_end
	
	sw t1, 0(a0) # Guarda o elemento no endereço alocado
	sw t0, 4(a0) # Guarda o endereço do elemento anterior nos outros 4 bytes alocados
	sw a0, 0(s0) # Pointer aponta para o novo elemento
	
	addi s1, s1, 1 # Incrementa o tamanho da lista
	jr ra

lista_vazia: # Não há necessidade de alocar memória para inserção do elemento
	sw a0, 0(t0)
	sw zero, 4(t0) # Não existe elemento anterior para ser endereçado
	addi s1, s1, 1
	jr ra
	
lista_remover_topo: # Remove um elemento no topo da lista
	# Parâmetros: N/A
	# Retornos: N/A
	
	# Retorna se a lista for vazia ou não criada
	beq zero, s1, retorno
	lw t0, 0(s0)
	beq zero, t0, retorno
	
	lw t0, 4(t0) # Atualiza t0 com endereço do elemento anterior
	# Se t0 for 0, o elemento removido era o único elemeto na lista
	# Retorna da função para não atualizar o pointer com um endereço nulo
	beq t0, zero, retorno
	sw t0, 0(s0) # Atualiza o endereço apontado pelo pointer
	
	addi s1, s1, -1 # Decrementa o tamanho da lista
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
	add a1, zero, zero # Sucesso na operação
	
	jr ra
	
falha:
	li a1, 1
	jr ra	
		
retorno:
	jr ra
	
the_end: # Encerra o programa
	li a7 10
	ecall
