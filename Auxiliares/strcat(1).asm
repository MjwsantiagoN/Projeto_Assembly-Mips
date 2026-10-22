# ==============================================================
# Grupo: Brenno, João, Letícia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organização de Computadores
# Semestre letivo: 2026.2
# Arquivo: strcat.asm
# Descrição: Função strcat: acrescenta a string source ao final de destination.
# Convenção: argumentos em $a0-$a2, retorno em $v0.
# Usa apenas $t0, $t1 e $a0-$a2 (não usa a pilha).
# ==============================================================

.text
.globl strcat                       # Torna o rótulo visível para os outros arquivos

# $a0 = endereço de destination (deve ter espaço suficiente)
# $a1 = endereço de source
# $v0 = endereço original de destination
strcat:
    move $t0, $a0                   # Guarda o endereço original do destino em $t0

strcat_procurar_fim:
    lbu  $t1, 0($a0)                # Carrega um byte do destino
    beq  $t1, $zero, strcat_copiar  # Se for NULL, achou o fim do destino
    addi $a0, $a0, 1                # Avança o ponteiro do destino
    j    strcat_procurar_fim        # Continua procurando o NULL

strcat_copiar:
    lbu  $t1, 0($a1)                # Carrega um byte da origem
    sb   $t1, 0($a0)                # Copia o byte para o final do destino
    beq  $t1, $zero, strcat_fim     # Se o byte for NULL, terminou
    addi $a1, $a1, 1                # Avança o ponteiro da origem
    addi $a0, $a0, 1                # Avança o ponteiro do destino
    j    strcat_copiar              # Volta para copiar o próximo byte

strcat_fim:
    move $v0, $t0                   # Retorna o endereço original do destino
    jr   $ra                        # Retorna para quem chamou
