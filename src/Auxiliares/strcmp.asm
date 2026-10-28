# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: strcmp.asm
# Descricao: Funcao strcmp: compara duas strings caractere por caractere.
# Convencao: argumentos em $a0-$a2, retorno em $v0.
#            Usa apenas $t0, $t1 e $a0-$a2 (nao usa a pilha).
# ==============================================================

.text                           # Segmento de codigo
.globl strcmp                       # Torna o rótulo visível para os outros arquivos

# $a0 = endereço de str1
# $a1 = endereço de str2
# $v0 = 0 se iguais; diferença dos bytes (str1 - str2) se diferentes
strcmp:                         # Entrada de strcmp

strcmp_loop:                    # Laco: compara um par de caracteres
    lbu  $t0, 0($a0)                # Carrega um byte da primeira string
    lbu  $t1, 0($a1)                # Carrega um byte da segunda string
    bne  $t0, $t1, strcmp_diferente # Se os bytes diferem, sai com a diferença
    beq  $t0, $zero, strcmp_igual   # Se ambos são NULL, as strings são iguais
    addi $a0, $a0, 1                # Avança na primeira string
    addi $a1, $a1, 1                # Avança na segunda string
    j    strcmp_loop                # Continua a comparação

strcmp_diferente:               # Caracteres diferentes: retorna a diferenca
    sub  $v0, $t0, $t1              # Resultado = byte1 - byte2
    jr   $ra                        # Retorna para quem chamou

strcmp_igual:                   # Strings iguais: retorna 0
    li   $v0, 0                     # Resultado = 0 (iguais)
    jr   $ra                        # Retorna para quem chamou
