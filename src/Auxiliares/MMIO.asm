# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: MMIO.asm
# Descricao: Entrada e saida pelo Keyboard and Display MMIO do MARS (polling).
#            Teclado: controle 0xFFFF0000 (bit 0 = tecla pronta), dado 0xFFFF0004.
#            Display: controle 0xFFFF0008 (bit 0 = pronto),       dado 0xFFFF000C.
#            Requer "Tools > Keyboard and Display MMIO Simulator" com "Connect to MIPS".
#            O que o usuario digita aparece so no campo KEYBOARD do simulador (onde o
#            Backspace ja funciona); o display mostra apenas o que o programa imprime.
# Convencao: argumentos em $a0-$a1, retorno em $v0.
#            Podem alterar $t0-$t5 e $v0. $s0-$s7 sao preservados.
# ==============================================================

.eqv MMIO_KBD_CTRL   0xFFFF0000 # Registrador de controle do teclado (bit 0 = tecla pronta)
.eqv MMIO_KBD_DATA   0xFFFF0004 # Registrador de dados do teclado
.eqv MMIO_DSP_CTRL   0xFFFF0008 # Registrador de controle do display (bit 0 = pronto)
.eqv MMIO_DSP_DATA   0xFFFF000C # Registrador de dados do display

.data                           # Segmento de dados
mmio_numbuf: .space 12              # buffer de mmio_print_int

.text                           # Segmento de codigo

# mmio_getchar: espera uma tecla. $v0 = caractere
mmio_getchar:                   # Entrada de mmio_getchar
    li   $t0, MMIO_KBD_CTRL     # $t0 = endereco do controle do teclado
mmio_getchar_poll:              # Laco de polling: espera uma tecla
    lw   $t1, 0($t0)            # Le o registrador de controle
    andi $t1, $t1, 1            # Isola o bit 0 (tecla pronta)
    beq  $t1, $zero, mmio_getchar_poll  # Bit 0 = 0: nenhuma tecla, continua esperando
    li   $t0, MMIO_KBD_DATA     # $t0 = endereco do dado do teclado
    lw   $v0, 0($t0)                # ler o dado zera o bit de pronto
    jr   $ra                    # Retorna ($v0 = caractere)

# mmio_putchar: espera o display ficar livre e escreve um caractere. $a0 = caractere
mmio_putchar:                   # Entrada de mmio_putchar
    li   $t0, MMIO_DSP_CTRL     # $t0 = endereco do controle do display
mmio_putchar_poll:              # Laco de polling: espera o display ficar livre
    lw   $t1, 0($t0)            # Le o registrador de controle
    andi $t1, $t1, 1            # Isola o bit 0 (display pronto)
    beq  $t1, $zero, mmio_putchar_poll  # Bit 0 = 0: display ocupado, continua esperando
    li   $t0, MMIO_DSP_DATA     # $t0 = endereco do dado do display
    sw   $a0, 0($t0)            # Escreve o caractere (aparece no display)
    jr   $ra                    # Retorna

# mmio_print_string: escreve uma string terminada em NUL. $a0 = endereco
mmio_print_string:              # Entrada de mmio_print_string
    move $t2, $a0               # $t2 percorre a string
mmio_print_string_loop:         # Laco: imprime um caractere por iteracao
    lbu  $t3, 0($t2)            # Caractere atual
    beq  $t3, $zero, mmio_print_string_fim  # NUL: terminou a string
    li   $t0, MMIO_DSP_CTRL     # $t0 = endereco do controle do display
mmio_print_string_poll:         # Espera o display ficar livre
    lw   $t1, 0($t0)            # Le o registrador de controle
    andi $t1, $t1, 1            # Isola o bit 0 (display pronto)
    beq  $t1, $zero, mmio_print_string_poll  # Display ocupado: continua esperando
    li   $t0, MMIO_DSP_DATA     # $t0 = endereco do dado do display
    sw   $t3, 0($t0)            # Escreve o caractere no display
    addi $t2, $t2, 1            # Proximo caractere
    j    mmio_print_string_loop # Repete
mmio_print_string_fim:          # Fim da string
    jr   $ra                    # Retorna

# mmio_print_int: escreve um inteiro com sinal em decimal. $a0 = valor
mmio_print_int:                 # Entrada de mmio_print_int
    addi $sp, $sp, -8           # Reserva 8 bytes na pilha
    sw   $ra, 0($sp)            # Salva o endereco de retorno
    sw   $s0, 4($sp)            # Salva $s0 (flag de sinal)
    li   $s0, 0                     # flag de sinal
    la   $t4, mmio_numbuf       # $t4 = inicio do buffer de digitos
    addi $t4, $t4, 11           # Aponta para o fim do buffer (12 bytes)
    sb   $zero, 0($t4)          # Grava o NUL final
    bge  $a0, $zero, mmio_print_int_conv  # Valor nao negativo: vai converter
    li   $s0, 1                 # Valor negativo: marca o sinal
    sub  $a0, $zero, $a0        # Troca o sinal do valor
mmio_print_int_conv:            # Converte o valor em digitos
    li   $t5, 10                # $t5 = 10 (base decimal)
mmio_print_int_loop:            # Laco: extrai um digito por iteracao
    divu $a0, $t5               # Divide o valor por 10
    mfhi $t2                    # $t2 = resto (digito)
    mflo $a0                    # $a0 = quociente
    addi $t2, $t2, 48           # Converte o digito em ASCII
    addi $t4, $t4, -1           # Recua uma posicao no buffer
    sb   $t2, 0($t4)            # Grava o digito
    bne  $a0, $zero, mmio_print_int_loop  # Ainda ha digitos: repete
    beq  $s0, $zero, mmio_print_int_out  # Sem sinal negativo: vai imprimir
    addi $t4, $t4, -1           # Recua uma posicao para o sinal
    li   $t2, 45                    # '-'
    sb   $t2, 0($t4)            # Grava o "-" no buffer
mmio_print_int_out:             # Imprime o numero convertido
    move $a0, $t4               # $a0 = inicio do texto
    jal  mmio_print_string      # Imprime a string
    lw   $s0, 4($sp)            # Restaura $s0
    lw   $ra, 0($sp)            # Restaura o endereco de retorno
    addi $sp, $sp, 8            # Libera a pilha
    jr   $ra                    # Retorna

# mmio_read_line: le uma linha do teclado ate o Enter, sem eco no display.
# Backspace (8 ou 127) remove o ultimo caractere do buffer. Excesso e descartado.
# $a0 = buffer, $a1 = capacidade (com o NUL), $v0 = quantidade de caracteres
mmio_read_line:                 # Entrada de mmio_read_line
    addi $sp, $sp, -20          # Reserva 20 bytes na pilha
    sw   $ra, 0($sp)            # Salva o endereco de retorno
    sw   $s0, 4($sp)            # Salva $s0 (buffer)
    sw   $s1, 8($sp)            # Salva $s1 (maximo de caracteres)
    sw   $s2, 12($sp)           # Salva $s2 (caracteres lidos)
    sw   $s3, 16($sp)           # Salva $s3 (caractere atual)
    move $s0, $a0                   # inicio do buffer
    addi $s1, $a1, -1               # maximo de caracteres
    li   $s2, 0                     # caracteres lidos
mmio_read_line_loop:            # Laco: le uma tecla por iteracao
    jal  mmio_getchar           # Espera uma tecla
    move $s3, $v0               # $s3 = tecla lida
    li   $t0, 10                # 10 = Enter (LF)
    beq  $s3, $t0, mmio_read_line_fim   # Enter
    li   $t0, 13                # 13 = CR
    beq  $s3, $t0, mmio_read_line_fim   # CR tratado como Enter
    li   $t0, 8                 # 8 = Backspace
    beq  $s3, $t0, mmio_read_line_bs  # Backspace: apaga o ultimo caractere
    li   $t0, 127               # 127 = Delete
    beq  $s3, $t0, mmio_read_line_bs  # Delete: apaga o ultimo caractere
    slti $t0, $s3, 32           # Caractere de controle (< 32)?
    bne  $t0, $zero, mmio_read_line_loop # ignora outros caracteres de controle
    bge  $s2, $s1, mmio_read_line_loop   # buffer cheio
    add  $t0, $s0, $s2          # $t0 = posicao livre do buffer
    sb   $s3, 0($t0)            # Guarda o caractere no buffer
    addi $s2, $s2, 1            # Conta o caractere
    j    mmio_read_line_loop    # Volta a esperar a proxima tecla
mmio_read_line_bs:              # Tratamento do Backspace
    beq  $s2, $zero, mmio_read_line_loop # nada para apagar
    addi $s2, $s2, -1           # Um caractere a menos no buffer
    j    mmio_read_line_loop    # Volta a esperar a proxima tecla
mmio_read_line_fim:             # Fim da linha: fecha a string
    add  $t0, $s0, $s2          # $t0 = posicao final
    sb   $zero, 0($t0)          # Grava o NUL terminador
    move $v0, $s2               # $v0 = quantidade de caracteres lidos
    lw   $s3, 16($sp)           # Restaura $s3
    lw   $s2, 12($sp)           # Restaura $s2
    lw   $s1, 8($sp)            # Restaura $s1
    lw   $s0, 4($sp)            # Restaura $s0
    lw   $ra, 0($sp)            # Restaura o endereco de retorno
    addi $sp, $sp, 20           # Libera a pilha
    jr   $ra                    # Retorna

# print_str: nome usado por addMorador/rmvMorador (= mmio_print_string)
print_str:                      # Entrada de print_str (apelido de mmio_print_string)
    j    mmio_print_string      # Desvia para mmio_print_string
