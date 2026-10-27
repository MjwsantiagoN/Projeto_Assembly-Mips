# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: infoAp_executar_teste.asm
# Descricao: compara a consulta de APs ficticios e verifica somente leitura.
# O teste MMIO usa disponibilidade simulada, sem validar a janela grafica.
# ==============================================================

.data                                    # Inicia os dados exclusivos do teste.
.align 2                                 # Alinha os controles para words.
ti_idCaso: .word 0                       # Reserva um controle do programa de teste.
ti_statusEsperado: .word 0               # Reserva um controle do programa de teste.
ti_indiceEsperado: .word 0               # Reserva um controle do programa de teste.
ti_pilha: .word 0                        # Reserva um controle do programa de teste.
ti_saidaPos: .word 0                     # Reserva um controle do programa de teste.
ti_controleAntes: .word 0                # Reserva um controle do programa de teste.
ti_contexto: .space 32                   # Guarda os oito registradores salvos.
ti_argumentos: .space 16                 # Guarda os quatro argumentos.
ti_nome: .asciiz "Morador Teste"         # Define texto ficticio ou mensagem esperada do teste.
ti_modelo: .asciiz "Modelo Teste"        # Define texto ficticio ou mensagem esperada do teste.
ti_placa: .asciiz "ABC1234"              # Define texto ficticio ou mensagem esperada do teste.
ti_erroAP: .asciiz "Falha: AP invalido\n" # Define texto ficticio ou mensagem esperada do teste.
ti_erroDados: .asciiz "Falha: dados do AP invalidos\n" # Define texto ficticio ou mensagem esperada do teste.
ti_nl: .asciiz "\n"                      # Define texto ficticio ou mensagem esperada do teste.
ti_ok: .asciiz "OK cenario "             # Define texto ficticio ou mensagem esperada do teste.
ti_pass: .asciiz "PASS: infoAp_executar (24 cenarios)\n" # Define texto ficticio ou mensagem esperada do teste.
ti_fail: .asciiz "FAIL: infoAp_executar, cenario " # Define texto ficticio ou mensagem esperada do teste.
ti_textoMMIO: .asciiz "OK"               # Define texto ficticio ou mensagem esperada do teste.
ti_esperado1: .asciiz "AP: 101\nApartamento vazio\n" # Define a saida exata esperada no cenario 1.
ti_esperado2: .asciiz "AP: 202\nMoradores:\nMorador Teste\n" # Define a saida exata esperada no cenario 2.
ti_esperado3: .asciiz "AP: 1102\nMoradores:\nMorador Teste\nMorador Teste\nCarro:\nModelo Teste / ABC1234\n" # Define a saida exata esperada no cenario 3.
ti_esperado4: .asciiz "AP: 1202\nMoradores:\nMorador Teste\nMorador Teste\nMorador Teste\nMorador Teste\nMorador Teste\nMorador Teste\nMoto:\nModelo Teste / ABC1234\nModelo Teste / ABC1234\nModelo Teste / ABC1234\n" # Define a saida exata esperada no cenario 4.
ti_esperado5: .asciiz "Falha: AP invalido\n" # Define a saida exata esperada no cenario 5.
ti_esperado6: .asciiz "Falha: AP invalido\n" # Define a saida exata esperada no cenario 6.
ti_esperado7: .asciiz "Falha: AP invalido\n" # Define a saida exata esperada no cenario 7.
ti_esperado8: .asciiz "Falha: AP invalido\n" # Define a saida exata esperada no cenario 8.
ti_esperado9: .asciiz "Falha: AP invalido\n" # Define a saida exata esperada no cenario 9.
ti_esperado10: .asciiz ""                # Define a saida exata esperada no cenario 10.
ti_esperado11: .asciiz "Falha: dados do AP invalidos\n" # Define a saida exata esperada no cenario 11.
ti_esperado12: .asciiz "Falha: dados do AP invalidos\n" # Define a saida exata esperada no cenario 12.
ti_esperado13: .asciiz "Falha: dados do AP invalidos\n" # Define a saida exata esperada no cenario 13.
ti_esperado14: .asciiz "AP: 202\nMoradores:\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n" # Define a saida exata esperada no cenario 14.
ti_esperado15: .asciiz "AP: 1102\nMoradores:\nMorador Teste\nMorador Teste\nCarro:\nModelo Teste / ABC1234\n" # Define a saida exata esperada no cenario 15.
ti_esperado16: .asciiz ""                # Define a saida exata esperada no cenario 16.
ti_esperado17: .asciiz "AP: 101\nApartamento vazio\n" # Define a saida exata esperada no cenario 17.
ti_esperado18: .asciiz "Falha: dados do AP invalidos\n" # Define a saida exata esperada no cenario 18.
ti_esperado19: .asciiz "Falha: dados do AP invalidos\n" # Define a saida exata esperada no cenario 19.
ti_esperado20: .asciiz "Falha: dados do AP invalidos\n" # Define a saida exata esperada no cenario 20.
ti_esperado21: .asciiz "AP: 202\nMoradores:\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n" # Define a saida exata esperada no cenario 21.
ti_esperado22: .asciiz "Falha: AP invalido\n" # Define a saida exata esperada no cenario 22.
ti_esperado23: .asciiz "Falha: AP invalido\n" # Define a saida exata esperada no cenario 23.
.align 2                                 # Alinha tabelas e sentinelas.
ti_original: .space 12288                # Reserva a referencia de 24 registros de 512 bytes.
ti_guardaAntes: .word 0x13579BDF         # Protege o limite anterior da tabela de trabalho.
ti_tabela: .space 12288                  # Reserva a tabela de trabalho.
ti_guardaDepois: .word 0x2468ACE0        # Protege o limite posterior da tabela.
ti_snapshot: .space 12288                # Guarda toda a tabela antes da consulta.
ti_saidaAntes: .word 0x1234ABCD          # Protege o limite anterior da captura.
ti_saida: .space 4096                    # Reserva a captura de texto.
ti_saidaDepois: .word 0x5678DCBA         # Protege o limite posterior da captura.

.text                                    # Inicia as instrucoes do teste.
.globl main                              # Exporta a entrada.
main:                                    # Cria a referencia antes de executar os cenarios.
    jal ti_criarOriginal                 # Cria APs ficticios sem os cadastros do grupo.
    nop                                  # Protege o delay slot da chamada.

# Cenario 1: AP vazio.
    li $t0, 1                            # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, 0                            # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, 0                            # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 101                          # Fornece o numero solicitado.
    la $a1, ti_esperado1                 # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 0                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 2: morador sem veiculo.
    li $t0, 2                            # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, 0                            # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, 3                            # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 202                          # Fornece o numero solicitado.
    la $a1, ti_esperado2                 # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 0                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 3: dois moradores e carro.
    li $t0, 3                            # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, 0                            # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, 21                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1102                         # Fornece o numero solicitado.
    la $a1, ti_esperado3                 # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 0                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 4: seis moradores e tres motos.
    li $t0, 4                            # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, 0                            # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, 23                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1202                         # Fornece o numero solicitado.
    la $a1, ti_esperado4                 # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 0                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 5: AP ausente.
    li $t0, 5                            # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -1                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1301                         # Fornece o numero solicitado.
    la $a1, ti_esperado5                 # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 0                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 6: base nula.
    li $t0, 6                            # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -1                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1102                         # Fornece o numero solicitado.
    la $a1, ti_esperado6                 # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 1                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 7: passo insuficiente.
    li $t0, 7                            # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -1                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1102                         # Fornece o numero solicitado.
    la $a1, ti_esperado7                 # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 2                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 8: passo desalinhado.
    li $t0, 8                            # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -1                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1102                         # Fornece o numero solicitado.
    la $a1, ti_esperado8                 # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 3                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 9: base desalinhada.
    li $t0, 9                            # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -1                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1102                         # Fornece o numero solicitado.
    la $a1, ti_esperado9                 # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 4                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 10: escritor nulo.
    li $t0, 10                           # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -1                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1102                         # Fornece o numero solicitado.
    la $a1, ti_esperado10                # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 5                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 11: moradores acima do limite.
    li $t0, 11                           # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -2                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1102                         # Fornece o numero solicitado.
    la $a1, ti_esperado11                # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 6                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 12: veiculos acima dos slots.
    li $t0, 12                           # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -2                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1102                         # Fornece o numero solicitado.
    la $a1, ti_esperado12                # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 7                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 13: tipo carro com dois veiculos.
    li $t0, 13                           # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -2                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1102                         # Fornece o numero solicitado.
    la $a1, ti_esperado13                # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 8                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 14: nome no limite.
    li $t0, 14                           # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, 0                            # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, 3                            # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 202                          # Fornece o numero solicitado.
    la $a1, ti_esperado14                # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 9                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 15: tabela compacta.
    li $t0, 15                           # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, 0                            # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, 21                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1102                         # Fornece o numero solicitado.
    la $a1, ti_esperado15                # Seleciona a saida esperada.
    li $a2, 448                          # Define o passo ficticio.
    li $a3, 0                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 16: escritor desalinhado.
    li $t0, 16                           # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -1                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1102                         # Fornece o numero solicitado.
    la $a1, ti_esperado16                # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 10                           # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 17: garagem residual em AP vazio.
    li $t0, 17                           # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, 0                            # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, 0                            # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 101                          # Fornece o numero solicitado.
    la $a1, ti_esperado17                # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 11                           # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 18: moradores negativos.
    li $t0, 18                           # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -2                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1102                         # Fornece o numero solicitado.
    la $a1, ti_esperado18                # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 12                           # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 19: veiculos negativos.
    li $t0, 19                           # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -2                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1102                         # Fornece o numero solicitado.
    la $a1, ti_esperado19                # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 13                           # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 20: tipo geral desconhecido.
    li $t0, 20                           # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -2                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 1102                         # Fornece o numero solicitado.
    la $a1, ti_esperado20                # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 14                           # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 21: nome sem terminador.
    li $t0, 21                           # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, 0                            # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, 3                            # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 202                          # Fornece o numero solicitado.
    la $a1, ti_esperado21                # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 15                           # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 22: AP zero.
    li $t0, 22                           # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -1                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, 0                            # Fornece o numero solicitado.
    la $a1, ti_esperado22                # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 0                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 23: AP negativo.
    li $t0, 23                           # Define o identificador do cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador fora dos registradores em teste.
    li $t0, -1                           # Define o status esperado.
    sw $t0, ti_statusEsperado            # Guarda o status esperado.
    li $t0, -1                           # Define o indice esperado ou -1 para erro.
    sw $t0, ti_indiceEsperado            # Guarda o indice esperado.
    li $a0, -1                           # Fornece o numero solicitado.
    la $a1, ti_esperado23                # Seleciona a saida esperada.
    li $a2, 512                          # Define o passo ficticio.
    li $a3, 0                            # Seleciona o modo de parametros ou dados.
    jal ti_executar                      # Consulta, captura e confere a rotina real.
    nop                                  # Protege o delay slot da chamada.

# Cenario 24: escrita MMIO com disponibilidade simulada.
    li $t0, 24                           # Identifica o ultimo cenario.
    sw $t0, ti_idCaso                    # Guarda o identificador.
    li $t7, 0xFFFF0008                   # Seleciona o controle real do display.
    lw $t6, 0($t7)                       # Le o controle antes do teste.
    sw $t6, ti_controleAntes             # Guarda o controle anterior.
    li $t6, 1                            # Define disponibilidade permanente simulada.
    sw $t6, 0($t7)                       # Sinaliza que o display esta disponivel.
    la $a0, ti_textoMMIO                 # Seleciona o texto OK.
    move $s7, $sp                        # Guarda o equilibrio da pilha.
    jal infoAp_escreverMMIO              # Executa o escritor real com disponibilidade simulada.
    nop                                  # Protege o delay slot.
    li $t7, 0xFFFF0008                   # Recupera o endereco de controle.
    lw $t0, 4($t7)                       # Le o ultimo caractere enviado ao display.
    li $t1, 75                           # Define o ASCII de K.
    bne $t0, $t1, ti_falha               # Confere o endereco e o byte final escritos.
    nop                                  # Protege o delay slot.
    la $t0, ti_textoMMIO                 # Recupera o argumento original.
    bne $a0, $t0, ti_falha               # Exige preservacao do argumento.
    nop                                  # Protege o delay slot.
    bne $sp, $s7, ti_falha               # Exige preservacao da pilha.
    nop                                  # Protege o delay slot.
    lw $t6, ti_controleAntes             # Recupera o controle anterior.
    sw $t6, 0($t7)                       # Restaura o controle MMIO.
    la $a0, ti_pass                      # Seleciona a mensagem de sucesso global.
    li $v0, 4                            # Seleciona impressao de string do teste.
    syscall                              # Exibe o sucesso dos 24 cenarios.
    move $a0, $zero                      # Define codigo de sucesso.
    li $v0, 17                           # Seleciona encerramento com codigo.
    syscall                              # Encerra o programa de teste.

ti_criarOriginal:                        # Prepara a tabela de referencia que os testes nao devem alterar.
    addiu $sp, $sp, -40                  # Reserva frame alinhado e area para chamadas auxiliares.
    sw $ra, 36($sp)                      # Preserva $ra antes de criar os dados ficticios.
    sw $s0, 32($sp)                      # Preserva $s0 antes de criar os dados ficticios.
    sw $s1, 28($sp)                      # Preserva $s1 antes de criar os dados ficticios.
    sw $s2, 24($sp)                      # Preserva $s2 antes de criar os dados ficticios.
    sw $s3, 20($sp)                      # Preserva $s3 antes de criar os dados ficticios.
    la $t0, ti_original                  # Aponta para o inicio da referencia.
    li $t1, 3072                         # Define a quantidade de words nos 12288 bytes.
ti_originalZerar:                        # Inicializa toda a referencia antes de montar seus campos.
    sw $zero, 0($t0)                     # Zera uma word da referencia.
    addiu $t0, $t0, 4                    # Avanca para a proxima word.
    addiu $t1, $t1, -1                   # Desconta a word inicializada.
    bne $t1, $zero, ti_originalZerar     # Repete ate inicializar a referencia inteira.
    nop                                  # Protege o delay slot do desvio.
    la $s0, ti_original                  # Seleciona o primeiro registro ficticio.
    move $s1, $zero                      # Inicializa o indice do primeiro apartamento.
ti_originalRegistro:                     # Define identificacao e cadastros de um registro ficticio.
    srl $t0, $s1, 1                      # Obtem o andar menos um pela divisao do indice por dois.
    addiu $t0, $t0, 1                    # Converte o resultado para andares de 1 a 12.
    li $t1, 100                          # Define o fator decimal dos numeros de apartamento.
    mul $t0, $t0, $t1                    # Forma a centena correspondente ao andar.
    andi $t1, $s1, 1                     # Identifica o primeiro ou segundo apartamento do andar.
    addiu $t1, $t1, 1                    # Converte a unidade para 1 ou 2.
    addu $t0, $t0, $t1                   # Forma o identificador ficticio do apartamento.
    sw $t0, 0($s0)                       # Grava a identificacao que a limpeza deve preservar.
    li $s2, 1                            # Define um morador para os apartamentos de referencia comuns.
    bne $s1, $zero, ti_originalContar21  # Mantem o primeiro AP como caso especial de vazio.
    nop                                  # Protege o delay slot do desvio.
    move $s2, $zero                      # Define o primeiro apartamento como vazio.
    j ti_originalContagemPronta          # Finaliza a contagem do caso vazio.
    nop                                  # Protege o delay slot do salto.
ti_originalContar21:                     # Verifica o registro usado para o teste de carro.
    li $t0, 21                           # Seleciona o indice do apartamento 1102.
    bne $s1, $t0, ti_originalContar23    # Segue para o outro caso especial se nao for 1102.
    nop                                  # Protege o delay slot do desvio.
    li $s2, 2                            # Define dois moradores no apartamento com carro.
    j ti_originalContagemPronta          # Finaliza a contagem desse apartamento.
    nop                                  # Protege o delay slot do salto.
ti_originalContar23:                     # Verifica o registro usado para o teste de motos.
    li $t0, 23                           # Seleciona o indice do apartamento 1202.
    bne $s1, $t0, ti_originalContagemPronta # Mantem a contagem comum para os demais APs.
    nop                                  # Protege o delay slot do desvio.
    li $s2, 6                            # Define o limite de seis moradores no ultimo apartamento.
ti_originalContagemPronta:               # Grava e prepara os nomes dos moradores ficticios.
    sw $s2, 4($s0)                       # Grava a quantidade no offset proposto para moradores.
    addiu $s3, $s0, 8                    # Aponta para o primeiro espaco ficticio de nome.
    beq $s2, $zero, ti_originalVeiculos  # Pula os nomes no apartamento vazio.
    nop                                  # Protege o delay slot do desvio.
ti_originalNome:                         # Grava nomes apenas nos espacos ocupados da referencia.
    move $a0, $s3                        # Seleciona o espaco de nome a preencher.
    la $a1, ti_nome                      # Seleciona uma string ficticia terminada em zero.
    jal ti_copiarString                  # Copia o nome sem depender de uma funcao do projeto.
    nop                                  # Protege o delay slot da chamada.
    addiu $s3, $s3, 48                   # Avanca para o proximo espaco usado somente neste teste.
    addiu $s2, $s2, -1                   # Desconta o morador que recebeu um nome.
    bne $s2, $zero, ti_originalNome      # Repete ate preencher os nomes ficticios cadastrados.
    nop                                  # Protege o delay slot do desvio.
ti_originalVeiculos:                     # Seleciona quais apartamentos de referencia tem garagem ocupada.
    li $t0, 1                            # Seleciona um AP vizinho que tambem deve ser preservado.
    beq $s1, $t0, ti_originalCarro       # Cadastra um carro no apartamento vizinho.
    nop                                  # Protege o delay slot do desvio.
    li $t0, 21                           # Seleciona o apartamento 1102.
    beq $s1, $t0, ti_originalCarro       # Cadastra um carro no apartamento alvo intermediario.
    nop                                  # Protege o delay slot do desvio.
    li $t0, 23                           # Seleciona o apartamento 1202.
    beq $s1, $t0, ti_originalMotos       # Cadastra tres motos no ultimo apartamento.
    nop                                  # Protege o delay slot do desvio.
    j ti_originalReserva                 # Mantem sem veiculos os demais registros.
    nop                                  # Protege o delay slot do salto.
ti_originalCarro:                        # Define o cabecalho de garagem com um carro.
    li $s2, 1                            # Define um veiculo no apartamento.
    li $t0, 99                           # Define o tipo carro pelo ASCII de c.
    j ti_originalGaragem                 # Segue para a gravacao dos campos da garagem.
    nop                                  # Protege o delay slot do salto.
ti_originalMotos:                        # Define o cabecalho de garagem com tres motos.
    li $s2, 3                            # Define tres veiculos no apartamento.
    li $t0, 109                          # Define o tipo moto pelo ASCII de m.
ti_originalGaragem:                      # Grava o cabecalho conforme o layout publicado por Brenno.
    sw $s2, 296($s0)                     # Grava a quantidade de veiculos no registro.
    sw $t0, 300($s0)                     # Grava o tipo geral de veiculo no registro.
    addiu $s3, $s0, 304                  # Aponta para o primeiro slot de veiculo.
ti_originalSlot:                         # Preenche os slots ocupados com modelo e placa ficticios.
    lw $t0, 300($s0)                     # Recupera o tipo geral para este slot.
    sw $t0, 0($s3)                       # Grava o tipo dentro do slot.
    addiu $a0, $s3, 4                    # Aponta para o campo de modelo do slot.
    la $a1, ti_modelo                    # Seleciona o modelo ficticio.
    jal ti_copiarString                  # Grava o modelo sem chamar o cadastro dos colegas.
    nop                                  # Protege o delay slot da chamada.
    addiu $a0, $s3, 36                   # Aponta para o campo de placa do slot.
    la $a1, ti_placa                     # Seleciona a placa ficticia.
    jal ti_copiarString                  # Grava a placa sem chamar o cadastro dos colegas.
    nop                                  # Protege o delay slot da chamada.
    addiu $s3, $s3, 48                   # Avanca para o proximo slot de veiculo.
    addiu $s2, $s2, -1                   # Desconta o veiculo que recebeu seus dados.
    bne $s2, $zero, ti_originalSlot      # Preenche todos os slots declarados no contador.
    nop                                  # Protege o delay slot do desvio.
ti_originalReserva:                      # Prepara os bytes opcionais que devem ficar intactos.
    addiu $t0, $s0, 448                  # Aponta para o inicio da reserva posterior a garagem.
    li $t1, 64                           # Define os bytes extras usados no passo de 512.
    li $t2, 165                          # Define uma marca nao nula para detectar limpeza excessiva.
ti_originalReservaLoop:                  # Preenche a reserva com a marca de preservacao.
    sb $t2, 0($t0)                       # Grava a marca em um byte da reserva.
    addiu $t0, $t0, 1                    # Avanca para o proximo byte reservado.
    addiu $t1, $t1, -1                   # Desconta o byte preparado.
    bne $t1, $zero, ti_originalReservaLoop # Repete ate preparar toda a reserva.
    nop                                  # Protege o delay slot do desvio.
    addiu $s0, $s0, 512                  # Avanca para o proximo registro da referencia.
    addiu $s1, $s1, 1                    # Incrementa o indice de registro preparado.
    slti $t0, $s1, 24                    # Verifica se ainda faltam apartamentos.
    bne $t0, $zero, ti_originalRegistro  # Continua ate preparar todos os 24 registros.
    nop                                  # Protege o delay slot do desvio.
    lw $s3, 20($sp)                      # Restaura $s3 apos preparar a referencia.
    lw $s2, 24($sp)                      # Restaura $s2 apos preparar a referencia.
    lw $s1, 28($sp)                      # Restaura $s1 apos preparar a referencia.
    lw $s0, 32($sp)                      # Restaura $s0 apos preparar a referencia.
    lw $ra, 36($sp)                      # Restaura $ra apos preparar a referencia.
    addiu $sp, $sp, 40                   # Libera o frame usado na montagem dos dados ficticios.
    jr $ra                               # Retorna ao inicio dos cenarios.
    nop                                  # Protege o delay slot do retorno.

ti_copiarString:                         # Copia uma string curta entre buffers exclusivos do teste.
    lbu $t8, 0($a1)                      # Le um byte da string de referencia.
    sb $t8, 0($a0)                       # Copia o byte para o buffer ficticio.
    beq $t8, $zero, ti_copiarStringFim   # Finaliza depois de copiar o terminador nulo.
    nop                                  # Protege o delay slot do desvio.
    addiu $a0, $a0, 1                    # Avanca o destino para o proximo byte.
    addiu $a1, $a1, 1                    # Avanca a origem para o proximo byte.
    j ti_copiarString                    # Continua a copia do texto ficticio.
    nop                                  # Protege o delay slot do salto.
ti_copiarStringFim:                      # Finaliza a auxiliar que pertence somente ao teste.
    jr $ra                               # Retorna ao preparador dos registros ficticios.
    nop                                  # Protege o delay slot do retorno.

ti_prepararTabela:                       # Recebe em a0 o passo ficticio e copia a referencia para o teste.
    la $t0, ti_tabela                    # Aponta para o buffer de trabalho completo.
    li $t1, 3072                         # Define quantas words cabem no buffer maximo.
    li $t2, 0xCCCCCCCC                   # Define o padrao da parte do buffer que ficar sem uso.
ti_prepararSobra:                        # Inicializa o buffer para detectar escritas apos a tabela compacta.
    sw $t2, 0($t0)                       # Grava uma word do padrao de preservacao.
    addiu $t0, $t0, 4                    # Avanca para a proxima word.
    addiu $t1, $t1, -1                   # Desconta a word preparada.
    bne $t1, $zero, ti_prepararSobra     # Repete ate preparar o buffer completo.
    nop                                  # Protege o delay slot do desvio.
    la $t0, ti_original                  # Seleciona o primeiro registro da referencia.
    la $t1, ti_tabela                    # Seleciona o primeiro registro de trabalho.
    li $t2, 24                           # Define a quantidade de registros que serao copiados.
ti_prepararRegistro:                     # Copia um registro respeitando o passo ficticio selecionado.
    move $t5, $t0                        # Copia o ponteiro de leitura deste registro.
    move $t6, $t1                        # Copia o ponteiro de escrita deste registro.
    srl $t7, $a0, 2                      # Converte o passo alinhado em quantidade de words a copiar.
ti_prepararWord:                         # Copia os bytes de um registro sem chamar a rotina sob teste.
    lw $t4, 0($t5)                       # Le uma word dos dados de referencia.
    sw $t4, 0($t6)                       # Grava a word no registro de trabalho.
    addiu $t5, $t5, 4                    # Avanca a leitura dentro do registro.
    addiu $t6, $t6, 4                    # Avanca a escrita dentro do registro.
    addiu $t7, $t7, -1                   # Desconta a word copiada.
    bne $t7, $zero, ti_prepararWord      # Repete ate copiar o registro inteiro.
    nop                                  # Protege o delay slot do desvio.
    addiu $t0, $t0, 512                  # Avanca ao proximo registro da referencia fixa.
    addu $t1, $t1, $a0                   # Avanca no destino usando passo de 448 ou 512.
    addiu $t2, $t2, -1                   # Desconta o registro que foi copiado.
    bne $t2, $zero, ti_prepararRegistro  # Repete para todos os apartamentos.
    nop                                  # Protege o delay slot do desvio.
    jr $ra                               # Retorna com a tabela de trabalho pronta.
    nop                                  # Protege o delay slot do retorno.

ti_executar:                             # Recebe numero, texto esperado, passo e modo do cenario.
    addiu $sp, $sp, -64                  # Reserva frame alinhado para o verificador.
    sw $ra, 60($sp)                      # Preserva $ra do chamador do teste.
    sw $s0, 56($sp)                      # Preserva $s0 do chamador do teste.
    sw $s1, 52($sp)                      # Preserva $s1 do chamador do teste.
    sw $s2, 48($sp)                      # Preserva $s2 do chamador do teste.
    sw $s3, 44($sp)                      # Preserva $s3 do chamador do teste.
    sw $s4, 40($sp)                      # Preserva $s4 do chamador do teste.
    sw $s5, 36($sp)                      # Preserva $s5 do chamador do teste.
    sw $s6, 32($sp)                      # Preserva $s6 do chamador do teste.
    sw $s7, 28($sp)                      # Preserva $s7 do chamador do teste.
    move $s0, $a0                        # Mantem a configuracao 1 entre chamadas.
    move $s1, $a1                        # Mantem a configuracao 2 entre chamadas.
    move $s2, $a2                        # Mantem a configuracao 3 entre chamadas.
    move $s3, $a3                        # Mantem a configuracao 4 entre chamadas.
    move $a0, $s2                        # Fornece o passo da tabela ficticia.
    jal ti_prepararTabela                # Restaura os dados antes de cada consulta.
    nop                                  # Protege o delay slot.
    la $t0, ti_tabela                    # Seleciona a base dos dados artificiais.
    addiu $t0, $t0, 10752                # Seleciona o AP 1102, de indice 21 e passo 512.
    li $t3, 6                            # Seleciona um caso de dados inconsistentes.
    bne $s3, $t3, ti_dadosSeguinte6      # Pula a alteracao para os outros modos.
    nop                                  # Protege o delay slot.
    li $t1, 7                            # Define o valor inconsistente do cenario.
    sw $t1, 4($t0)                       # Altera apenas a tabela ficticia antes do snapshot.
ti_dadosSeguinte6:                       # Continua a preparacao do cenario.
    li $t3, 7                            # Seleciona um caso de dados inconsistentes.
    bne $s3, $t3, ti_dadosSeguinte7      # Pula a alteracao para os outros modos.
    nop                                  # Protege o delay slot.
    li $t1, 4                            # Define o valor inconsistente do cenario.
    sw $t1, 296($t0)                     # Altera apenas a tabela ficticia antes do snapshot.
ti_dadosSeguinte7:                       # Continua a preparacao do cenario.
    li $t3, 8                            # Seleciona um caso de dados inconsistentes.
    bne $s3, $t3, ti_dadosSeguinte8      # Pula a alteracao para os outros modos.
    nop                                  # Protege o delay slot.
    li $t1, 2                            # Define o valor inconsistente do cenario.
    sw $t1, 296($t0)                     # Altera apenas a tabela ficticia antes do snapshot.
ti_dadosSeguinte8:                       # Continua a preparacao do cenario.
    li $t3, 12                           # Seleciona um caso de dados inconsistentes.
    bne $s3, $t3, ti_dadosSeguinte12     # Pula a alteracao para os outros modos.
    nop                                  # Protege o delay slot.
    li $t1, -1                           # Define o valor inconsistente do cenario.
    sw $t1, 4($t0)                       # Altera apenas a tabela ficticia antes do snapshot.
ti_dadosSeguinte12:                      # Continua a preparacao do cenario.
    li $t3, 13                           # Seleciona um caso de dados inconsistentes.
    bne $s3, $t3, ti_dadosSeguinte13     # Pula a alteracao para os outros modos.
    nop                                  # Protege o delay slot.
    li $t1, -1                           # Define o valor inconsistente do cenario.
    sw $t1, 296($t0)                     # Altera apenas a tabela ficticia antes do snapshot.
ti_dadosSeguinte13:                      # Continua a preparacao do cenario.
    li $t3, 14                           # Seleciona um caso de dados inconsistentes.
    bne $s3, $t3, ti_dadosSeguinte14     # Pula a alteracao para os outros modos.
    nop                                  # Protege o delay slot.
    li $t1, 120                          # Define o valor inconsistente do cenario.
    sw $t1, 300($t0)                     # Altera apenas a tabela ficticia antes do snapshot.
ti_dadosSeguinte14:                      # Continua a preparacao do cenario.
    li $t3, 11                           # Seleciona garagem residual em AP sem moradores.
    bne $s3, $t3, ti_verNomeLimite       # Pula a alteracao nos demais modos.
    nop                                  # Protege o delay slot.
    la $t0, ti_tabela                    # Seleciona o primeiro apartamento, que esta vazio.
    li $t1, 999                          # Define uma contagem residual de veiculos.
    sw $t1, 296($t0)                     # Grava os dados que nao devem ser listados em AP vazio.
ti_verNomeLimite:                        # Seleciona os testes de capacidade e terminacao.
    li $t3, 9                            # Identifica nome com 47 caracteres e terminador.
    beq $s3, $t3, ti_nomeLimite          # Prepara o nome no limite.
    nop                                  # Protege o delay slot.
    li $t3, 15                           # Identifica campo sem terminador.
    bne $s3, $t3, ti_snapshotPreparar    # Pula a alteracao para outros modos.
    nop                                  # Protege o delay slot.
ti_nomeLimite:                           # Preenche o primeiro nome do AP 202.
    la $t0, ti_tabela                    # Seleciona a base da tabela.
    addiu $t0, $t0, 1544                 # Seleciona o nome no indice 3 e offset 8 com passo 512.
    li $t1, 48                           # Define a capacidade inteira do campo.
    li $t2, 65                           # Define o ASCII de A.
ti_nomeLimiteLoop:                       # Preenche todos os bytes do campo para testar o limite.
    sb $t2, 0($t0)                       # Grava um caractere A.
    addiu $t0, $t0, 1                    # Avanca no campo.
    addiu $t1, $t1, -1                   # Desconta o byte preenchido.
    bne $t1, $zero, ti_nomeLimiteLoop    # Preenche os 48 bytes.
    nop                                  # Protege o delay slot.
    li $t3, 9                            # Seleciona apenas o cenario de nome valido no limite.
    bne $s3, $t3, ti_snapshotPreparar    # Mantem o campo sem terminador no outro cenario.
    nop                                  # Protege o delay slot.
    sb $zero, -1($t0)                    # Garante terminacao apos os 47 caracteres do nome valido.
ti_snapshotPreparar:                     # Guarda a tabela imediatamente antes da rotina real.
    la $t0, ti_tabela                    # Seleciona a tabela preparada.
    la $t1, ti_snapshot                  # Seleciona o snapshot independente.
    li $t2, 3072                         # Define os 12288 bytes em words.
ti_snapshotLoop:                         # Copia todos os registros e reservas.
    lw $t3, 0($t0)                       # Le uma word antes da consulta.
    sw $t3, 0($t1)                       # Guarda a word no snapshot.
    addiu $t0, $t0, 4                    # Avanca a origem.
    addiu $t1, $t1, 4                    # Avanca o snapshot.
    addiu $t2, $t2, -1                   # Desconta a word copiada.
    bne $t2, $zero, ti_snapshotLoop      # Copia o buffer inteiro.
    nop                                  # Protege o delay slot.
    sw $zero, ti_saidaPos                # Reinicia o tamanho da captura.
    sb $zero, ti_saida                   # Reinicia o texto como string vazia.
    la $a0, ti_tabela                    # Fornece a base normal da tabela.
    move $a1, $s0                        # Fornece o numero do AP.
    move $a2, $s2                        # Fornece o passo normal.
    la $a3, ti_capturar                  # Fornece o escritor com temporarios volateis.
    li $t0, 1                            # Seleciona um modo de argumentos invalidos.
    bne $s3, $t0, ti_argSeguinte1        # Pula a injecao nos demais modos.
    nop                                  # Protege o delay slot.
    move $a0, $zero                      # Injeta o parametro invalido selecionado.
ti_argSeguinte1:                         # Continua a preparacao dos argumentos.
    li $t0, 2                            # Seleciona um modo de argumentos invalidos.
    bne $s3, $t0, ti_argSeguinte2        # Pula a injecao nos demais modos.
    nop                                  # Protege o delay slot.
    li $a2, 444                          # Injeta o parametro invalido selecionado.
ti_argSeguinte2:                         # Continua a preparacao dos argumentos.
    li $t0, 3                            # Seleciona um modo de argumentos invalidos.
    bne $s3, $t0, ti_argSeguinte3        # Pula a injecao nos demais modos.
    nop                                  # Protege o delay slot.
    li $a2, 450                          # Injeta o parametro invalido selecionado.
ti_argSeguinte3:                         # Continua a preparacao dos argumentos.
    li $t0, 4                            # Seleciona um modo de argumentos invalidos.
    bne $s3, $t0, ti_argSeguinte4        # Pula a injecao nos demais modos.
    nop                                  # Protege o delay slot.
    addiu $a0, $a0, 1                    # Injeta o parametro invalido selecionado.
ti_argSeguinte4:                         # Continua a preparacao dos argumentos.
    li $t0, 5                            # Seleciona um modo de argumentos invalidos.
    bne $s3, $t0, ti_argSeguinte5        # Pula a injecao nos demais modos.
    nop                                  # Protege o delay slot.
    move $a3, $zero                      # Injeta o parametro invalido selecionado.
ti_argSeguinte5:                         # Continua a preparacao dos argumentos.
    li $t0, 10                           # Seleciona um modo de argumentos invalidos.
    bne $s3, $t0, ti_argSeguinte10       # Pula a injecao nos demais modos.
    nop                                  # Protege o delay slot.
    li $a3, 1                            # Injeta o parametro invalido selecionado.
ti_argSeguinte10:                        # Continua a preparacao dos argumentos.
    li $s4, 305397764                    # Define uma marca em registrador salvo livre.
    li $s5, 305397765                    # Define uma marca em registrador salvo livre.
    li $s6, 305397766                    # Define uma marca em registrador salvo livre.
    li $s7, 305397767                    # Define uma marca em registrador salvo livre.
    sw $a0, ti_argumentos+0              # Guarda o valor esperado de $a0.
    sw $a1, ti_argumentos+4              # Guarda o valor esperado de $a1.
    sw $a2, ti_argumentos+8              # Guarda o valor esperado de $a2.
    sw $a3, ti_argumentos+12             # Guarda o valor esperado de $a3.
    sw $s0, ti_contexto+0                # Guarda o valor esperado de $s0.
    sw $s1, ti_contexto+4                # Guarda o valor esperado de $s1.
    sw $s2, ti_contexto+8                # Guarda o valor esperado de $s2.
    sw $s3, ti_contexto+12               # Guarda o valor esperado de $s3.
    sw $s4, ti_contexto+16               # Guarda o valor esperado de $s4.
    sw $s5, ti_contexto+20               # Guarda o valor esperado de $s5.
    sw $s6, ti_contexto+24               # Guarda o valor esperado de $s6.
    sw $s7, ti_contexto+28               # Guarda o valor esperado de $s7.
    sw $sp, ti_pilha                     # Guarda a posicao inicial da pilha.
    jal infoAp_executar                  # Executa a consulta real.
    nop                                  # Protege o delay slot.
    lw $t0, ti_argumentos+0              # Recupera o valor esperado de $a0.
    bne $a0, $t0, ti_falha               # Exige preservacao de $a0.
    nop                                  # Protege o delay slot.
    lw $t0, ti_argumentos+4              # Recupera o valor esperado de $a1.
    bne $a1, $t0, ti_falha               # Exige preservacao de $a1.
    nop                                  # Protege o delay slot.
    lw $t0, ti_argumentos+8              # Recupera o valor esperado de $a2.
    bne $a2, $t0, ti_falha               # Exige preservacao de $a2.
    nop                                  # Protege o delay slot.
    lw $t0, ti_argumentos+12             # Recupera o valor esperado de $a3.
    bne $a3, $t0, ti_falha               # Exige preservacao de $a3.
    nop                                  # Protege o delay slot.
    lw $t0, ti_contexto+0                # Recupera o valor esperado de $s0.
    bne $s0, $t0, ti_falha               # Exige preservacao de $s0.
    nop                                  # Protege o delay slot.
    lw $t0, ti_contexto+4                # Recupera o valor esperado de $s1.
    bne $s1, $t0, ti_falha               # Exige preservacao de $s1.
    nop                                  # Protege o delay slot.
    lw $t0, ti_contexto+8                # Recupera o valor esperado de $s2.
    bne $s2, $t0, ti_falha               # Exige preservacao de $s2.
    nop                                  # Protege o delay slot.
    lw $t0, ti_contexto+12               # Recupera o valor esperado de $s3.
    bne $s3, $t0, ti_falha               # Exige preservacao de $s3.
    nop                                  # Protege o delay slot.
    lw $t0, ti_contexto+16               # Recupera o valor esperado de $s4.
    bne $s4, $t0, ti_falha               # Exige preservacao de $s4.
    nop                                  # Protege o delay slot.
    lw $t0, ti_contexto+20               # Recupera o valor esperado de $s5.
    bne $s5, $t0, ti_falha               # Exige preservacao de $s5.
    nop                                  # Protege o delay slot.
    lw $t0, ti_contexto+24               # Recupera o valor esperado de $s6.
    bne $s6, $t0, ti_falha               # Exige preservacao de $s6.
    nop                                  # Protege o delay slot.
    lw $t0, ti_contexto+28               # Recupera o valor esperado de $s7.
    bne $s7, $t0, ti_falha               # Exige preservacao de $s7.
    nop                                  # Protege o delay slot.
    lw $t0, ti_pilha                     # Recupera a posicao inicial da pilha.
    bne $sp, $t0, ti_falha               # Exige equilibrio da pilha.
    nop                                  # Protege o delay slot.
    lw $t0, ti_statusEsperado            # Recupera o status esperado.
    bne $v0, $t0, ti_falha               # Exige o status correto apos todas as chamadas de saida.
    nop                                  # Protege o delay slot.
    bne $t0, $zero, ti_checarErro        # Seleciona a verificacao de mensagem de erro.
    nop                                  # Protege o delay slot.
    lw $t0, ti_indiceEsperado            # Recupera o indice esperado.
    mul $t1, $t0, $s2                    # Calcula o deslocamento do registro.
    la $t0, ti_tabela                    # Recupera a base da tabela.
    addu $t0, $t0, $t1                   # Calcula o endereco esperado.
    bne $v1, $t0, ti_falha               # Exige retorno do registro correto.
    nop                                  # Protege o delay slot.
    j ti_checarSaida                     # Segue para conferir o texto.
    nop                                  # Protege o delay slot.
ti_checarErro:                           # Confere a mensagem retornada mesmo sem escritor valido.
    move $a0, $v1                        # Seleciona a mensagem retornada.
    la $a1, ti_erroAP                    # Seleciona a mensagem esperada de AP invalido.
    li $t1, -2                           # Seleciona o status de registro inconsistente.
    bne $t0, $t1, ti_checarMensagem      # Mantem a mensagem de AP nos demais erros.
    nop                                  # Protege o delay slot.
    la $a1, ti_erroDados                 # Seleciona a mensagem de dados invalidos.
ti_checarMensagem:                       # Compara a mensagem inteira retornada em v1.
    jal ti_compararStrings               # Compara caracteres e terminador.
    nop                                  # Protege o delay slot.
    bne $v0, $zero, ti_falha             # Exige mensagem identica.
    nop                                  # Protege o delay slot.
ti_checarSaida:                          # Verifica exatamente as linhas produzidas.
    la $a0, ti_saida                     # Seleciona o texto capturado.
    move $a1, $s1                        # Seleciona o texto esperado.
    jal ti_compararStrings               # Compara titulos, nomes, veiculos e quebras de linha.
    nop                                  # Protege o delay slot.
    bne $v0, $zero, ti_falha             # Detecta qualquer texto diferente ou extra.
    nop                                  # Protege o delay slot.
    la $t0, ti_tabela                    # Seleciona o buffer depois da consulta.
    la $t1, ti_snapshot                  # Seleciona a copia anterior.
    li $t2, 3072                         # Define quantas words devem permanecer iguais.
ti_conferirTabela:                       # Confere o buffer inteiro e todas as reservas.
    lw $t3, 0($t0)                       # Le uma word depois da consulta.
    lw $t4, 0($t1)                       # Le a word anterior correspondente.
    bne $t3, $t4, ti_falha               # Detecta qualquer escrita indevida.
    nop                                  # Protege o delay slot.
    addiu $t0, $t0, 4                    # Avanca no resultado.
    addiu $t1, $t1, 4                    # Avanca no snapshot.
    addiu $t2, $t2, -1                   # Desconta a word conferida.
    bne $t2, $zero, ti_conferirTabela    # Confere todos os 12288 bytes.
    nop                                  # Protege o delay slot.
    lw $t0, ti_guardaAntes               # Le um sentinela externo.
    li $t1, 0x13579BDF                   # Recupera o valor original.
    bne $t0, $t1, ti_falha               # Exige preservacao dos limites.
    nop                                  # Protege o delay slot.
    lw $t0, ti_guardaDepois              # Le um sentinela externo.
    li $t1, 0x2468ACE0                   # Recupera o valor original.
    bne $t0, $t1, ti_falha               # Exige preservacao dos limites.
    nop                                  # Protege o delay slot.
    lw $t0, ti_saidaAntes                # Le um sentinela externo.
    li $t1, 0x1234ABCD                   # Recupera o valor original.
    bne $t0, $t1, ti_falha               # Exige preservacao dos limites.
    nop                                  # Protege o delay slot.
    lw $t0, ti_saidaDepois               # Le um sentinela externo.
    li $t1, 0x5678DCBA                   # Recupera o valor original.
    bne $t0, $t1, ti_falha               # Exige preservacao dos limites.
    nop                                  # Protege o delay slot.
    lw $t0, ti_idCaso                    # Recupera o numero do cenario.
    li $t1, 5                            # Seleciona as quatro consultas iniciais para demonstracao.
    bge $t0, $t1, ti_imprimirOk          # Pula a demonstracao nos outros casos.
    nop                                  # Protege o delay slot.
    la $a0, ti_saida                     # Seleciona o texto exato ja conferido.
    li $v0, 4                            # Seleciona impressao apenas para o teste.
    syscall                              # Demonstra a consulta no terminal.
ti_imprimirOk:                           # Informa que o cenario passou.
    la $a0, ti_ok                        # Seleciona o prefixo de aprovacao.
    li $v0, 4                            # Seleciona impressao de string.
    syscall                              # Imprime a aprovacao.
    lw $a0, ti_idCaso                    # Recupera o identificador.
    li $v0, 1                            # Seleciona impressao de inteiro.
    syscall                              # Imprime o numero do cenario.
    la $a0, ti_nl                        # Seleciona a quebra de linha.
    li $v0, 4                            # Seleciona impressao de string.
    syscall                              # Finaliza o resultado.
    lw $s7, 28($sp)                      # Restaura $s7 do chamador.
    lw $s6, 32($sp)                      # Restaura $s6 do chamador.
    lw $s5, 36($sp)                      # Restaura $s5 do chamador.
    lw $s4, 40($sp)                      # Restaura $s4 do chamador.
    lw $s3, 44($sp)                      # Restaura $s3 do chamador.
    lw $s2, 48($sp)                      # Restaura $s2 do chamador.
    lw $s1, 52($sp)                      # Restaura $s1 do chamador.
    lw $s0, 56($sp)                      # Restaura $s0 do chamador.
    lw $ra, 60($sp)                      # Restaura $ra do chamador.
    addiu $sp, $sp, 64                   # Libera o frame do verificador.
    jr $ra                               # Retorna ao proximo cenario.
    nop                                  # Protege o delay slot.

ti_capturar:                             # Escritor que exercita a area de argumentos e temporarios volateis.
    sw $a0, 0($sp)                       # Usa a area reservada pelo chamador para $a0.
    sw $a1, 4($sp)                       # Usa a area reservada pelo chamador para $a1.
    sw $a2, 8($sp)                       # Usa a area reservada pelo chamador para $a2.
    sw $a3, 12($sp)                      # Usa a area reservada pelo chamador para $a3.
ti_capturarLoop:                         # Acrescenta uma string ao buffer de captura.
    lbu $t2, 0($a0)                      # Le um caractere recebido.
    beq $t2, $zero, ti_capturarFim       # Finaliza no terminador.
    nop                                  # Protege o delay slot.
    lw $t0, ti_saidaPos                  # Recupera o tamanho capturado.
    li $t1, 4095                         # Reserva um byte para terminacao.
    bge $t0, $t1, ti_falha               # Rejeita captura alem da capacidade.
    nop                                  # Protege o delay slot.
    la $t1, ti_saida                     # Seleciona a base da captura.
    addu $t1, $t1, $t0                   # Seleciona a proxima posicao.
    sb $t2, 0($t1)                       # Acrescenta o caractere.
    sb $zero, 1($t1)                     # Mantem a captura terminada em zero.
    addiu $t0, $t0, 1                    # Incrementa o tamanho.
    sw $t0, ti_saidaPos                  # Guarda o tamanho atualizado.
    addiu $a0, $a0, 1                    # Avanca na string recebida.
    j ti_capturarLoop                    # Continua a captura.
    nop                                  # Protege o delay slot.
ti_capturarFim:                          # Altera todos os registradores que o escritor pode modificar.
    li $t0, 100                          # Sobrescreve o temporario $t0.
    li $t1, 101                          # Sobrescreve o temporario $t1.
    li $t2, 102                          # Sobrescreve o temporario $t2.
    li $t3, 103                          # Sobrescreve o temporario $t3.
    li $t4, 104                          # Sobrescreve o temporario $t4.
    li $t5, 105                          # Sobrescreve o temporario $t5.
    li $t6, 106                          # Sobrescreve o temporario $t6.
    li $t7, 107                          # Sobrescreve o temporario $t7.
    li $t8, 108                          # Sobrescreve o temporario $t8.
    li $t9, 109                          # Sobrescreve o temporario $t9.
    li $a0, 200                          # Sobrescreve o argumento temporario $a0.
    li $a1, 201                          # Sobrescreve o argumento temporario $a1.
    li $a2, 202                          # Sobrescreve o argumento temporario $a2.
    li $a3, 203                          # Sobrescreve o argumento temporario $a3.
    li $v0, 300                          # Sobrescreve o primeiro retorno.
    li $v1, 301                          # Sobrescreve o segundo retorno.
    multu $t0, $t1                       # Sobrescreve HI e LO.
    jr $ra                               # Retorna preservando salvos e pilha.
    nop                                  # Protege o delay slot.

ti_compararStrings:                      # Compara textos sem chamar as rotinas do projeto.
    lbu $t0, 0($a0)                      # Le um byte do texto real.
    lbu $t1, 0($a1)                      # Le um byte do texto esperado.
    bne $t0, $t1, ti_stringsDiferentes   # Identifica uma divergencia.
    nop                                  # Protege o delay slot.
    beq $t0, $zero, ti_stringsIguais     # Finaliza quando ambos chegam ao terminador.
    nop                                  # Protege o delay slot.
    addiu $a0, $a0, 1                    # Avanca no texto real.
    addiu $a1, $a1, 1                    # Avanca no texto esperado.
    j ti_compararStrings                 # Continua a comparacao integral.
    nop                                  # Protege o delay slot.
ti_stringsDiferentes:                    # Retorna divergencia.
    li $v0, 1                            # Informa que os textos diferem.
    jr $ra                               # Retorna ao verificador.
    nop                                  # Protege o delay slot.
ti_stringsIguais:                        # Retorna igualdade.
    move $v0, $zero                      # Informa que os textos sao identicos.
    jr $ra                               # Retorna ao verificador.
    nop                                  # Protege o delay slot.

ti_falha:                                # Encerra ao encontrar qualquer resultado incorreto.
    la $a0, ti_fail                      # Seleciona a mensagem de falha.
    li $v0, 4                            # Seleciona impressao de string.
    syscall                              # Informa a falha.
    lw $a0, ti_idCaso                    # Recupera o cenario fora dos salvos em teste.
    li $v0, 1                            # Seleciona impressao de inteiro.
    syscall                              # Identifica o cenario.
    la $a0, ti_nl                        # Seleciona a quebra de linha.
    li $v0, 4                            # Seleciona impressao de string.
    syscall                              # Finaliza a mensagem.
    li $a0, 1                            # Define codigo de falha.
    li $v0, 17                           # Seleciona encerramento com codigo.
    syscall                              # Encerra o teste com falha.

.include "../src/apartamento/infoAp.asm" # Inclui somente a consulta real, sem shell ou cadastros.
