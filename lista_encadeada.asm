	.data
	.align 2
pointer: .word 0 # Ponteiro da lista encadeada que aponta para o 1o elemento. Inicializado em 0
	
	.text
	.align 2
	.globl main
	
main:
	# Guarda o endereço do ponteiro em s0
	la s0, pointer
	
	jal ra, lista_criar
	# Guarda o endereço da memória alocada em pointer
	sw a0, 0(s0)
	
	li a0, 1
	jal ra, lista_inserir
	li a0, 2
	jal ra, lista_inserir
	li a0, 3
	jal ra, lista_inserir
	jal ra, lista_remover_topo
	jal ra, lista_remover_topo
	
	jal ra, lista_topo
	li a7, 1
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
	
	# Guarda o número de elementos em s1
	add s1, zero, zero
	
	jr ra
	
lista_inserir: # Insere um elemento na cabeça da lista
	# Parâmetros:
	# - a0: elemento a ser inserido
	# Retornos: N/A
	
	lw t0, 0(s0)
	beq t0, zero, retorno # Retorna se a lista não foi criada
	beq s1, zero, lista_vazia
	
	add t1, zero, a0 # Guarda o elemento em t1
	
	# Aloca memória para o novo elemento
	li a7, 9
	li a0, 8
	ecall
	
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
	
lista_remover_topo: # Remove o elemento no topo da lista
	# Parâmetros: N/A
	# Retornos: N/A
	
	# Retorna se a lista for vazia ou não criada
	lw t0, 0(s0)
	beq zero, t0, retorno
	beq zero, s1, retorno
	
	lw t0, 4(t0) # Atualiza o endereço apontado pelo elemento anterior
	sw t0, 0(s0) # Atualiza o endereço apontado pelo pointer
	
	addi s1, s1, -1 # Decrementa o tamanho da lista
	jr ra

	
lista_topo:
	# Parâmetros: N/A
	# Retornos:
	# - a0: elemento no topo da lista
	# - a1: configura o sucesso da operação. 0 = sucesso, 1 = falha
	
	beq zero, s1, falha # Retorna que a operação falhou
	lw t0, 0(s0)
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
