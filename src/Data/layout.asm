# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: layout.asm
# Descricao: Constantes do layout de memoria dos apartamentos e
#            a tabela global ap_table (24 blocos de AP).
#            PROPOSTA: precisa ser confirmada pelo grupo.
# Obs: este arquivo deve ser incluido UMA unica vez, pelo main.asm,
#      antes de todos os outros (.include).
# ==============================================================

# ---- Constantes gerais (.eqv funciona como um "define") ----
.eqv N_APS          24      # 12 andares x 2 apartamentos por andar
.eqv MAX_MORADORES  6       # maximo de moradores por apartamento
.eqv NOME_TAM       32      # bytes por slot de nome (31 caracteres + NULL)

# ---- Layout de UM bloco de apartamento (offsets em bytes) ----
.eqv AP_QTD_MOR     0       # word: quantidade de moradores (0 a 6)
.eqv AP_NOMES       4       # 6 slots de 32 bytes: nomes dos moradores (compactados)
.eqv AP_AUTOS       196     # inicio da area de automoveis (4 + 6*32); definida pelo Brenno
.eqv AP_AUTOS_TAM   140     # tamanho da area de automoveis (ate o fim do bloco)
.eqv AP_TAM         336     # tamanho total de um bloco de AP (196 + 140)

.data
.align 2                                # alinha em palavra (necessario para lw/sw)
.globl ap_table
ap_table: .space 8064                   # 24 APs x 336 bytes (tudo comeca zerado = AP vazio)
