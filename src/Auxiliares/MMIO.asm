# Grupo: LBFM (Leticia, Brenno, Ferraz, Marcos)
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

.eqv MMIO_KBD_CTRL   0xFFFF0000
.eqv MMIO_KBD_DATA   0xFFFF0004
.eqv MMIO_DSP_CTRL   0xFFFF0008
.eqv MMIO_DSP_DATA   0xFFFF000C

.data
mmio_numbuf: .space 12              # buffer de mmio_print_int

.text

# mmio_getchar: espera uma tecla. $v0 = caractere
mmio_getchar:
    li   $t0, MMIO_KBD_CTRL
mmio_getchar_poll:
    lw   $t1, 0($t0)
    andi $t1, $t1, 1
    beq  $t1, $zero, mmio_getchar_poll
    li   $t0, MMIO_KBD_DATA
    lw   $v0, 0($t0)                # ler o dado zera o bit de pronto
    jr   $ra

# mmio_putchar: espera o display ficar livre e escreve um caractere. $a0 = caractere
mmio_putchar:
    li   $t0, MMIO_DSP_CTRL
mmio_putchar_poll:
    lw   $t1, 0($t0)
    andi $t1, $t1, 1
    beq  $t1, $zero, mmio_putchar_poll
    li   $t0, MMIO_DSP_DATA
    sw   $a0, 0($t0)
    jr   $ra

# mmio_print_string: escreve uma string terminada em NUL. $a0 = endereco
mmio_print_string:
    move $t2, $a0
mmio_print_string_loop:
    lbu  $t3, 0($t2)
    beq  $t3, $zero, mmio_print_string_fim
    li   $t0, MMIO_DSP_CTRL
mmio_print_string_poll:
    lw   $t1, 0($t0)
    andi $t1, $t1, 1
    beq  $t1, $zero, mmio_print_string_poll
    li   $t0, MMIO_DSP_DATA
    sw   $t3, 0($t0)
    addi $t2, $t2, 1
    j    mmio_print_string_loop
mmio_print_string_fim:
    jr   $ra

# mmio_print_int: escreve um inteiro com sinal em decimal. $a0 = valor
mmio_print_int:
    addi $sp, $sp, -8
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    li   $s0, 0                     # flag de sinal
    la   $t4, mmio_numbuf
    addi $t4, $t4, 11
    sb   $zero, 0($t4)
    bge  $a0, $zero, mmio_print_int_conv
    li   $s0, 1
    sub  $a0, $zero, $a0
mmio_print_int_conv:
    li   $t5, 10
mmio_print_int_loop:
    divu $a0, $t5
    mfhi $t2
    mflo $a0
    addi $t2, $t2, 48
    addi $t4, $t4, -1
    sb   $t2, 0($t4)
    bne  $a0, $zero, mmio_print_int_loop
    beq  $s0, $zero, mmio_print_int_out
    addi $t4, $t4, -1
    li   $t2, 45                    # '-'
    sb   $t2, 0($t4)
mmio_print_int_out:
    move $a0, $t4
    jal  mmio_print_string
    lw   $s0, 4($sp)
    lw   $ra, 0($sp)
    addi $sp, $sp, 8
    jr   $ra

# mmio_read_line: le uma linha do teclado ate o Enter, sem eco no display.
# Backspace (8 ou 127) remove o ultimo caractere do buffer. Excesso e descartado.
# $a0 = buffer, $a1 = capacidade (com o NUL), $v0 = quantidade de caracteres
mmio_read_line:
    addi $sp, $sp, -20
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $s2, 12($sp)
    sw   $s3, 16($sp)
    move $s0, $a0                   # inicio do buffer
    addi $s1, $a1, -1               # maximo de caracteres
    li   $s2, 0                     # caracteres lidos
mmio_read_line_loop:
    jal  mmio_getchar
    move $s3, $v0
    li   $t0, 10
    beq  $s3, $t0, mmio_read_line_fim   # Enter
    li   $t0, 13
    beq  $s3, $t0, mmio_read_line_fim   # CR tratado como Enter
    li   $t0, 8
    beq  $s3, $t0, mmio_read_line_bs
    li   $t0, 127
    beq  $s3, $t0, mmio_read_line_bs
    slti $t0, $s3, 32
    bne  $t0, $zero, mmio_read_line_loop # ignora outros caracteres de controle
    bge  $s2, $s1, mmio_read_line_loop   # buffer cheio
    add  $t0, $s0, $s2
    sb   $s3, 0($t0)
    addi $s2, $s2, 1
    j    mmio_read_line_loop
mmio_read_line_bs:
    beq  $s2, $zero, mmio_read_line_loop # nada para apagar
    addi $s2, $s2, -1
    j    mmio_read_line_loop
mmio_read_line_fim:
    add  $t0, $s0, $s2
    sb   $zero, 0($t0)
    move $v0, $s2
    lw   $s3, 16($sp)
    lw   $s2, 12($sp)
    lw   $s1, 8($sp)
    lw   $s0, 4($sp)
    lw   $ra, 0($sp)
    addi $sp, $sp, 20
    jr   $ra

# print_str: nome usado por addMorador/rmvMorador (= mmio_print_string)
print_str:
    j    mmio_print_string
