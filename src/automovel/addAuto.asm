# ==============================================================
# Universidade Federal Rural de Pernambuco - UFRPE
# Departamento de Estatistica e Informatica - DEINFO
# Disciplina: Arquitetura e Organizacao de Computadores - 2026.2
# Professor: Vitor A. Coutinho
# Atividade: Projeto 01 (PE1 da 1a VA) - Assembly MIPS e MARS
# Grupo: LBFM (Leticia, Brenno, Ferraz, Marcos)
# Arquivo: addAuto.asm
# Autor: Brenno Leite (brennolpereira@outlook.com.br)
# Descricao: Rotinas de validacao de capacidade de garagem e insercao
#            de automoveis no registro do apartamento.
#            Cada AP suporta no maximo 1 carro OU ate 3 motos.
# ==============================================================
# Contrato de addAuto_validar_capacidade:
# Argumentos:
#   $a0 = Endereco base do registro do apartamento na memoria.
#         Offset +296: num_veiculos (word, 0 a 3)
#         Offset +300: tipo_veiculo (word, 0 = vazio, 'c' = 99, 'm' = 109)
#   $a1 = Tipo do automovel a ser adicionado ('c'/'C' = carro, 'm'/'M' = moto).
# Retornos:
#   $v0 = Codigo de status da validacao:
#          0: Sucesso / Vaga disponivel conforme regras do condominio.
#         -1: Falha: tipo invalido (diferente de 'c', 'C', 'm', 'M' ou AP nulo/invalido).
#         -2: Falha: AP com numero maximo de automoveis (ou incompatibilidade).
#   $v1 = Tipo normalizado ('c' = 99 ou 'm' = 109) em caso de sucesso.
# Preservacao:
#   Preserva os argumentos $a0, $a1 e todos os registradores salvos $s0-$s7.
#   Modifica apenas os temporarios $t0-$t5 e os retornos $v0-$v1.
# Compatibilidade:
#   100% compativel com Delayed Branching ativado (nop em delay slots).
# ==============================================================

# Constantes de configuracao da estrutura de automoveis e slots (48 bytes por slot)
.eqv AP_OFF_NUM_VEICULOS 296       # Deslocamento do contador de veiculos no registro do AP
.eqv AP_OFF_TIPO_VEICULO 300       # Deslocamento do tipo geral de veiculo no registro do AP
.eqv AP_OFF_VEICULOS     304       # Deslocamento do array de 3 slots de veiculos no AP
.eqv VEIC_SLOT_SIZE       48       # Tamanho total em bytes de cada slot de automovel
.eqv VEIC_OFF_TIPO         0       # Deslocamento do tipo dentro do slot (word: 'c', 'm' ou 0)
.eqv VEIC_OFF_MODELO       4       # Deslocamento da string do modelo dentro do slot (32 bytes)
.eqv VEIC_OFF_PLACA       36       # Deslocamento da string da placa dentro do slot (12 bytes)
.eqv VEIC_MAX_MODELO      32       # Capacidade maxima do buffer de modelo (incluindo '\0')
.eqv VEIC_MAX_PLACA       12       # Capacidade maxima do buffer de placa (incluindo '\0')
.eqv MAX_CARROS_POR_AP     1       # Limite maximo regulamentar de carros por apartamento
.eqv MAX_MOTOS_POR_AP      3       # Limite maximo regulamentar de motos por apartamento
.eqv ASCII_CHAR_C_MIN     99       # Codigo ASCII do caractere 'c' (carro minusculo)
.eqv ASCII_CHAR_C_MAI     67       # Codigo ASCII do caractere 'C' (carro maiusculo)
.eqv ASCII_CHAR_M_MIN    109       # Codigo ASCII do caractere 'm' (moto minuscula)
.eqv ASCII_CHAR_M_MAI     77       # Codigo ASCII do caractere 'M' (moto maiuscula)

.text                              # Segmento de codigo executavel
.globl addAuto_validar_capacidade  # Torna a rotina de validacao acessivel globalmente

addAuto_validar_capacidade:        # Ponto de entrada da rotina de validacao
    beq   $a0, $zero, val_tipo_invalido # Se o endereco do AP for nulo, rejeita com erro
    nop                            # Preenche o delay slot do desvio condicional

    # Identificacao e normalizacao do tipo solicitado em $a1
    li    $t1, ASCII_CHAR_C_MIN    # Carrega valor ASCII 'c' (99)
    beq   $a1, $t1, val_tipo_carro # Se $a1 == 'c', trata como carro
    nop                            # Preenche o delay slot do desvio condicional

    li    $t1, ASCII_CHAR_C_MAI    # Carrega valor ASCII 'C' (67)
    beq   $a1, $t1, val_tipo_carro # Se $a1 == 'C', normaliza para carro
    nop                            # Preenche o delay slot do desvio condicional

    li    $t1, ASCII_CHAR_M_MIN    # Carrega valor ASCII 'm' (109)
    beq   $a1, $t1, val_tipo_moto  # Se $a1 == 'm', trata como moto
    nop                            # Preenche o delay slot do desvio condicional

    li    $t1, ASCII_CHAR_M_MAI    # Carrega valor ASCII 'M' (77)
    beq   $a1, $t1, val_tipo_moto  # Se $a1 == 'M', normaliza para moto
    nop                            # Preenche o delay slot do desvio condicional

    j     val_tipo_invalido        # Se nao coincidir com nenhum caractere valido, falha
    nop                            # Preenche o delay slot do salto incondicional

val_tipo_carro:                    # Bloco de normalizacao para tipo CARRO
    li    $t0, ASCII_CHAR_C_MIN    # $t0 recebe 'c' (tipo normalizado)
    j     val_checar_regras        # Prossegue para validacao das regras do condominio
    nop                            # Preenche o delay slot do salto incondicional

val_tipo_moto:                     # Bloco de normalizacao para tipo MOTO
    li    $t0, ASCII_CHAR_M_MIN    # $t0 recebe 'm' (tipo normalizado)
    j     val_checar_regras        # Prossegue para validacao das regras do condominio
    nop                            # Preenche o delay slot do salto incondicional

val_checar_regras:                 # Inicia verificacao das regras de vagas da garagem
    lw    $t2, AP_OFF_NUM_VEICULOS($a0) # Le quantidade atual de veiculos do AP (offset 296)
    lw    $t3, AP_OFF_TIPO_VEICULO($a0) # Le tipo atual de veiculo registrado no AP (offset 300)

    # Validacao de integridade: quantidade de veiculos nao pode ser negativa
    bltz  $t2, val_tipo_invalido   # Se num_veiculos < 0, registro do AP esta corrompido
    nop                            # Preenche o delay slot do desvio condicional

    # Se num_veiculos == 0, o apartamento esta sem veiculos (garagem totalmente livre):
    # Qualquer tipo valido (carro ou moto) e permitido de imediato.
    # Isso assegura que valores residuais em tipo_veiculo nao bloqueiem moto indevidamente.
    beqz  $t2, val_sucesso         # Se num_veiculos == 0, vaga livre garantida
    nop                            # Preenche o delay slot do desvio condicional

    # A partir deste ponto, num_veiculos > 0 (ja ha veiculo cadastrado no AP)
    li    $t1, ASCII_CHAR_C_MIN    # Carrega 'c' para comparacao
    bne   $t0, $t1, val_regras_moto # Se nao for carro, desvia para checar regras de moto
    nop                            # Preenche o delay slot do desvio condicional

    # Regras para CARRO (com num_veiculos > 0):
    # 1. Cada AP pode ter no maximo 1 carro.
    # 2. Mutua exclusao: nao pode ter carro se ja houver qualquer veiculo (carro ou moto).
    # Como num_veiculos > 0, novo carro e sempre proibido.
    j     val_max_atingido         # AP ja atingiu o maximo de carros / incompatibilidade
    nop                            # Preenche o delay slot do salto incondicional

val_regras_moto:                   # Regras para MOTO (com num_veiculos > 0):
    # 1. Mutua exclusao: se o AP ja tiver carro cadastrado ('c' ou 'C'), moto e proibida.
    li    $t4, ASCII_CHAR_C_MIN    # Carrega 'c' minusculo
    beq   $t3, $t4, val_max_atingido # Se tipo atual no AP e 'c', conflito com carro: erro
    nop                            # Preenche o delay slot do desvio condicional

    li    $t4, ASCII_CHAR_C_MAI    # Carrega 'C' maiusculo
    beq   $t3, $t4, val_max_atingido # Se tipo atual no AP e 'C', conflito com carro: erro
    nop                            # Preenche o delay slot do desvio condicional

    # Verificacao adicional de seguranca no slot 0: confirma se o primeiro veiculo e carro
    lw    $t4, AP_OFF_VEICULOS($a0)        # Le tipo gravado no primeiro slot (offset 304 + 0)
    li    $t5, ASCII_CHAR_C_MIN    # Carrega 'c' minusculo
    beq   $t4, $t5, val_max_atingido # Se slot 0 contem 'c', conflito com carro: erro
    nop                            # Preenche o delay slot do desvio condicional

    li    $t5, ASCII_CHAR_C_MAI    # Carrega 'C' maiusculo
    beq   $t4, $t5, val_max_atingido # Se slot 0 contem 'C', conflito com carro: erro
    nop                            # Preenche o delay slot do desvio condicional

    # 2. Capacidade: cada AP pode ter no maximo 3 motos.
    li    $t4, MAX_MOTOS_POR_AP    # Carrega limite maximo de motos (3)
    bge   $t2, $t4, val_max_atingido # Se num_veiculos >= 3, limite da garagem atingido
    nop                            # Preenche o delay slot do desvio condicional

    j     val_sucesso              # Vaga disponivel e compativel com moto
    nop                            # Preenche o delay slot do salto incondicional

val_sucesso:                       # Finalizacao com sucesso
    li    $v0, 0                   # Define codigo de retorno 0 (OK)
    move  $v1, $t0                 # Retorna em $v1 o tipo normalizado ('c' ou 'm')
    jr    $ra                      # Retorna ao chamador
    nop                            # Preenche o delay slot do salto de retorno

val_tipo_invalido:                 # Tratamento de erro de tipo invalido
    li    $v0, -1                  # Define codigo de retorno -1 (tipo invalido)
    li    $v1, 0                   # Zera retorno secundario
    jr    $ra                      # Retorna ao chamador
    nop                            # Preenche o delay slot do salto de retorno

val_max_atingido:                  # Tratamento de erro de capacidade maxima
    li    $v0, -2                  # Define codigo de retorno -2 (AP com maximo de veiculos)
    li    $v1, 0                   # Zera retorno secundario
    jr    $ra                      # Retorna ao chamador
    nop                            # Preenche o delay slot do salto de retorno
