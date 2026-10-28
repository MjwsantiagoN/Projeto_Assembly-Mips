# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: memcpy.asm
# Descricao: Funcao memcpy: copia exatamente num bytes da origem para o destino.
# Convencao: argumentos em $a0-$a2, retorno em $v0.
#            Usa apenas $t0, $t1 e $a0-$a2 (nao usa a pilha).
# ==============================================================

.text                           # Segmento de codigo
.globl memcpy                       # Torna o rótulo visível para os outros arquivos

# $a0 = endereço de destination
# $a1 = endereço de source
# $a2 = num (quantidade de bytes)
# $v0 = endereço original de destination
memcpy:                         # Entrada de memcpy
    move $t0, $a0                   # Guarda o endereço original do destino em $t0
    beq  $a2, $zero, memcpy_fim     # Se num é zero, não copia nada

memcpy_loop:                    # Laco: copia um byte por iteracao
    lbu  $t1, 0($a1)                # Carrega um byte da origem
    sb   $t1, 0($a0)                # Copia o byte para o destino
    addi $a1, $a1, 1                # Avança o ponteiro da origem
    addi $a0, $a0, 1                # Avança o ponteiro do destino
    addi $a2, $a2, -1               # Decrementa a quantidade restante
    bne  $a2, $zero, memcpy_loop    # Continua enquanto houver bytes

memcpy_fim:                     # Fim: retorna o destino original
    move $v0, $t0                   # Retorna o endereço original do destino
    jr   $ra                        # Retorna para quem chamou
