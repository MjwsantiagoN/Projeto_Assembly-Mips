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

# ==============================================================
# Contrato de addAuto_inserir / addAuto_adicionar:
# Argumentos:
#   $a0 = Endereco base do registro do apartamento na memoria.
#   $a1 = Tipo do veiculo ('c'/'C' = carro, 'm'/'M' = moto).
#   $a2 = Endereco da string com o modelo (max 31 chars + '\0' = 32B). 0 se vazio.
#   $a3 = Endereco da string com a placa (max 11 chars + '\0' = 12B). 0 se vazio.
# Retornos:
#   $v0 = Codigo de status:
#          0: Sucesso na insercao do veiculo.
#         -1: Falha: tipo invalido ou parametro nulo.
#         -2: Falha: AP com numero maximo de automoveis (vagas esgotadas).
#   $v1 = Endereco base do slot onde o veiculo foi gravado.
# Efeitos colaterais:
#   - Grava tipo (word), modelo (32 bytes com '\0' garantido) e placa (12 bytes
#     com '\0' garantido) no proximo slot livre (offset 304 + num_veiculos * 48).
#   - Zera previamente todo o slot (48 bytes) para evitar residuos de memoria.
#   - Atualiza tipo_veiculo no offset +300 para o tipo normalizado.
#   - Incrementa o contador num_veiculos no offset +296.
# Preservacao:
#   Preserva $s0-$s7 e a integridade da pilha.
# Compatibilidade:
#   100% compativel com Delayed Branching ativado (nop em delay slots).
# ==============================================================

.globl addAuto_inserir             # Torna rotina de insercao visivel globalmente
.globl addAuto_adicionar           # Alias compativel com nome alternativo

addAuto_adicionar:                 # Ponto de entrada alias
addAuto_inserir:                   # Ponto de entrada principal
    addi  $sp, $sp, -32            # Aloca espaco no frame da pilha (32 bytes)
    sw    $ra, 28($sp)             # Salva o endereco de retorno
    sw    $s0, 24($sp)             # Salva $s0: guardara endereco base do AP
    sw    $s1, 20($sp)             # Salva $s1: guardara tipo normalizado
    sw    $s2, 16($sp)             # Salva $s2: guardara ponteiro da string modelo
    sw    $s3, 12($sp)             # Salva $s3: guardara ponteiro da string placa
    sw    $s4, 8($sp)              # Salva $s4: guardara endereco do slot alocado

    move  $s0, $a0                 # Preserva endereco base do AP em $s0
    move  $s2, $a2                 # Preserva ponteiro da string modelo em $s2
    move  $s3, $a3                 # Preserva ponteiro da string placa em $s3

    # Passo 1: Validar capacidade e tipo usando addAuto_validar_capacidade
    # $a0 ja contem o endereco base do AP; $a1 ja contem o tipo do automovel
    jal   addAuto_validar_capacidade # Executa validacao das regras do condominio
    nop                            # Preenche o delay slot da chamada

    bne   $v0, $zero, ins_falha    # Se retorno != 0, propaga codigo de erro
    nop                            # Preenche o delay slot do desvio condicional

    # Passo 2: Validacao teve sucesso (0) -> $v1 contem tipo normalizado ('c' ou 'm')
    move  $s1, $v1                 # Salva o tipo normalizado em $s1

    # Passo 3: Localizar o proximo slot de veiculo livre no AP
    # endereco_slot = AP + 304 + (num_veiculos * 48)
    lw    $t0, AP_OFF_NUM_VEICULOS($s0) # Carrega contagem atual de veiculos (0, 1 ou 2)
    li    $t1, VEIC_SLOT_SIZE      # Carrega tamanho do slot de veiculo (48 bytes)
    mul   $t2, $t0, $t1            # Deslocamento relativo = num_veiculos * 48
    addiu $s4, $s0, AP_OFF_VEICULOS # Endereco base do vetor de veiculos (offset 304)
    addu  $s4, $s4, $t2            # $s4 = endereco inicial do novo slot de veiculo

    # Passo 4: Limpar o slot inteiro de 48 bytes (12 words) com zeros
    sw    $zero, 0($s4)            # Zera word 0 (+0 a +3: tipo)
    sw    $zero, 4($s4)            # Zera word 1 (+4 a +7: modelo)
    sw    $zero, 8($s4)            # Zera word 2 (+8 a +11: modelo)
    sw    $zero, 12($s4)           # Zera word 3 (+12 a +15: modelo)
    sw    $zero, 16($s4)           # Zera word 4 (+16 a +19: modelo)
    sw    $zero, 20($s4)           # Zera word 5 (+20 a +23: modelo)
    sw    $zero, 24($s4)           # Zera word 6 (+24 a +27: modelo)
    sw    $zero, 28($s4)           # Zera word 7 (+28 a +31: modelo)
    sw    $zero, 32($s4)           # Zera word 8 (+32 a +35: modelo)
    sw    $zero, 36($s4)           # Zera word 9 (+36 a +39: placa)
    sw    $zero, 40($s4)           # Zera word 10 (+40 a +43: placa)
    sw    $zero, 44($s4)           # Zera word 11 (+44 a +47: placa)

    # Passo 5: Gravar o tipo de veiculo no offset 0 do slot
    sw    $s1, VEIC_OFF_TIPO($s4)  # Grava tipo normalizado ('c' ou 'm') na posicao +0

    # Passo 6: Copiar modelo para o slot (+4 ate +35, max 32 bytes com '\0' garantido)
    beq   $s2, $zero, ins_copiar_placa # Se ponteiro de modelo for nulo, mantem zerado
    nop                            # Preenche o delay slot do desvio condicional

    li    $t0, 0                   # Inicializa indice de copia do modelo i = 0
    li    $t1, 31                  # Limite maximo de caracteres uteis para modelo (31)
ins_copia_mod_loop:
    bge   $t0, $t1, ins_copia_mod_fim # Se atingiu 31 caracteres, encerra copia
    nop                            # Preenche o delay slot do desvio condicional

    addu  $t2, $s2, $t0            # Endereco do byte atual na string de origem ($s2 + i)
    lbu   $t3, 0($t2)              # Carrega byte da string modelo de origem
    beq   $t3, $zero, ins_copia_mod_fim # Se encontrou o terminador nulo, encerra
    nop                            # Preenche o delay slot do desvio condicional

    addu  $t4, $s4, $t0            # Endereco relativo no destino ($s4 + i)
    sb    $t3, VEIC_OFF_MODELO($t4) # Grava byte no campo modelo do slot (+4)
    addiu $t0, $t0, 1              # Incrementa indice i = i + 1
    j     ins_copia_mod_loop       # Itera para o proximo caractere
    nop                            # Preenche o delay slot do salto incondicional

ins_copia_mod_fim:
    addu  $t4, $s4, $t0            # Calcula posicao do terminador nulo no buffer
    sb    $zero, VEIC_OFF_MODELO($t4) # Assegura terminador nulo no modelo

ins_copiar_placa:                  # Passo 7: Copiar placa (+36 ate +47, max 12 bytes)
    beq   $s3, $zero, ins_atualizar_cabecalho # Se ponteiro de placa for nulo, mantem zerado
    nop                            # Preenche o delay slot do desvio condicional

    li    $t0, 0                   # Inicializa indice de copia da placa j = 0
    li    $t1, 11                  # Limite maximo de caracteres uteis para placa (11)
ins_copia_plc_loop:
    bge   $t0, $t1, ins_copia_plc_fim # Se atingiu 11 caracteres, encerra copia
    nop                            # Preenche o delay slot do desvio condicional

    addu  $t2, $s3, $t0            # Endereco do byte atual na placa de origem ($s3 + j)
    lbu   $t3, 0($t2)              # Carrega byte da string placa de origem
    beq   $t3, $zero, ins_copia_plc_fim # Se encontrou o terminador nulo, encerra
    nop                            # Preenche o delay slot do desvio condicional

    addu  $t4, $s4, $t0            # Endereco relativo no destino ($s4 + j)
    sb    $t3, VEIC_OFF_PLACA($t4) # Grava byte no campo placa do slot (+36)
    addiu $t0, $t0, 1              # Incrementa indice j = j + 1
    j     ins_copia_plc_loop       # Itera para o proximo caractere
    nop                            # Preenche o delay slot do salto incondicional

ins_copia_plc_fim:
    addu  $t4, $s4, $t0            # Calcula posicao do terminador nulo no buffer
    sb    $zero, VEIC_OFF_PLACA($t4) # Assegura terminador nulo na placa

ins_atualizar_cabecalho:           # Passo 8: Atualizar contadores e tipo no AP
    sw    $s1, AP_OFF_TIPO_VEICULO($s0) # Atualiza tipo_veiculo no registro do AP (offset 300)
    lw    $t0, AP_OFF_NUM_VEICULOS($s0) # Carrega quantidade atual de veiculos
    addiu $t0, $t0, 1              # Incrementa contagem de veiculos (+1)
    sw    $t0, AP_OFF_NUM_VEICULOS($s0) # Grava novo num_veiculos no AP (offset 296)

    # Retorno de sucesso
    li    $v0, 0                   # Define codigo de retorno 0 (Sucesso)
    move  $v1, $s4                 # Retorna em $v1 o endereco base do slot inserido
    j     ins_finalizar            # Salta para restauracao de contexto
    nop                            # Preenche o delay slot do salto incondicional

ins_falha:                         # Tratamento de erro propagado pela validacao
    # $v0 ja contem o codigo de erro (-1 ou -2)
    li    $v1, 0                   # Zera retorno de endereco

ins_finalizar:                     # Epilogo: restauracao de contexto e retorno
    lw    $s4, 8($sp)              # Restaura registrador salvo $s4
    lw    $s3, 12($sp)             # Restaura registrador salvo $s3
    lw    $s2, 16($sp)             # Restaura registrador salvo $s2
    lw    $s1, 20($sp)             # Restaura registrador salvo $s1
    lw    $s0, 24($sp)             # Restaura registrador salvo $s0
    lw    $ra, 28($sp)             # Restaura registrador de retorno $ra
    addi  $sp, $sp, 32             # Desaloca o espaco do frame da pilha
    jr    $ra                      # Retorna ao procedimento chamador
    nop                            # Preenche o delay slot do retorno
