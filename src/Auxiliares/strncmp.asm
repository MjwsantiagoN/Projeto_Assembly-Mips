# ==============================================================
# Grupo: Brenno, João, Letícia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organização de Computadores
# Semestre letivo: 2026.2
# Arquivo: strncmp.asm
# Descrição: Função strncmp: compara no máximo num caracteres de duas strings.
# Convenção: argumentos em $a0-$a2, retorno em $v0.
# Usa apenas $t0, $t1 e $a0-$a2 (não usa a pilha).
# ==============================================================

.text
.globl strncmp # Torna o rótulo visível para os outros arquivos

# $a0 = endereço de str1
# $a1 = endereço de str2
# $a2 = num (máximo de caracteres a comparar; antes era $a3)
# $v0 = 0 se iguais nos num primeiros; diferença dos bytes caso contrário

strncmp:
    beq  $a2, $zero, strncmp_igual  # Se num é zero, não há o que comparar

strncmp_loop:
    lbu  $t0, 0($a0)                # Carrega um byte da primeira string
    lbu  $t1, 0($a1)                # Carrega um byte da segunda string
    bne  $t0, $t1, strncmp_diferente # Se os bytes diferem, sai com a diferença
    beq  $t0, $zero, strncmp_igual  # Se ambos são NULL, as strings são iguais
    addi $a0, $a0, 1                # Avança na primeira string
    addi $a1, $a1, 1                # Avança na segunda string
    addi $a2, $a2, -1               # Decrementa o contador de caracteres
    bne  $a2, $zero, strncmp_loop   # Se ainda restam caracteres, continua

strncmp_igual:
    li   $v0, 0                     # Resultado = 0 (iguais)
    jr   $ra                        # Retorna para quem chamou

strncmp_diferente:
    sub  $v0, $t0, $t1              # Resultado = byte1 - byte2
    jr   $ra                        # Retorna para quem chamou
