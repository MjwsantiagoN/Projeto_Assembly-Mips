# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: strlen.asm
# Descricao: Funcao strlen: conta os caracteres de uma string (sem contar o NULL).
# Convencao: argumento em $a0, retorno em $v0. Usa apenas $t0, $t1 e $a0 (sem pilha).
# ==============================================================

.text
.globl strlen                       # Torna o rotulo visivel para os outros arquivos

# $a0 = endereco da string (terminada em NULL)
# $v0 = quantidade de caracteres (sem o NULL)
strlen:
    li   $v0, 0                     # contador = 0

strlen_loop:
    add  $t0, $a0, $v0              # t0 = endereco do caractere atual
    lbu  $t1, 0($t0)                # le o caractere
    beq  $t1, $zero, strlen_fim     # NULL: terminou
    addi $v0, $v0, 1                # conta mais um caractere
    j    strlen_loop                # repete

strlen_fim:
    jr   $ra                        # retorna para quem chamou
