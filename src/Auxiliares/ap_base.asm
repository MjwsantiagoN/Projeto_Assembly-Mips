# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: ap_base.asm
# Descricao: Converte o indice do AP (0..23) no endereco do bloco desse AP em ap_tabela.
# Convencao: argumento em $a0, retorno em $v0. Usa apenas $t0 e $a0 (sem pilha).
# Depende: constante AP_TAM (layout.asm) e rotulo ap_tabela (main.asm).
# ==============================================================

.text                           # Segmento de codigo
.globl ap_base                  # Torna ap_base visivel para os outros arquivos

# $a0 = indice do AP (0 a 23)
# $v0 = endereco do bloco desse AP dentro de ap_tabela
ap_base:                        # Entrada da rotina ap_base
    li   $t0, AP_TAM                # t0 = tamanho de um bloco
    mul  $t0, $a0, $t0              # t0 = indice * tamanho do bloco
    la   $v0, ap_tabela             # v0 = endereco inicial da tabela
    add  $v0, $v0, $t0              # v0 = endereco do bloco do AP
    jr   $ra                        # retorna
