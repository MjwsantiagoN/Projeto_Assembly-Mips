# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: limparAp_executar_teste.asm
# Descricao: tabela ficticia de 24 APs para testar o contrato PROPOSTO.
# Demonstra antes/depois e nao implementa o shell nem o cadastro do grupo.
# ==============================================================

.data                                    # Inicia os dados exclusivos do programa de teste.
.align 2                                 # Alinha os controles e buffers para acesso por word.
tc_idCaso: .word 0                       # Guarda o numero do cenario para identificar falhas.
tc_contexto: .space 32                   # Guarda os oito registradores salvos antes da rotina real.
tc_argumentos: .space 16                 # Guarda os quatro argumentos antes da rotina real.
tc_pilha: .word 0                        # Guarda a posicao da pilha antes da rotina real.
tc_nome: .asciiz "Morador Teste"         # Define um nome ficticio para os registros ocupados.
tc_modelo: .asciiz "Modelo Teste"        # Define um modelo ficticio para os veiculos.
tc_placa: .asciiz "ABC1234"              # Define uma placa ficticia para os veiculos.
tc_msgAntes: .asciiz "ANTES AP "         # Identifica a exibicao do registro antes da limpeza.
tc_msgDepois: .asciiz "DEPOIS AP "       # Identifica a exibicao do registro depois da limpeza.
tc_msgMoradores: .asciiz " moradores="   # Identifica a contagem ficticia de moradores.
tc_msgVeiculos: .asciiz " veiculos="     # Identifica a contagem ficticia de veiculos.
tc_nl: .asciiz "\n"                      # Finaliza uma linha de resultado no terminal.
tc_erroEsperado: .asciiz "Falha: AP invalido\n" # Define o texto de erro esperado independentemente da rotina.
tc_msgOk: .asciiz "OK cenario "          # Identifica a conclusao de cada cenario.
tc_msgPass: .asciiz "PASS: limparAp_executar (12 cenarios)\n" # Identifica o sucesso global do teste.
tc_msgFail: .asciiz "FAIL: limparAp_executar, cenario " # Identifica o cenario que encontrou divergencia.
.align 2                                 # Alinha as tabelas artificiais apos as strings.
tc_original: .space 12288                # Reserva 24 registros de referencia com passo de 512 bytes.
tc_guardaAntes: .word 0x13579BDF         # Marca o limite anterior da tabela que pode ser modificada.
tc_tabela: .space 12288                  # Reserva a tabela de trabalho, com capacidade para os dois passos.
tc_guardaDepois: .word 0x2468ACE0        # Marca o limite posterior do buffer de trabalho.

.text                                    # Inicia as instrucoes do teste independente.
.globl main                              # Exporta a entrada do programa de teste.
main:                                    # Inicializa a referencia e executa os doze cenarios.
    jal tc_criarOriginal                 # Monta apartamentos ficticios com identificadores de 101 a 1202.
    nop                                  # Protege o delay slot da chamada.

# Cenario 1: AP intermediario com dois moradores e um carro.
    li $t0, 1                            # Define o identificador deste cenario.
    sw $t0, tc_idCaso                    # Preserva o identificador fora dos registradores em teste.
    li $a0, 1102                         # Fornece o numero do apartamento a procurar.
    li $a1, 21                           # Define o indice esperado, ou -1 para exigir erro sem escrita.
    li $a2, 512                          # Define o passo da tabela ficticia deste cenario.
    li $a3, 0                            # Seleciona os parametros normais ou a falha a injetar.
    jal tc_executar                      # Executa e verifica a rotina real sobre a tabela ficticia.
    nop                                  # Protege o delay slot da chamada.

# Cenario 2: ultimo AP com seis moradores e tres motos.
    li $t0, 2                            # Define o identificador deste cenario.
    sw $t0, tc_idCaso                    # Preserva o identificador fora dos registradores em teste.
    li $a0, 1202                         # Fornece o numero do apartamento a procurar.
    li $a1, 23                           # Define o indice esperado, ou -1 para exigir erro sem escrita.
    li $a2, 512                          # Define o passo da tabela ficticia deste cenario.
    li $a3, 0                            # Seleciona os parametros normais ou a falha a injetar.
    jal tc_executar                      # Executa e verifica a rotina real sobre a tabela ficticia.
    nop                                  # Protege o delay slot da chamada.

# Cenario 3: primeiro AP ja vazio.
    li $t0, 3                            # Define o identificador deste cenario.
    sw $t0, tc_idCaso                    # Preserva o identificador fora dos registradores em teste.
    li $a0, 101                          # Fornece o numero do apartamento a procurar.
    li $a1, 0                            # Define o indice esperado, ou -1 para exigir erro sem escrita.
    li $a2, 512                          # Define o passo da tabela ficticia deste cenario.
    li $a3, 0                            # Seleciona os parametros normais ou a falha a injetar.
    jal tc_executar                      # Executa e verifica a rotina real sobre a tabela ficticia.
    nop                                  # Protege o delay slot da chamada.

# Cenario 4: numero de AP ausente da tabela.
    li $t0, 4                            # Define o identificador deste cenario.
    sw $t0, tc_idCaso                    # Preserva o identificador fora dos registradores em teste.
    li $a0, 1301                         # Fornece o numero do apartamento a procurar.
    li $a1, -1                           # Define o indice esperado, ou -1 para exigir erro sem escrita.
    li $a2, 512                          # Define o passo da tabela ficticia deste cenario.
    li $a3, 0                            # Seleciona os parametros normais ou a falha a injetar.
    jal tc_executar                      # Executa e verifica a rotina real sobre a tabela ficticia.
    nop                                  # Protege o delay slot da chamada.

# Cenario 5: base de tabela nula.
    li $t0, 5                            # Define o identificador deste cenario.
    sw $t0, tc_idCaso                    # Preserva o identificador fora dos registradores em teste.
    li $a0, 1102                         # Fornece o numero do apartamento a procurar.
    li $a1, -1                           # Define o indice esperado, ou -1 para exigir erro sem escrita.
    li $a2, 512                          # Define o passo da tabela ficticia deste cenario.
    li $a3, 1                            # Seleciona os parametros normais ou a falha a injetar.
    jal tc_executar                      # Executa e verifica a rotina real sobre a tabela ficticia.
    nop                                  # Protege o delay slot da chamada.

# Cenario 6: passo menor que o tamanho minimo.
    li $t0, 6                            # Define o identificador deste cenario.
    sw $t0, tc_idCaso                    # Preserva o identificador fora dos registradores em teste.
    li $a0, 1102                         # Fornece o numero do apartamento a procurar.
    li $a1, -1                           # Define o indice esperado, ou -1 para exigir erro sem escrita.
    li $a2, 512                          # Define o passo da tabela ficticia deste cenario.
    li $a3, 2                            # Seleciona os parametros normais ou a falha a injetar.
    jal tc_executar                      # Executa e verifica a rotina real sobre a tabela ficticia.
    nop                                  # Protege o delay slot da chamada.

# Cenario 7: passo sem alinhamento de word.
    li $t0, 7                            # Define o identificador deste cenario.
    sw $t0, tc_idCaso                    # Preserva o identificador fora dos registradores em teste.
    li $a0, 1102                         # Fornece o numero do apartamento a procurar.
    li $a1, -1                           # Define o indice esperado, ou -1 para exigir erro sem escrita.
    li $a2, 512                          # Define o passo da tabela ficticia deste cenario.
    li $a3, 3                            # Seleciona os parametros normais ou a falha a injetar.
    jal tc_executar                      # Executa e verifica a rotina real sobre a tabela ficticia.
    nop                                  # Protege o delay slot da chamada.

# Cenario 8: base sem alinhamento de word.
    li $t0, 8                            # Define o identificador deste cenario.
    sw $t0, tc_idCaso                    # Preserva o identificador fora dos registradores em teste.
    li $a0, 1102                         # Fornece o numero do apartamento a procurar.
    li $a1, -1                           # Define o indice esperado, ou -1 para exigir erro sem escrita.
    li $a2, 512                          # Define o passo da tabela ficticia deste cenario.
    li $a3, 4                            # Seleciona os parametros normais ou a falha a injetar.
    jal tc_executar                      # Executa e verifica a rotina real sobre a tabela ficticia.
    nop                                  # Protege o delay slot da chamada.

# Cenario 9: numero de AP zero.
    li $t0, 9                            # Define o identificador deste cenario.
    sw $t0, tc_idCaso                    # Preserva o identificador fora dos registradores em teste.
    li $a0, 0                            # Fornece o numero do apartamento a procurar.
    li $a1, -1                           # Define o indice esperado, ou -1 para exigir erro sem escrita.
    li $a2, 512                          # Define o passo da tabela ficticia deste cenario.
    li $a3, 0                            # Seleciona os parametros normais ou a falha a injetar.
    jal tc_executar                      # Executa e verifica a rotina real sobre a tabela ficticia.
    nop                                  # Protege o delay slot da chamada.

# Cenario 10: numero de AP negativo.
    li $t0, 10                           # Define o identificador deste cenario.
    sw $t0, tc_idCaso                    # Preserva o identificador fora dos registradores em teste.
    li $a0, -1                           # Fornece o numero do apartamento a procurar.
    li $a1, -1                           # Define o indice esperado, ou -1 para exigir erro sem escrita.
    li $a2, 512                          # Define o passo da tabela ficticia deste cenario.
    li $a3, 0                            # Seleciona os parametros normais ou a falha a injetar.
    jal tc_executar                      # Executa e verifica a rotina real sobre a tabela ficticia.
    nop                                  # Protege o delay slot da chamada.

# Cenario 11: tabela compacta com passo de 448 bytes.
    li $t0, 11                           # Define o identificador deste cenario.
    sw $t0, tc_idCaso                    # Preserva o identificador fora dos registradores em teste.
    li $a0, 1102                         # Fornece o numero do apartamento a procurar.
    li $a1, 21                           # Define o indice esperado, ou -1 para exigir erro sem escrita.
    li $a2, 448                          # Define o passo da tabela ficticia deste cenario.
    li $a3, 0                            # Seleciona os parametros normais ou a falha a injetar.
    jal tc_executar                      # Executa e verifica a rotina real sobre a tabela ficticia.
    nop                                  # Protege o delay slot da chamada.

# Cenario 12: repeticao na tabela compacta ja limpa.
    li $t0, 12                           # Define o identificador deste cenario.
    sw $t0, tc_idCaso                    # Preserva o identificador fora dos registradores em teste.
    li $a0, 1102                         # Fornece o numero do apartamento a procurar.
    li $a1, 21                           # Define o indice esperado, ou -1 para exigir erro sem escrita.
    li $a2, 448                          # Define o passo da tabela ficticia deste cenario.
    li $a3, 5                            # Seleciona os parametros normais ou a falha a injetar.
    jal tc_executar                      # Executa e verifica a rotina real sobre a tabela ficticia.
    nop                                  # Protege o delay slot da chamada.

    la $a0, tc_msgPass                   # Seleciona a mensagem de sucesso dos doze cenarios.
    li $v0, 4                            # Seleciona impressao de string apenas para o teste.
    syscall                              # Exibe o resultado global no terminal do MARS.
    move $a0, $zero                      # Define codigo de saida zero para sucesso.
    li $v0, 17                           # Seleciona encerramento com codigo de saida.
    syscall                              # Encerra o programa de teste com sucesso.

# Monta apenas uma referencia de teste: nao cria dados globais do sistema.
tc_criarOriginal:                        # Prepara a tabela de referencia que os testes nao devem alterar.
    addiu $sp, $sp, -40                  # Reserva frame alinhado e area para chamadas auxiliares.
    sw $ra, 36($sp)                      # Preserva $ra antes de criar os dados ficticios.
    sw $s0, 32($sp)                      # Preserva $s0 antes de criar os dados ficticios.
    sw $s1, 28($sp)                      # Preserva $s1 antes de criar os dados ficticios.
    sw $s2, 24($sp)                      # Preserva $s2 antes de criar os dados ficticios.
    sw $s3, 20($sp)                      # Preserva $s3 antes de criar os dados ficticios.
    la $t0, tc_original                  # Aponta para o inicio da referencia.
    li $t1, 3072                         # Define a quantidade de words nos 12288 bytes.
tc_originalZerar:                        # Inicializa toda a referencia antes de montar seus campos.
    sw $zero, 0($t0)                     # Zera uma word da referencia.
    addiu $t0, $t0, 4                    # Avanca para a proxima word.
    addiu $t1, $t1, -1                   # Desconta a word inicializada.
    bne $t1, $zero, tc_originalZerar     # Repete ate inicializar a referencia inteira.
    nop                                  # Protege o delay slot do desvio.
    la $s0, tc_original                  # Seleciona o primeiro registro ficticio.
    move $s1, $zero                      # Inicializa o indice do primeiro apartamento.
tc_originalRegistro:                     # Define identificacao e cadastros de um registro ficticio.
    srl $t0, $s1, 1                      # Obtem o andar menos um pela divisao do indice por dois.
    addiu $t0, $t0, 1                    # Converte o resultado para andares de 1 a 12.
    li $t1, 100                          # Define o fator decimal dos numeros de apartamento.
    mul $t0, $t0, $t1                    # Forma a centena correspondente ao andar.
    andi $t1, $s1, 1                     # Identifica o primeiro ou segundo apartamento do andar.
    addiu $t1, $t1, 1                    # Converte a unidade para 1 ou 2.
    addu $t0, $t0, $t1                   # Forma o identificador ficticio do apartamento.
    sw $t0, 0($s0)                       # Grava a identificacao que a limpeza deve preservar.
    li $s2, 1                            # Define um morador para os apartamentos de referencia comuns.
    bne $s1, $zero, tc_originalContar21  # Mantem o primeiro AP como caso especial de vazio.
    nop                                  # Protege o delay slot do desvio.
    move $s2, $zero                      # Define o primeiro apartamento como vazio.
    j tc_originalContagemPronta          # Finaliza a contagem do caso vazio.
    nop                                  # Protege o delay slot do salto.
tc_originalContar21:                     # Verifica o registro usado para o teste de carro.
    li $t0, 21                           # Seleciona o indice do apartamento 1102.
    bne $s1, $t0, tc_originalContar23    # Segue para o outro caso especial se nao for 1102.
    nop                                  # Protege o delay slot do desvio.
    li $s2, 2                            # Define dois moradores no apartamento com carro.
    j tc_originalContagemPronta          # Finaliza a contagem desse apartamento.
    nop                                  # Protege o delay slot do salto.
tc_originalContar23:                     # Verifica o registro usado para o teste de motos.
    li $t0, 23                           # Seleciona o indice do apartamento 1202.
    bne $s1, $t0, tc_originalContagemPronta # Mantem a contagem comum para os demais APs.
    nop                                  # Protege o delay slot do desvio.
    li $s2, 6                            # Define o limite de seis moradores no ultimo apartamento.
tc_originalContagemPronta:               # Grava e prepara os nomes dos moradores ficticios.
    sw $s2, 4($s0)                       # Grava a quantidade no offset proposto para moradores.
    addiu $s3, $s0, 8                    # Aponta para o primeiro espaco ficticio de nome.
    beq $s2, $zero, tc_originalVeiculos  # Pula os nomes no apartamento vazio.
    nop                                  # Protege o delay slot do desvio.
tc_originalNome:                         # Grava nomes apenas nos espacos ocupados da referencia.
    move $a0, $s3                        # Seleciona o espaco de nome a preencher.
    la $a1, tc_nome                      # Seleciona uma string ficticia terminada em zero.
    jal tc_copiarString                  # Copia o nome sem depender de uma funcao do projeto.
    nop                                  # Protege o delay slot da chamada.
    addiu $s3, $s3, 48                   # Avanca para o proximo espaco usado somente neste teste.
    addiu $s2, $s2, -1                   # Desconta o morador que recebeu um nome.
    bne $s2, $zero, tc_originalNome      # Repete ate preencher os nomes ficticios cadastrados.
    nop                                  # Protege o delay slot do desvio.
tc_originalVeiculos:                     # Seleciona quais apartamentos de referencia tem garagem ocupada.
    li $t0, 1                            # Seleciona um AP vizinho que tambem deve ser preservado.
    beq $s1, $t0, tc_originalCarro       # Cadastra um carro no apartamento vizinho.
    nop                                  # Protege o delay slot do desvio.
    li $t0, 21                           # Seleciona o apartamento 1102.
    beq $s1, $t0, tc_originalCarro       # Cadastra um carro no apartamento alvo intermediario.
    nop                                  # Protege o delay slot do desvio.
    li $t0, 23                           # Seleciona o apartamento 1202.
    beq $s1, $t0, tc_originalMotos       # Cadastra tres motos no ultimo apartamento.
    nop                                  # Protege o delay slot do desvio.
    j tc_originalReserva                 # Mantem sem veiculos os demais registros.
    nop                                  # Protege o delay slot do salto.
tc_originalCarro:                        # Define o cabecalho de garagem com um carro.
    li $s2, 1                            # Define um veiculo no apartamento.
    li $t0, 99                           # Define o tipo carro pelo ASCII de c.
    j tc_originalGaragem                 # Segue para a gravacao dos campos da garagem.
    nop                                  # Protege o delay slot do salto.
tc_originalMotos:                        # Define o cabecalho de garagem com tres motos.
    li $s2, 3                            # Define tres veiculos no apartamento.
    li $t0, 109                          # Define o tipo moto pelo ASCII de m.
tc_originalGaragem:                      # Grava o cabecalho conforme o layout publicado por Brenno.
    sw $s2, 296($s0)                     # Grava a quantidade de veiculos no registro.
    sw $t0, 300($s0)                     # Grava o tipo geral de veiculo no registro.
    addiu $s3, $s0, 304                  # Aponta para o primeiro slot de veiculo.
tc_originalSlot:                         # Preenche os slots ocupados com modelo e placa ficticios.
    lw $t0, 300($s0)                     # Recupera o tipo geral para este slot.
    sw $t0, 0($s3)                       # Grava o tipo dentro do slot.
    addiu $a0, $s3, 4                    # Aponta para o campo de modelo do slot.
    la $a1, tc_modelo                    # Seleciona o modelo ficticio.
    jal tc_copiarString                  # Grava o modelo sem chamar o cadastro dos colegas.
    nop                                  # Protege o delay slot da chamada.
    addiu $a0, $s3, 36                   # Aponta para o campo de placa do slot.
    la $a1, tc_placa                     # Seleciona a placa ficticia.
    jal tc_copiarString                  # Grava a placa sem chamar o cadastro dos colegas.
    nop                                  # Protege o delay slot da chamada.
    addiu $s3, $s3, 48                   # Avanca para o proximo slot de veiculo.
    addiu $s2, $s2, -1                   # Desconta o veiculo que recebeu seus dados.
    bne $s2, $zero, tc_originalSlot      # Preenche todos os slots declarados no contador.
    nop                                  # Protege o delay slot do desvio.
tc_originalReserva:                      # Prepara os bytes opcionais que devem ficar intactos.
    addiu $t0, $s0, 448                  # Aponta para o inicio da reserva posterior a garagem.
    li $t1, 64                           # Define os bytes extras usados no passo de 512.
    li $t2, 165                          # Define uma marca nao nula para detectar limpeza excessiva.
tc_originalReservaLoop:                  # Preenche a reserva com a marca de preservacao.
    sb $t2, 0($t0)                       # Grava a marca em um byte da reserva.
    addiu $t0, $t0, 1                    # Avanca para o proximo byte reservado.
    addiu $t1, $t1, -1                   # Desconta o byte preparado.
    bne $t1, $zero, tc_originalReservaLoop # Repete ate preparar toda a reserva.
    nop                                  # Protege o delay slot do desvio.
    addiu $s0, $s0, 512                  # Avanca para o proximo registro da referencia.
    addiu $s1, $s1, 1                    # Incrementa o indice de registro preparado.
    slti $t0, $s1, 24                    # Verifica se ainda faltam apartamentos.
    bne $t0, $zero, tc_originalRegistro  # Continua ate preparar todos os 24 registros.
    nop                                  # Protege o delay slot do desvio.
    lw $s3, 20($sp)                      # Restaura $s3 apos preparar a referencia.
    lw $s2, 24($sp)                      # Restaura $s2 apos preparar a referencia.
    lw $s1, 28($sp)                      # Restaura $s1 apos preparar a referencia.
    lw $s0, 32($sp)                      # Restaura $s0 apos preparar a referencia.
    lw $ra, 36($sp)                      # Restaura $ra apos preparar a referencia.
    addiu $sp, $sp, 40                   # Libera o frame usado na montagem dos dados ficticios.
    jr $ra                               # Retorna ao inicio dos cenarios.
    nop                                  # Protege o delay slot do retorno.

tc_copiarString:                         # Copia uma string curta entre buffers exclusivos do teste.
    lbu $t8, 0($a1)                      # Le um byte da string de referencia.
    sb $t8, 0($a0)                       # Copia o byte para o buffer ficticio.
    beq $t8, $zero, tc_copiarStringFim   # Finaliza depois de copiar o terminador nulo.
    nop                                  # Protege o delay slot do desvio.
    addiu $a0, $a0, 1                    # Avanca o destino para o proximo byte.
    addiu $a1, $a1, 1                    # Avanca a origem para o proximo byte.
    j tc_copiarString                    # Continua a copia do texto ficticio.
    nop                                  # Protege o delay slot do salto.
tc_copiarStringFim:                      # Finaliza a auxiliar que pertence somente ao teste.
    jr $ra                               # Retorna ao preparador dos registros ficticios.
    nop                                  # Protege o delay slot do retorno.

tc_prepararTabela:                       # Recebe em a0 o passo ficticio e copia a referencia para o teste.
    la $t0, tc_tabela                    # Aponta para o buffer de trabalho completo.
    li $t1, 3072                         # Define quantas words cabem no buffer maximo.
    li $t2, 0xCCCCCCCC                   # Define o padrao da parte do buffer que ficar sem uso.
tc_prepararSobra:                        # Inicializa o buffer para detectar escritas apos a tabela compacta.
    sw $t2, 0($t0)                       # Grava uma word do padrao de preservacao.
    addiu $t0, $t0, 4                    # Avanca para a proxima word.
    addiu $t1, $t1, -1                   # Desconta a word preparada.
    bne $t1, $zero, tc_prepararSobra     # Repete ate preparar o buffer completo.
    nop                                  # Protege o delay slot do desvio.
    la $t0, tc_original                  # Seleciona o primeiro registro da referencia.
    la $t1, tc_tabela                    # Seleciona o primeiro registro de trabalho.
    li $t2, 24                           # Define a quantidade de registros que serao copiados.
tc_prepararRegistro:                     # Copia um registro respeitando o passo ficticio selecionado.
    move $t5, $t0                        # Copia o ponteiro de leitura deste registro.
    move $t6, $t1                        # Copia o ponteiro de escrita deste registro.
    srl $t7, $a0, 2                      # Converte o passo alinhado em quantidade de words a copiar.
tc_prepararWord:                         # Copia os bytes de um registro sem chamar a rotina sob teste.
    lw $t4, 0($t5)                       # Le uma word dos dados de referencia.
    sw $t4, 0($t6)                       # Grava a word no registro de trabalho.
    addiu $t5, $t5, 4                    # Avanca a leitura dentro do registro.
    addiu $t6, $t6, 4                    # Avanca a escrita dentro do registro.
    addiu $t7, $t7, -1                   # Desconta a word copiada.
    bne $t7, $zero, tc_prepararWord      # Repete ate copiar o registro inteiro.
    nop                                  # Protege o delay slot do desvio.
    addiu $t0, $t0, 512                  # Avanca ao proximo registro da referencia fixa.
    addu $t1, $t1, $a0                   # Avanca no destino usando passo de 448 ou 512.
    addiu $t2, $t2, -1                   # Desconta o registro que foi copiado.
    bne $t2, $zero, tc_prepararRegistro  # Repete para todos os apartamentos.
    nop                                  # Protege o delay slot do desvio.
    jr $ra                               # Retorna com a tabela de trabalho pronta.
    nop                                  # Protege o delay slot do retorno.

tc_executar:                             # Recebe numero, indice esperado, passo ficticio e modo de teste.
    addiu $sp, $sp, -64                  # Reserva frame alinhado para preservar o contexto do teste.
    sw $ra, 60($sp)                      # Preserva $ra do chamador do verificador.
    sw $s0, 56($sp)                      # Preserva $s0 do chamador do verificador.
    sw $s1, 52($sp)                      # Preserva $s1 do chamador do verificador.
    sw $s2, 48($sp)                      # Preserva $s2 do chamador do verificador.
    sw $s3, 44($sp)                      # Preserva $s3 do chamador do verificador.
    sw $s4, 40($sp)                      # Preserva $s4 do chamador do verificador.
    sw $s5, 36($sp)                      # Preserva $s5 do chamador do verificador.
    sw $s6, 32($sp)                      # Preserva $s6 do chamador do verificador.
    sw $s7, 28($sp)                      # Preserva $s7 do chamador do verificador.
    move $s0, $a0                        # Mantem o parametro de teste 1 entre chamadas.
    move $s1, $a1                        # Mantem o parametro de teste 2 entre chamadas.
    move $s2, $a2                        # Mantem o parametro de teste 3 entre chamadas.
    move $s3, $a3                        # Mantem o parametro de teste 4 entre chamadas.
    li $t0, 5                            # Identifica o modo que repete a limpeza sem recriar a tabela.
    beq $s3, $t0, tc_tabelaPronta        # Preserva a tabela ja limpa no cenario de repeticao.
    nop                                  # Protege o delay slot do desvio.
    move $a0, $s2                        # Fornece o passo ficticio ao preparador da tabela.
    jal tc_prepararTabela                # Restaura os registros antes de um cenario independente.
    nop                                  # Protege o delay slot da chamada.
tc_tabelaPronta:                         # Mostra o estado inicial apenas quando um AP deve ser encontrado.
    bltz $s1, tc_montarArgumentos        # Pula a demonstracao de registros nos cenarios de erro.
    nop                                  # Protege o delay slot do desvio.
    la $a0, tc_tabela                    # Seleciona o inicio da tabela de trabalho.
    mul $t0, $s1, $s2                    # Calcula o deslocamento do registro esperado.
    addu $a0, $a0, $t0                   # Aponta para o registro que sera limpo.
    la $a1, tc_msgAntes                  # Seleciona o prefixo da demonstracao inicial.
    jal tc_mostrarEstado                 # Exibe identificacao e contadores antes da limpeza.
    nop                                  # Protege o delay slot da chamada.
tc_montarArgumentos:                     # Prepara os argumentos reais para a rotina do projeto.
    la $a0, tc_tabela                    # Fornece a base normal da tabela de trabalho.
    move $a1, $s0                        # Fornece o numero solicitado neste cenario.
    move $a2, $s2                        # Fornece o passo normal deste cenario.
    li $a3, 4660                         # Prepara uma marca para verificar preservacao do quarto argumento.
    li $t0, 1                            # Seleciona um modo de parametros invalidos.
    bne $s3, $t0, tc_modoSeguinte1       # Pula a injecao se este nao for o modo solicitado.
    nop                                  # Protege o delay slot do desvio.
    move $a0, $zero                      # Injeta uma base nula.
    j tc_argumentosProntos               # Conclui a injecao mantendo os outros argumentos.
    nop                                  # Protege o delay slot do salto.
tc_modoSeguinte1:                        # Continua a selecao do modo de teste.
    li $t0, 2                            # Seleciona um modo de parametros invalidos.
    bne $s3, $t0, tc_modoSeguinte2       # Pula a injecao se este nao for o modo solicitado.
    nop                                  # Protege o delay slot do desvio.
    li $a2, 444                          # Injeta um passo menor que o registro minimo.
    j tc_argumentosProntos               # Conclui a injecao mantendo os outros argumentos.
    nop                                  # Protege o delay slot do salto.
tc_modoSeguinte2:                        # Continua a selecao do modo de teste.
    li $t0, 3                            # Seleciona um modo de parametros invalidos.
    bne $s3, $t0, tc_modoSeguinte3       # Pula a injecao se este nao for o modo solicitado.
    nop                                  # Protege o delay slot do desvio.
    li $a2, 450                          # Injeta um passo sem alinhamento de quatro bytes.
    j tc_argumentosProntos               # Conclui a injecao mantendo os outros argumentos.
    nop                                  # Protege o delay slot do salto.
tc_modoSeguinte3:                        # Continua a selecao do modo de teste.
    li $t0, 4                            # Seleciona um modo de parametros invalidos.
    bne $s3, $t0, tc_modoSeguinte4       # Pula a injecao se este nao for o modo solicitado.
    nop                                  # Protege o delay slot do desvio.
    addiu $a0, $a0, 1                    # Injeta uma base desalinhada.
    j tc_argumentosProntos               # Conclui a injecao mantendo os outros argumentos.
    nop                                  # Protege o delay slot do salto.
tc_modoSeguinte4:                        # Continua a selecao do modo de teste.
tc_argumentosProntos:                    # Guarda o contexto esperado antes de chamar a rotina real.
    li $s4, 286326788                    # Define uma marca em registrador salvo nao usado como controle.
    li $s5, 286326789                    # Define uma marca em registrador salvo nao usado como controle.
    li $s6, 286326790                    # Define uma marca em registrador salvo nao usado como controle.
    li $s7, 286326791                    # Define uma marca em registrador salvo nao usado como controle.
    sw $a0, tc_argumentos+0              # Guarda o valor esperado de $a0.
    sw $a1, tc_argumentos+4              # Guarda o valor esperado de $a1.
    sw $a2, tc_argumentos+8              # Guarda o valor esperado de $a2.
    sw $a3, tc_argumentos+12             # Guarda o valor esperado de $a3.
    sw $s0, tc_contexto+0                # Guarda o valor esperado de $s0.
    sw $s1, tc_contexto+4                # Guarda o valor esperado de $s1.
    sw $s2, tc_contexto+8                # Guarda o valor esperado de $s2.
    sw $s3, tc_contexto+12               # Guarda o valor esperado de $s3.
    sw $s4, tc_contexto+16               # Guarda o valor esperado de $s4.
    sw $s5, tc_contexto+20               # Guarda o valor esperado de $s5.
    sw $s6, tc_contexto+24               # Guarda o valor esperado de $s6.
    sw $s7, tc_contexto+28               # Guarda o valor esperado de $s7.
    sw $sp, tc_pilha                     # Guarda a posicao da pilha antes da chamada real.
    jal limparAp_executar                # Executa a rotina do projeto sobre os dados ficticios.
    nop                                  # Protege o delay slot da chamada.
    lw $t0, tc_argumentos+0              # Recupera o valor esperado de $a0.
    bne $a0, $t0, tc_falha               # Exige preservacao de $a0.
    nop                                  # Protege o delay slot do desvio.
    lw $t0, tc_argumentos+4              # Recupera o valor esperado de $a1.
    bne $a1, $t0, tc_falha               # Exige preservacao de $a1.
    nop                                  # Protege o delay slot do desvio.
    lw $t0, tc_argumentos+8              # Recupera o valor esperado de $a2.
    bne $a2, $t0, tc_falha               # Exige preservacao de $a2.
    nop                                  # Protege o delay slot do desvio.
    lw $t0, tc_argumentos+12             # Recupera o valor esperado de $a3.
    bne $a3, $t0, tc_falha               # Exige preservacao de $a3.
    nop                                  # Protege o delay slot do desvio.
    lw $t0, tc_contexto+0                # Recupera o valor esperado de $s0.
    bne $s0, $t0, tc_falha               # Exige preservacao de $s0.
    nop                                  # Protege o delay slot do desvio.
    lw $t0, tc_contexto+4                # Recupera o valor esperado de $s1.
    bne $s1, $t0, tc_falha               # Exige preservacao de $s1.
    nop                                  # Protege o delay slot do desvio.
    lw $t0, tc_contexto+8                # Recupera o valor esperado de $s2.
    bne $s2, $t0, tc_falha               # Exige preservacao de $s2.
    nop                                  # Protege o delay slot do desvio.
    lw $t0, tc_contexto+12               # Recupera o valor esperado de $s3.
    bne $s3, $t0, tc_falha               # Exige preservacao de $s3.
    nop                                  # Protege o delay slot do desvio.
    lw $t0, tc_contexto+16               # Recupera o valor esperado de $s4.
    bne $s4, $t0, tc_falha               # Exige preservacao de $s4.
    nop                                  # Protege o delay slot do desvio.
    lw $t0, tc_contexto+20               # Recupera o valor esperado de $s5.
    bne $s5, $t0, tc_falha               # Exige preservacao de $s5.
    nop                                  # Protege o delay slot do desvio.
    lw $t0, tc_contexto+24               # Recupera o valor esperado de $s6.
    bne $s6, $t0, tc_falha               # Exige preservacao de $s6.
    nop                                  # Protege o delay slot do desvio.
    lw $t0, tc_contexto+28               # Recupera o valor esperado de $s7.
    bne $s7, $t0, tc_falha               # Exige preservacao de $s7.
    nop                                  # Protege o delay slot do desvio.
    lw $t0, tc_pilha                     # Recupera a posicao inicial da pilha.
    bne $sp, $t0, tc_falha               # Exige equilibrio da pilha depois da rotina real.
    nop                                  # Protege o delay slot do desvio.
    bltz $s1, tc_esperarErro             # Seleciona a verificacao de erro para indice esperado negativo.
    nop                                  # Protege o delay slot do desvio.
    bne $v0, $zero, tc_falha             # Exige sucesso quando o apartamento existe.
    nop                                  # Protege o delay slot do desvio.
    la $t0, tc_tabela                    # Recupera a base da tabela ficticia.
    mul $t1, $s1, $s2                    # Calcula o deslocamento do registro esperado.
    addu $t0, $t0, $t1                   # Calcula o endereco exato que deveria ser retornado.
    bne $v1, $t0, tc_falha               # Exige que a rotina devolva o registro correto.
    nop                                  # Protege o delay slot do desvio.
    move $a0, $v1                        # Seleciona o registro limpo para demonstrar o resultado.
    la $a1, tc_msgDepois                 # Seleciona o prefixo da demonstracao final.
    jal tc_mostrarEstado                 # Exibe identificacao e contadores depois da limpeza.
    nop                                  # Protege o delay slot da chamada.
    j tc_verificarResultado              # Segue para a verificacao byte a byte da tabela.
    nop                                  # Protege o delay slot do salto.
tc_esperarErro:                          # Confere o status e a mensagem devolvidos nos cenarios invalidos.
    li $t0, -1                           # Define o status esperado para os argumentos invalidos.
    bne $v0, $t0, tc_falha               # Exige retorno de falha sem sucesso indevido.
    nop                                  # Protege o delay slot do desvio.
    move $t0, $v1                        # Aponta para a mensagem devolvida pela rotina real.
    la $t1, tc_erroEsperado              # Aponta para a mensagem exigida pelo teste.
tc_compararErro:                         # Confere a mensagem completa inclusive quebra de linha e terminador.
    lbu $t2, 0($t0)                      # Le um byte da mensagem devolvida.
    lbu $t3, 0($t1)                      # Le o byte correspondente da mensagem esperada.
    bne $t2, $t3, tc_falha               # Exige correspondencia exata entre as mensagens.
    nop                                  # Protege o delay slot do desvio.
    beq $t2, $zero, tc_verificarResultado # Finaliza ao conferir os terminadores nulos.
    nop                                  # Protege o delay slot do desvio.
    addiu $t0, $t0, 1                    # Avanca na mensagem devolvida.
    addiu $t1, $t1, 1                    # Avanca na mensagem esperada.
    j tc_compararErro                    # Continua a verificacao do texto completo.
    nop                                  # Protege o delay slot do salto.
tc_verificarResultado:                   # Verifica memoria tanto nos caminhos de sucesso como de erro.
    move $a0, $s1                        # Fornece o indice que pode mudar, ou -1 para preservar tudo.
    move $a1, $s2                        # Fornece o passo da tabela ficticia realmente alocada.
    jal tc_verificarTabela               # Confere todos os registros e os limites do buffer.
    nop                                  # Protege o delay slot da chamada.
    la $a0, tc_msgOk                     # Seleciona o texto de conclusao de um cenario.
    li $v0, 4                            # Seleciona impressao de string apenas no teste.
    syscall                              # Informa que o cenario passou pelas verificacoes.
    lw $a0, tc_idCaso                    # Recupera o identificador do cenario.
    li $v0, 1                            # Seleciona impressao de inteiro apenas no teste.
    syscall                              # Exibe o numero do cenario concluido.
    la $a0, tc_nl                        # Seleciona a quebra de linha.
    li $v0, 4                            # Seleciona impressao de string.
    syscall                              # Finaliza a linha do cenario.
    lw $s7, 28($sp)                      # Restaura $s7 do chamador do verificador.
    lw $s6, 32($sp)                      # Restaura $s6 do chamador do verificador.
    lw $s5, 36($sp)                      # Restaura $s5 do chamador do verificador.
    lw $s4, 40($sp)                      # Restaura $s4 do chamador do verificador.
    lw $s3, 44($sp)                      # Restaura $s3 do chamador do verificador.
    lw $s2, 48($sp)                      # Restaura $s2 do chamador do verificador.
    lw $s1, 52($sp)                      # Restaura $s1 do chamador do verificador.
    lw $s0, 56($sp)                      # Restaura $s0 do chamador do verificador.
    lw $ra, 60($sp)                      # Restaura $ra do chamador do verificador.
    addiu $sp, $sp, 64                   # Libera o frame do verificador.
    jr $ra                               # Retorna para o proximo cenario do programa.
    nop                                  # Protege o delay slot do retorno.

tc_mostrarEstado:                        # Recebe endereco de registro ficticio e prefixo da demonstracao.
    move $t5, $a0                        # Mantem o endereco enquanto as syscalls usam a0.
    move $a0, $a1                        # Seleciona o prefixo ANTES ou DEPOIS.
    li $v0, 4                            # Seleciona impressao de string apenas para a demonstracao.
    syscall                              # Imprime o prefixo do estado.
    lw $a0, 0($t5)                       # Recupera o identificador do apartamento.
    li $v0, 1                            # Seleciona impressao de inteiro.
    syscall                              # Imprime o numero do apartamento ficticio.
    la $a0, tc_msgMoradores              # Seleciona o rotulo de contagem de moradores.
    li $v0, 4                            # Seleciona impressao de string.
    syscall                              # Imprime o rotulo dos moradores.
    lw $a0, 4($t5)                       # Le a contagem conforme o contrato proposto.
    li $v0, 1                            # Seleciona impressao de inteiro.
    syscall                              # Mostra a quantidade ficticia de moradores.
    la $a0, tc_msgVeiculos               # Seleciona o rotulo da contagem de veiculos.
    li $v0, 4                            # Seleciona impressao de string.
    syscall                              # Imprime o rotulo dos veiculos.
    lw $a0, 296($t5)                     # Le a contagem conforme o layout publicado por Brenno.
    li $v0, 1                            # Seleciona impressao de inteiro.
    syscall                              # Mostra a quantidade ficticia de veiculos.
    la $a0, tc_nl                        # Seleciona a quebra de linha.
    li $v0, 4                            # Seleciona impressao de string.
    syscall                              # Finaliza a demonstracao do estado.
    jr $ra                               # Retorna sem alterar os registros ficticios.
    nop                                  # Protege o delay slot do retorno.

tc_verificarTabela:                      # Recebe indice autorizado em a0 e passo real em a1.
    la $t0, tc_original                  # Aponta para o primeiro registro de referencia.
    la $t1, tc_tabela                    # Aponta para o primeiro registro depois da operacao.
    move $t2, $zero                      # Inicializa o indice do registro que sera conferido.
tc_verificarRegistro:                    # Inicia a verificacao de um apartamento inteiro.
    move $t3, $zero                      # Inicializa o deslocamento do primeiro byte do registro.
tc_verificarByte:                        # Calcula o valor esperado sem executar outra limpeza.
    addu $t4, $t0, $t3                   # Localiza o byte original neste registro.
    lbu $t5, 0($t4)                      # Assume inicialmente que o byte precisa ser preservado.
    bne $t2, $a0, tc_verificarComparar   # Preserva todos os bytes dos apartamentos nao selecionados.
    nop                                  # Protege o delay slot do desvio.
    sltiu $t6, $t3, 4                    # Verifica se o byte pertence a identificacao do AP.
    bne $t6, $zero, tc_verificarComparar # Preserva a identificacao inclusive no registro limpo.
    nop                                  # Protege o delay slot do desvio.
    sltiu $t6, $t3, 448                  # Verifica se o byte pertence aos campos mutaveis propostos.
    beq $t6, $zero, tc_verificarComparar # Preserva eventuais campos opcionais depois da garagem.
    nop                                  # Protege o delay slot do desvio.
    move $t5, $zero                      # Exige zero somente nos campos mutaveis do AP escolhido.
tc_verificarComparar:                    # Compara o byte real com o valor esperado para seu papel.
    addu $t4, $t1, $t3                   # Localiza o byte correspondente na tabela de trabalho.
    lbu $t6, 0($t4)                      # Le o byte real depois da rotina do projeto.
    bne $t6, $t5, tc_falha               # Detecta dado nao limpo ou alteracao de dados preservados.
    nop                                  # Protege o delay slot do desvio.
    addiu $t3, $t3, 1                    # Avanca para o proximo byte do registro.
    bne $t3, $a1, tc_verificarByte       # Confere todos os bytes do passo informado.
    nop                                  # Protege o delay slot do desvio.
    addiu $t0, $t0, 512                  # Avanca na referencia de registros ficticios de 512 bytes.
    addu $t1, $t1, $a1                   # Avanca no resultado respeitando o passo do cenario.
    addiu $t2, $t2, 1                    # Incrementa o indice de apartamento conferido.
    li $t6, 24                           # Define o total de registros que precisam ser verificados.
    bne $t2, $t6, tc_verificarRegistro   # Verifica tambem os apartamentos anteriores e posteriores.
    nop                                  # Protege o delay slot do desvio.
    la $t0, tc_guardaDepois              # Aponta para o final do buffer maximo de trabalho.
    li $t3, 204                          # Define o padrao esperado na sobra da tabela compacta.
    beq $t1, $t0, tc_verificarGuardas    # Pula a sobra quando o passo usa o buffer inteiro.
    nop                                  # Protege o delay slot do desvio.
tc_verificarSobra:                       # Verifica bytes nao usados depois da tabela compacta.
    lbu $t2, 0($t1)                      # Le um byte posterior ao ultimo registro compacto.
    bne $t2, $t3, tc_falha               # Detecta escrita fora dos 24 registros reais.
    nop                                  # Protege o delay slot do desvio.
    addiu $t1, $t1, 1                    # Avanca para o proximo byte nao usado.
    bne $t1, $t0, tc_verificarSobra      # Confere toda a sobra ate o sentinela final.
    nop                                  # Protege o delay slot do desvio.
tc_verificarGuardas:                     # Confere os dois limites externos da tabela de trabalho.
    lw $t0, tc_guardaAntes               # Le o sentinela anterior da tabela.
    li $t1, 0x13579BDF                   # Recupera o valor original desse sentinela.
    bne $t0, $t1, tc_falha               # Detecta escrita antes do primeiro registro.
    nop                                  # Protege o delay slot do desvio.
    lw $t0, tc_guardaDepois              # Le o sentinela posterior da tabela.
    li $t1, 0x2468ACE0                   # Recupera o valor original desse sentinela.
    bne $t0, $t1, tc_falha               # Detecta escrita depois do buffer maximo.
    nop                                  # Protege o delay slot do desvio.
    jr $ra                               # Retorna depois de conferir todos os dados e limites.
    nop                                  # Protege o delay slot do retorno.

tc_falha:                                # Encerra o programa ao encontrar qualquer divergencia.
    la $a0, tc_msgFail                   # Seleciona a mensagem de falha.
    li $v0, 4                            # Seleciona impressao de string no teste.
    syscall                              # Imprime a descricao da falha.
    lw $a0, tc_idCaso                    # Recupera o cenario sem depender dos registradores salvos.
    li $v0, 1                            # Seleciona impressao de inteiro.
    syscall                              # Identifica o cenario que falhou.
    la $a0, tc_nl                        # Seleciona a quebra de linha da mensagem.
    li $v0, 4                            # Seleciona impressao de string.
    syscall                              # Finaliza a mensagem de erro.
    li $a0, 1                            # Define codigo de saida nao zero para falha.
    li $v0, 17                           # Seleciona encerramento com codigo de saida.
    syscall                              # Encerra o teste sem produzir falso resultado de sucesso.

.include "../src/apartamento/limparAp.asm" # Inclui as rotinas reais sem incluir o shell ou os modulos dos colegas.
