# ==============================================================
# Universidade Federal Rural de Pernambuco - UFRPE
# Departamento de Estatistica e Informatica - DEINFO
# Disciplina: Arquitetura e Organizacao de Computadores - 2026.2
# Professor: Vitor A. Coutinho
# Atividade: Projeto 01 (PE1 da 1a VA) - Assembly MIPS e MARS
# Grupo: LBFM (Leticia, Brenno, Ferraz, Marcos)
# Arquivo: rmvAuto.asm
# Autor: Brenno Leite (brennolpereira@outlook.com.br)
# Descricao: Rotinas de busca de automovel por placa (tolerante a
#            maiusculas/minusculas) e remocao com compactacao de
#            slots e atualizacao do registro do apartamento.
# ==============================================================
# Contrato de rmvAuto_busca_placa:
# Argumentos:
#   $a0 = Endereco base do registro do apartamento na memoria.
#         Offset +296: num_veiculos (word, 0 a 3)
#         Offset +300: tipo_veiculo (word, 0 = vazio, 'c' = 99, 'm' = 109)
#         Offset +304: array de 3 slots de veiculos (48 bytes por slot)
#   $a1 = Endereco da string com a placa procurada (terminada em '\0').
# Retornos:
#   $v0 = Codigo de status / Indice:
#         >= 0: Indice do slot onde a placa foi encontrada (0, 1 ou 2).
#           -1: Falha: automovel nao encontrado ou AP sem veiculos (num_veiculos == 0).
#           -2: Falha: parametro nulo ($a0 == 0 ou $a1 == 0).
#   $v1 = Endereco base do slot encontrado ($a0 + 304 + i*48), ou 0 em caso de erro.
# Preservacao:
#   Preserva todos os registradores salvos $s0-$s7 e os argumentos $a0-$a1.
#   Modifica apenas os temporarios $t0-$t8 e os retornos $v0-$v1.
# Compatibilidade:
#   100% compativel com Delayed Branching ativado (nop em delay slots).
# ==============================================================
# Contrato de rmvAuto_remover / rmvAuto_excluir:
# Argumentos:
#   $a0 = Endereco base do registro do apartamento na memoria.
#   $a1 = Endereco da string com a placa do veiculo a remover.
# Retornos:
#   $v0 = Codigo de status da remocao:
#          0: Sucesso na remocao e compactacao dos veiculos.
#         -1: Falha: automovel nao encontrado ou AP sem veiculos (num_veiculos == 0).
#         -2: Falha: parametro nulo ($a0 == 0 ou $a1 == 0).
#   $v1 = 0 em todas as condicoes.
# Efeitos colaterais:
#   - Localiza o automovel pela placa (case-insensitive).
#   - Se encontrado no slot k:
#     - Realiza compactacao: translada todos os slots posteriores (k+1 ate N-1)
#       uma posicao a esquerda (slot j <- slot j+1).
#     - Zera integralmente o ultimo slot que continha dados (todos os 48 bytes / 12 words).
#     - Decrementa num_veiculos no offset +296 (novo valor = N - 1).
#     - Se num_veiculos passar a ser 0, reseta tipo_veiculo no offset +300 para 0.
#   - Se nao encontrado ou parametros nulos:
#     - A memoria do apartamento permanece intacta.
# Preservacao:
#   Preserva todos os registradores salvos $s0-$s7, $ra e a pilha alinhada.
# Compatibilidade:
#   100% compativel com Delayed Branching ativado (nop em delay slots).
# ==============================================================

# Constantes de configuracao e deslocamentos do registro do apartamento e automoveis
.eqv RMV_AP_OFF_NUM_VEICULOS 296       # Deslocamento do contador de veiculos no AP (+296)
.eqv RMV_AP_OFF_TIPO_VEICULO 300       # Deslocamento do tipo geral de veiculo no AP (+300)
.eqv RMV_AP_OFF_VEICULOS     304       # Deslocamento base do vetor de slots de veiculos (+304)
.eqv RMV_VEIC_SLOT_SIZE       48       # Tamanho total em bytes de cada slot de automovel
.eqv RMV_VEIC_OFF_TIPO         0       # Deslocamento do tipo de veiculo dentro do slot (+0)
.eqv RMV_VEIC_OFF_MODELO       4       # Deslocamento da string do modelo no slot (+4)
.eqv RMV_VEIC_OFF_PLACA       36       # Deslocamento da string da placa no slot (+36)
.eqv RMV_VEIC_MAX_MODELO      32       # Capacidade maxima do buffer de modelo (bytes)
.eqv RMV_VEIC_MAX_PLACA       12       # Capacidade maxima do buffer de placa (bytes)
.eqv RMV_MAX_VEICULOS          3       # Capacidade maxima regulamentar de veiculos no AP
.eqv RMV_ASCII_A_MIN          97       # Codigo ASCII do caractere 'a' minusculo
.eqv RMV_ASCII_Z_MIN         122       # Codigo ASCII do caractere 'z' minusculo
.eqv RMV_ASCII_DIFF_MAI_MIN   32       # Diferenca numerica ASCII entre minuscula e maiuscula

.text                                  # Segmento de instrucoes executaveis
.globl rmvAuto_busca_placa             # Torna a rotina de busca visivel externamente

rmvAuto_busca_placa:                   # Ponto de entrada da rotina de busca de veiculo por placa
    beqz  $a0, busca_err_param         # Se ponteiro base do AP for nulo, retorna erro de parametro (-2)
    nop                                # Preenche o delay slot do desvio condicional

    beqz  $a1, busca_err_param         # Se ponteiro da string de placa for nulo, retorna erro (-2)
    nop                                # Preenche o delay slot do desvio condicional

    lbu   $t0, 0($a1)                  # Le primeiro caractere da placa pesquisada
    beqz  $t0, busca_nao_encontrado    # Placa vazia ("") nunca e encontrada no AP (-1)
    nop                                # Preenche o delay slot do desvio condicional

    lw    $t0, RMV_AP_OFF_NUM_VEICULOS($a0) # Le contador num_veiculos no registro do AP (+296)
    blez  $t0, busca_nao_encontrado    # Se num_veiculos <= 0, nao ha veiculos para pesquisar (-1)
    nop                                # Preenche o delay slot do desvio condicional

    li    $t1, RMV_MAX_VEICULOS        # Carrega limite maximo de veiculos permitido (3)
    bgt   $t0, $t1, busca_nao_encontrado # Se num_veiculos > 3, dados corrompidos; retorna nao encontrado
    nop                                # Preenche o delay slot do desvio condicional

    li    $t2, 0                       # Inicializa indice de slot: i = 0

busca_loop_slots:
    bge   $t2, $t0, busca_nao_encontrado # Se i >= num_veiculos, percorreu todos sem achar: falha (-1)
    nop                                # Preenche o delay slot do desvio condicional

    li    $t3, RMV_VEIC_SLOT_SIZE      # Carrega tamanho de cada slot (48 bytes)
    mul   $t4, $t2, $t3                # Calcula deslocamento do slot: i * 48
    addiu $t5, $a0, RMV_AP_OFF_VEICULOS # Calcula endereco base do array de veiculos (+304)
    addu  $t5, $t5, $t4                # $t5 = endereco base do slot i atual (AP + 304 + i*48)

    addiu $t6, $t5, RMV_VEIC_OFF_PLACA # $t6 = endereco da placa gravada no slot i (+36)
    li    $t7, 0                       # Inicializa indice do caractere da placa: k = 0

busca_cmp_char_loop:
    li    $t8, RMV_VEIC_MAX_PLACA      # Carrega limite maximo de bytes da placa (12)
    bge   $t7, $t8, busca_slot_prox    # Se k >= 12 sem encontrar terminador, encerra comparacao deste slot
    nop                                # Preenche o delay slot do desvio condicional

    addu  $t8, $t6, $t7                # Calcula endereco do byte k na placa do slot ($t6 + k)
    lbu   $t3, 0($t8)                  # Carrega byte da placa do slot
    addu  $t8, $a1, $t7                # Calcula endereco do byte k na placa pesquisada ($a1 + k)
    lbu   $t4, 0($t8)                  # Carrega byte da placa pesquisada

    # Normalizacao case-insensitive do caractere do slot ($t3) para maiuscula
    li    $t8, RMV_ASCII_A_MIN         # Carrega 'a' (97)
    blt   $t3, $t8, busca_norm_t4      # Se $t3 < 'a', nao e letra minuscula; mantem inalterado
    nop                                # Preenche o delay slot do desvio condicional
    li    $t8, RMV_ASCII_Z_MIN         # Carrega 'z' (122)
    bgt   $t3, $t8, busca_norm_t4      # Se $t3 > 'z', nao e letra minuscula; mantem inalterado
    nop                                # Preenche o delay slot do desvio condicional
    addiu $t3, $t3, -RMV_ASCII_DIFF_MAI_MIN # Converte letra minuscula para maiuscula ($t3 = $t3 - 32)

busca_norm_t4:
    # Normalizacao case-insensitive do caractere de busca ($t4) para maiuscula
    li    $t8, RMV_ASCII_A_MIN         # Carrega 'a' (97)
    blt   $t4, $t8, busca_cmp_eval     # Se $t4 < 'a', nao e letra minuscula; mantem inalterado
    nop                                # Preenche o delay slot do desvio condicional
    li    $t8, RMV_ASCII_Z_MIN         # Carrega 'z' (122)
    bgt   $t4, $t8, busca_cmp_eval     # Se $t4 > 'z', nao e letra minuscula; mantem inalterado
    nop                                # Preenche o delay slot do desvio condicional
    addiu $t4, $t4, -RMV_ASCII_DIFF_MAI_MIN # Converte letra minuscula para maiuscula ($t4 = $t4 - 32)

busca_cmp_eval:
    bne   $t3, $t4, busca_slot_prox    # Se caracteres forem diferentes, placa nao confere neste slot
    nop                                # Preenche o delay slot do desvio condicional

    beqz  $t3, busca_sucesso           # Se coincidiram e chegamos ao terminador '\0', match completo!
    nop                                # Preenche o delay slot do desvio condicional

    addiu $t7, $t7, 1                  # Avanca para o proximo caractere da placa (k = k + 1)
    j     busca_cmp_char_loop          # Itera comparacao para o proximo caractere
    nop                                # Preenche o delay slot do salto incondicional

busca_slot_prox:
    addiu $t2, $t2, 1                  # Avanca para o proximo slot (i = i + 1)
    j     busca_loop_slots             # Itera busca no proximo automovel
    nop                                # Preenche o delay slot do salto incondicional

busca_sucesso:
    move  $v0, $t2                     # Retorna em $v0 o indice do slot encontrado (0, 1 ou 2)
    move  $v1, $t5                     # Retorna em $v1 o endereco base do slot encontrado na memoria
    jr    $ra                          # Retorna ao procedimento chamador
    nop                                # Preenche o delay slot do salto de retorno

busca_nao_encontrado:
    li    $v0, -1                      # Define codigo de retorno -1 (automovel nao encontrado)
    li    $v1, 0                       # Zera ponteiro de retorno secundario
    jr    $ra                          # Retorna ao procedimento chamador
    nop                                # Preenche o delay slot do salto de retorno

busca_err_param:
    li    $v0, -2                      # Define codigo de retorno -2 (parametro nulo)
    li    $v1, 0                       # Zera ponteiro de retorno secundario
    jr    $ra                          # Retorna ao procedimento chamador
    nop                                # Preenche o delay slot do salto de retorno

# ==============================================================
# Rotina de remocao com compactacao e atualizacao do cabecalho
# ==============================================================
.globl rmvAuto_remover                 # Torna rotina principal de remocao visivel globalmente
.globl rmvAuto_excluir                 # Torna alias alternativo visivel globalmente

rmvAuto_excluir:                       # Ponto de entrada alias compativel
rmvAuto_remover:                       # Ponto de entrada da rotina principal de remocao
    beqz  $a0, rmv_err_param_direto    # Rejeita imediatamente com -2 se endereco do AP for nulo
    nop                                # Preenche o delay slot do desvio condicional

    beqz  $a1, rmv_err_param_direto    # Rejeita imediatamente com -2 se ponteiro da placa for nulo
    nop                                # Preenche o delay slot do desvio condicional

    addiu $sp, $sp, -32                # Aloca 32 bytes no frame da pilha para preservacao de contexto
    sw    $ra, 28($sp)                 # Salva registrador de retorno na pilha
    sw    $s0, 24($sp)                 # Salva registrador $s0 (preservara endereco base do AP)
    sw    $s1, 20($sp)                 # Salva registrador $s1 (preservara ponteiro da string da placa)
    sw    $s2, 16($sp)                 # Salva registrador $s2 (armazenara indice do slot encontrado)
    sw    $s3, 12($sp)                 # Salva registrador $s3 (armazenara quantidade atual num_veiculos)
    sw    $s4, 8($sp)                  # Salva registrador $s4 (indice do laco de translacao de slots)

    move  $s0, $a0                     # Preserva endereco base do AP em $s0
    move  $s1, $a1                     # Preserva ponteiro da string da placa em $s1

    lw    $s3, RMV_AP_OFF_NUM_VEICULOS($s0) # Carrega contagem atual de veiculos do AP (+296)

    # Passo 1: Localizar o automovel no registro usando rmvAuto_busca_placa
    move  $a0, $s0                     # Configura argumento $a0 = endereco base do AP
    move  $a1, $s1                     # Configura argumento $a1 = ponteiro da placa procurada
    jal   rmvAuto_busca_placa          # Executa busca case-insensitive por placa
    nop                                # Preenche o delay slot da chamada

    bltz  $v0, rmv_falha_busca         # Se busca retornar codigo negativo (< 0), propaga erro sem alterar AP
    nop                                # Preenche o delay slot do desvio condicional

    move  $s2, $v0                     # $s2 recebe o indice k do veiculo encontrado (0, 1 ou 2)

    # Passo 2: Compactacao de slots (se o veiculo removido nao for o ultimo do array)
    # Laco translada slots k+1 ate N-1 uma posicao para a esquerda: slot[j] <- slot[j+1]
    move  $s4, $s2                     # Inicializa variavel de controle do laco: j = k
    addiu $t0, $s3, -1                 # $t0 = N - 1 (limite maximo para indice j)

rmv_compact_loop:
    bge   $s4, $t0, rmv_limpar_ultimo_slot # Se j >= N - 1, translacao concluiu; passa a limpeza do ultimo slot
    nop                                # Preenche o delay slot do desvio condicional

    # Calcula endereco do slot destino j: AP + 304 + (j * 48)
    li    $t1, RMV_VEIC_SLOT_SIZE      # Carrega tamanho do slot (48 bytes)
    mul   $t2, $s4, $t1                # Calcula deslocamento do slot destino: j * 48
    addiu $t3, $s0, RMV_AP_OFF_VEICULOS # Endereco base do array de veiculos (+304)
    addu  $t3, $t3, $t2                # $t3 = endereco absoluto do slot destino j

    # Calcula endereco do slot origem j+1: endereco do slot j + 48
    addu  $t4, $t3, $t1                # $t4 = endereco absoluto do slot origem j + 1

    # Copia as 12 words (48 bytes) do slot origem j+1 para o slot destino j
    lw    $t5, 0($t4)                  # Le word 0 (+0: tipo do automovel)
    sw    $t5, 0($t3)                  # Grava word 0 no slot destino
    lw    $t5, 4($t4)                  # Le word 1 (+4 a +7: modelo)
    sw    $t5, 4($t3)                  # Grava word 1 no slot destino
    lw    $t5, 8($t4)                  # Le word 2 (+8 a +11: modelo)
    sw    $t5, 8($t3)                  # Grava word 2 no slot destino
    lw    $t5, 12($t4)                 # Le word 3 (+12 a +15: modelo)
    sw    $t5, 12($t3)                 # Grava word 3 no slot destino
    lw    $t5, 16($t4)                 # Le word 4 (+16 a +19: modelo)
    sw    $t5, 16($t3)                 # Grava word 4 no slot destino
    lw    $t5, 20($t4)                 # Le word 5 (+20 a +23: modelo)
    sw    $t5, 20($t3)                 # Grava word 5 no slot destino
    lw    $t5, 24($t4)                 # Le word 6 (+24 a +27: modelo)
    sw    $t5, 24($t3)                 # Grava word 6 no slot destino
    lw    $t5, 28($t4)                 # Le word 7 (+28 a +31: modelo)
    sw    $t5, 28($t3)                 # Grava word 7 no slot destino
    lw    $t5, 32($t4)                 # Le word 8 (+32 a +35: modelo)
    sw    $t5, 32($t3)                 # Grava word 8 no slot destino
    lw    $t5, 36($t4)                 # Le word 9 (+36 a +39: placa)
    sw    $t5, 36($t3)                 # Grava word 9 no slot destino
    lw    $t5, 40($t4)                 # Le word 10 (+40 a +43: placa)
    sw    $t5, 40($t3)                 # Grava word 10 no slot destino
    lw    $t5, 44($t4)                 # Le word 11 (+44 a +47: placa)
    sw    $t5, 44($t3)                 # Grava word 11 no slot destino

    addiu $s4, $s4, 1                  # Incrementa indice de iteracao j (j = j + 1)
    j     rmv_compact_loop             # Itera para o proximo slot da fila
    nop                                # Preenche o delay slot do salto incondicional

rmv_limpar_ultimo_slot:
    # Passo 3: Limpeza completa do ultimo slot ocupado anteriormente (indice N - 1)
    # Garante que nao restem dados fantasmas ou duplicados na memoria liberada
    addiu $t0, $s3, -1                 # $t0 = N - 1 (indice do slot desocupado)
    li    $t1, RMV_VEIC_SLOT_SIZE      # Carrega tamanho do slot (48 bytes)
    mul   $t2, $t0, $t1                # Calcula deslocamento do slot: (N - 1) * 48
    addiu $t3, $s0, RMV_AP_OFF_VEICULOS # Endereco base do array de veiculos (+304)
    addu  $t3, $t3, $t2                # $t3 = endereco absoluto do slot liberado (N - 1)

    # Zera integralmente as 12 words (48 bytes) do slot liberado
    sw    $zero, 0($t3)                # Zera word 0 (+0: tipo)
    sw    $zero, 4($t3)                # Zera word 1 (+4 a +7: modelo)
    sw    $zero, 8($t3)                # Zera word 2 (+8 a +11: modelo)
    sw    $zero, 12($t3)               # Zera word 3 (+12 a +15: modelo)
    sw    $zero, 16($t3)               # Zera word 4 (+16 a +19: modelo)
    sw    $zero, 20($t3)               # Zera word 5 (+20 a +23: modelo)
    sw    $zero, 24($t3)               # Zera word 6 (+24 a +27: modelo)
    sw    $zero, 28($t3)               # Zera word 7 (+28 a +31: modelo)
    sw    $zero, 32($t3)               # Zera word 8 (+32 a +35: modelo)
    sw    $zero, 36($t3)               # Zera word 9 (+36 a +39: placa)
    sw    $zero, 40($t3)               # Zera word 10 (+40 a +43: placa)
    sw    $zero, 44($t3)               # Zera word 11 (+44 a +47: placa)

    # Passo 4: Atualizar contador num_veiculos no registro do AP (offset +296)
    addiu $t6, $s3, -1                 # Decrementa contador de veiculos (N_novo = N - 1)
    sw    $t6, RMV_AP_OFF_NUM_VEICULOS($s0) # Grava novo num_veiculos no AP (+296)

    # Passo 5: Atualizar tipo_veiculo no registro do AP (offset +300)
    # Se num_veiculos chegou a 0, garagem ficou desocupada: tipo_veiculo deve ser resetado para 0
    bnez  $t6, rmv_finalizar_sucesso   # Se ainda restam veiculos (novo contador > 0), tipo permanece inalterado
    nop                                # Preenche o delay slot do desvio condicional

    sw    $zero, RMV_AP_OFF_TIPO_VEICULO($s0) # Reseta tipo_veiculo para 0 (garagem totalmente vazia)

rmv_finalizar_sucesso:
    li    $v0, 0                       # Define codigo de retorno 0 (Sucesso na remocao e compactacao)
    li    $v1, 0                       # Zera retorno secundario
    j     rmv_restaurar_epilogo        # Salta para restauracao de contexto e retorno
    nop                                # Preenche o delay slot do salto incondicional

rmv_falha_busca:
    # $v0 ja contem o codigo de erro retornado pela busca (-1 ou -2)
    li    $v1, 0                       # Zera retorno secundario
    j     rmv_restaurar_epilogo        # Salta para restauracao de contexto
    nop                                # Preenche o delay slot do salto incondicional

rmv_restaurar_epilogo:
    lw    $s4, 8($sp)                  # Restaura registrador salvo $s4
    lw    $s3, 12($sp)                 # Restaura registrador salvo $s3
    lw    $s2, 16($sp)                 # Restaura registrador salvo $s2
    lw    $s1, 20($sp)                 # Restaura registrador salvo $s1
    lw    $s0, 24($sp)                 # Restaura registrador salvo $s0
    lw    $ra, 28($sp)                 # Restaura registrador de retorno $ra
    addiu $sp, $sp, 32                 # Desaloca espaco no frame da pilha
    jr    $ra                          # Retorna ao procedimento chamador
    nop                                # Preenche o delay slot do salto de retorno

rmv_err_param_direto:
    li    $v0, -2                      # Define codigo de retorno -2 (parametro nulo)
    li    $v1, 0                       # Zera retorno secundario
    jr    $ra                          # Retorna diretamente sem acessar a pilha
    nop                                # Preenche o delay slot do salto de retorno
