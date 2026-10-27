# ==============================================================
# Universidade Federal Rural de Pernambuco - UFRPE
# Departamento de Estatistica e Informatica - DEINFO
# Disciplina: Arquitetura e Organizacao de Computadores - 2026.2
# Professor: Vitor A. Coutinho
# Atividade: Projeto 01 (PE1 da 1a VA) - Assembly MIPS e MARS
# Grupo: LBFM (Leticia, Brenno, Ferraz, Marcos)
# Arquivo: addAuto_teste.asm
# Autor: Brenno Leite (brennolpereira@outlook.com.br)
# Descricao: Suite de testes unitarios automatizados para as rotinas
#            addAuto_validar_capacidade e addAuto_inserir / addAuto_adicionar.
#            Cobre os 7 cenarios regulamentares de capacidade e integridade.
# ==============================================================

.data                              # Segmento de definicao de dados em memoria

# Constantes de controle e validacao de integridade de memoria
.eqv VAL_GUARDA_INICIO  0xDEADBEEF # Padrao sentinela para deteccao de overflow antes do buffer
.eqv VAL_GUARDA_FIM     0xCAFEBABE # Padrao sentinela para deteccao de overflow depois do buffer
.eqv OFF_AP_NUM_VEIC    296        # Deslocamento do campo num_veiculos no registro do AP
.eqv OFF_AP_TIPO_VEIC   300        # Deslocamento do campo tipo_veiculo no registro do AP
.eqv OFF_AP_SLOT_0      304        # Deslocamento do primeiro slot de automovel (+304)
.eqv OFF_AP_SLOT_1      352        # Deslocamento do segundo slot de automovel (+352)
.eqv OFF_AP_SLOT_2      400        # Deslocamento do terceiro slot de automovel (+400)

# Strings de teste para modelos e placas de veiculos
str_carro1_mod:     .asciiz "Civic Sedan"                           # Modelo do primeiro carro de teste
str_carro1_plc:     .asciiz "BRA2E19"                               # Placa do primeiro carro de teste
str_carro2_mod:     .asciiz "Corolla Altis"                         # Modelo do segundo carro de teste
str_carro2_plc:     .asciiz "XYZ9876"                               # Placa do segundo carro de teste
str_moto1_mod:      .asciiz "Honda CG 160"                          # Modelo da primeira moto de teste
str_moto1_plc:      .asciiz "KGA1234"                               # Placa da primeira moto de teste
str_moto2_mod:      .asciiz "Yamaha Fazer 250"                      # Modelo da segunda moto de teste
str_moto2_plc:      .asciiz "PEA5678"                               # Placa da segunda moto de teste
str_moto3_mod:      .asciiz "BMW G310 GS"                           # Modelo da terceira moto de teste
str_moto3_plc:      .asciiz "XYZ9012"                               # Placa da terceira moto de teste
str_moto4_mod:      .asciiz "Kawasaki Ninja"                        # Modelo da quarta moto para teste de excesso
str_moto4_plc:      .asciiz "KWA4444"                               # Placa da quarta moto para teste de excesso
str_longo_mod:      .asciiz "ModeloMuitoLongoComMaisDeTrintaEUmCaracteres" # String excedente para testar truncamento
str_longo_plc:      .asciiz "PlacaComMaisDeOnzeCaracteres"          # String de placa excedente para truncamento
str_longo_mod_trunc:.asciiz "ModeloMuitoLongoComMaisDeTrinta"       # Esperado apos truncamento maximo de 31 caracteres
str_longo_plc_trunc:.asciiz "PlacaComMai"                           # Esperado apos truncamento maximo de 11 caracteres

# Mensagens de informacao e resultado no terminal
msg_titulo:         .asciiz "=== INICIANDO SUITE DE TESTES UNITARIOS: addAuto ===\n" # Cabecalho da suite de testes
msg_c1_ok:          .asciiz "[CENARIO 1] SUCESSO: Adicao de 1 carro em AP vazio (num=1, tipo='c', slot=+304)\n" # Mensagem Cenario 1
msg_c2_ok:          .asciiz "[CENARIO 2] SUCESSO: Rejeicao de 2o carro em AP com carro (codigo -2)\n" # Mensagem Cenario 2
msg_c3_ok:          .asciiz "[CENARIO 3] SUCESSO: Rejeicao de moto em AP com carro (codigo -2)\n" # Mensagem Cenario 3
msg_c4_ok:          .asciiz "[CENARIO 4] SUCESSO: Adicao de 3 motos em AP vazio (num=3, tipo='m', slots=+304, +352, +400)\n" # Mensagem Cenario 4
msg_c5_ok:          .asciiz "[CENARIO 5] SUCESSO: Rejeicao de 4a moto em AP com 3 motos (codigo -2)\n" # Mensagem Cenario 5
msg_c6_ok:          .asciiz "[CENARIO 6] SUCESSO: Rejeicao de tipos invalidos ('x', 0, AP nulo/invalido) com codigo -1\n" # Mensagem Cenario 6
msg_c7_ok:          .asciiz "[CENARIO 7] SUCESSO: Integridade de memoria, offsets e terminadores nulos verificados\n" # Mensagem Cenario 7
msg_pass_final:     .asciiz "\nPASS: addAuto_teste (todos os 7 cenarios aprovados com sucesso)\n" # Mensagem global de aprovacao
msg_falha_c1:       .asciiz "FAIL: Falha detectada no Cenario 1 (adicao de carro em AP vazio)\n" # Mensagem de erro Cenario 1
msg_falha_c2:       .asciiz "FAIL: Falha detectada no Cenario 2 (rejeicao de segundo carro)\n" # Mensagem de erro Cenario 2
msg_falha_c3:       .asciiz "FAIL: Falha detectada no Cenario 3 (rejeicao de moto em AP com carro)\n" # Mensagem de erro Cenario 3
msg_falha_c4:       .asciiz "FAIL: Falha detectada no Cenario 4 (adicao de 3 motos consecutivas)\n" # Mensagem de erro Cenario 4
msg_falha_c5:       .asciiz "FAIL: Falha detectada no Cenario 5 (rejeicao de quarta moto)\n" # Mensagem de erro Cenario 5
msg_falha_c6:       .asciiz "FAIL: Falha detectada no Cenario 6 (rejeicao de tipos invalidos)\n" # Mensagem de erro Cenario 6
msg_falha_c7:       .asciiz "FAIL: Falha detectada no Cenario 7 (integridade de memoria / truncamento)\n" # Mensagem de erro Cenario 7

# Buffers de apartamentos de teste com sentinelas de borda para protecao de memoria
.align 2                           # Garante alinhamento a palavra de 4 bytes
ap1_guarda_antes:   .word VAL_GUARDA_INICIO # Sentinela anterior do buffer 1
ap1_buffer:         .space 512              # Buffer de dados do AP 1 (512 bytes)
ap1_guarda_depois:  .word VAL_GUARDA_FIM    # Sentinela posterior do buffer 1

.align 2                           # Garante alinhamento a palavra de 4 bytes
ap2_guarda_antes:   .word VAL_GUARDA_INICIO # Sentinela anterior do buffer 2
ap2_buffer:         .space 512              # Buffer de dados do AP 2 (512 bytes)
ap2_guarda_depois:  .word VAL_GUARDA_FIM    # Sentinela posterior do buffer 2

.align 2                           # Garante alinhamento a palavra de 4 bytes
ap3_guarda_antes:   .word VAL_GUARDA_INICIO # Sentinela anterior do buffer 3
ap3_buffer:         .space 512              # Buffer de dados do AP 3 (512 bytes)
ap3_guarda_depois:  .word VAL_GUARDA_FIM    # Sentinela posterior do buffer 3

.align 2                           # Garante alinhamento a palavra de 4 bytes
ap4_guarda_antes:   .word VAL_GUARDA_INICIO # Sentinela anterior do buffer 4
ap4_buffer:         .space 512              # Buffer de dados do AP 4 (512 bytes)
ap4_guarda_depois:  .word VAL_GUARDA_FIM    # Sentinela posterior do buffer 4

.align 2                           # Garante alinhamento a palavra de 4 bytes
ap5_guarda_antes:   .word VAL_GUARDA_INICIO # Sentinela anterior do buffer 5
ap5_buffer:         .space 512              # Buffer de dados do AP 5 (512 bytes)
ap5_guarda_depois:  .word VAL_GUARDA_FIM    # Sentinela posterior do buffer 5

# ==============================================================
# Segmento de Codigo Executavel
# ==============================================================
.text                              # Segmento de instrucoes executaveis
.globl main                        # Ponto de entrada do programa de teste no MARS

main:                              # Inicio do procedimento principal de testes
    # Imprime cabecalho inicial no console
    la    $a0, msg_titulo          # Carrega endereco da mensagem de cabecalho
    li    $v0, 4                   # Codigo da syscall 4: imprimir string
    syscall                        # Invoca servico do sistema MARS

    # ==============================================================
    # CENARIO 1: Adicionar 1 carro em apartamento vazio
    # Expectativa: Sucesso ($v0 = 0), slot = AP + 304,
    #              num_veiculos = 1, tipo_veiculo = 'c' (99)
    # ==============================================================
cenario_1:                         # Rotulo do Cenario 1
    # 1.0 Inicializar registradores salvos ($s0-$s7) com padroes para teste de preservacao
    li    $s0, 0x11111111          # Padrao de teste para $s0
    li    $s1, 0x22222222          # Padrao de teste para $s1
    li    $s2, 0x33333333          # Padrao de teste para $s2
    li    $s3, 0x44444444          # Padrao de teste para $s3
    li    $s4, 0x55555555          # Padrao de teste para $s4
    li    $s5, 0x66666666          # Padrao de teste para $s5
    li    $s6, 0x77777777          # Padrao de teste para $s6
    li    $s7, 0x88888888          # Padrao de teste para $s7

    # 1.1 Testar addAuto_validar_capacidade com AP vazio e tipo 'c'
    la    $a0, ap1_buffer          # Passa endereco base do AP 1 vazio em $a0
    li    $a1, 99                  # Passa tipo 'c' (ASCII 99) em $a1
    jal   addAuto_validar_capacidade # Executa rotina de validacao de capacidade
    nop                            # Delay slot da chamada

    bne   $v0, $zero, erro_cenario_1 # Falha se validacao nao retornar 0 (sucesso)
    nop                            # Delay slot do desvio condicional
    li    $t0, 99                  # Valor esperado do tipo normalizado ('c')
    bne   $v1, $t0, erro_cenario_1 # Falha se tipo normalizado em $v1 != 'c'
    nop                            # Delay slot do desvio condicional

    # 1.1b Verificar preservacao dos argumentos $a0, $a1 e salvos $s0-$s7 na validacao
    la    $t0, ap1_buffer          # Recarrega endereco esperado de $a0
    bne   $a0, $t0, erro_cenario_1 # Falha se $a0 foi modificado pela rotina
    nop                            # Delay slot do desvio condicional
    li    $t0, 99                  # Valor esperado em $a1
    bne   $a1, $t0, erro_cenario_1 # Falha se $a1 foi modificado pela rotina
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x11111111          # Valor esperado de $s0
    bne   $s0, $t0, erro_cenario_1 # Falha se $s0 foi modificado
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x22222222          # Valor esperado de $s1
    bne   $s1, $t0, erro_cenario_1 # Falha se $s1 foi modificado
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x33333333          # Valor esperado de $s2
    bne   $s2, $t0, erro_cenario_1 # Falha se $s2 foi modificado
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x44444444          # Valor esperado de $s3
    bne   $s3, $t0, erro_cenario_1 # Falha se $s3 foi modificado
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x55555555          # Valor esperado de $s4
    bne   $s4, $t0, erro_cenario_1 # Falha se $s4 foi modificado
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x66666666          # Valor esperado de $s5
    bne   $s5, $t0, erro_cenario_1 # Falha se $s5 foi modificado
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x77777777          # Valor esperado de $s6
    bne   $s6, $t0, erro_cenario_1 # Falha se $s6 foi modificado
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x88888888          # Valor esperado de $s7
    bne   $s7, $t0, erro_cenario_1 # Falha se $s7 foi modificado
    nop                            # Delay slot do desvio condicional

    # 1.2 Inserir carro no AP vazio usando addAuto_inserir
    la    $a0, ap1_buffer          # Passa endereco base do AP 1 em $a0
    li    $a1, 99                  # Passa tipo 'c' em $a1
    la    $a2, str_carro1_mod      # Passa endereco da string de modelo em $a2
    la    $a3, str_carro1_plc      # Passa endereco da string de placa em $a3
    jal   addAuto_inserir          # Executa rotina de insercao do automovel
    nop                            # Delay slot da chamada

    bne   $v0, $zero, erro_cenario_1 # Falha se insercao nao retornar codigo 0
    nop                            # Delay slot do desvio condicional

    # 1.2b Verificar preservacao dos salvos $s0-$s7 apos a insercao
    li    $t0, 0x11111111          # Valor esperado de $s0
    bne   $s0, $t0, erro_cenario_1 # Falha se $s0 foi corrompido por addAuto_inserir
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x22222222          # Valor esperado de $s1
    bne   $s1, $t0, erro_cenario_1 # Falha se $s1 foi corrompido por addAuto_inserir
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x33333333          # Valor esperado de $s2
    bne   $s2, $t0, erro_cenario_1 # Falha se $s2 foi corrompido por addAuto_inserir
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x44444444          # Valor esperado de $s3
    bne   $s3, $t0, erro_cenario_1 # Falha se $s3 foi corrompido por addAuto_inserir
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x55555555          # Valor esperado de $s4
    bne   $s4, $t0, erro_cenario_1 # Falha se $s4 foi corrompido por addAuto_inserir
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x66666666          # Valor esperado de $s5
    bne   $s5, $t0, erro_cenario_1 # Falha se $s5 foi corrompido por addAuto_inserir
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x77777777          # Valor esperado de $s6
    bne   $s6, $t0, erro_cenario_1 # Falha se $s6 foi corrompido por addAuto_inserir
    nop                            # Delay slot do desvio condicional
    li    $t0, 0x88888888          # Valor esperado de $s7
    bne   $s7, $t0, erro_cenario_1 # Falha se $s7 foi corrompido por addAuto_inserir
    nop                            # Delay slot do desvio condicional

    la    $t0, ap1_buffer          # Carrega endereco base do AP 1
    addiu $t0, $t0, OFF_AP_SLOT_0  # Calcula endereco esperado do Slot 0 (AP + 304)
    bne   $v1, $t0, erro_cenario_1 # Falha se endereco de retorno em $v1 divergir do Slot 0
    nop                            # Delay slot do desvio condicional

    # 1.3 Verificar campos atualizados no registro do AP
    la    $t0, ap1_buffer          # Carrega endereco base do AP 1
    lw    $t1, OFF_AP_NUM_VEIC($t0) # Le contagem num_veiculos no AP (offset 296)
    li    $t2, 1                   # Quantidade esperada de veiculos: 1
    bne   $t1, $t2, erro_cenario_1 # Falha se num_veiculos nao for exatamente 1
    nop                            # Delay slot do desvio condicional

    lw    $t1, OFF_AP_TIPO_VEIC($t0) # Le tipo_veiculo no registro do AP (offset 300)
    li    $t2, 99                  # Tipo esperado: 'c' (99)
    bne   $t1, $t2, erro_cenario_1 # Falha se tipo_veiculo nao for 'c'
    nop                            # Delay slot do desvio condicional

    # 1.4 Verificar integridade dos dados gravados no Slot 0
    lw    $t1, OFF_AP_SLOT_0($t0)  # Le tipo gravado no Slot 0 (+304)
    bne   $t1, $t2, erro_cenario_1 # Falha se tipo do veiculo no slot nao for 'c'
    nop                            # Delay slot do desvio condicional

    addiu $a0, $t0, 308            # Endereco da string modelo no Slot 0 (+304 + 4 = 308)
    la    $a1, str_carro1_mod      # Endereco da string de modelo esperada ("Civic Sedan")
    jal   aux_compara_string       # Compara strings caractere por caractere
    nop                            # Delay slot da chamada
    bne   $v0, $zero, erro_cenario_1 # Falha se string do modelo gravada for divergente
    nop                            # Delay slot do desvio condicional

    addiu $a0, $t0, 340            # Endereco da string placa no Slot 0 (+304 + 36 = 340)
    la    $a1, str_carro1_plc      # Endereco da string de placa esperada ("BRA2E19")
    jal   aux_compara_string       # Compara strings caractere por caractere
    nop                            # Delay slot da chamada
    bne   $v0, $zero, erro_cenario_1 # Falha se string da placa gravada for divergente
    nop                            # Delay slot do desvio condicional

    # Cenario 1 passou com sucesso
    la    $a0, msg_c1_ok           # Carrega mensagem de sucesso do Cenario 1
    li    $v0, 4                   # Codigo syscall para impressao de string
    syscall                        # Imprime confirmacao do Cenario 1

    # ==============================================================
    # CENARIO 2: Rejeitar 2o carro em apartamento que ja possui carro
    # Expectativa: Erro ($v0 = -2) tanto na validacao quanto na insercao.
    #              Registro permanece inalterado (num_veiculos = 1).
    # ==============================================================
cenario_2:                         # Rotulo do Cenario 2
    # 2.1 Validar tentativa com 'c' minusculo
    la    $a0, ap1_buffer          # AP 1 ja possui 1 carro registrado
    li    $a1, 99                  # Tipo 'c' minusculo
    jal   addAuto_validar_capacidade # Executa validacao de capacidade
    nop                            # Delay slot da chamada
    li    $t0, -2                  # Codigo de erro esperado: -2 (maximo atingido)
    bne   $v0, $t0, erro_cenario_2 # Falha se validacao nao rejeitar com -2
    nop                            # Delay slot do desvio condicional

    # 2.2 Validar tentativa com 'C' maiusculo
    la    $a0, ap1_buffer          # Endereco base do AP 1
    li    $a1, 67                  # Tipo 'C' maiusculo (ASCII 67)
    jal   addAuto_validar_capacidade # Executa validacao de capacidade
    nop                            # Delay slot da chamada
    li    $t0, -2                  # Codigo de erro esperado: -2
    bne   $v0, $t0, erro_cenario_2 # Falha se validacao com 'C' maiusculo nao retornar -2
    nop                            # Delay slot do desvio condicional

    # 2.3 Tentativa de insercao do 2o carro
    la    $a0, ap1_buffer          # Endereco base do AP 1
    li    $a1, 99                  # Tipo 'c'
    la    $a2, str_carro2_mod      # Modelo do segundo carro
    la    $a3, str_carro2_plc      # Placa do segundo carro
    jal   addAuto_inserir          # Tenta inserir segundo carro
    nop                            # Delay slot da chamada
    li    $t0, -2                  # Codigo de erro esperado: -2
    bne   $v0, $t0, erro_cenario_2 # Falha se insercao nao retornar erro -2
    nop                            # Delay slot do desvio condicional
    bne   $v1, $zero, erro_cenario_2 # Falha se ponteiro de slot retornado nao for 0
    nop                            # Delay slot do desvio condicional

    # 2.4 Verificar se o estado do AP 1 permaneceu integro
    la    $t0, ap1_buffer          # Endereco base do AP 1
    lw    $t1, OFF_AP_NUM_VEIC($t0) # Le contagem de veiculos
    li    $t2, 1                   # Quantidade deve permanecer 1
    bne   $t1, $t2, erro_cenario_2 # Falha se contador de veiculos foi alterado
    nop                            # Delay slot do desvio condicional

    lw    $t1, OFF_AP_SLOT_1($t0)  # Le tipo no Slot 1 (+352)
    bne   $t1, $zero, erro_cenario_2 # Falha se Slot 1 foi corrompido ou preenchido
    nop                            # Delay slot do desvio condicional

    # Cenario 2 passou com sucesso
    la    $a0, msg_c2_ok           # Carrega mensagem de sucesso do Cenario 2
    li    $v0, 4                   # Codigo syscall para impressao de string
    syscall                        # Imprime confirmacao do Cenario 2

    # ==============================================================
    # CENARIO 3: Rejeitar moto em apartamento que ja possui carro
    # Expectativa: Erro ($v0 = -2) por incompatibilidade de tipo / mutua exclusao.
    #              Registro permanece com 1 carro e tipo 'c'.
    # ==============================================================
cenario_3:                         # Rotulo do Cenario 3
    # 3.1 Validar tentativa com moto 'm' minusculo no AP com carro
    la    $a0, ap1_buffer          # AP 1 ja contem carro
    li    $a1, 109                 # Tipo 'm' minusculo (ASCII 109)
    jal   addAuto_validar_capacidade # Executa validacao de capacidade
    nop                            # Delay slot da chamada
    li    $t0, -2                  # Codigo de erro esperado: -2
    bne   $v0, $t0, erro_cenario_3 # Falha se validacao nao rejeitar moto com -2
    nop                            # Delay slot do desvio condicional

    # 3.2 Validar tentativa com moto 'M' maiusculo no AP com carro
    la    $a0, ap1_buffer          # Endereco base do AP 1
    li    $a1, 77                  # Tipo 'M' maiusculo (ASCII 77)
    jal   addAuto_validar_capacidade # Executa validacao de capacidade
    nop                            # Delay slot da chamada
    li    $t0, -2                  # Codigo de erro esperado: -2
    bne   $v0, $t0, erro_cenario_3 # Falha se validacao com 'M' maiusculo nao retornar -2
    nop                            # Delay slot do desvio condicional

    # 3.3 Tentar inserir moto no AP com carro
    la    $a0, ap1_buffer          # Endereco base do AP 1
    li    $a1, 109                 # Tipo 'm'
    la    $a2, str_moto1_mod       # Modelo da moto
    la    $a3, str_moto1_plc       # Placa da moto
    jal   addAuto_inserir          # Tenta inserir moto
    nop                            # Delay slot da chamada
    li    $t0, -2                  # Codigo de erro esperado: -2
    bne   $v0, $t0, erro_cenario_3 # Falha se insercao nao for rejeitada com -2
    nop                            # Delay slot do desvio condicional
    bne   $v1, $zero, erro_cenario_3 # Falha se retorno de slot nao for nulo
    nop                            # Delay slot do desvio condicional

    # 3.4 Verificar se o AP permanece inalterado
    la    $t0, ap1_buffer          # Endereco base do AP 1
    lw    $t1, OFF_AP_NUM_VEIC($t0) # Le num_veiculos
    li    $t2, 1                   # Valor esperado: 1
    bne   $t1, $t2, erro_cenario_3 # Falha se contagem foi modificada
    nop                            # Delay slot do desvio condicional
    lw    $t1, OFF_AP_TIPO_VEIC($t0) # Le tipo_veiculo
    li    $t2, 99                  # Valor esperado permanece 'c'
    bne   $t1, $t2, erro_cenario_3 # Falha se tipo_veiculo foi modificado
    nop                            # Delay slot do desvio condicional

    # Cenario 3 passou com sucesso
    la    $a0, msg_c3_ok           # Carrega mensagem de sucesso do Cenario 3
    li    $v0, 4                   # Codigo syscall para impressao de string
    syscall                        # Imprime confirmacao do Cenario 3

    # ==============================================================
    # CENARIO 4: Adicionar 3 motos consecutivas em apartamento vazio
    # Expectativa: Sucesso nas 3 insercoes, slots nos offsets +304, +352 e +400.
    #              Ao final, num_veiculos = 3 e tipo_veiculo = 'm'.
    # ==============================================================
cenario_4:                         # Rotulo do Cenario 4
    # 4.1 Inserir Primeira Moto (Slot 0 -> +304)
    la    $a0, ap2_buffer          # Endereco base do AP 2 vazio
    li    $a1, 109                 # Tipo 'm' minusculo
    la    $a2, str_moto1_mod       # Modelo moto 1: "Honda CG 160"
    la    $a3, str_moto1_plc       # Placa moto 1: "KGA1234"
    jal   addAuto_inserir          # Insere primeira moto
    nop                            # Delay slot da chamada

    bne   $v0, $zero, erro_cenario_4 # Falha se primeira insercao falhar
    nop                            # Delay slot do desvio condicional
    la    $t0, ap2_buffer          # Endereco base do AP 2
    addiu $t1, $t0, OFF_AP_SLOT_0  # Endereco esperado do Slot 0 (+304)
    bne   $v1, $t1, erro_cenario_4 # Falha se endereco do Slot 0 for incorreto
    nop                            # Delay slot do desvio condicional

    lw    $t2, OFF_AP_NUM_VEIC($t0) # Le num_veiculos do AP 2
    li    $t3, 1                   # Contagem esperada: 1
    bne   $t2, $t3, erro_cenario_4 # Falha se num_veiculos != 1 apos primeira moto
    nop                            # Delay slot do desvio condicional
    lw    $t2, OFF_AP_TIPO_VEIC($t0) # Le tipo_veiculo do AP 2
    li    $t3, 109                 # Tipo esperado: 'm' (109)
    bne   $t2, $t3, erro_cenario_4 # Falha se tipo_veiculo != 'm'
    nop                            # Delay slot do desvio condicional

    # 4.2 Inserir Segunda Moto com 'M' maiusculo para testar normalizacao (Slot 1 -> +352)
    la    $a0, ap2_buffer          # Endereco base do AP 2
    li    $a1, 77                  # Tipo 'M' maiusculo
    la    $a2, str_moto2_mod       # Modelo moto 2: "Yamaha Fazer 250"
    la    $a3, str_moto2_plc       # Placa moto 2: "PEA5678"
    jal   addAuto_inserir          # Insere segunda moto
    nop                            # Delay slot da chamada

    bne   $v0, $zero, erro_cenario_4 # Falha se segunda insercao falhar
    nop                            # Delay slot do desvio condicional
    la    $t0, ap2_buffer          # Endereco base do AP 2
    addiu $t1, $t0, OFF_AP_SLOT_1  # Endereco esperado do Slot 1 (+352)
    bne   $v1, $t1, erro_cenario_4 # Falha se endereco do Slot 1 for incorreto
    nop                            # Delay slot do desvio condicional

    lw    $t2, OFF_AP_NUM_VEIC($t0) # Le num_veiculos
    li    $t3, 2                   # Contagem esperada: 2
    bne   $t2, $t3, erro_cenario_4 # Falha se num_veiculos != 2 apos segunda moto
    nop                            # Delay slot do desvio condicional

    # 4.3 Inserir Terceira Moto (Slot 2 -> +400)
    la    $a0, ap2_buffer          # Endereco base do AP 2
    li    $a1, 109                 # Tipo 'm' minusculo
    la    $a2, str_moto3_mod       # Modelo moto 3: "BMW G310 GS"
    la    $a3, str_moto3_plc       # Placa moto 3: "XYZ9012"
    jal   addAuto_inserir          # Insere terceira moto
    nop                            # Delay slot da chamada

    bne   $v0, $zero, erro_cenario_4 # Falha se terceira insercao falhar
    nop                            # Delay slot do desvio condicional
    la    $t0, ap2_buffer          # Endereco base do AP 2
    addiu $t1, $t0, OFF_AP_SLOT_2  # Endereco esperado do Slot 2 (+400)
    bne   $v1, $t1, erro_cenario_4 # Falha se endereco do Slot 2 for incorreto
    nop                            # Delay slot do desvio condicional

    lw    $t2, OFF_AP_NUM_VEIC($t0) # Le num_veiculos final
    li    $t3, 3                   # Contagem esperada: 3
    bne   $t2, $t3, erro_cenario_4 # Falha se num_veiculos != 3 apos terceira moto
    nop                            # Delay slot do desvio condicional
    lw    $t2, OFF_AP_TIPO_VEIC($t0) # Le tipo_veiculo final
    li    $t3, 109                 # Tipo esperado: 'm'
    bne   $t2, $t3, erro_cenario_4 # Falha se tipo_veiculo != 'm'
    nop                            # Delay slot do desvio condicional

    # Cenario 4 passou com sucesso
    la    $a0, msg_c4_ok           # Carrega mensagem de sucesso do Cenario 4
    li    $v0, 4                   # Codigo syscall para impressao de string
    syscall                        # Imprime confirmacao do Cenario 4

    # ==============================================================
    # CENARIO 5: Rejeitar 4a moto em apartamento que ja possui 3 motos
    # Expectativa: Erro ($v0 = -2) tanto na validacao quanto na insercao.
    #              num_veiculos permanece 3.
    # ==============================================================
cenario_5:                         # Rotulo do Cenario 5
    # 5.1 Validar capacidade para 4a moto
    la    $a0, ap2_buffer          # AP 2 ja possui 3 motos registradas
    li    $a1, 109                 # Tipo 'm'
    jal   addAuto_validar_capacidade # Executa validacao de capacidade
    nop                            # Delay slot da chamada
    li    $t0, -2                  # Retorno esperado: -2 (limite maximo)
    bne   $v0, $t0, erro_cenario_5 # Falha se validacao nao rejeitar com -2
    nop                            # Delay slot do desvio condicional

    # 5.2 Tentar inserir 4a moto
    la    $a0, ap2_buffer          # Endereco base do AP 2
    li    $a1, 109                 # Tipo 'm'
    la    $a2, str_moto4_mod       # Modelo excedente
    la    $a3, str_moto4_plc       # Placa excedente
    jal   addAuto_inserir          # Tenta inserir quarta moto
    nop                            # Delay slot da chamada
    li    $t0, -2                  # Retorno esperado: -2
    bne   $v0, $t0, erro_cenario_5 # Falha se insercao nao retornar -2
    nop                            # Delay slot do desvio condicional
    bne   $v1, $zero, erro_cenario_5 # Falha se endereco de slot nao for nulo
    nop                            # Delay slot do desvio condicional

    # 5.3 Verificar se o contador de veiculos permanece 3
    la    $t0, ap2_buffer          # Endereco base do AP 2
    lw    $t1, OFF_AP_NUM_VEIC($t0) # Le contagem de veiculos
    li    $t2, 3                   # Valor esperado: 3
    bne   $t1, $t2, erro_cenario_5 # Falha se contador foi incrementado indevidamente
    nop                            # Delay slot do desvio condicional

    # 5.4 Validar rejeicao de carro em AP com 3 motos (mutua exclusao)
    la    $a0, ap2_buffer          # AP 2 ja possui 3 motos registradas
    li    $a1, 99                  # Tipo 'c'
    jal   addAuto_validar_capacidade # Executa validacao de capacidade para carro
    nop                            # Delay slot da chamada
    li    $t0, -2                  # Retorno esperado: -2 (incompatibilidade / limite)
    bne   $v0, $t0, erro_cenario_5 # Falha se carro em AP com motos nao retornar -2
    nop                            # Delay slot do desvio condicional

    # 5.5 Tentar inserir carro em AP com motos
    la    $a0, ap2_buffer          # Endereco base do AP 2
    li    $a1, 99                  # Tipo 'c'
    la    $a2, str_carro1_mod      # Modelo generico
    la    $a3, str_carro1_plc      # Placa generica
    jal   addAuto_inserir          # Tenta inserir carro
    nop                            # Delay slot da chamada
    li    $t0, -2                  # Retorno esperado: -2
    bne   $v0, $t0, erro_cenario_5 # Falha se insercao de carro nao retornar -2
    nop                            # Delay slot do desvio condicional
    bne   $v1, $zero, erro_cenario_5 # Falha se endereco de slot nao for nulo
    nop                            # Delay slot do desvio condicional

    # 5.6 Confirmar que estado do AP 2 permanece integro (3 motos e tipo 'm')
    la    $t0, ap2_buffer          # Endereco base do AP 2
    lw    $t1, OFF_AP_NUM_VEIC($t0) # Le contagem de veiculos
    li    $t2, 3                   # Valor esperado: 3
    bne   $t1, $t2, erro_cenario_5 # Falha se contagem foi alterada
    nop                            # Delay slot do desvio condicional
    lw    $t1, OFF_AP_TIPO_VEIC($t0) # Le tipo geral de veiculo
    li    $t2, 109                 # Tipo deve permanecer 'm'
    bne   $t1, $t2, erro_cenario_5 # Falha se tipo_veiculo foi alterado
    nop                            # Delay slot do desvio condicional

    # Cenario 5 passou com sucesso
    la    $a0, msg_c5_ok           # Carrega mensagem de sucesso do Cenario 5
    li    $v0, 4                   # Codigo syscall para impressao de string
    syscall                        # Imprime confirmacao do Cenario 5

    # ==============================================================
    # CENARIO 6: Rejeitar tipos invalidos ('x', 0, nulo) com erro -1
    # Expectativa: $v0 = -1 e $v1 = 0 em todas as operacoes invalidas.
    # ==============================================================
cenario_6:                         # Rotulo do Cenario 6
    # 6.1 Testar caractere 'x' (ASCII 120) na validacao
    la    $a0, ap3_buffer          # Endereco base do AP 3 vazio
    li    $a1, 120                 # Caractere invalido 'x'
    jal   addAuto_validar_capacidade # Valida tipo desconhecido
    nop                            # Delay slot da chamada
    li    $t0, -1                  # Retorno esperado: -1 (tipo invalido)
    bne   $v0, $t0, erro_cenario_6 # Falha se tipo 'x' nao for rejeitado com -1
    nop                            # Delay slot do desvio condicional

    # 6.2 Testar caractere 'x' na insercao
    la    $a0, ap3_buffer          # Endereco base do AP 3
    li    $a1, 120                 # Caractere invalido 'x'
    la    $a2, str_carro1_mod      # Modelo generico
    la    $a3, str_carro1_plc      # Placa generica
    jal   addAuto_inserir          # Tenta inserir veiculo de tipo invalido
    nop                            # Delay slot da chamada
    li    $t0, -1                  # Retorno esperado: -1
    bne   $v0, $t0, erro_cenario_6 # Falha se insercao com 'x' nao retornar -1
    nop                            # Delay slot do desvio condicional
    bne   $v1, $zero, erro_cenario_6 # Falha se retorno $v1 nao for zero
    nop                            # Delay slot do desvio condicional

    # 6.3 Testar valor zero (caractere nulo) na validacao
    la    $a0, ap3_buffer          # Endereco base do AP 3
    li    $a1, 0                   # Tipo numerico 0
    jal   addAuto_validar_capacidade # Valida tipo nulo
    nop                            # Delay slot da chamada
    li    $t0, -1                  # Retorno esperado: -1
    bne   $v0, $t0, erro_cenario_6 # Falha se tipo 0 nao for rejeitado com -1
    nop                            # Delay slot do desvio condicional

    # 6.3b Testar rejeicao de valor zero na insercao (codigo -1)
    la    $a0, ap3_buffer          # Endereco base do AP 3
    li    $a1, 0                   # Tipo numerico 0
    la    $a2, str_carro1_mod      # Modelo generico
    la    $a3, str_carro1_plc      # Placa generica
    jal   addAuto_inserir          # Tenta insercao com tipo nulo
    nop                            # Delay slot da chamada
    li    $t0, -1                  # Retorno esperado: -1
    bne   $v0, $t0, erro_cenario_6 # Falha se insercao com tipo 0 nao retornar -1
    nop                            # Delay slot do desvio condicional
    bne   $v1, $zero, erro_cenario_6 # Falha se retorno $v1 nao for zero
    nop                            # Delay slot do desvio condicional

    # 6.4 Testar endereco base de apartamento nulo ($a0 = 0)
    move  $a0, $zero               # Passa ponteiro nulo para AP
    li    $a1, 99                  # Tipo valido 'c'
    jal   addAuto_validar_capacidade # Valida chamada com AP nulo
    nop                            # Delay slot da chamada
    li    $t0, -1                  # Retorno esperado: -1
    bne   $v0, $t0, erro_cenario_6 # Falha se ponteiro de AP nulo nao retornar -1
    nop                            # Delay slot do desvio condicional

    move  $a0, $zero               # Passa ponteiro nulo para insercao
    li    $a1, 99                  # Tipo valido 'c'
    la    $a2, str_carro1_mod      # Modelo generico
    la    $a3, str_carro1_plc      # Placa generica
    jal   addAuto_inserir          # Tenta insercao com AP nulo
    nop                            # Delay slot da chamada
    li    $t0, -1                  # Retorno esperado: -1
    bne   $v0, $t0, erro_cenario_6 # Falha se insercao com AP nulo nao retornar -1
    nop                            # Delay slot do desvio condicional
    bne   $v1, $zero, erro_cenario_6 # Falha se $v1 nao for zero
    nop                            # Delay slot do desvio condicional

    # 6.5 Testar integridade de contador corrompido (num_veiculos < 0)
    la    $t0, ap3_buffer          # Endereco base do AP 3
    li    $t1, -1                  # Valor corrompido para num_veiculos
    sw    $t1, OFF_AP_NUM_VEIC($t0) # Forca num_veiculos = -1 no AP 3
    la    $a0, ap3_buffer          # Passa AP 3 com campo corrompido
    li    $a1, 99                  # Tipo 'c'
    jal   addAuto_validar_capacidade # Executa validacao de integridade
    nop                            # Delay slot da chamada
    li    $t2, -1                  # Retorno esperado: -1
    bne   $v0, $t2, erro_cenario_6 # Falha se AP com contagem negativa nao for rejeitado
    nop                            # Delay slot do desvio condicional
    la    $t0, ap3_buffer          # Recarrega endereco base do AP 3
    sw    $zero, OFF_AP_NUM_VEIC($t0) # Restaura num_veiculos = 0 para seguranca

    # Cenario 6 passou com sucesso
    la    $a0, msg_c6_ok           # Carrega mensagem de sucesso do Cenario 6
    li    $v0, 4                   # Codigo syscall para impressao de string
    syscall                        # Imprime confirmacao do Cenario 6

    # ==============================================================
    # CENARIO 7: Integridade de memoria, offsets e terminacao nula
    # Verificacoes:
    # 7.1 Confirmar offsets de slots no AP 2: +304, +352, +400 e strings.
    # 7.2 Insercao com strings longas no AP 4: garantir truncamento e '\0'.
    # 7.3 Insercao com ponteiros nulos de string no AP 5.
    # 7.4 Inviolabilidade dos sentinelas DEADBEEF e CAFEBABE.
    # ==============================================================
cenario_7:                         # Rotulo do Cenario 7
    # 7.1 Checar dados e terminadores nulos nas 3 motos do AP 2
    la    $t0, ap2_buffer          # Carrega base do AP 2

    # Slot 0 (+304)
    lw    $t1, OFF_AP_SLOT_0($t0)  # Le tipo no Slot 0
    li    $t2, 109                 # Esperado: 'm' (109)
    bne   $t1, $t2, erro_cenario_7 # Falha se tipo no Slot 0 for invalido
    nop                            # Delay slot do desvio condicional
    addiu $a0, $t0, 308            # Modelo da Moto 1 no Slot 0 (+308)
    la    $a1, str_moto1_mod       # Esperado: "Honda CG 160"
    jal   aux_compara_string       # Valida correspondencia exata da string
    nop                            # Delay slot da chamada
    bne   $v0, $zero, erro_cenario_7 # Falha se string de modelo divergir
    nop                            # Delay slot do desvio condicional
    addiu $a0, $t0, 340            # Placa da Moto 1 no Slot 0 (+340)
    la    $a1, str_moto1_plc       # Esperado: "KGA1234"
    jal   aux_compara_string       # Valida correspondencia exata da placa
    nop                            # Delay slot da chamada
    bne   $v0, $zero, erro_cenario_7 # Falha se string de placa divergir
    nop                            # Delay slot do desvio condicional

    # Slot 1 (+352)
    lw    $t1, OFF_AP_SLOT_1($t0)  # Le tipo no Slot 1
    li    $t2, 109                 # Esperado: 'm' (109)
    bne   $t1, $t2, erro_cenario_7 # Falha se tipo no Slot 1 for invalido
    nop                            # Delay slot do desvio condicional
    addiu $a0, $t0, 356            # Modelo da Moto 2 no Slot 1 (+356)
    la    $a1, str_moto2_mod       # Esperado: "Yamaha Fazer 250"
    jal   aux_compara_string       # Valida correspondencia exata da string
    nop                            # Delay slot da chamada
    bne   $v0, $zero, erro_cenario_7 # Falha se modelo no Slot 1 divergir
    nop                            # Delay slot do desvio condicional
    addiu $a0, $t0, 388            # Placa da Moto 2 no Slot 1 (+388)
    la    $a1, str_moto2_plc       # Esperado: "PEA5678"
    jal   aux_compara_string       # Valida correspondencia exata da placa
    nop                            # Delay slot da chamada
    bne   $v0, $zero, erro_cenario_7 # Falha se placa no Slot 1 divergir
    nop                            # Delay slot do desvio condicional

    # Slot 2 (+400)
    lw    $t1, OFF_AP_SLOT_2($t0)  # Le tipo no Slot 2
    li    $t2, 109                 # Esperado: 'm' (109)
    bne   $t1, $t2, erro_cenario_7 # Falha se tipo no Slot 2 for invalido
    nop                            # Delay slot do desvio condicional
    addiu $a0, $t0, 404            # Modelo da Moto 3 no Slot 2 (+404)
    la    $a1, str_moto3_mod       # Esperado: "BMW G310 GS"
    jal   aux_compara_string       # Valida correspondencia exata da string
    nop                            # Delay slot da chamada
    bne   $v0, $zero, erro_cenario_7 # Falha se modelo no Slot 2 divergir
    nop                            # Delay slot do desvio condicional
    addiu $a0, $t0, 436            # Placa da Moto 3 no Slot 2 (+436)
    la    $a1, str_moto3_plc       # Esperado: "XYZ9012"
    jal   aux_compara_string       # Valida correspondencia exata da placa
    nop                            # Delay slot da chamada
    bne   $v0, $zero, erro_cenario_7 # Falha se placa no Slot 2 divergir
    nop                            # Delay slot do desvio condicional

    # 7.2 Testar truncamento seguro com strings longas no AP 4
    # Pre-preenche o slot 0 do AP 4 com bytes sujos (0xFF) para testar limpeza e truncamento
    la    $t0, ap4_buffer          # Endereco base do AP 4
    li    $t1, 0xFFFFFFFF          # Padrao de bytes sujos
    sw    $t1, 304($t0)            # Preenche word 0 do slot com lixo
    sw    $t1, 308($t0)            # Preenche word 1 do slot com lixo
    sw    $t1, 312($t0)            # Preenche word 2 do slot com lixo
    sw    $t1, 316($t0)            # Preenche word 3 do slot com lixo
    sw    $t1, 320($t0)            # Preenche word 4 do slot com lixo
    sw    $t1, 324($t0)            # Preenche word 5 do slot com lixo
    sw    $t1, 328($t0)            # Preenche word 6 do slot com lixo
    sw    $t1, 332($t0)            # Preenche word 7 do slot com lixo
    sw    $t1, 336($t0)            # Preenche word 8 do slot com lixo
    sw    $t1, 340($t0)            # Preenche word 9 do slot com lixo
    sw    $t1, 344($t0)            # Preenche word 10 do slot com lixo
    sw    $t1, 348($t0)            # Preenche word 11 do slot com lixo
    sw    $zero, OFF_AP_NUM_VEIC($t0) # Assegura num_veiculos = 0 no AP 4
    sw    $zero, OFF_AP_TIPO_VEIC($t0) # Assegura tipo_veiculo = 0 no AP 4

    la    $a0, ap4_buffer          # Endereco base do AP 4
    li    $a1, 99                  # Tipo 'c'
    la    $a2, str_longo_mod       # Modelo excedente (42 caracteres)
    la    $a3, str_longo_plc       # Placa excedente (28 caracteres)
    jal   addAuto_inserir          # Executa insercao com buffers longos
    nop                            # Delay slot da chamada
    bne   $v0, $zero, erro_cenario_7 # Falha se insercao com string longa falhar
    nop                            # Delay slot do desvio condicional

    # Verifica byte terminador no final do buffer de modelo (offset 304 + 4 + 31 = 339)
    la    $t0, ap4_buffer          # Endereco base do AP 4
    lbu   $t1, 339($t0)            # Le 32o byte do campo modelo (indice 31)
    bne   $t1, $zero, erro_cenario_7 # Falha se terminador nulo nao for garantido no modelo
    nop                            # Delay slot do desvio condicional

    # Verifica byte terminador no final do buffer de placa (offset 304 + 36 + 11 = 351)
    lbu   $t1, 351($t0)            # Le 12o byte do campo placa (indice 11)
    bne   $t1, $zero, erro_cenario_7 # Falha se terminador nulo nao for garantido na placa
    nop                            # Delay slot do desvio condicional

    # Verifica correspondencia exata dos primeiros 31 caracteres do modelo truncado
    addiu $a0, $t0, 308            # Modelo gravado no Slot 0 (+308)
    la    $a1, str_longo_mod_trunc # Esperado: 31 caracteres de str_longo_mod
    jal   aux_compara_string       # Compara conteudo truncado do modelo
    nop                            # Delay slot da chamada
    bne   $v0, $zero, erro_cenario_7 # Falha se string do modelo truncado divergir
    nop                            # Delay slot do desvio condicional

    # Verifica correspondencia exata dos primeiros 11 caracteres da placa truncada
    addiu $a0, $t0, 340            # Placa gravada no Slot 0 (+340)
    la    $a1, str_longo_plc_trunc # Esperado: 11 caracteres de str_longo_plc
    jal   aux_compara_string       # Compara conteudo truncado da placa
    nop                            # Delay slot da chamada
    bne   $v0, $zero, erro_cenario_7 # Falha se string da placa truncada divergir
    nop                            # Delay slot do desvio condicional

    # 7.3 Testar insercao com ponteiros nulos de string no AP 5
    # Pre-preenche o slot 0 do AP 5 com bytes sujos (0xAA) para verificar se o slot e zerado
    la    $t0, ap5_buffer          # Endereco base do AP 5
    li    $t1, 0xAAAAAAAA          # Padrao de lixo de memoria
    sw    $t1, 304($t0)            # Word 0 do slot
    sw    $t1, 308($t0)            # Word 1 do slot
    sw    $t1, 312($t0)            # Word 2 do slot
    sw    $t1, 316($t0)            # Word 3 do slot
    sw    $t1, 320($t0)            # Word 4 do slot
    sw    $t1, 324($t0)            # Word 5 do slot
    sw    $t1, 328($t0)            # Word 6 do slot
    sw    $t1, 332($t0)            # Word 7 do slot
    sw    $t1, 336($t0)            # Word 8 do slot
    sw    $t1, 340($t0)            # Word 9 do slot
    sw    $t1, 344($t0)            # Word 10 do slot
    sw    $t1, 348($t0)            # Word 11 do slot
    sw    $zero, OFF_AP_NUM_VEIC($t0) # Assegura num_veiculos = 0
    sw    $zero, OFF_AP_TIPO_VEIC($t0) # Assegura tipo_veiculo = 0

    la    $a0, ap5_buffer          # Endereco base do AP 5
    li    $a1, 99                  # Tipo 'c'
    move  $a2, $zero               # Ponteiro de modelo nulo (0)
    move  $a3, $zero               # Ponteiro de placa nulo (0)
    jal   addAuto_adicionar        # Executa insercao usando alias addAuto_adicionar
    nop                            # Delay slot da chamada
    bne   $v0, $zero, erro_cenario_7 # Falha se insercao com ponteiro nulo falhar
    nop                            # Delay slot do desvio condicional

    la    $t0, ap5_buffer          # Endereco base do AP 5
    lw    $t1, OFF_AP_SLOT_0($t0)  # Le tipo no Slot 0
    li    $t2, 99                  # Esperado: 'c' (99)
    bne   $t1, $t2, erro_cenario_7 # Falha se tipo nao foi gravado
    nop                            # Delay slot do desvio condicional

    # Valida que todas as 11 words de modelo e placa foram zeradas (limpeza ativa)
    lw    $t1, 308($t0)            # Word 1 (modelo)
    bne   $t1, $zero, erro_cenario_7 # Falha se word 1 nao foi zerada
    nop                            # Delay slot do desvio condicional
    lw    $t1, 312($t0)            # Word 2 (modelo)
    bne   $t1, $zero, erro_cenario_7 # Falha se word 2 nao foi zerada
    nop                            # Delay slot do desvio condicional
    lw    $t1, 316($t0)            # Word 3 (modelo)
    bne   $t1, $zero, erro_cenario_7 # Falha se word 3 nao foi zerada
    nop                            # Delay slot do desvio condicional
    lw    $t1, 320($t0)            # Word 4 (modelo)
    bne   $t1, $zero, erro_cenario_7 # Falha se word 4 nao foi zerada
    nop                            # Delay slot do desvio condicional
    lw    $t1, 324($t0)            # Word 5 (modelo)
    bne   $t1, $zero, erro_cenario_7 # Falha se word 5 nao foi zerada
    nop                            # Delay slot do desvio condicional
    lw    $t1, 328($t0)            # Word 6 (modelo)
    bne   $t1, $zero, erro_cenario_7 # Falha se word 6 nao foi zerada
    nop                            # Delay slot do desvio condicional
    lw    $t1, 332($t0)            # Word 7 (modelo)
    bne   $t1, $zero, erro_cenario_7 # Falha se word 7 nao foi zerada
    nop                            # Delay slot do desvio condicional
    lw    $t1, 336($t0)            # Word 8 (modelo)
    bne   $t1, $zero, erro_cenario_7 # Falha se word 8 nao foi zerada
    nop                            # Delay slot do desvio condicional
    lw    $t1, 340($t0)            # Word 9 (placa)
    bne   $t1, $zero, erro_cenario_7 # Falha se word 9 nao foi zerada
    nop                            # Delay slot do desvio condicional
    lw    $t1, 344($t0)            # Word 10 (placa)
    bne   $t1, $zero, erro_cenario_7 # Falha se word 10 nao foi zerada
    nop                            # Delay slot do desvio condicional
    lw    $t1, 348($t0)            # Word 11 (placa)
    bne   $t1, $zero, erro_cenario_7 # Falha se word 11 nao foi zerada
    nop                            # Delay slot do desvio condicional

    # 7.4 Verificacao dos sentinelas de borda em todos os buffers
    # AP 1: sentinelas
    lw    $t0, ap1_guarda_antes    # Le sentinela anterior do AP 1
    li    $t1, VAL_GUARDA_INICIO   # Sentinela esperado 0xDEADBEEF
    bne   $t0, $t1, erro_cenario_7 # Falha se sentinela anterior do AP 1 foi corrompido
    nop                            # Delay slot do desvio condicional
    lw    $t0, ap1_guarda_depois   # Le sentinela posterior do AP 1
    li    $t1, VAL_GUARDA_FIM      # Sentinela esperado 0xCAFEBABE
    bne   $t0, $t1, erro_cenario_7 # Falha se sentinela posterior do AP 1 foi corrompido
    nop                            # Delay slot do desvio condicional

    # AP 2: sentinelas
    lw    $t0, ap2_guarda_antes    # Le sentinela anterior do AP 2
    li    $t1, VAL_GUARDA_INICIO   # Sentinela esperado 0xDEADBEEF
    bne   $t0, $t1, erro_cenario_7 # Falha se sentinela anterior do AP 2 foi corrompido
    nop                            # Delay slot do desvio condicional
    lw    $t0, ap2_guarda_depois   # Le sentinela posterior do AP 2
    li    $t1, VAL_GUARDA_FIM      # Sentinela esperado 0xCAFEBABE
    bne   $t0, $t1, erro_cenario_7 # Falha se sentinela posterior do AP 2 foi corrompido
    nop                            # Delay slot do desvio condicional

    # AP 3: sentinelas
    lw    $t0, ap3_guarda_antes    # Le sentinela anterior do AP 3
    li    $t1, VAL_GUARDA_INICIO   # Sentinela esperado 0xDEADBEEF
    bne   $t0, $t1, erro_cenario_7 # Falha se sentinela anterior do AP 3 foi corrompido
    nop                            # Delay slot do desvio condicional
    lw    $t0, ap3_guarda_depois   # Le sentinela posterior do AP 3
    li    $t1, VAL_GUARDA_FIM      # Sentinela esperado 0xCAFEBABE
    bne   $t0, $t1, erro_cenario_7 # Falha se sentinela posterior do AP 3 foi corrompido
    nop                            # Delay slot do desvio condicional

    # AP 4: sentinelas
    lw    $t0, ap4_guarda_antes    # Le sentinela anterior do AP 4
    li    $t1, VAL_GUARDA_INICIO   # Sentinela esperado 0xDEADBEEF
    bne   $t0, $t1, erro_cenario_7 # Falha se sentinela anterior do AP 4 foi corrompido
    nop                            # Delay slot do desvio condicional
    lw    $t0, ap4_guarda_depois   # Le sentinela posterior do AP 4
    li    $t1, VAL_GUARDA_FIM      # Sentinela esperado 0xCAFEBABE
    bne   $t0, $t1, erro_cenario_7 # Falha se sentinela posterior do AP 4 foi corrompido
    nop                            # Delay slot do desvio condicional

    # AP 5: sentinelas
    lw    $t0, ap5_guarda_antes    # Le sentinela anterior do AP 5
    li    $t1, VAL_GUARDA_INICIO   # Sentinela esperado 0xDEADBEEF
    bne   $t0, $t1, erro_cenario_7 # Falha se sentinela anterior do AP 5 foi corrompido
    nop                            # Delay slot do desvio condicional
    lw    $t0, ap5_guarda_depois   # Le sentinela posterior do AP 5
    li    $t1, VAL_GUARDA_FIM      # Sentinela esperado 0xCAFEBABE
    bne   $t0, $t1, erro_cenario_7 # Falha se sentinela posterior do AP 5 foi corrompido
    nop                            # Delay slot do desvio condicional

    # Cenario 7 passou com sucesso
    la    $a0, msg_c7_ok           # Carrega mensagem de sucesso do Cenario 7
    li    $v0, 4                   # Codigo syscall para impressao de string
    syscall                        # Imprime confirmacao do Cenario 7

    # ==============================================================
    # FINALIZACAO: Todos os cenarios aprovados
    # ==============================================================
testes_sucesso:                    # Ponto de sucesso global da suite
    la    $a0, msg_pass_final      # Carrega mensagem global de sucesso
    li    $v0, 4                   # Codigo syscall para impressao de string
    syscall                        # Imprime confirmacao de sucesso

    li    $a0, 0                   # Define codigo de saida 0 (sucesso)
    li    $v0, 17                  # Codigo syscall 17: exit2 com codigo em $a0
    syscall                        # Encerra execucao com sucesso

# ==============================================================
# Blocos de Tratamento de Erros por Cenario
# ==============================================================
erro_cenario_1:                    # Ponto de falha no Cenario 1
    la    $a0, msg_falha_c1        # Mensagem de falha do Cenario 1
    j     encerrar_com_falha       # Salta para encerramento com codigo de erro
    nop                            # Delay slot do salto incondicional

erro_cenario_2:                    # Ponto de falha no Cenario 2
    la    $a0, msg_falha_c2        # Mensagem de falha do Cenario 2
    j     encerrar_com_falha       # Salta para encerramento com codigo de erro
    nop                            # Delay slot do salto incondicional

erro_cenario_3:                    # Ponto de falha no Cenario 3
    la    $a0, msg_falha_c3        # Mensagem de falha do Cenario 3
    j     encerrar_com_falha       # Salta para encerramento com codigo de erro
    nop                            # Delay slot do salto incondicional

erro_cenario_4:                    # Ponto de falha no Cenario 4
    la    $a0, msg_falha_c4        # Mensagem de falha do Cenario 4
    j     encerrar_com_falha       # Salta para encerramento com codigo de erro
    nop                            # Delay slot do salto incondicional

erro_cenario_5:                    # Ponto de falha no Cenario 5
    la    $a0, msg_falha_c5        # Mensagem de falha do Cenario 5
    j     encerrar_com_falha       # Salta para encerramento com codigo de erro
    nop                            # Delay slot do salto incondicional

erro_cenario_6:                    # Ponto de falha no Cenario 6
    la    $a0, msg_falha_c6        # Mensagem de falha do Cenario 6
    j     encerrar_com_falha       # Salta para encerramento com codigo de erro
    nop                            # Delay slot do salto incondicional

erro_cenario_7:                    # Ponto de falha no Cenario 7
    la    $a0, msg_falha_c7        # Mensagem de falha do Cenario 7
    j     encerrar_com_falha       # Salta para encerramento com codigo de erro
    nop                            # Delay slot do salto incondicional

encerrar_com_falha:                # Rotina comum para finalizacao com falha
    li    $v0, 4                   # Syscall 4: imprimir string de erro
    syscall                        # Imprime mensagem de erro correspondente
    li    $a0, 1                   # Codigo de retorno 1 (falha)
    li    $v0, 17                  # Syscall 17: exit2 com codigo de falha
    syscall                        # Encerra execucao com erro

# ==============================================================
# Sub-rotina auxiliar: aux_compara_string
# Argumentos:
#   $a0 = Endereco da primeira string (terminada em '\0')
#   $a1 = Endereco da segunda string (terminada em '\0')
# Retorno:
#   $v0 = 0 se as strings forem identicas, 1 se houver diferenca
# Preservacao:
#   Usa apenas $t8 e $t9 como temporarios
# ==============================================================
aux_compara_string:                # Ponto de entrada da rotina de comparacao
    move  $v0, $zero               # Inicializa resultado como 0 (sucesso/iguais)
aux_cmp_loop:                      # Laco de iteracao de comparacao
    lbu   $t8, 0($a0)              # Carrega byte da primeira string
    lbu   $t9, 0($a1)              # Carrega byte da segunda string
    bne   $t8, $t9, aux_cmp_diferente # Se bytes forem distintos, salta para falha
    nop                            # Delay slot do desvio condicional
    beq   $t8, $zero, aux_cmp_iguais # Se chegou ao fim ('\0') e sao iguais, conclui
    nop                            # Delay slot do desvio condicional
    addiu $a0, $a0, 1              # Incrementa ponteiro da primeira string (+1)
    addiu $a1, $a1, 1              # Incrementa ponteiro da segunda string (+1)
    j     aux_cmp_loop             # Continua comparacao no proximo caractere
    nop                            # Delay slot do salto incondicional

aux_cmp_diferente:                 # Ponto de divergencia entre as strings
    li    $v0, 1                   # Define codigo de retorno 1 (diferentes)
    jr    $ra                      # Retorna ao procedimento chamador
    nop                            # Delay slot do retorno

aux_cmp_iguais:                    # Ponto de igualdade confirmada
    li    $v0, 0                   # Define codigo de retorno 0 (identicas)
    jr    $ra                      # Retorna ao procedimento chamador
    nop                            # Delay slot do retorno

# ==============================================================
# Inclusao do modulo sob teste (addAuto.asm)
# ==============================================================
.include "../src/automovel/addAuto.asm" # Inclui arquivo com as rotinas reais sob teste
