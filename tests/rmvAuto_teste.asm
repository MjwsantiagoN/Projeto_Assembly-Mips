# ==============================================================
# Universidade Federal Rural de Pernambuco - UFRPE
# Departamento de Estatistica e Informatica - DEINFO
# Disciplina: Arquitetura e Organizacao de Computadores - 2026.2
# Professor: Vitor A. Coutinho
# Atividade: Projeto 01 (PE1 da 1a VA) - Assembly MIPS e MARS
# Grupo: LBFM (Leticia, Brenno, Ferraz, Marcos)
# Arquivo: rmvAuto_teste.asm
# Autor: Brenno Leite (brennolpereira@outlook.com.br)
# Descricao: Suite de testes unitarios automatizados para as rotinas
#            rmvAuto_busca_placa e rmvAuto_remover / rmvAuto_excluir.
#            Cobre os 7 cenarios regulamentares de remocao, compactacao,
#            tolerancia case-insensitive, erros e integridade de memoria.
# ==============================================================

.data                                  # Segmento de definicao de dados estaticos em memoria

# Constantes de controle e validacao de integridade de memoria
.eqv VAL_GUARDA_INICIO       0xDEADBEEF # Padrao sentinela para deteccao de overflow antes do buffer
.eqv VAL_GUARDA_FIM          0xCAFEBABE # Padrao sentinela para deteccao de overflow depois do buffer
.eqv TEST_OFF_NUM_VEIC       296        # Deslocamento do campo num_veiculos no registro do AP
.eqv TEST_OFF_TIPO_VEIC      300        # Deslocamento do campo tipo_veiculo no registro do AP
.eqv TEST_OFF_SLOT_0         304        # Deslocamento do primeiro slot de automovel (+304)
.eqv TEST_OFF_SLOT_1         352        # Deslocamento do segundo slot de automovel (+352)
.eqv TEST_OFF_SLOT_2         400        # Deslocamento do terceiro slot de automovel (+400)
.eqv TEST_SLOT_SIZE           48        # Tamanho de cada slot de automovel em bytes
.eqv TEST_OFF_MODELO           4        # Deslocamento relativo da string de modelo no slot
.eqv TEST_OFF_PLACA           36        # Deslocamento relativo da string de placa no slot

# Constantes de canarios para verificacao estrita dos registradores salvos $s0-$s7
.eqv CANARIO_S0              0x11111111 # Valor canario esperado para $s0
.eqv CANARIO_S1              0x22222222 # Valor canario esperado para $s1
.eqv CANARIO_S2              0x33333333 # Valor canario esperado para $s2
.eqv CANARIO_S3              0x44444444 # Valor canario esperado para $s3
.eqv CANARIO_S4              0x55555555 # Valor canario esperado para $s4
.eqv CANARIO_S5              0x66666666 # Valor canario esperado para $s5
.eqv CANARIO_S6              0x77777777 # Valor canario esperado para $s6
.eqv CANARIO_S7              0x88888888 # Valor canario esperado para $s7

# Strings de teste para modelos e placas de veiculos
str_carro1_mod:       .asciiz "Civic Sedan"                           # Modelo do primeiro carro de teste
str_carro1_plc:       .asciiz "BRA2E19"                               # Placa do primeiro carro de teste
str_moto1_mod:        .asciiz "Honda CG 160"                          # Modelo da primeira moto de teste
str_moto1_plc:        .asciiz "KGA1234"                               # Placa da primeira moto de teste
str_moto2_mod:        .asciiz "Yamaha Fazer 250"                      # Modelo da segunda moto de teste
str_moto2_plc:        .asciiz "PEA5678"                               # Placa da segunda moto de teste
str_moto3_mod:        .asciiz "BMW G310 GS"                           # Modelo da terceira moto de teste
str_moto3_plc:        .asciiz "XYZ9012"                               # Placa da terceira moto de teste
str_fiat_mod:         .asciiz "Fiat Uno"                              # Modelo de carro para teste case-insensitive
str_fiat_plc_mai:     .asciiz "ABC1234"                               # Placa em maiusculas para teste case-insensitive
str_fiat_plc_min:     .asciiz "abc1234"                               # Placa em minusculas para busca case-insensitive
str_inexistente_plc:  .asciiz "NAO9999"                               # Placa inexistente para teste de erro
str_placa_vazia:      .asciiz ""                                      # Placa vazia para teste de borda
str_mercosul_src:     .asciiz "aBc1D23"                               # Placa Mercosul com maiusculas e minusculas
str_mercosul_tgt:     .asciiz "AbC1d23"                               # Placa Mercosul com caixa alternada para busca

# Mensagens de informacao e resultado exibidas no terminal
msg_titulo:           .asciiz "=== INICIANDO SUITE DE TESTES UNITARIOS: rmvAuto ===\n" # Cabecalho da suite
msg_c1_ok:            .asciiz "[CENARIO 1] SUCESSO: Remocao do unico carro do AP (num: 1->0, tipo: 'c'->0, slot zerado)\n" # Mensagem Cenario 1
msg_c2_ok:            .asciiz "[CENARIO 2] SUCESSO: Remocao de moto do meio com compactacao (M1,M2,M3 -> M1,M3, num=2)\n" # Mensagem Cenario 2
msg_c3_ok:            .asciiz "[CENARIO 3] SUCESSO: Remocao da ultima moto (slot 1 mantido, slot 2 zerado, num=1)\n" # Mensagem Cenario 3
msg_c4_ok:            .asciiz "[CENARIO 4] SUCESSO: Remocao case-insensitive ('abc1234' vs 'ABC1234' -> remocao OK)\n" # Mensagem Cenario 4
msg_c5_ok:            .asciiz "[CENARIO 5] SUCESSO: Erro ao buscar placa inexistente no AP (codigo -1, memoria intacta)\n" # Mensagem Cenario 5
msg_c6_ok:            .asciiz "[CENARIO 6] SUCESSO: Erro ao tentar remover em AP com 0 veiculos (codigo -1)\n" # Mensagem Cenario 6
msg_c7_ok:            .asciiz "[CENARIO 7] SUCESSO: Validacao de ponteiros nulos (codigo -2, sentinelas intactos)\n" # Mensagem Cenario 7
msg_pass_final:       .asciiz "\nPASS: rmvAuto_teste (todos os 7 cenarios aprovados com sucesso)\n" # Aprovacao geral
msg_falha_c1:         .asciiz "FAIL: Falha detectada no Cenario 1 (remocao do unico carro)\n" # Mensagem de falha 1
msg_falha_c2:         .asciiz "FAIL: Falha detectada no Cenario 2 (remocao com compactacao de motos)\n" # Mensagem de falha 2
msg_falha_c3:         .asciiz "FAIL: Falha detectada no Cenario 3 (remocao da ultima moto)\n" # Mensagem de falha 3
msg_falha_c4:         .asciiz "FAIL: Falha detectada no Cenario 4 (remocao case-insensitive)\n" # Mensagem de falha 4
msg_falha_c5:         .asciiz "FAIL: Falha detectada no Cenario 5 (placa inexistente no AP)\n" # Mensagem de falha 5
msg_falha_c6:         .asciiz "FAIL: Falha detectada no Cenario 6 (remocao em AP com 0 veiculos)\n" # Mensagem de falha 6
msg_falha_c7:         .asciiz "FAIL: Falha detectada no Cenario 7 (validacao de ponteiros nulos)\n" # Mensagem de falha 7

# Buffers de apartamentos de teste com sentinelas de borda para protecao de memoria
.align 2                               # Alinha buffer 1 a fronteira de palavra de 4 bytes
ap1_guarda_antes:     .word VAL_GUARDA_INICIO # Sentinela anterior para protecao contra underflow
ap1_buffer:           .space 512              # Buffer de memoria do apartamento 1 (512 bytes)
ap1_guarda_depois:    .word VAL_GUARDA_FIM    # Sentinela posterior para protecao contra overflow

.align 2                               # Alinha buffer 2 a fronteira de palavra de 4 bytes
ap2_guarda_antes:     .word VAL_GUARDA_INICIO # Sentinela anterior do buffer 2
ap2_buffer:           .space 512              # Buffer de memoria do apartamento 2 (512 bytes)
ap2_guarda_depois:    .word VAL_GUARDA_FIM    # Sentinela posterior do buffer 2

.align 2                               # Alinha buffer 3 a fronteira de palavra de 4 bytes
ap3_guarda_antes:     .word VAL_GUARDA_INICIO # Sentinela anterior do buffer 3
ap3_buffer:           .space 512              # Buffer de memoria do apartamento 3 (512 bytes)
ap3_guarda_depois:    .word VAL_GUARDA_FIM    # Sentinela posterior do buffer 3

.align 2                               # Alinha buffer 4 a fronteira de palavra de 4 bytes
ap4_guarda_antes:     .word VAL_GUARDA_INICIO # Sentinela anterior do buffer 4
ap4_buffer:           .space 512              # Buffer de memoria do apartamento 4 (512 bytes)
ap4_guarda_depois:    .word VAL_GUARDA_FIM    # Sentinela posterior do buffer 4

.align 2                               # Alinha buffer 5 a fronteira de palavra de 4 bytes
ap5_guarda_antes:     .word VAL_GUARDA_INICIO # Sentinela anterior do buffer 5
ap5_buffer:           .space 512              # Buffer de memoria do apartamento 5 (512 bytes)
ap5_guarda_depois:    .word VAL_GUARDA_FIM    # Sentinela posterior do buffer 5

.align 2                               # Alinha buffer 6 a fronteira de palavra de 4 bytes
ap6_guarda_antes:     .word VAL_GUARDA_INICIO # Sentinela anterior do buffer 6
ap6_buffer:           .space 512              # Buffer de memoria do apartamento 6 (512 bytes)
ap6_guarda_depois:    .word VAL_GUARDA_FIM    # Sentinela posterior do buffer 6

# ==============================================================
# Segmento de Codigo Executavel dos Testes
# ==============================================================
.text                                  # Segmento de codigo
.globl main                            # Ponto de entrada padrao do simulador MARS

main:                                  # Inicio do procedimento principal de testes
    # Exibe titulo e cabecalho no console
    la    $a0, msg_titulo              # Carrega endereco da string de cabecalho
    li    $v0, 4                       # Syscall 4: imprimir string
    syscall                            # Invoca servico de saida de console do MARS

    # ==============================================================
    # CENARIO 1: Remocao do unico carro de um AP
    # Estado inicial: num_veiculos = 1, tipo_veiculo = 'c', Slot 0 preenchido
    # Comportamento esperado: $v0 = 0, num_veiculos = 0, tipo_veiculo = 0, Slot 0 zerado
    # ==============================================================
teste_cenario_1:
    la    $s0, ap1_buffer              # $s0 = endereco base do AP 1

    # Limpa buffer do AP 1 com zeros (512 bytes = 128 words)
    move  $a0, $s0                     # Argumento $a0: base do buffer
    li    $a1, 128                     # Argumento $a1: quantidade de words
    jal   aux_zerar_words              # Zera o buffer por completo
    nop                                # Delay slot da chamada

    # Configura cabecalho do AP 1: 1 carro ('c' = 99)
    li    $t0, 1                       # Quantidade de veiculos = 1
    sw    $t0, TEST_OFF_NUM_VEIC($s0)  # Grava num_veiculos no offset +296
    li    $t0, 99                      # Tipo geral de veiculo = 'c' (99)
    sw    $t0, TEST_OFF_TIPO_VEIC($s0) # Grava tipo_veiculo no offset +300

    # Preenche Slot 0 (+304): tipo = 'c', modelo = Civic Sedan, placa = BRA2E19
    addiu $t1, $s0, TEST_OFF_SLOT_0    # Endereco base do Slot 0
    li    $t0, 99                      # Carrega 'c'
    sw    $t0, 0($t1)                  # Grava tipo no slot (+0)
    addiu $a1, $t1, TEST_OFF_MODELO    # Destino do modelo (+4)
    la    $a0, str_carro1_mod          # Origem do modelo
    jal   aux_copiar_string            # Copia string do modelo
    nop                                # Delay slot da chamada
    addiu $a1, $t1, TEST_OFF_PLACA     # Destino da placa (+36)
    la    $a0, str_carro1_plc          # Origem da placa
    jal   aux_copiar_string            # Copia string da placa
    nop                                # Delay slot da chamada

    # Preenche canarios nos registradores salvos para testar preservacao estrita
    jal   aux_carregar_canarios        # Carrega canarios em $s0-$s7
    nop                                # Delay slot da chamada

    # Executa a remocao do carro pela placa
    la    $a0, ap1_buffer              # $a0 = base do AP 1
    la    $a1, str_carro1_plc          # $a1 = "BRA2E19"
    jal   rmvAuto_remover              # Invoca a rotina de remocao
    nop                                # Delay slot da chamada

    # Verificacoes do Cenario 1:
    bne   $v0, $zero, falha_c1         # Se retorno $v0 != 0, falha
    nop                                # Delay slot do desvio condicional

    # Verifica preservacao dos registradores salvos
    jal   aux_verificar_canarios       # Confirma valores canarios
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c1         # Se algum registrador foi corrompido, falha
    nop                                # Delay slot do desvio condicional

    la    $s0, ap1_buffer              # Recarrega base do AP 1
    lw    $t0, TEST_OFF_NUM_VEIC($s0)  # Le num_veiculos (+296)
    bne   $t0, $zero, falha_c1         # num_veiculos deve ser 0
    nop                                # Delay slot do desvio condicional

    lw    $t0, TEST_OFF_TIPO_VEIC($s0) # Le tipo_veiculo (+300)
    bne   $t0, $zero, falha_c1         # tipo_veiculo deve ser resetado para 0
    nop                                # Delay slot do desvio condicional

    # Verifica se o Slot 0 foi totalmente zerado (todas as 12 words zeradas)
    addiu $a0, $s0, TEST_OFF_SLOT_0    # Endereco base do Slot 0
    jal   aux_verifica_slot_zerado     # Testa se todos os 48 bytes estao zerados
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c1         # Se slot nao estiver zerado, falha
    nop                                # Delay slot do desvio condicional

    # Verifica sentinelas de protecao de memoria
    lw    $t0, ap1_guarda_antes        # Le sentinela anterior
    li    $t1, VAL_GUARDA_INICIO       # Valor esperado
    bne   $t0, $t1, falha_c1           # Se sentinela violado, falha
    nop                                # Delay slot do desvio condicional

    lw    $t0, ap1_guarda_depois       # Le sentinela posterior
    li    $t1, VAL_GUARDA_FIM          # Valor esperado
    bne   $t0, $t1, falha_c1           # Se sentinela violado, falha
    nop                                # Delay slot do desvio condicional

    # Emite mensagem de sucesso do Cenario 1
    la    $a0, msg_c1_ok               # Carrega mensagem de sucesso do Cenario 1
    li    $v0, 4                       # Syscall 4: imprimir string
    syscall                            # Imprime mensagem de confirmacao

    # ==============================================================
    # CENARIO 2: Remocao de moto do meio com compactacao (M1, M2, M3)
    # Estado inicial: num_veiculos = 3, tipo_veiculo = 'm', 3 motos cadastradas
    # Acao: remover M2 ("PEA5678")
    # Comportamento esperado: $v0 = 0, num_veiculos = 2, tipo_veiculo = 'm',
    #                         Slot 0 mantem M1, Slot 1 recebe M3, Slot 2 zerado
    # ==============================================================
teste_cenario_2:
    la    $s0, ap2_buffer              # $s0 = endereco base do AP 2

    # Limpa buffer do AP 2 com zeros
    move  $a0, $s0                     # Base do buffer
    li    $a1, 128                     # 128 words (512 bytes)
    jal   aux_zerar_words              # Zera o buffer
    nop                                # Delay slot da chamada

    # Configura cabecalho: 3 motos ('m' = 109)
    li    $t0, 3                       # num_veiculos = 3
    sw    $t0, TEST_OFF_NUM_VEIC($s0)  # Grava num_veiculos
    li    $t0, 109                     # tipo_veiculo = 'm' (109)
    sw    $t0, TEST_OFF_TIPO_VEIC($s0) # Grava tipo_veiculo

    # Slot 0: M1 (Honda CG 160, KGA1234)
    addiu $t1, $s0, TEST_OFF_SLOT_0    # Endereco base Slot 0
    li    $t0, 109                     # 'm'
    sw    $t0, 0($t1)                  # Tipo no slot 0
    addiu $a1, $t1, TEST_OFF_MODELO    # Destino modelo
    la    $a0, str_moto1_mod           # Origem modelo 1
    jal   aux_copiar_string            # Copia modelo
    nop                                # Delay slot da chamada
    addiu $a1, $t1, TEST_OFF_PLACA     # Destino placa
    la    $a0, str_moto1_plc           # Origem placa 1
    jal   aux_copiar_string            # Copia placa
    nop                                # Delay slot da chamada

    # Slot 1: M2 (Yamaha Fazer 250, PEA5678)
    addiu $t1, $s0, TEST_OFF_SLOT_1    # Endereco base Slot 1
    li    $t0, 109                     # 'm'
    sw    $t0, 0($t1)                  # Tipo no slot 1
    addiu $a1, $t1, TEST_OFF_MODELO    # Destino modelo
    la    $a0, str_moto2_mod           # Origem modelo 2
    jal   aux_copiar_string            # Copia modelo
    nop                                # Delay slot da chamada
    addiu $a1, $t1, TEST_OFF_PLACA     # Destino placa
    la    $a0, str_moto2_plc           # Origem placa 2
    jal   aux_copiar_string            # Copia placa
    nop                                # Delay slot da chamada

    # Slot 2: M3 (BMW G310 GS, XYZ9012)
    addiu $t1, $s0, TEST_OFF_SLOT_2    # Endereco base Slot 2
    li    $t0, 109                     # 'm'
    sw    $t0, 0($t1)                  # Tipo no slot 2
    addiu $a1, $t1, TEST_OFF_MODELO    # Destino modelo
    la    $a0, str_moto3_mod           # Origem modelo 3
    jal   aux_copiar_string            # Copia modelo
    nop                                # Delay slot da chamada
    addiu $a1, $t1, TEST_OFF_PLACA     # Destino placa
    la    $a0, str_moto3_plc           # Origem placa 3
    jal   aux_copiar_string            # Copia placa
    nop                                # Delay slot da chamada

    # Preenche canarios nos registradores salvos
    jal   aux_carregar_canarios        # Carrega canarios
    nop                                # Delay slot da chamada

    # Remove M2 pela placa "PEA5678"
    la    $a0, ap2_buffer              # $a0 = AP 2
    la    $a1, str_moto2_plc           # $a1 = "PEA5678"
    jal   rmvAuto_remover              # Invoca remocao
    nop                                # Delay slot da chamada

    # Verificacoes do Cenario 2:
    bne   $v0, $zero, falha_c2         # Se $v0 != 0, falha
    nop                                # Delay slot do desvio condicional

    # Confirma canarios
    jal   aux_verificar_canarios       # Verifica registradores salvos
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c2         # Se violados, falha
    nop                                # Delay slot do desvio condicional

    la    $s0, ap2_buffer              # Recarrega base do AP 2
    lw    $t0, TEST_OFF_NUM_VEIC($s0)  # Le num_veiculos
    li    $t1, 2                       # Esperado = 2
    bne   $t0, $t1, falha_c2           # Se != 2, falha
    nop                                # Delay slot do desvio condicional

    lw    $t0, TEST_OFF_TIPO_VEIC($s0) # Le tipo_veiculo
    li    $t1, 109                     # Deve permanecer 'm' (109)
    bne   $t0, $t1, falha_c2           # Se != 'm', falha
    nop                                # Delay slot do desvio condicional

    # Slot 0 deve permanecer com M1 intacta (placa "KGA1234")
    addiu $a0, $s0, TEST_OFF_SLOT_0    # Slot 0
    addiu $a0, $a0, TEST_OFF_PLACA     # Placa do Slot 0
    la    $a1, str_moto1_plc           # Esperado: "KGA1234"
    jal   aux_compara_string           # Compara strings
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c2         # Se diferente, falha
    nop                                # Delay slot do desvio condicional

    # Slot 1 deve conter M3 transladada (placa "XYZ9012" e modelo "BMW G310 GS")
    addiu $a0, $s0, TEST_OFF_SLOT_1    # Slot 1
    addiu $a0, $a0, TEST_OFF_PLACA     # Placa do Slot 1
    la    $a1, str_moto3_plc           # Esperado: "XYZ9012"
    jal   aux_compara_string           # Compara strings
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c2         # Se diferente, falha
    nop                                # Delay slot do desvio condicional

    addiu $a0, $s0, TEST_OFF_SLOT_1    # Slot 1
    addiu $a0, $a0, TEST_OFF_MODELO    # Modelo do Slot 1
    la    $a1, str_moto3_mod           # Esperado: "BMW G310 GS"
    jal   aux_compara_string           # Compara strings
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c2         # Se diferente, falha
    nop                                # Delay slot do desvio condicional

    # Slot 2 (indice N-1 liberado) deve estar TOTALMENTE zerado
    addiu $a0, $s0, TEST_OFF_SLOT_2    # Endereco base do Slot 2
    jal   aux_verifica_slot_zerado     # Verifica se as 12 words sao zero
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c2         # Se slot nao foi zerado, falha
    nop                                # Delay slot do desvio condicional

    # Sentinelas
    lw    $t0, ap2_guarda_antes        # Guarda antes
    li    $t1, VAL_GUARDA_INICIO       # Valor inicial
    bne   $t0, $t1, falha_c2           # Se corrompido, falha
    nop                                # Delay slot do desvio condicional
    lw    $t0, ap2_guarda_depois       # Guarda depois
    li    $t1, VAL_GUARDA_FIM          # Valor final
    bne   $t0, $t1, falha_c2           # Se corrompido, falha
    nop                                # Delay slot do desvio condicional

    # Emite mensagem de sucesso do Cenario 2
    la    $a0, msg_c2_ok               # Mensagem Cenario 2
    li    $v0, 4                       # Syscall 4
    syscall                            # Imprime confirmacao

    # ==============================================================
    # CENARIO 3: Remocao da ultima moto (continua no AP 2)
    # Estado inicial: num_veiculos = 2 (Slot 0=M1, Slot 1=M3, Slot 2=zerado)
    # Acao: remover M3 ("XYZ9012") no Slot 1
    # Comportamento esperado: $v0 = 0, num_veiculos = 1, tipo_veiculo = 'm',
    #                         Slot 0 mantido (M1), Slot 1 zerado, Slot 2 zerado
    # ==============================================================
teste_cenario_3:
    la    $s0, ap2_buffer              # Continua utilizando o AP 2

    # Preenche canarios nos registradores salvos
    jal   aux_carregar_canarios        # Carrega canarios
    nop                                # Delay slot da chamada

    # Remove M3 pela placa "XYZ9012"
    la    $a0, ap2_buffer              # $a0 = base do AP 2
    la    $a1, str_moto3_plc           # $a1 = "XYZ9012"
    jal   rmvAuto_remover              # Invoca remocao
    nop                                # Delay slot da chamada

    # Verificacoes do Cenario 3:
    bne   $v0, $zero, falha_c3         # Se $v0 != 0, falha
    nop                                # Delay slot do desvio condicional

    # Confirma canarios
    jal   aux_verificar_canarios       # Verifica salvos
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c3         # Se violados, falha
    nop                                # Delay slot do desvio condicional

    la    $s0, ap2_buffer              # Recarrega base do AP 2
    lw    $t0, TEST_OFF_NUM_VEIC($s0)  # Le num_veiculos
    li    $t1, 1                       # Esperado = 1
    bne   $t0, $t1, falha_c3           # Se != 1, falha
    nop                                # Delay slot do desvio condicional

    lw    $t0, TEST_OFF_TIPO_VEIC($s0) # Le tipo_veiculo
    li    $t1, 109                     # Esperado = 'm' (109)
    bne   $t0, $t1, falha_c3           # Se != 'm', falha
    nop                                # Delay slot do desvio condicional

    # Slot 0 deve continuar com M1 intacta
    addiu $a0, $s0, TEST_OFF_SLOT_0    # Slot 0
    addiu $a0, $a0, TEST_OFF_PLACA     # Placa Slot 0
    la    $a1, str_moto1_plc           # "KGA1234"
    jal   aux_compara_string           # Compara strings
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c3         # Se diferente, falha
    nop                                # Delay slot do desvio condicional

    # Slot 1 agora deve estar TOTALMENTE zerado
    addiu $a0, $s0, TEST_OFF_SLOT_1    # Slot 1
    jal   aux_verifica_slot_zerado     # Confirma se esta zerado
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c3         # Se nao estiver zerado, falha
    nop                                # Delay slot do desvio condicional

    # Slot 2 continua TOTALMENTE zerado
    addiu $a0, $s0, TEST_OFF_SLOT_2    # Slot 2
    jal   aux_verifica_slot_zerado     # Confirma se esta zerado
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c3         # Se nao estiver zerado, falha
    nop                                # Delay slot do desvio condicional

    # Sentinelas
    lw    $t0, ap2_guarda_antes        # Guarda anterior
    li    $t1, VAL_GUARDA_INICIO       # Valor inicial
    bne   $t0, $t1, falha_c3           # Se corrompido, falha
    nop                                # Delay slot do desvio condicional
    lw    $t0, ap2_guarda_depois       # Guarda posterior
    li    $t1, VAL_GUARDA_FIM          # Valor final
    bne   $t0, $t1, falha_c3           # Se corrompido, falha
    nop                                # Delay slot do desvio condicional

    # Emite mensagem de sucesso do Cenario 3
    la    $a0, msg_c3_ok               # Mensagem Cenario 3
    li    $v0, 4                       # Syscall 4
    syscall                            # Imprime confirmacao

    # ==============================================================
    # CENARIO 4: Remocao case-insensitive ("abc1234" vs "ABC1234")
    # Estado inicial: AP com carro registrado com placa maiuscula "ABC1234"
    # Acao 1: Testar rmvAuto_busca_placa com "abc1234" -> retorno $v0 = 0
    # Acao 2: Testar rmvAuto_remover com "abc1234" -> retorno $v0 = 0, remove com sucesso
    # ==============================================================
teste_cenario_4:
    la    $s0, ap3_buffer              # $s0 = base do AP 3

    # Limpa buffer do AP 3
    move  $a0, $s0                     # Base do buffer
    li    $a1, 128                     # 128 words
    jal   aux_zerar_words              # Zera memoria
    nop                                # Delay slot da chamada

    # Configura cabecalho: 1 carro ('c' = 99)
    li    $t0, 1                       # num_veiculos = 1
    sw    $t0, TEST_OFF_NUM_VEIC($s0)  # Grava num_veiculos
    li    $t0, 99                      # tipo_veiculo = 'c'
    sw    $t0, TEST_OFF_TIPO_VEIC($s0) # Grava tipo_veiculo

    # Slot 0: Fiat Uno, placa "ABC1234" (maiuscula)
    addiu $t1, $s0, TEST_OFF_SLOT_0    # Slot 0
    li    $t0, 99                      # 'c'
    sw    $t0, 0($t1)                  # Tipo no slot 0
    addiu $a1, $t1, TEST_OFF_MODELO    # Destino modelo
    la    $a0, str_fiat_mod            # Origem modelo
    jal   aux_copiar_string            # Copia modelo
    nop                                # Delay slot da chamada
    addiu $a1, $t1, TEST_OFF_PLACA     # Destino placa
    la    $a0, str_fiat_plc_mai        # Origem placa ("ABC1234")
    jal   aux_copiar_string            # Copia placa
    nop                                # Delay slot da chamada

    # Teste isolado de busca case-insensitive
    la    $a0, ap3_buffer              # $a0 = AP 3
    la    $a1, str_fiat_plc_min        # $a1 = "abc1234" (minuscula)
    jal   rmvAuto_busca_placa          # Invoca busca por placa
    nop                                # Delay slot da chamada

    bne   $v0, $zero, falha_c4         # Deve retornar indice 0 com sucesso
    nop                                # Delay slot do desvio condicional
    addiu $t0, $s0, TEST_OFF_SLOT_0    # Endereco esperado do slot 0
    bne   $v1, $t0, falha_c4           # $v1 deve ser o endereco do slot 0
    nop                                # Delay slot do desvio condicional

    # Agora executa remocao case-insensitive
    la    $a0, ap3_buffer              # $a0 = AP 3
    la    $a1, str_fiat_plc_min        # $a1 = "abc1234"
    jal   rmvAuto_remover              # Invoca remocao
    nop                                # Delay slot da chamada

    bne   $v0, $zero, falha_c4         # Retorno deve ser 0
    nop                                # Delay slot do desvio condicional

    la    $s0, ap3_buffer              # Recarrega base do AP 3
    lw    $t0, TEST_OFF_NUM_VEIC($s0)  # Le num_veiculos
    bne   $t0, $zero, falha_c4         # num_veiculos deve ser 0
    nop                                # Delay slot do desvio condicional

    lw    $t0, TEST_OFF_TIPO_VEIC($s0) # Le tipo_veiculo
    bne   $t0, $zero, falha_c4         # tipo_veiculo deve ser 0
    nop                                # Delay slot do desvio condicional

    addiu $a0, $s0, TEST_OFF_SLOT_0    # Slot 0
    jal   aux_verifica_slot_zerado     # Slot 0 deve estar zerado
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c4         # Se nao zerado, falha
    nop                                # Delay slot do desvio condicional

    # Teste adicional: placa Mercosul com caixa mista ("aBc1D23" cadastrado vs "AbC1d23" buscado)
    li    $t0, 1                       # Configura num_veiculos = 1
    sw    $t0, TEST_OFF_NUM_VEIC($s0)  # Grava num_veiculos
    li    $t0, 99                      # Carro ('c')
    sw    $t0, TEST_OFF_TIPO_VEIC($s0) # Grava tipo
    sw    $t0, TEST_OFF_SLOT_0($s0)    # Grava tipo no slot
    addiu $a1, $s0, TEST_OFF_SLOT_0    # Slot 0
    addiu $a1, $a1, TEST_OFF_PLACA     # Offset da placa
    la    $a0, str_mercosul_src        # "aBc1D23"
    jal   aux_copiar_string            # Copia placa Mercosul mista
    nop                                # Delay slot da chamada

    la    $a0, ap3_buffer              # AP 3
    la    $a1, str_mercosul_tgt        # "AbC1d23"
    jal   rmvAuto_busca_placa          # Busca Mercosul case-insensitive
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c4         # Deve encontrar no indice 0
    nop                                # Delay slot do desvio condicional

    la    $a0, ap3_buffer              # AP 3
    la    $a1, str_mercosul_tgt        # "AbC1d23"
    jal   rmvAuto_remover              # Remove Mercosul case-insensitive
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c4         # Retorno deve ser 0
    nop                                # Delay slot do desvio condicional

    lw    $t0, TEST_OFF_NUM_VEIC($s0)  # Le num_veiculos
    bne   $t0, $zero, falha_c4         # num_veiculos deve ser 0
    nop                                # Delay slot do desvio condicional
    lw    $t0, TEST_OFF_TIPO_VEIC($s0) # Le tipo_veiculo
    bne   $t0, $zero, falha_c4         # tipo_veiculo deve ser 0
    nop                                # Delay slot do desvio condicional

    # Sentinelas
    lw    $t0, ap3_guarda_antes        # Guarda anterior
    li    $t1, VAL_GUARDA_INICIO       # Valor esperado
    bne   $t0, $t1, falha_c4           # Se violado, falha
    nop                                # Delay slot do desvio condicional
    lw    $t0, ap3_guarda_depois       # Guarda posterior
    li    $t1, VAL_GUARDA_FIM          # Valor esperado
    bne   $t0, $t1, falha_c4           # Se violado, falha
    nop                                # Delay slot do desvio condicional

    # Emite mensagem de sucesso do Cenario 4
    la    $a0, msg_c4_ok               # Mensagem Cenario 4
    li    $v0, 4                       # Syscall 4
    syscall                            # Imprime confirmacao

    # ==============================================================
    # CENARIO 5: Erro quando a placa nao existe no AP (com veiculos)
    # Estado inicial: AP com 1 carro cadastrado ("BRA2E19")
    # Acao: tentar remover "NAO9999"
    # Comportamento esperado: $v0 = -1, memoria e cabecalho inalterados
    # ==============================================================
teste_cenario_5:
    la    $s0, ap4_buffer              # $s0 = base do AP 4

    # Limpa buffer do AP 4
    move  $a0, $s0                     # Base do buffer
    li    $a1, 128                     # 128 words
    jal   aux_zerar_words              # Zera memoria
    nop                                # Delay slot da chamada

    # Configura cabecalho: 1 carro
    li    $t0, 1                       # num_veiculos = 1
    sw    $t0, TEST_OFF_NUM_VEIC($s0)  # Grava num_veiculos
    li    $t0, 99                      # tipo_veiculo = 'c'
    sw    $t0, TEST_OFF_TIPO_VEIC($s0) # Grava tipo_veiculo

    # Slot 0: Civic Sedan, BRA2E19
    addiu $t1, $s0, TEST_OFF_SLOT_0    # Slot 0
    li    $t0, 99                      # 'c'
    sw    $t0, 0($t1)                  # Tipo no slot 0
    addiu $a1, $t1, TEST_OFF_MODELO    # Destino modelo
    la    $a0, str_carro1_mod          # Origem modelo
    jal   aux_copiar_string            # Copia modelo
    nop                                # Delay slot da chamada
    addiu $a1, $t1, TEST_OFF_PLACA     # Destino placa
    la    $a0, str_carro1_plc          # Origem placa
    jal   aux_copiar_string            # Copia placa
    nop                                # Delay slot da chamada

    # Invoca busca por placa inexistente
    la    $a0, ap4_buffer              # $a0 = AP 4
    la    $a1, str_inexistente_plc     # $a1 = "NAO9999"
    jal   rmvAuto_busca_placa          # Busca placa inexistente
    nop                                # Delay slot da chamada

    li    $t0, -1                      # Esperado = -1
    bne   $v0, $t0, falha_c5           # Se != -1, falha
    nop                                # Delay slot do desvio condicional
    bne   $v1, $zero, falha_c5         # $v1 deve ser 0 em caso de erro
    nop                                # Delay slot do desvio condicional

    # Invoca remocao com placa inexistente
    la    $a0, ap4_buffer              # $a0 = AP 4
    la    $a1, str_inexistente_plc     # $a1 = "NAO9999"
    jal   rmvAuto_remover              # Tenta remover
    nop                                # Delay slot da chamada

    li    $t0, -1                      # Esperado = -1
    bne   $v0, $t0, falha_c5           # Se != -1, falha
    nop                                # Delay slot do desvio condicional
    bne   $v1, $zero, falha_c5         # $v1 deve ser 0 em caso de erro
    nop                                # Delay slot do desvio condicional

    # Invoca busca e remocao com string de placa vazia ("")
    la    $a0, ap4_buffer              # $a0 = AP 4
    la    $a1, str_placa_vazia         # $a1 = ""
    jal   rmvAuto_busca_placa          # Busca placa vazia
    nop                                # Delay slot da chamada
    li    $t0, -1                      # Esperado = -1
    bne   $v0, $t0, falha_c5           # Se != -1, falha
    nop                                # Delay slot do desvio condicional
    bne   $v1, $zero, falha_c5         # $v1 deve ser 0
    nop                                # Delay slot do desvio condicional

    la    $a0, ap4_buffer              # $a0 = AP 4
    la    $a1, str_placa_vazia         # $a1 = ""
    jal   rmvAuto_remover              # Tenta remover placa vazia
    nop                                # Delay slot da chamada
    li    $t0, -1                      # Esperado = -1
    bne   $v0, $t0, falha_c5           # Se != -1, falha
    nop                                # Delay slot do desvio condicional
    bne   $v1, $zero, falha_c5         # $v1 deve ser 0
    nop                                # Delay slot do desvio condicional

    # Verifica se a memoria do AP 4 permaneceu rigorosamente intacta
    la    $s0, ap4_buffer              # Recarrega base do AP 4
    lw    $t0, TEST_OFF_NUM_VEIC($s0)  # Le num_veiculos
    li    $t1, 1                       # Deve continuar 1
    bne   $t0, $t1, falha_c5           # Se alterou, falha
    nop                                # Delay slot do desvio condicional

    lw    $t0, TEST_OFF_TIPO_VEIC($s0) # Le tipo_veiculo
    li    $t1, 99                      # Deve continuar 'c' (99)
    bne   $t0, $t1, falha_c5           # Se alterou, falha
    nop                                # Delay slot do desvio condicional

    # Verifica integridade dos dados no Slot 0
    addiu $a0, $s0, TEST_OFF_SLOT_0    # Slot 0
    addiu $a0, $a0, TEST_OFF_PLACA     # Placa
    la    $a1, str_carro1_plc          # "BRA2E19"
    jal   aux_compara_string           # Confirma placa intacta
    nop                                # Delay slot da chamada
    bne   $v0, $zero, falha_c5         # Se alterou, falha
    nop                                # Delay slot do desvio condicional

    # Sentinelas
    lw    $t0, ap4_guarda_antes        # Guarda anterior
    li    $t1, VAL_GUARDA_INICIO       # Valor esperado
    bne   $t0, $t1, falha_c5           # Se violado, falha
    nop                                # Delay slot do desvio condicional
    lw    $t0, ap4_guarda_depois       # Guarda posterior
    li    $t1, VAL_GUARDA_FIM          # Valor esperado
    bne   $t0, $t1, falha_c5           # Se violado, falha
    nop                                # Delay slot do desvio condicional

    # Emite mensagem de sucesso do Cenario 5
    la    $a0, msg_c5_ok               # Mensagem Cenario 5
    li    $v0, 4                       # Syscall 4
    syscall                            # Imprime confirmacao

    # ==============================================================
    # CENARIO 6: Erro ao tentar remover em AP com 0 veiculos
    # Estado inicial: AP com num_veiculos = 0, tipo_veiculo = 0
    # Acao: chamar rmvAuto_remover com qualquer placa
    # Comportamento esperado: $v0 = -1, memoria inalterada
    # ==============================================================
teste_cenario_6:
    la    $s0, ap5_buffer              # $s0 = base do AP 5

    # Limpa buffer do AP 5
    move  $a0, $s0                     # Base do buffer
    li    $a1, 128                     # 128 words
    jal   aux_zerar_words              # Zera memoria
    nop                                # Delay slot da chamada

    # Cabecalho com 0 veiculos
    sw    $zero, TEST_OFF_NUM_VEIC($s0) # num_veiculos = 0
    sw    $zero, TEST_OFF_TIPO_VEIC($s0) # tipo_veiculo = 0

    # Busca em AP vazio
    la    $a0, ap5_buffer              # AP 5
    la    $a1, str_carro1_plc          # "BRA2E19"
    jal   rmvAuto_busca_placa          # Invoca busca
    nop                                # Delay slot da chamada

    li    $t0, -1                      # Esperado = -1
    bne   $v0, $t0, falha_c6           # Se != -1, falha
    nop                                # Delay slot do desvio condicional
    bne   $v1, $zero, falha_c6         # $v1 deve ser 0 em caso de erro
    nop                                # Delay slot do desvio condicional

    # Remocao em AP vazio
    la    $a0, ap5_buffer              # AP 5
    la    $a1, str_carro1_plc          # "BRA2E19"
    jal   rmvAuto_remover              # Invoca remocao
    nop                                # Delay slot da chamada

    li    $t0, -1                      # Esperado = -1
    bne   $v0, $t0, falha_c6           # Se != -1, falha
    nop                                # Delay slot do desvio condicional
    bne   $v1, $zero, falha_c6         # $v1 deve ser 0 em caso de erro
    nop                                # Delay slot do desvio condicional

    # Verifica integridade
    la    $s0, ap5_buffer              # Recarrega base
    lw    $t0, TEST_OFF_NUM_VEIC($s0)  # Le num_veiculos
    bne   $t0, $zero, falha_c6         # Deve permanecer 0
    nop                                # Delay slot do desvio condicional
    lw    $t0, TEST_OFF_TIPO_VEIC($s0) # Le tipo_veiculo
    bne   $t0, $zero, falha_c6         # Deve permanecer 0
    nop                                # Delay slot do desvio condicional

    # Sentinelas
    lw    $t0, ap5_guarda_antes        # Guarda anterior
    li    $t1, VAL_GUARDA_INICIO       # Valor esperado
    bne   $t0, $t1, falha_c6           # Se violado, falha
    nop                                # Delay slot do desvio condicional
    lw    $t0, ap5_guarda_depois       # Guarda posterior
    li    $t1, VAL_GUARDA_FIM          # Valor esperado
    bne   $t0, $t1, falha_c6           # Se violado, falha
    nop                                # Delay slot do desvio condicional

    # Emite mensagem de sucesso do Cenario 6
    la    $a0, msg_c6_ok               # Mensagem Cenario 6
    li    $v0, 4                       # Syscall 4
    syscall                            # Imprime confirmacao

    # ==============================================================
    # CENARIO 7: Validacao de limites de parametros (ponteiros nulos)
    # Acoes:
    # 1. rmvAuto_remover(0, "BRA2E19") -> $v0 = -2
    # 2. rmvAuto_remover(ap6_buffer, 0) -> $v0 = -2
    # 3. rmvAuto_busca_placa(0, "BRA2E19") -> $v0 = -2
    # 4. rmvAuto_busca_placa(ap6_buffer, 0) -> $v0 = -2
    # Comportamento esperado: $v0 = -2 em todas as chamadas, sentinelas intactos
    # ==============================================================
teste_cenario_7:
    la    $s0, ap6_buffer              # $s0 = base do AP 6

    # Limpa buffer do AP 6
    move  $a0, $s0                     # Base do buffer
    li    $a1, 128                     # 128 words
    jal   aux_zerar_words              # Zera memoria
    nop                                # Delay slot da chamada

    # Teste 1: rmvAuto_remover com $a0 nulo
    li    $a0, 0                       # AP nulo
    la    $a1, str_carro1_plc          # Placa valida
    jal   rmvAuto_remover              # Invoca remocao
    nop                                # Delay slot da chamada
    li    $t0, -2                      # Esperado = -2
    bne   $v0, $t0, falha_c7           # Se != -2, falha
    nop                                # Delay slot do desvio condicional
    bne   $v1, $zero, falha_c7         # $v1 deve ser 0
    nop                                # Delay slot do desvio condicional

    # Teste 2: rmvAuto_remover com $a1 nulo
    la    $a0, ap6_buffer              # AP valido
    li    $a1, 0                       # Placa nula
    jal   rmvAuto_remover              # Invoca remocao
    nop                                # Delay slot da chamada
    li    $t0, -2                      # Esperado = -2
    bne   $v0, $t0, falha_c7           # Se != -2, falha
    nop                                # Delay slot do desvio condicional
    bne   $v1, $zero, falha_c7         # $v1 deve ser 0
    nop                                # Delay slot do desvio condicional

    # Teste 3: rmvAuto_busca_placa com $a0 nulo
    li    $a0, 0                       # AP nulo
    la    $a1, str_carro1_plc          # Placa valida
    jal   rmvAuto_busca_placa          # Invoca busca
    nop                                # Delay slot da chamada
    li    $t0, -2                      # Esperado = -2
    bne   $v0, $t0, falha_c7           # Se != -2, falha
    nop                                # Delay slot do desvio condicional
    bne   $v1, $zero, falha_c7         # $v1 deve ser 0
    nop                                # Delay slot do desvio condicional

    # Teste 4: rmvAuto_busca_placa com $a1 nulo
    la    $a0, ap6_buffer              # AP valido
    li    $a1, 0                       # Placa nula
    jal   rmvAuto_busca_placa          # Invoca busca
    nop                                # Delay slot da chamada
    li    $t0, -2                      # Esperado = -2
    bne   $v0, $t0, falha_c7           # Se != -2, falha
    nop                                # Delay slot do desvio condicional
    bne   $v1, $zero, falha_c7         # $v1 deve ser 0
    nop                                # Delay slot do desvio condicional

    # Teste 5: rmvAuto_excluir (alias) com $a0 nulo
    li    $a0, 0                       # AP nulo
    la    $a1, str_carro1_plc          # Placa valida
    jal   rmvAuto_excluir              # Invoca alias
    nop                                # Delay slot da chamada
    li    $t0, -2                      # Esperado = -2
    bne   $v0, $t0, falha_c7           # Se != -2, falha
    nop                                # Delay slot do desvio condicional
    bne   $v1, $zero, falha_c7         # $v1 deve ser 0
    nop                                # Delay slot do desvio condicional

    # Teste 6: rmvAuto_excluir (alias) com $a1 nulo
    la    $a0, ap6_buffer              # AP valido
    li    $a1, 0                       # Placa nula
    jal   rmvAuto_excluir              # Invoca alias
    nop                                # Delay slot da chamada
    li    $t0, -2                      # Esperado = -2
    bne   $v0, $t0, falha_c7           # Se != -2, falha
    nop                                # Delay slot do desvio condicional
    bne   $v1, $zero, falha_c7         # $v1 deve ser 0
    nop                                # Delay slot do desvio condicional

    # Sentinelas do AP 6 devem permanecer intactos
    lw    $t0, ap6_guarda_antes        # Guarda anterior
    li    $t1, VAL_GUARDA_INICIO       # Valor esperado
    bne   $t0, $t1, falha_c7           # Se violado, falha
    nop                                # Delay slot do desvio condicional
    lw    $t0, ap6_guarda_depois       # Guarda posterior
    li    $t1, VAL_GUARDA_FIM          # Valor esperado
    bne   $t0, $t1, falha_c7           # Se violado, falha
    nop                                # Delay slot do desvio condicional

    # Emite mensagem de sucesso do Cenario 7
    la    $a0, msg_c7_ok               # Mensagem Cenario 7
    li    $v0, 4                       # Syscall 4
    syscall                            # Imprime confirmacao

    # ==============================================================
    # Finalizacao com Sucesso Global de Todos os 7 Cenarios
    # ==============================================================
sucesso_global:
    la    $a0, msg_pass_final          # Carrega mensagem de sucesso de todos os cenarios
    li    $v0, 4                       # Syscall 4: imprimir string
    syscall                            # Imprime confirmacao geral de aprovacao

    li    $a0, 0                       # Codigo de encerramento 0 (Sucesso absoluto)
    li    $v0, 17                      # Syscall 17: exit2 com codigo de retorno
    syscall                            # Encerra execucao do simulador MARS

# ==============================================================
# Blocos de Tratamento de Falhas por Cenario
# ==============================================================
falha_c1:
    la    $a0, msg_falha_c1            # Carrega mensagem de erro do Cenario 1
    j     encerrar_com_falha           # Salta para encerramento com codigo 1
    nop                                # Preenche delay slot

falha_c2:
    la    $a0, msg_falha_c2            # Carrega mensagem de erro do Cenario 2
    j     encerrar_com_falha           # Salta para encerramento com codigo 1
    nop                                # Preenche delay slot

falha_c3:
    la    $a0, msg_falha_c3            # Carrega mensagem de erro do Cenario 3
    j     encerrar_com_falha           # Salta para encerramento com codigo 1
    nop                                # Preenche delay slot

falha_c4:
    la    $a0, msg_falha_c4            # Carrega mensagem de erro do Cenario 4
    j     encerrar_com_falha           # Salta para encerramento com codigo 1
    nop                                # Preenche delay slot

falha_c5:
    la    $a0, msg_falha_c5            # Carrega mensagem de erro do Cenario 5
    j     encerrar_com_falha           # Salta para encerramento com codigo 1
    nop                                # Preenche delay slot

falha_c6:
    la    $a0, msg_falha_c6            # Carrega mensagem de erro do Cenario 6
    j     encerrar_com_falha           # Salta para encerramento com codigo 1
    nop                                # Preenche delay slot

falha_c7:
    la    $a0, msg_falha_c7            # Carrega mensagem de erro do Cenario 7
    j     encerrar_com_falha           # Salta para encerramento com codigo 1
    nop                                # Preenche delay slot

encerrar_com_falha:
    li    $v0, 4                       # Syscall 4: imprimir string de erro
    syscall                            # Imprime a mensagem de erro correspondente
    li    $a0, 1                       # Codigo de encerramento 1 (Falha)
    li    $v0, 17                      # Syscall 17: exit2 com codigo de status
    syscall                            # Encerra execucao com status de erro

# ==============================================================
# Sub-rotinas Auxiliares de Teste
# ==============================================================

# --------------------------------------------------------------
# aux_zerar_words: Zera uma regiao de memoria por words
# Argumentos: $a0 = endereco base, $a1 = quantidade de words (4 bytes)
# --------------------------------------------------------------
aux_zerar_words:
    li    $t8, 0                       # Indice de word k = 0
aux_zw_loop:
    bge   $t8, $a1, aux_zw_fim         # Se k >= quantidade, encerra laco
    nop                                # Delay slot do desvio condicional
    sll   $t9, $t8, 2                  # Deslocamento em bytes = k * 4
    addu  $t9, $a0, $t9                # Endereco da word k
    sw    $zero, 0($t9)                # Zera word de memoria
    addiu $t8, $t8, 1                  # Incrementa k (k = k + 1)
    j     aux_zw_loop                  # Repete para a proxima word
    nop                                # Delay slot do salto incondicional
aux_zw_fim:
    jr    $ra                          # Retorna ao procedimento chamador
    nop                                # Delay slot do retorno

# --------------------------------------------------------------
# aux_copiar_string: Copia string de $a0 para $a1 incluindo '\0'
# --------------------------------------------------------------
aux_copiar_string:
    move  $t8, $a0                     # Ponteiro de origem
    move  $t9, $a1                     # Ponteiro de destino
aux_cp_loop:
    lbu   $t7, 0($t8)                  # Le caractere da origem
    sb    $t7, 0($t9)                  # Grava caractere no destino
    beqz  $t7, aux_cp_fim              # Se encontrou '\0', encerra
    nop                                # Delay slot do desvio condicional
    addiu $t8, $t8, 1                  # Avanca ponteiro origem
    addiu $t9, $t9, 1                  # Avanca ponteiro destino
    j     aux_cp_loop                  # Itera laco de copia
    nop                                # Delay slot do salto incondicional
aux_cp_fim:
    jr    $ra                          # Retorna ao procedimento chamador
    nop                                # Delay slot do retorno

# --------------------------------------------------------------
# aux_compara_string: Compara strings exatas terminadas em '\0'
# Retorno: $v0 = 0 se iguais, 1 se diferentes
# --------------------------------------------------------------
aux_compara_string:
    move  $v0, $zero                   # Inicializa retorno com 0 (iguais)
aux_cmp_loop:
    lbu   $t8, 0($a0)                  # Le byte da primeira string
    lbu   $t9, 0($a1)                  # Le byte da segunda string
    bne   $t8, $t9, aux_cmp_dif        # Se diferentes, falha
    nop                                # Delay slot do desvio condicional
    beqz  $t8, aux_cmp_fim             # Se chegou a '\0' e sao iguais, encerra
    nop                                # Delay slot do desvio condicional
    addiu $a0, $a0, 1                  # Avanca primeira string
    addiu $a1, $a1, 1                  # Avanca segunda string
    j     aux_cmp_loop                 # Itera comparacao
    nop                                # Delay slot do salto incondicional
aux_cmp_dif:
    li    $v0, 1                       # Retorna 1 (diferentes)
aux_cmp_fim:
    jr    $ra                          # Retorna ao procedimento chamador
    nop                                # Delay slot do retorno

# --------------------------------------------------------------
# aux_verifica_slot_zerado: Verifica se as 12 words (48 bytes) de um slot sao 0
# Argumentos: $a0 = endereco base do slot
# Retorno: $v0 = 0 se todo zerado, 1 se contiver qualquer byte != 0
# --------------------------------------------------------------
aux_verifica_slot_zerado:
    li    $t8, 0                       # Indice de word w = 0
    li    $t7, 12                      # Total de words por slot (12 words = 48 bytes)
aux_vsz_loop:
    bge   $t8, $t7, aux_vsz_ok         # Se checou todas as 12 words, esta zerado
    nop                                # Delay slot do desvio condicional
    sll   $t9, $t8, 2                  # Deslocamento em bytes = w * 4
    addu  $t9, $a0, $t9                # Endereco da word
    lw    $t6, 0($t9)                  # Carrega word
    bnez  $t6, aux_vsz_erro            # Se word != 0, encontrou resíduo indesejado
    nop                                # Delay slot do desvio condicional
    addiu $t8, $t8, 1                  # w = w + 1
    j     aux_vsz_loop                 # Repete para a proxima word
    nop                                # Delay slot do salto incondicional
aux_vsz_ok:
    li    $v0, 0                       # Retorna 0 (slot totalmente zerado)
    jr    $ra                          # Retorna
    nop                                # Delay slot
aux_vsz_erro:
    li    $v0, 1                       # Retorna 1 (slot contem residuos)
    jr    $ra                          # Retorna
    nop                                # Delay slot

# --------------------------------------------------------------
# aux_carregar_canarios: Carrega valores canarios em $s0-$s7
# --------------------------------------------------------------
aux_carregar_canarios:
    li    $s0, CANARIO_S0              # Carrega canario em $s0
    li    $s1, CANARIO_S1              # Carrega canario em $s1
    li    $s2, CANARIO_S2              # Carrega canario em $s2
    li    $s3, CANARIO_S3              # Carrega canario em $s3
    li    $s4, CANARIO_S4              # Carrega canario em $s4
    li    $s5, CANARIO_S5              # Carrega canario em $s5
    li    $s6, CANARIO_S6              # Carrega canario em $s6
    li    $s7, CANARIO_S7              # Carrega canario em $s7
    jr    $ra                          # Retorna ao chamador
    nop                                # Delay slot do retorno

# --------------------------------------------------------------
# aux_verificar_canarios: Verifica se $s0-$s7 continuam com os canarios
# Retorno: $v0 = 0 se todos intactos, 1 se qualquer um foi corrompido
# --------------------------------------------------------------
aux_verificar_canarios:
    li    $t8, CANARIO_S0              # Canario $s0
    bne   $s0, $t8, aux_can_erro       # Verifica $s0
    nop                                # Delay slot
    li    $t8, CANARIO_S1              # Canario $s1
    bne   $s1, $t8, aux_can_erro       # Verifica $s1
    nop                                # Delay slot
    li    $t8, CANARIO_S2              # Canario $s2
    bne   $s2, $t8, aux_can_erro       # Verifica $s2
    nop                                # Delay slot
    li    $t8, CANARIO_S3              # Canario $s3
    bne   $s3, $t8, aux_can_erro       # Verifica $s3
    nop                                # Delay slot
    li    $t8, CANARIO_S4              # Canario $s4
    bne   $s4, $t8, aux_can_erro       # Verifica $s4
    nop                                # Delay slot
    li    $t8, CANARIO_S5              # Canario $s5
    bne   $s5, $t8, aux_can_erro       # Verifica $s5
    nop                                # Delay slot
    li    $t8, CANARIO_S6              # Canario $s6
    bne   $s6, $t8, aux_can_erro       # Verifica $s6
    nop                                # Delay slot
    li    $t8, CANARIO_S7              # Canario $s7
    bne   $s7, $t8, aux_can_erro       # Verifica $s7
    nop                                # Delay slot
    li    $v0, 0                       # Todos os registradores salvos estao intactos
    jr    $ra                          # Retorna
    nop                                # Delay slot
aux_can_erro:
    li    $v0, 1                       # Registrador salvo corrompido
    jr    $ra                          # Retorna
    nop                                # Delay slot

# ==============================================================
# Inclusao do modulo sob teste (rmvAuto.asm)
# ==============================================================
.include "../src/automovel/rmvAuto.asm" # Inclui arquivo com as rotinas sob teste
