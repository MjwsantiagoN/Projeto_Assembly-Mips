# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: infoAp.asm
# Objetivo: procurar um AP e mostrar seus dados sem altera-los.
# Usa chamadas diretas a ap_imprimirTexto, em Auxiliares/saidaApMMIO.asm.
# O shell e a opcao all nao fazem parte desta versao individual.
# ==============================================================

# ENTRADA: a0 = base da tabela com 24 APs; a1 = numero do AP; a2 = passo.
# Passo e a distancia entre registros: multiplo de 4 e pelo menos 448.
# SAIDA: v0 = 0 e v1 = endereco do AP no sucesso.
# Erro de AP ou parametros: v0 = -1. Dados inconsistentes: v0 = -2.
# Nos erros, v1 aponta para a mesma mensagem que foi mostrada.
# Preserva os argumentos, os registradores salvos e a pilha.
# Os temporarios e HI/LO podem mudar durante a impressao.
# Usa s0 = AP atual, s1 = quantidade a listar, s2 = endereco do campo atual.
# O chamador fornece memoria legivel para os 24 registros e IDs validos e unicos.
# Este modulo nao comprova a validade de qualquer endereco arbitrario.

# LAYOUT PROPOSTO, ainda sujeito a revisao do grupo:
# +0: numero do AP; +4: quantidade de moradores; +8: seis nomes de 48 bytes.
# Cada nome termina em zero e tem no maximo 47 caracteres uteis.
# Os primeiros num_moradores nomes sao os ativos.
# Garagem de Brenno: contador +296, tipo +300 e tres slots a partir de +304.
# Cada slot tem 48 bytes: tipo +0, modelo +4 (32 bytes), placa +36 (12 bytes).
# A ocupacao e definida pelo contador de moradores, nao por um segundo indicador.
# Ver docs/contrato_apartamentos.md para a proposta completa.

.data                                      # Inicia as mensagens usadas na consulta.
infoAp_txtAP: .asciiz "AP: "               # Guarda um texto terminado pelo byte zero.
infoAp_txtVazio: .asciiz "Apartamento vazio\n" # Guarda um texto terminado pelo byte zero.
infoAp_txtMoradores: .asciiz "Moradores:\n" # Guarda um texto terminado pelo byte zero.
infoAp_txtCarro: .asciiz "Carro:\n"        # Guarda um texto terminado pelo byte zero.
infoAp_txtMoto: .asciiz "Moto:\n"          # Guarda um texto terminado pelo byte zero.
infoAp_txtSeparador: .asciiz " / "         # Guarda um texto terminado pelo byte zero.
infoAp_txtNL: .asciiz "\n"                 # Guarda um texto terminado pelo byte zero.
infoAp_txtErroAP: .asciiz "Falha: AP invalido\n" # Guarda um texto terminado pelo byte zero.
infoAp_txtErroDados: .asciiz "Falha: dados do AP invalidos\n" # Guarda um texto terminado pelo byte zero.
.text                                      # Retoma as instrucoes executaveis.
.globl infoAp_executar                     # Permite que o futuro shell chame a consulta.

infoAp_executar:                           # Guarda os dados necessarios antes de chamar outras funcoes.
    addiu $sp, $sp, -40                    # Reserva 24 bytes para dados e 16 para argumentos das chamadas.
    sw $ra, 36($sp)                        # Guarda $ra para devolver seu valor ao chamador.
    sw $s0, 32($sp)                        # Guarda $s0 para devolver seu valor ao chamador.
    sw $s1, 28($sp)                        # Guarda $s1 para devolver seu valor ao chamador.
    sw $s2, 24($sp)                        # Guarda $s2 para devolver seu valor ao chamador.
    sw $a0, 20($sp)                        # Guarda $a0 para devolver seu valor ao chamador.
    sw $a1, 16($sp)                        # Guarda $a1 para devolver seu valor ao chamador.
    move $s0, $a0                          # Comeca a busca no primeiro registro da tabela.
    beq $a0, $zero, infoAp_erroAP          # Nao le dados de uma tabela com endereco nulo.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    andi $t0, $a0, 3                       # Verifica os bits que indicam desalinhamento da tabela.
    bne $t0, $zero, infoAp_erroAP          # Rejeita endereco que nao permite leitura alinhada de word.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    blez $a1, infoAp_erroAP                # Rejeita numero de AP zero ou negativo.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    slti $t0, $a2, 448                     # Verifica passo negativo ou menor que o registro minimo.
    bne $t0, $zero, infoAp_erroAP          # Nao percorre uma tabela com passo insuficiente.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    andi $t0, $a2, 3                       # Verifica se o passo e multiplo de quatro.
    bne $t0, $zero, infoAp_erroAP          # O registro seguinte tambem precisa estar alinhado.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    li $t1, 24                             # Conta quantos apartamentos ainda falta procurar.
infoAp_buscar:                             # Procura comparando um identificador por vez.
    lw $t0, 0($s0)                         # Le o numero do registro atual.
    beq $t0, $a1, infoAp_validarRegistro   # Se o numero e igual ao pedido, encontrou o AP.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    addiu $t1, $t1, -1                     # Desconta o registro que foi verificado.
    beq $t1, $zero, infoAp_erroAP          # Depois de 24 tentativas sem sucesso, mostra erro.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    addu $s0, $s0, $a2                     # Soma o passo para visitar o proximo AP.
    j infoAp_buscar                        # Repete a procura.
    nop                                    # Nao faz trabalho no atraso deste salto.

# Antes de imprimir, confere os contadores para nao listar campos fora do AP.
infoAp_validarRegistro:                    # Valida apenas os dados que serao usados na exibicao.
    lw $t0, 4($s0)                         # Le a quantidade de moradores.
    bltz $t0, infoAp_erroDados             # Quantidade negativa indica registro inconsistente.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    slti $t2, $t0, 7                       # Verifica se existem no maximo seis moradores.
    beq $t2, $zero, infoAp_erroDados       # Nao percorre nomes alem dos seis espacos.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    beq $t0, $zero, infoAp_cabecalho       # AP sem moradores sera mostrado como vazio.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    lw $t1, 296($s0)                       # Le a quantidade de veiculos.
    bltz $t1, infoAp_erroDados             # Rejeita uma quantidade negativa de veiculos.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    slti $t2, $t1, 4                       # Verifica o limite fisico de tres slots.
    beq $t2, $zero, infoAp_erroDados       # Nao le um quarto slot que nao existe.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    beq $t1, $zero, infoAp_cabecalho       # Se nao ha veiculos, nao precisa interpretar o tipo.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    lw $t0, 300($s0)                       # Le o tipo geral da garagem.
    li $t2, 109                            # Define o ASCII de m, usado para motos.
    beq $t0, $t2, infoAp_cabecalho         # Motos podem ocupar os slots que ja foram contados.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    li $t2, 99                             # Define o ASCII de c, usado para carro.
    bne $t0, $t2, infoAp_erroDados         # Outro tipo nao e reconhecido no contrato da garagem.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    li $t2, 1                              # Carro permite apenas um veiculo.
    bne $t1, $t2, infoAp_erroDados         # Rejeita varios veiculos sob o tipo carro.
    nop                                    # Nao faz trabalho no atraso deste desvio.

infoAp_cabecalho:                          # Mostra a identificacao do AP antes dos seus dados.
    la $a0, infoAp_txtAP                   # Seleciona o texto AP.
    li $a1, 0                              # Zero pede para imprimir ate o fim desta mensagem.
    jal ap_imprimirTexto                   # Chama diretamente a rotina de impressao.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    lw $a0, 0($s0)                         # Seleciona o numero inteiro do apartamento.
    jal infoAp_imprimirNumero              # Transforma o numero em digitos e imprime.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    la $a0, infoAp_txtNL                   # Seleciona a quebra de linha apos o numero.
    li $a1, 0                              # Zero pede para imprimir ate o fim desta mensagem.
    jal ap_imprimirTexto                   # Chama diretamente a rotina de impressao.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    lw $t0, 4($s0)                         # Recupera a quantidade de moradores depois da impressao.
    bne $t0, $zero, infoAp_listarMoradores # Com moradores, segue para a lista de nomes.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    la $a0, infoAp_txtVazio                # Seleciona a mensagem de AP vazio.
    li $a1, 0                              # Zero pede para imprimir ate o fim desta mensagem.
    jal ap_imprimirTexto                   # Chama diretamente a rotina de impressao.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    j infoAp_sucesso                       # Finaliza sem mostrar dados residuais da garagem.
    nop                                    # Nao faz trabalho no atraso deste salto.
infoAp_listarMoradores:                    # Prepara a lista dos moradores cadastrados.
    la $a0, infoAp_txtMoradores            # Seleciona o titulo Moradores.
    li $a1, 0                              # Zero pede para imprimir ate o fim desta mensagem.
    jal ap_imprimirTexto                   # Chama diretamente a rotina de impressao.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    lw $s1, 4($s0)                         # Guarda quantos nomes ainda falta imprimir.
    addiu $s2, $s0, 8                      # Aponta para o primeiro nome.
infoAp_moradorLoop:                        # Imprime um morador por repeticao.
    move $a0, $s2                          # Seleciona o nome atual.
    li $a1, 47                             # Limita a leitura aos caracteres uteis do campo de 48 bytes.
    jal ap_imprimirTexto                   # Imprime o nome diretamente, sem copiar para outro buffer.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    la $a0, infoAp_txtNL                   # Seleciona a quebra de linha apos o nome.
    li $a1, 0                              # Zero pede para imprimir ate o fim desta mensagem.
    jal ap_imprimirTexto                   # Chama diretamente a rotina de impressao.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    addiu $s2, $s2, 48                     # Avanca para o proximo campo de nome.
    addiu $s1, $s1, -1                     # Um morador foi mostrado; falta um a menos.
    bne $s1, $zero, infoAp_moradorLoop     # Repete ate mostrar todos os moradores.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    lw $t0, 296($s0)                       # Recupera a quantidade de veiculos.
    beq $t0, $zero, infoAp_sucesso         # Sem veiculos, nao cria um titulo de garagem.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    lw $t0, 300($s0)                       # Recupera o tipo geral de veiculo.
    li $t1, 99                             # Seleciona o tipo carro.
    bne $t0, $t1, infoAp_tituloMoto        # O outro tipo validado e moto.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    la $a0, infoAp_txtCarro                # Seleciona o titulo Carro.
    li $a1, 0                              # Zero pede para imprimir ate o fim desta mensagem.
    jal ap_imprimirTexto                   # Chama diretamente a rotina de impressao.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    j infoAp_listarVeiculos                # Segue para mostrar os campos do veiculo.
    nop                                    # Nao faz trabalho no atraso deste salto.
infoAp_tituloMoto:                         # Seleciona o titulo das motos.
    la $a0, infoAp_txtMoto                 # Seleciona o titulo Moto.
    li $a1, 0                              # Zero pede para imprimir ate o fim desta mensagem.
    jal ap_imprimirTexto                   # Chama diretamente a rotina de impressao.
    nop                                    # Nao faz trabalho no atraso desta chamada.
infoAp_listarVeiculos:                     # Prepara o percurso dos slots cadastrados.
    lw $s1, 296($s0)                       # Guarda quantos veiculos falta mostrar.
    addiu $s2, $s0, 304                    # Aponta para o primeiro slot de veiculo.
infoAp_veiculoLoop:                        # Mostra modelo e placa de um veiculo.
    addiu $a0, $s2, 4                      # Pula a word de tipo e aponta para o modelo.
    li $a1, 31                             # Limita o modelo a seus 31 caracteres uteis.
    jal ap_imprimirTexto                   # Imprime o modelo pelo display.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    la $a0, infoAp_txtSeparador            # Seleciona a separacao entre modelo e placa.
    li $a1, 0                              # Zero pede para imprimir ate o fim desta mensagem.
    jal ap_imprimirTexto                   # Chama diretamente a rotina de impressao.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    addiu $a0, $s2, 36                     # Aponta para a placa no mesmo slot.
    li $a1, 11                             # Limita a placa a seus 11 caracteres uteis.
    jal ap_imprimirTexto                   # Imprime a placa pelo display.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    la $a0, infoAp_txtNL                   # Seleciona a quebra de linha depois do veiculo.
    li $a1, 0                              # Zero pede para imprimir ate o fim desta mensagem.
    jal ap_imprimirTexto                   # Chama diretamente a rotina de impressao.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    addiu $s2, $s2, 48                     # Avanca para o proximo slot.
    addiu $s1, $s1, -1                     # Um veiculo foi mostrado; falta um a menos.
    bne $s1, $zero, infoAp_veiculoLoop     # Continua ate listar os veiculos cadastrados.
    nop                                    # Nao faz trabalho no atraso deste desvio.
infoAp_sucesso:                            # Prepara os valores de retorno da consulta.
    li $v0, 0                              # Informa que a consulta terminou corretamente.
    move $v1, $s0                          # Retorna o endereco do registro mostrado.
    j infoAp_restaurar                     # Segue para restaurar o contexto do chamador.
    nop                                    # Nao faz trabalho no atraso deste salto.
infoAp_erroAP:                             # Mostra erro de apartamento ou parametros.
    la $a0, infoAp_txtErroAP               # Seleciona o texto de AP invalido.
    li $a1, 0                              # Zero pede para imprimir ate o fim desta mensagem.
    jal ap_imprimirTexto                   # Chama diretamente a rotina de impressao.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    li $v0, -1                             # Retorna o codigo de erro de AP.
    la $v1, infoAp_txtErroAP               # Retorna o endereco da mensagem exibida.
    j infoAp_restaurar                     # Segue para devolver os valores guardados.
    nop                                    # Nao faz trabalho no atraso deste salto.
infoAp_erroDados:                          # Mostra erro de contadores ou tipo inconsistentes.
    la $a0, infoAp_txtErroDados            # Seleciona o texto de dados invalidos.
    li $a1, 0                              # Zero pede para imprimir ate o fim desta mensagem.
    jal ap_imprimirTexto                   # Chama diretamente a rotina de impressao.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    li $v0, -2                             # Retorna o codigo de registro inconsistente.
    la $v1, infoAp_txtErroDados            # Retorna o endereco da mensagem exibida.
infoAp_restaurar:                          # Recupera os valores guardados na pilha.
    lw $a1, 16($sp)                        # Recupera $a1 do chamador.
    lw $a0, 20($sp)                        # Recupera $a0 do chamador.
    lw $s2, 24($sp)                        # Recupera $s2 do chamador.
    lw $s1, 28($sp)                        # Recupera $s1 do chamador.
    lw $s0, 32($sp)                        # Recupera $s0 do chamador.
    lw $ra, 36($sp)                        # Recupera $ra do chamador.
    addiu $sp, $sp, 40                     # Libera exatamente os 40 bytes reservados.
    jr $ra                                 # Volta para o chamador da consulta.
    nop                                    # Nao faz trabalho no atraso deste retorno.

# AUXILIAR: imprimir um identificador positivo em decimal.
# Entrada: a0 = numero. Divide por 10 para separar cada digito.
# O resto e um digito de 0 a 9; somar 48 transforma-o em caractere ASCII.
# Como os restos saem do ultimo digito para o primeiro, escreve de tras para frente.
# O buffer e pequeno e local: nao altera os dados do apartamento.
infoAp_imprimirNumero:                     # Converte o numero do AP para uma string.
    addiu $sp, $sp, -48                    # Reserva buffer local, area de argumentos e retorno.
    sw $ra, 44($sp)                        # Guarda o retorno antes de imprimir a string.
    move $t0, $a0                          # Copia o numero a converter.
    li $t1, 10                             # Define a base decimal.
    addiu $t2, $sp, 31                     # Aponta para o fim do buffer local.
    sb $zero, 0($t2)                       # Coloca o terminador nulo no fim do numero.
infoAp_numeroDigito:                       # Separa e guarda um digito de cada vez.
    divu $t0, $t1                          # Divide o numero por dez.
    mfhi $t3                               # O resto da divisao e o proximo digito.
    mflo $t0                               # O quociente e a parte que ainda falta converter.
    addiu $t3, $t3, 48                     # Converte o digito numerico para seu caractere ASCII.
    addiu $t2, $t2, -1                     # Recua uma posicao para manter os digitos na ordem certa.
    sb $t3, 0($t2)                         # Grava o caractere no buffer.
    bne $t0, $zero, infoAp_numeroDigito    # Repete enquanto ainda houver parte do numero.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    move $a0, $t2                          # Seleciona o inicio da string decimal formada.
    li $a1, 0                              # Pede para imprimir ate o terminador.
    jal ap_imprimirTexto                   # Imprime o numero usando a mesma rotina dos textos.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    lw $ra, 44($sp)                        # Recupera para onde esta auxiliar deve voltar.
    addiu $sp, $sp, 48                     # Libera o espaco local usado pela conversao.
    jr $ra                                 # Volta para a consulta.
    nop                                    # Nao faz trabalho no atraso deste retorno.
