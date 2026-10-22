# ==============================================================
# Grupo: Brenno, João, Letícia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organização de Computadores
# Semestre letivo: 2026.2
# Arquivo: strcpy.asm
# Descrição: Função strcpy: copia uma string (com o NULL) da origem para o destino.
# Convenção: argumentos em $a0-$a2, retorno em $v0.
# Usa apenas $t0, $t1 e $a0-$a2 (não usa a pilha).
# ==============================================================

.text
.globl strcpy                       # Torna o rótulo visível para os outros arquivos

# $a0 = endereço de destination
# $a1 = endereço de source
# $v0 = endereço original de destination
strcpy:
    move $t0, $a0                   # Guarda o endereço original do destino em $t0

strcpy_loop:
    lbu  $t1, 0($a1)                # Carrega um byte da origem
    sb   $t1, 0($a0)                # Copia o byte para o destino
    beq  $t1, $zero, strcpy_fim     # Se o byte for NULL, terminou a cópia
    addi $a1, $a1, 1                # Avança o ponteiro da origem
    addi $a0, $a0, 1                # Avança o ponteiro do destino
    j    strcpy_loop                # Volta para copiar o próximo byte

strcpy_fim:
    move $v0, $t0                   # Retorna o endereço original do destino
    jr   $ra                        # Retorna para quem chamou
