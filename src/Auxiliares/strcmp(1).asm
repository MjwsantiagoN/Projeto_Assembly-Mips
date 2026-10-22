# ==============================================================
# Grupo: Brenno, João, Letícia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organização de Computadores
# Semestre letivo: 2026.2
# Arquivo: strcmp.asm
# Descrição: Função strcmp: compara duas strings caractere por caractere.
# Convenção: argumentos em $a0-$a2, retorno em $v0.
# Usa apenas $t0, $t1 e $a0-$a2 (não usa a pilha).
# ==============================================================

.text
.globl strcmp                       # Torna o rótulo visível para os outros arquivos

# $a0 = endereço de str1
# $a1 = endereço de str2
# $v0 = 0 se iguais; diferença dos bytes (str1 - str2) se diferentes
strcmp:

strcmp_loop:
    lbu  $t0, 0($a0)                # Carrega um byte da primeira string
    lbu  $t1, 0($a1)                # Carrega um byte da segunda string
    bne  $t0, $t1, strcmp_diferente # Se os bytes diferem, sai com a diferença
    beq  $t0, $zero, strcmp_igual   # Se ambos são NULL, as strings são iguais
    addi $a0, $a0, 1                # Avança na primeira string
    addi $a1, $a1, 1                # Avança na segunda string
    j    strcmp_loop                # Continua a comparação

strcmp_diferente:
    sub  $v0, $t0, $t1              # Resultado = byte1 - byte2
    jr   $ra                        # Retorna para quem chamou

strcmp_igual:
    li   $v0, 0                     # Resultado = 0 (iguais)
    jr   $ra                        # Retorna para quem chamou
