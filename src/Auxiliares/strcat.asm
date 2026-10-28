# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: strcat.asm
# Descricao: Funcao strcat: acrescenta a string source ao final de destination.
# Convencao: argumentos em $a0-$a2, retorno em $v0.
#            Usa apenas $t0, $t1 e $a0-$a2 (nao usa a pilha).
# ==============================================================

.text                           # Segmento de codigo
.globl strcat                       # Torna o rótulo visível para os outros arquivos

# $a0 = endereço de destination (deve ter espaço suficiente)
# $a1 = endereço de source
# $v0 = endereço original de destination
strcat:                         # Entrada de strcat
    move $t0, $a0                   # Guarda o endereço original do destino em $t0

strcat_procurar_fim:            # Procura o NULL do final do destino
    lbu  $t1, 0($a0)                # Carrega um byte do destino
    beq  $t1, $zero, strcat_copiar  # Se for NULL, achou o fim do destino
    addi $a0, $a0, 1                # Avança o ponteiro do destino
    j    strcat_procurar_fim        # Continua procurando o NULL

strcat_copiar:                  # Copia a origem (com o NULL) a partir do fim do destino
    lbu  $t1, 0($a1)                # Carrega um byte da origem
    sb   $t1, 0($a0)                # Copia o byte para o final do destino
    beq  $t1, $zero, strcat_fim     # Se o byte for NULL, terminou
    addi $a1, $a1, 1                # Avança o ponteiro da origem
    addi $a0, $a0, 1                # Avança o ponteiro do destino
    j    strcat_copiar              # Volta para copiar o próximo byte

strcat_fim:                     # Fim: retorna o destino
    move $v0, $t0                   # Retorna o endereço original do destino
    jr   $ra                        # Retorna para quem chamou
