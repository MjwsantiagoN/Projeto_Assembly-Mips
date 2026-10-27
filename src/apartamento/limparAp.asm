# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: limparAp.asm
# Objetivo: limpar bytes, a garagem e o registro de um apartamento.
# O layout de moradores e uma proposta: ver docs/contrato_apartamentos.md.
# ==============================================================

# COMO LER: endereco e a posicao de um dado na memoria.
# Um byte ocupa uma posicao; uma word ocupa quatro bytes.
# Depois de saltos e chamadas, nop deixa o atraso de salto sem trabalho.
# Isso permite usar o mesmo codigo com Delayed Branching ligado ou desligado.

# 1. ZERAR UMA REGIAO
# Entrada: a0 = endereco inicial; a1 = quantidade de bytes.
# Saida: v0 = quantidade limpa; -1 se tamanho negativo ou endereco nulo.
# Tamanho zero e valido e nao acessa a memoria.
# Usa t0 como endereco atual e t1 como contador. Preserva a0 e a1.
# O chamador deve fornecer memoria valida, gravavel e com tamanho suficiente.
# Exemplo: quatro bytes 10,20,30,40 tornam-se 0,0,0,0.

.text                                      # Inicia as instrucoes do programa.
.globl limparAp_zerarRegiao                # Permite que outros arquivos chamem esta funcao.
limparAp_zerarRegiao:                      # Inicio da funcao que limpa uma quantidade de bytes.
    li $v0, -1                             # Deixa preparado o retorno de erro.
    bltz $a1, limparAp_zerarRetorno        # Tamanho negativo nao pode ser usado como contador.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    beq $a1, $zero, limparAp_zerarSucesso  # Com tamanho zero, nao existe byte para limpar.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    beq $a0, $zero, limparAp_zerarRetorno  # Endereco nulo nao pode receber os bytes.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    move $t0, $a0                          # Copia o endereco para preservar o argumento original.
    move $t1, $a1                          # Copia a quantidade que ainda falta limpar.
limparAp_zerarLoop:                        # Repete a mesma operacao para cada byte.
    sb $zero, 0($t0)                       # Grava zero no byte indicado pelo endereco atual.
    addiu $t0, $t0, 1                      # Avanca uma posicao de memoria: o proximo byte.
    addiu $t1, $t1, -1                     # Um byte foi limpo; diminui o que ainda falta.
    bne $t1, $zero, limparAp_zerarLoop     # Se ainda faltam bytes, repete o laco.
    nop                                    # Nao faz trabalho no atraso deste desvio.
limparAp_zerarSucesso:                     # Prepara a quantidade limpa como resultado.
    move $v0, $a1                          # A quantidade limpa e a quantidade pedida inicialmente.
limparAp_zerarRetorno:                     # Fim da funcao, tanto em sucesso como em erro.
    jr $ra                                 # Volta para quem chamou a funcao.
    nop                                    # Nao faz trabalho no atraso deste retorno.

# 2. LIMPAR A GARAGEM
# Entrada: a0 = endereco base de um AP valido.
# Saida: v0 = 0 no sucesso ou -1 para endereco nulo.
# Preserva os argumentos, os registradores salvos e a pilha.
# O layout de Brenno coloca contador em +296, tipo em +300 e slots em +304.
# A garagem inteira ocupa 8 + 3*48 = 152 bytes, de +296 a +447.
# O resto do apartamento nao e alterado.

.eqv LIMPAR_AP_GARAGEM_INICIO 296          # Da nome ao primeiro byte da garagem.
.eqv LIMPAR_AP_GARAGEM_BYTES 152           # Da nome ao total de bytes da garagem.
.globl limparAp_limparVeiculos             # Permite chamar a limpeza da garagem de outro arquivo.
limparAp_limparVeiculos:                   # Inicio da limpeza da garagem de um AP.
    li $v0, -1                             # Deixa preparado o erro de endereco nulo.
    beq $a0, $zero, limparAp_veiculosRetorno # Nao soma o deslocamento a um endereco nulo.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    addiu $sp, $sp, -32                    # Reserva espaco na pilha para guardar dados da chamada.
    sw $ra, 28($sp)                        # Guarda para onde voltar depois de chamar outra funcao.
    sw $a0, 24($sp)                        # Guarda o endereco original do apartamento.
    sw $a1, 20($sp)                        # Guarda o segundo argumento, que sera usado como tamanho.
    addiu $a0, $a0, LIMPAR_AP_GARAGEM_INICIO # A base do AP mais 296 aponta para a garagem.
    li $a1, LIMPAR_AP_GARAGEM_BYTES        # Pede a limpeza de todos os 152 bytes da garagem.
    jal limparAp_zerarRegiao               # Chama a funcao anterior para fazer a limpeza.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    li $v0, 0                              # Os argumentos da auxiliar sao validos; informa sucesso.
limparAp_veiculosRestaurar:                # Recupera os valores guardados antes da chamada.
    lw $a1, 20($sp)                        # Devolve o valor original do segundo argumento.
    lw $a0, 24($sp)                        # Devolve o endereco original do AP.
    lw $ra, 28($sp)                        # Recupera para onde esta funcao deve retornar.
    addiu $sp, $sp, 32                     # Libera exatamente o espaco reservado na pilha.
limparAp_veiculosRetorno:                  # Finaliza a limpeza da garagem.
    jr $ra                                 # Volta para o chamador com o status em v0.
    nop                                    # Nao faz trabalho no atraso deste retorno.

# 3. PROCURAR E LIMPAR UM APARTAMENTO
# Entrada: a0 = tabela com 24 APs; a1 = numero procurado; a2 = passo.
# Passo e a distancia em bytes entre dois registros: por exemplo, 448 ou 512.
# O passo deve ser multiplo de quatro e pelo menos 448.
# Saida: v0 = 0 e v1 = endereco do AP; ou v0 = -1 e v1 = mensagem de erro.
# Preserva os argumentos, os registradores salvos e a pilha.
# Usa s0 para manter o endereco do AP entre as chamadas de limpeza.
# Na busca, t0 le o identificador e t1 conta os 24 registros restantes.
# A tabela precisa ter memoria valida e IDs validos e unicos, sem estouro de enderecos.
# Proposta: ID em +0; contador de moradores em +4; nomes de +8 a +295.
# AP vazio significa contador de moradores igual a zero.
# Preserva ID, outros APs e tudo a partir de +448. Nao salva arquivos nem imprime.

.eqv LIMPAR_AP_TOTAL_REGISTROS 24          # Nomeia a quantidade de apartamentos do enunciado.
.eqv LIMPAR_AP_REGISTRO_MINIMO 448         # Nomeia o tamanho minimo que comporta a garagem.
.eqv LIMPAR_AP_MORADORES_INICIO 4          # Pula a word do numero do AP, que deve permanecer.
.eqv LIMPAR_AP_MORADORES_BYTES 292         # Abrange contador e nomes: do byte 4 ao byte 295.
.data                                      # Inicia os textos guardados na memoria.
limparAp_msgApInvalido: .asciiz "Falha: AP invalido\n" # Mensagem que o shell deve mostrar em caso de erro.
.text                                      # Retoma as instrucoes executaveis.
.globl limparAp_executar                   # Exporta a limpeza por numero de apartamento.
limparAp_executar:                         # Primeiro valida os parametros sem alterar a tabela.
    li $v0, -1                             # Prepara o status de erro.
    la $v1, limparAp_msgApInvalido         # Prepara o endereco do texto de erro.
    beq $a0, $zero, limparAp_completoRetorno # Rejeita uma tabela com endereco nulo.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    andi $t0, $a0, 3                       # Bits finais diferentes de zero indicam word desalinhada.
    bne $t0, $zero, limparAp_completoRetorno # Nao faz leitura de word em base desalinhada.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    blez $a1, limparAp_completoRetorno     # Rejeita numero de AP zero ou negativo.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    slti $t0, $a2, LIMPAR_AP_REGISTRO_MINIMO # Verifica se o passo e menor que 448, inclusive negativo.
    bne $t0, $zero, limparAp_completoRetorno # Um registro menor nao comporta os campos usados.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    andi $t0, $a2, 3                       # Verifica se o passo e multiplo de quatro.
    bne $t0, $zero, limparAp_completoRetorno # O proximo AP tambem precisa estar alinhado.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    addiu $sp, $sp, -32                    # Reserva somente o espaco necessario para esta funcao.
    sw $ra, 28($sp)                        # Guarda o retorno antes das chamadas auxiliares.
    sw $s0, 24($sp)                        # Preserva o valor de s0 que pertencia ao chamador.
    sw $a0, 20($sp)                        # Guarda a base original da tabela.
    sw $a1, 16($sp)                        # Guarda o numero originalmente pedido.
    move $s0, $a0                          # Comeca a procura no primeiro registro.
    li $t1, LIMPAR_AP_TOTAL_REGISTROS      # Prepara o contador de 24 registros.
limparAp_completoBuscar:                   # Procura o AP comparando um identificador por vez.
    lw $t0, 0($s0)                         # Le o numero no inicio do registro atual.
    beq $t0, $a1, limparAp_completoEncontrado # Se o numero coincide, encontrou o AP.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    addiu $t1, $t1, -1                     # Um registro foi verificado; falta um a menos.
    beq $t1, $zero, limparAp_completoFalha # Depois de 24 tentativas sem encontrar, retorna erro.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    addu $s0, $s0, $a2                     # Soma o passo para visitar o proximo registro.
    j limparAp_completoBuscar              # Repete a comparacao no AP seguinte.
    nop                                    # Nao faz trabalho no atraso deste salto.
limparAp_completoEncontrado:               # Limpa moradores e depois veiculos do mesmo AP.
    addiu $a0, $s0, LIMPAR_AP_MORADORES_INICIO # Pula a identificacao e aponta para o contador de moradores.
    li $a1, LIMPAR_AP_MORADORES_BYTES      # Seleciona contador e toda a area de nomes.
    jal limparAp_zerarRegiao               # Zera os moradores e deixa sua quantidade em zero.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    move $a0, $s0                          # Volta ao endereco base do mesmo apartamento.
    jal limparAp_limparVeiculos            # Zera o contador, o tipo e os slots da garagem.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    li $v0, 0                              # As duas limpezas terminaram; retorna sucesso.
    move $v1, $s0                          # Informa o endereco do apartamento que foi limpo.
    j limparAp_completoRestaurar           # Segue para recuperar o contexto original.
    nop                                    # Nao faz trabalho no atraso deste salto.
limparAp_completoFalha:                    # Prepara o erro para um numero nao encontrado.
    li $v0, -1                             # Informa que nenhum AP foi limpo.
    la $v1, limparAp_msgApInvalido         # Entrega a mensagem para o shell exibir.
limparAp_completoRestaurar:                # Restaura os dados guardados na pilha.
    lw $a1, 16($sp)                        # Recupera o numero original pedido.
    lw $a0, 20($sp)                        # Recupera a base original da tabela.
    lw $s0, 24($sp)                        # Devolve a s0 o valor anterior do chamador.
    lw $ra, 28($sp)                        # Recupera o endereco de retorno.
    addiu $sp, $sp, 32                     # Libera o mesmo espaco que foi reservado.
limparAp_completoRetorno:                  # Retorna o status e o endereco preparados.
    jr $ra                                 # Volta para o chamador.
    nop                                    # Nao faz trabalho no atraso deste retorno.
