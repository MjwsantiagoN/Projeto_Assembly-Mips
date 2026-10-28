# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: layout.asm
# Descricao: Constantes do layout de memoria dos apartamentos e
#            LAYOUT UNICO DO GRUPO (usado por addAuto, rmvAuto, addMorador, rmvMorador,
#            limparAp, infoAp e Data/*). A tabela ap_tabela fica no main.asm.
# Obs: este arquivo deve ser incluido UMA unica vez, pelo main.asm,
#      antes de todos os outros (.include).
# ==============================================================

# ---- Constantes gerais (.eqv funciona como um "define") ----
.eqv N_APS          24      # 12 andares x 2 apartamentos por andar
.eqv MAX_MORADORES  6       # maximo de moradores por apartamento
.eqv NOME_TAM       48      # bytes por slot de nome (47 caracteres + NULL)

# ---- Layout de UM bloco de apartamento (offsets em bytes) ----
.eqv AP_ID          0       # word: numero do AP (101, 102, 201, ..., 1202)
.eqv AP_QTD_MOR     4       # word: quantidade de moradores (0 a 6); 0 = AP vazio
.eqv AP_NOMES       8       # 6 slots de 48 bytes: nomes dos moradores (compactados), ate +295
.eqv AP_AUTOS       296     # inicio da garagem: +296 qtd veiculos, +300 tipo, +304 tres slots de 48 bytes
.eqv AP_AUTOS_TAM   152     # tamanho da garagem (296 ate 447)
.eqv AP_TAM         448     # tamanho total de um bloco de AP (= passo da tabela)
.eqv COND_TAM       10752   # tamanho de toda a tabela: 24 APs x 448 bytes
# ---- Detalhes da garagem (a partir de AP_AUTOS) ----
.eqv AP_AUTOS_TIPO   300     # word: tipo geral dos veiculos ('c' = 99 ou 'm' = 109)
.eqv AP_AUTOS_SLOTS  304     # inicio dos 3 slots de veiculo
.eqv AUTO_SLOT_TAM   48      # bytes por slot de veiculo
.eqv AUTO_OFF_MODELO 4       # modelo dentro do slot (string, 32 bytes)
.eqv AUTO_OFF_PLACA  36      # placa dentro do slot (string, 12 bytes)
