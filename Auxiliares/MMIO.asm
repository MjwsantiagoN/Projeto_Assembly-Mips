# ==============================================================
# Grupo: Brenno, João, Letícia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organização de Computadores
# Semestre letivo: 2026.2
# Arquivo: MMIO_1.asm
# Descrição: Eco de teclado usando Keyboard e Display MMIO do MARS.
#            Aguarda (polling) um caractere no teclado em 0xFFFF0000/0xFFFF0004
#            e o escreve no display em 0xFFFF0008/0xFFFF000C, repetindo
#            indefinidamente. (Requer "Keyboard and Display MMIO Simulator"
#            conectado ao programa.)
# ==============================================================


.data

.text

main:

    # Carrega o endereço do registrador de controle do teclado MMIO em $t0.
    # O bit 0 indica se existe um caractere disponível.
    li $t0, 0xFFFF0000

    # Carrega o endereço do registrador de dados do teclado MMIO em $t1.
    # O caractere digitado será lido deste endereço.
    li $t1, 0xFFFF0004

    # Carrega o endereço do registrador de controle do display MMIO em $t2.
    # O bit 0 indica se o display está disponível.
    li $t2, 0xFFFF0008

    # Carrega o endereço do registrador de dados do display MMIO em $t3.
    # O caractere será escrito neste endereço.
    li $t3, 0xFFFF000C

poll_keyboard:

    # Lê o registrador de controle do teclado.
    lw $t4, 0($t0)

    # Mantém somente o bit 0 do registrador.
    # Se o resultado for 0, não existe caractere disponível.
    andi $t4, $t4, 1

    # Se não houver caractere disponível,
    # volta para continuar verificando o teclado.
    beq $t4, $zero, poll_keyboard

    # Lê o caractere disponível no teclado.
    # O caractere será armazenado em $t5.
    lw $t5, 0($t1)

poll_display:

    # Lê o registrador de controle do display.
    lw $t4, 0($t2)

    # Mantém somente o bit 0 do registrador.
    # Se o resultado for 0, o display está ocupado.
    andi $t4, $t4, 1

    # Se o display estiver ocupado,
    # continua verificando até ficar disponível.
    beq $t4, $zero, poll_display

    # O display está disponível.
    # Escreve o caractere lido no registrador de dados do display.
    sw $t5, 0($t3)

    # Volta para verificar o teclado novamente e aguardar o próximo caractere.
    j poll_keyboard

