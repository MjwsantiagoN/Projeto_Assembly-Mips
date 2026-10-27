# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: ap_base.asm
# Descricao: Converte o indice do AP (0..23) no endereco do bloco desse AP em ap_table.
# Convencao: argumento em $a0, retorno em $v0. Usa apenas $t0 e $a0 (sem pilha).
# Depende: constante AP_TAM e rotulo ap_table (layout.asm).
# ==============================================================

.text
.globl ap_base

# $a0 = indice do AP (0 a 23)
# $v0 = endereco do bloco desse AP dentro de ap_table
ap_base:
    li   $t0, AP_TAM                # t0 = tamanho de um bloco
    mul  $t0, $a0, $t0              # t0 = indice * tamanho do bloco
    la   $v0, ap_table              # v0 = endereco inicial da tabela
    add  $v0, $v0, $t0              # v0 = endereco do bloco do AP
    jr   $ra                        # retorna
