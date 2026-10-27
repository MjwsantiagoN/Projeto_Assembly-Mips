# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: memzero.asm
# Descricao: Funcao memzero: zera num bytes a partir de um endereco.
# Convencao: argumentos em $a0-$a1, sem retorno. Usa apenas $a0 e $a1 (sem pilha).
# ==============================================================

.text
.globl memzero                      # Torna o rotulo visivel para os outros arquivos

# $a0 = endereco inicial
# $a1 = num (quantidade de bytes a zerar)
memzero:
    beq  $a1, $zero, memzero_fim    # Se num e zero, nao faz nada

memzero_loop:
    sb   $zero, 0($a0)              # zera um byte
    addi $a0, $a0, 1                # avanca o ponteiro
    addi $a1, $a1, -1               # um byte a menos
    bne  $a1, $zero, memzero_loop   # repete ate zerar todos

memzero_fim:
    jr   $ra                        # retorna para quem chamou
