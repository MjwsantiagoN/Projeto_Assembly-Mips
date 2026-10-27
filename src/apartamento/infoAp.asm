# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: infoAp.asm
# Descricao: consulta individual sob o contrato PROPOSTO de apartamentos.
# O interpretador do shell e a opcao all nao fazem parte desta etapa.
# ==============================================================

# Contrato de infoAp_executar:
# $a0 = base alinhada de uma tabela legivel com 24 registros validos.
# $a1 = numero inteiro do apartamento procurado.
# $a2 = passo entre registros, multiplo de quatro e pelo menos 448.
# $a3 = endereco alinhado de uma rotina que imprime a string recebida em $a0.
# Para Display MMIO, passar o endereco de infoAp_escreverMMIO explicitamente.
# O escritor deve preservar $s0-$s7, $sp e retornar normalmente por $ra.
# Pode modificar argumentos, temporarios, retornos e HI/LO; seus retornos sao ignorados.
# $v0 = 0 no sucesso; -1 para AP/parametros invalidos; -2 para contadores/tipo invalidos.
# $v1 = endereco do AP no sucesso; endereco da mensagem no erro.
# Com escritor nulo/desalinhado, retorna -1 sem tentar imprimir.
# Preserva $a0-$a3, $s0-$s7 e o equilibrio da pilha. Pode alterar temporarios e HI/LO.
# A rotina e o escritor nao devem alterar a tabela consultada.
# O chamador garante memoria legivel, identificadores validos e unicos,
# ausencia de estouro de enderecos e um escritor executavel adequado.
# Nao existe verificacao geral de enderecos arbitrarios.

# Extensao PROPOSTA do formato de moradores para esta consulta:
# +0: numero do AP; +4: quantidade de moradores (0 a 6).
# +8: seis nomes contiguos de 48 bytes, terminados em zero (maximo 47 caracteres).
# Os primeiros num_moradores espacos sao os registros ativos.
# A garagem mantem os offsets +296, +300 e +304 publicados em addAuto.asm.
# Cada slot de veiculo tem tipo word, modelo de 32 bytes e placa de 12 bytes.
# Campos de texto sao limitados a capacidade menos um antes de imprimir.
# Com zero moradores, exibe Apartamento vazio e nao lista a garagem.
# Consultar docs/contrato_apartamentos.md antes de integrar com o grupo.

.data                                      # Inicia as mensagens privadas da consulta.
infoAp_txtAP: .asciiz "AP: "               # Define o prefixo do identificador do apartamento.
infoAp_txtVazio: .asciiz "Apartamento vazio\n" # Define a mensagem exigida para apartamento sem moradores.
infoAp_txtMoradores: .asciiz "Moradores:\n" # Define o titulo da lista de moradores.
infoAp_txtCarro: .asciiz "Carro:\n"        # Define o titulo da lista de carro.
infoAp_txtMoto: .asciiz "Moto:\n"          # Define o titulo da lista de motos.
infoAp_txtSeparador: .asciiz " / "         # Separa o modelo da placa de cada veiculo.
infoAp_txtNL: .asciiz "\n"                 # Define uma quebra de linha.
infoAp_txtErroAP: .asciiz "Falha: AP invalido\n" # Define a mensagem de apartamento ou parametros invalidos.
infoAp_txtErroDados: .asciiz "Falha: dados do AP invalidos\n" # Define a mensagem de registro com contadores ou tipo invalidos.
.text                                      # Inicia as instrucoes da consulta.
.globl infoAp_executar                     # Exporta a consulta individual por numero de apartamento.
.globl infoAp_escreverMMIO                 # Exporta um escritor opcional para o Display MMIO.

infoAp_executar:                           # Recebe tabela, numero, passo e endereco do escritor.
    li $v0, -1                             # Prepara o erro para um escritor que nao possa ser chamado.
    la $v1, infoAp_txtErroAP               # Disponibiliza a mensagem de erro mesmo sem escritor.
    beq $a3, $zero, infoAp_retornoDireto   # Rejeita escritor nulo antes de qualquer chamada.
    nop                                    # Protege o delay slot do desvio.
    andi $t0, $a3, 3                       # Verifica alinhamento do endereco do escritor.
    bne $t0, $zero, infoAp_retornoDireto   # Rejeita escritor desalinhado sem tentar executa-lo.
    nop                                    # Protege o delay slot do desvio.
    addiu $sp, $sp, -80                    # Reserva frame alinhado e area para argumentos de chamadas.
    sw $ra, 76($sp)                        # Preserva $ra antes das chamadas de impressao.
    sw $s0, 72($sp)                        # Preserva $s0 antes das chamadas de impressao.
    sw $s1, 68($sp)                        # Preserva $s1 antes das chamadas de impressao.
    sw $s2, 64($sp)                        # Preserva $s2 antes das chamadas de impressao.
    sw $s3, 60($sp)                        # Preserva $s3 antes das chamadas de impressao.
    sw $s4, 56($sp)                        # Preserva $s4 antes das chamadas de impressao.
    sw $s5, 52($sp)                        # Preserva $s5 antes das chamadas de impressao.
    sw $s6, 48($sp)                        # Preserva $s6 antes das chamadas de impressao.
    sw $s7, 44($sp)                        # Preserva $s7 antes das chamadas de impressao.
    sw $a0, 40($sp)                        # Preserva $a0 antes das chamadas de impressao.
    sw $a1, 36($sp)                        # Preserva $a1 antes das chamadas de impressao.
    sw $a2, 32($sp)                        # Preserva $a2 antes das chamadas de impressao.
    sw $a3, 28($sp)                        # Preserva $a3 antes das chamadas de impressao.
    move $s0, $a0                          # Mantem a base para procurar o apartamento.
    move $s1, $a1                          # Mantem o numero solicitado.
    move $s2, $a2                          # Mantem o passo fornecido pelo chamador.
    move $s3, $a3                          # Mantem o escritor apesar de seus argumentos serem temporarios.
    beq $s0, $zero, infoAp_erroAP          # Rejeita tabela nula antes de acessar memoria.
    nop                                    # Protege o delay slot do desvio.
    andi $t0, $s0, 3                       # Verifica alinhamento da tabela para leitura de word.
    bne $t0, $zero, infoAp_erroAP          # Rejeita base desalinhada.
    nop                                    # Protege o delay slot do desvio.
    blez $s1, infoAp_erroAP                # Rejeita numero de AP zero ou negativo.
    nop                                    # Protege o delay slot do desvio.
    slti $t0, $s2, 448                     # Verifica passo negativo ou menor que o registro minimo.
    bne $t0, $zero, infoAp_erroAP          # Rejeita passo insuficiente.
    nop                                    # Protege o delay slot do desvio.
    andi $t0, $s2, 3                       # Verifica se o passo preserva o alinhamento dos registros.
    bne $t0, $zero, infoAp_erroAP          # Rejeita passo nao multiplo de quatro.
    nop                                    # Protege o delay slot do desvio.
    li $s4, 24                             # Limita a busca aos apartamentos do enunciado.
infoAp_buscar:                             # Examina o identificador de um registro sem modifica-lo.
    lw $t0, 0($s0)                         # Le o numero do apartamento atual.
    beq $t0, $s1, infoAp_validarRegistro   # Segue para a consulta do apartamento encontrado.
    nop                                    # Protege o delay slot do desvio.
    addiu $s4, $s4, -1                     # Desconta o registro examinado.
    beq $s4, $zero, infoAp_erroAP          # Retorna erro depois de procurar nos 24 registros.
    nop                                    # Protege o delay slot do desvio.
    addu $s0, $s0, $s2                     # Avanca usando o passo fornecido pelo chamador.
    j infoAp_buscar                        # Continua a busca no registro seguinte.
    nop                                    # Protege o delay slot do salto.

infoAp_validarRegistro:                    # Valida contadores e tipo antes de comecar a imprimir.
    lw $s6, 4($s0)                         # Le a quantidade de moradores no contrato proposto.
    bltz $s6, infoAp_erroDados             # Rejeita contagem negativa de moradores.
    nop                                    # Protege o delay slot do desvio.
    slti $t0, $s6, 7                       # Verifica o limite de seis moradores.
    beq $t0, $zero, infoAp_erroDados       # Rejeita contagem superior ao limite do projeto.
    nop                                    # Protege o delay slot do desvio.
    beq $s6, $zero, infoAp_cabecalho       # Consulta AP vazio sem interpretar dados residuais de veiculos.
    nop                                    # Protege o delay slot do desvio.
    lw $s7, 296($s0)                       # Le a quantidade de veiculos no layout de Brenno.
    bltz $s7, infoAp_erroDados             # Rejeita contagem negativa de veiculos.
    nop                                    # Protege o delay slot do desvio.
    slti $t0, $s7, 4                       # Verifica a capacidade fisica dos tres slots publicados.
    beq $t0, $zero, infoAp_erroDados       # Rejeita leitura de slots alem da capacidade.
    nop                                    # Protege o delay slot do desvio.
    beq $s7, $zero, infoAp_cabecalho       # Dispensa interpretacao do tipo quando nao ha veiculos.
    nop                                    # Protege o delay slot do desvio.
    lw $t0, 300($s0)                       # Le o tipo geral normalizado do cadastro de veiculos.
    li $t1, 109                            # Define o tipo moto pelo ASCII de m.
    beq $t0, $t1, infoAp_cabecalho         # Aceita a contagem ja validada de motos.
    nop                                    # Protege o delay slot do desvio.
    li $t1, 99                             # Define o tipo carro pelo ASCII de c.
    bne $t0, $t1, infoAp_erroDados         # Rejeita um tipo geral nao reconhecido.
    nop                                    # Protege o delay slot do desvio.
    li $t1, 1                              # Define o unico carro permitido no contrato da garagem.
    bne $s7, $t1, infoAp_erroDados         # Rejeita varios veiculos sob o tipo geral de carro.
    nop                                    # Protege o delay slot do desvio.

infoAp_cabecalho:                          # Inicia a saida somente depois de validar o registro.
    la $a0, infoAp_txtAP                   # Seleciona o prefixo AP.
    jalr $s3                               # Envia a string ao escritor escolhido pelo chamador.
    nop                                    # Protege o delay slot da chamada.
    lw $a0, 0($s0)                         # Seleciona o identificador positivo do registro encontrado.
    move $a1, $s3                          # Fornece o escritor para a conversao decimal.
    jal infoAp_emitirNumero                # Converte e imprime o numero sem usar syscall na rotina real.
    nop                                    # Protege o delay slot da chamada.
    la $a0, infoAp_txtNL                   # Seleciona a quebra de linha apos a identificacao.
    jalr $s3                               # Envia a string ao escritor escolhido pelo chamador.
    nop                                    # Protege o delay slot da chamada.
    bne $s6, $zero, infoAp_listarMoradores # Segue para os cadastros quando ha moradores.
    nop                                    # Protege o delay slot do desvio.
    la $a0, infoAp_txtVazio                # Seleciona a mensagem de apartamento vazio.
    jalr $s3                               # Envia a string ao escritor escolhido pelo chamador.
    nop                                    # Protege o delay slot da chamada.
    j infoAp_sucesso                       # Finaliza sem mostrar cadastros de um apartamento vazio.
    nop                                    # Protege o delay slot do salto.
infoAp_listarMoradores:                    # Imprime os primeiros num_moradores nomes do contrato proposto.
    la $a0, infoAp_txtMoradores            # Seleciona o titulo dos moradores.
    jalr $s3                               # Envia a string ao escritor escolhido pelo chamador.
    nop                                    # Protege o delay slot da chamada.
    addiu $s5, $s0, 8                      # Aponta para o primeiro espaco proposto de nome.
    move $s4, $s6                          # Inicializa a quantidade de nomes a imprimir.
infoAp_moradorLoop:                        # Imprime um nome com limite do campo de 48 bytes.
    move $a0, $s5                          # Fornece o endereco do nome.
    li $a1, 48                             # Fornece a capacidade do campo, incluindo o terminador.
    move $a2, $s3                          # Fornece o escritor para a copia limitada.
    jal infoAp_emitirCampo                 # Imprime no maximo 47 caracteres deste nome.
    nop                                    # Protege o delay slot da chamada.
    la $a0, infoAp_txtNL                   # Finaliza a linha do morador.
    jalr $s3                               # Envia a string ao escritor escolhido pelo chamador.
    nop                                    # Protege o delay slot da chamada.
    addiu $s5, $s5, 48                     # Avanca para o nome seguinte.
    addiu $s4, $s4, -1                     # Desconta o morador que foi exibido.
    bne $s4, $zero, infoAp_moradorLoop     # Continua ate exibir todos os moradores ativos.
    nop                                    # Protege o delay slot do desvio.
    beq $s7, $zero, infoAp_sucesso         # Finaliza sem criar titulo de veiculos inexistentes.
    nop                                    # Protege o delay slot do desvio.
    lw $t0, 300($s0)                       # Recupera o tipo geral depois das chamadas ao escritor.
    li $t1, 99                             # Seleciona o tipo carro.
    bne $t0, $t1, infoAp_tituloMoto        # Seleciona o titulo de motos quando o tipo nao e carro.
    nop                                    # Protege o delay slot do desvio.
    la $a0, infoAp_txtCarro                # Seleciona o titulo de carro.
    jalr $s3                               # Envia a string ao escritor escolhido pelo chamador.
    nop                                    # Protege o delay slot da chamada.
    j infoAp_listarVeiculos                # Segue para os campos dos veiculos cadastrados.
    nop                                    # Protege o delay slot do salto.
infoAp_tituloMoto:                         # Seleciona o titulo das motos cadastradas.
    la $a0, infoAp_txtMoto                 # Seleciona o titulo de motos.
    jalr $s3                               # Envia a string ao escritor escolhido pelo chamador.
    nop                                    # Protege o delay slot da chamada.
infoAp_listarVeiculos:                     # Inicializa o percurso dos slots ativos da garagem.
    addiu $s5, $s0, 304                    # Aponta para o primeiro slot publicado por Brenno.
    move $s4, $s7                          # Inicializa a quantidade de veiculos a exibir.
infoAp_veiculoLoop:                        # Imprime modelo e placa de um slot ativo.
    addiu $a0, $s5, 4                      # Aponta para o modelo do veiculo.
    li $a1, 32                             # Define a capacidade de modelo publicada em addAuto.
    move $a2, $s3                          # Fornece o escritor da consulta.
    jal infoAp_emitirCampo                 # Imprime o modelo sem ultrapassar seu campo.
    nop                                    # Protege o delay slot da chamada.
    la $a0, infoAp_txtSeparador            # Seleciona a separacao entre modelo e placa.
    jalr $s3                               # Envia a string ao escritor escolhido pelo chamador.
    nop                                    # Protege o delay slot da chamada.
    addiu $a0, $s5, 36                     # Aponta para a placa do mesmo slot.
    li $a1, 12                             # Define a capacidade da placa publicada em addAuto.
    move $a2, $s3                          # Fornece o escritor da consulta.
    jal infoAp_emitirCampo                 # Imprime a placa sem ultrapassar seu campo.
    nop                                    # Protege o delay slot da chamada.
    la $a0, infoAp_txtNL                   # Finaliza a linha do veiculo.
    jalr $s3                               # Envia a string ao escritor escolhido pelo chamador.
    nop                                    # Protege o delay slot da chamada.
    addiu $s5, $s5, 48                     # Avanca para o proximo slot da garagem.
    addiu $s4, $s4, -1                     # Desconta o veiculo exibido.
    bne $s4, $zero, infoAp_veiculoLoop     # Continua somente pelos slots ativos.
    nop                                    # Protege o delay slot do desvio.
infoAp_sucesso:                            # Prepara o retorno depois de concluir a exibicao.
    li $v0, 0                              # Informa sucesso da consulta individual.
    move $v1, $s0                          # Retorna o endereco do apartamento consultado.
    j infoAp_restaurar                     # Segue para a recuperacao do contexto original.
    nop                                    # Protege o delay slot do salto.
infoAp_erroAP:                             # Exibe o erro de apartamento ou de parametros.
    la $a0, infoAp_txtErroAP               # Seleciona a mensagem de AP invalido.
    jalr $s3                               # Envia a string ao escritor escolhido pelo chamador.
    nop                                    # Protege o delay slot da chamada.
    li $v0, -1                             # Restaura o status depois de o escritor usar os retornos.
    la $v1, infoAp_txtErroAP               # Retorna o endereco da mensagem exibida.
    j infoAp_restaurar                     # Segue para a recuperacao do contexto.
    nop                                    # Protege o delay slot do salto.
infoAp_erroDados:                          # Exibe o erro antes de imprimir dados de registro inconsistente.
    la $a0, infoAp_txtErroDados            # Seleciona a mensagem de dados invalidos.
    jalr $s3                               # Envia a string ao escritor escolhido pelo chamador.
    nop                                    # Protege o delay slot da chamada.
    li $v0, -2                             # Informa contadores ou tipo inconsistentes.
    la $v1, infoAp_txtErroDados            # Retorna o endereco da mensagem exibida.
infoAp_restaurar:                          # Recupera os argumentos e registradores do chamador.
    lw $a3, 28($sp)                        # Restaura $a3 depois de todas as chamadas de saida.
    lw $a2, 32($sp)                        # Restaura $a2 depois de todas as chamadas de saida.
    lw $a1, 36($sp)                        # Restaura $a1 depois de todas as chamadas de saida.
    lw $a0, 40($sp)                        # Restaura $a0 depois de todas as chamadas de saida.
    lw $s7, 44($sp)                        # Restaura $s7 depois de todas as chamadas de saida.
    lw $s6, 48($sp)                        # Restaura $s6 depois de todas as chamadas de saida.
    lw $s5, 52($sp)                        # Restaura $s5 depois de todas as chamadas de saida.
    lw $s4, 56($sp)                        # Restaura $s4 depois de todas as chamadas de saida.
    lw $s3, 60($sp)                        # Restaura $s3 depois de todas as chamadas de saida.
    lw $s2, 64($sp)                        # Restaura $s2 depois de todas as chamadas de saida.
    lw $s1, 68($sp)                        # Restaura $s1 depois de todas as chamadas de saida.
    lw $s0, 72($sp)                        # Restaura $s0 depois de todas as chamadas de saida.
    lw $ra, 76($sp)                        # Restaura $ra depois de todas as chamadas de saida.
    addiu $sp, $sp, 80                     # Libera o frame da consulta.
infoAp_retornoDireto:                      # Finaliza inclusive a rejeicao inicial de escritor invalido.
    jr $ra                                 # Retorna status e endereco em v0 e v1.
    nop                                    # Protege o delay slot do retorno.

# Auxiliar privada: a0 aponta para o campo; a1 e sua capacidade de 1 a 48;
# a2 e o escritor. Usa buffer local fora da area de argumentos de chamadas.
infoAp_emitirCampo:                        # Cria uma string limitada sem alterar o campo original.
    addiu $sp, $sp, -80                    # Reserva buffer de 48 bytes, area de argumentos e retorno.
    sw $ra, 76($sp)                        # Guarda o retorno antes de chamar o escritor.
    move $t6, $a2                          # Mantem o escritor ate terminar a copia.
    move $t1, $a0                          # Aponta para o primeiro byte do campo.
    addiu $t0, $a1, -1                     # Reserva um byte para garantir terminacao nula.
    addiu $t2, $sp, 16                     # Aponta para o buffer depois da area de argumentos.
infoAp_campoCopiar:                        # Copia somente os caracteres permitidos pelo campo.
    beq $t0, $zero, infoAp_campoFim        # Finaliza ao atingir a capacidade util.
    nop                                    # Protege o delay slot do desvio.
    lbu $t3, 0($t1)                        # Le um byte dentro do limite do campo.
    beq $t3, $zero, infoAp_campoFim        # Finaliza ao encontrar o terminador original.
    nop                                    # Protege o delay slot do desvio.
    sb $t3, 0($t2)                         # Copia um caractere para o buffer local.
    addiu $t1, $t1, 1                      # Avanca a leitura do campo.
    addiu $t2, $t2, 1                      # Avanca a escrita do buffer.
    addiu $t0, $t0, -1                     # Desconta o caractere copiado.
    j infoAp_campoCopiar                   # Continua a copia limitada.
    nop                                    # Protege o delay slot do salto.
infoAp_campoFim:                           # Finaliza a string local e entrega-a ao escritor.
    sb $zero, 0($t2)                       # Garante que o escritor receba uma string terminada em zero.
    addiu $a0, $sp, 16                     # Fornece o inicio do buffer local.
    jalr $t6                               # Imprime o campo pelo escritor escolhido.
    nop                                    # Protege o delay slot da chamada.
    lw $ra, 76($sp)                        # Recupera o retorno sem depender dos temporarios do escritor.
    addiu $sp, $sp, 80                     # Libera o buffer e o frame.
    jr $ra                                 # Retorna a consulta sem alterar o registro.
    nop                                    # Protege o delay slot do retorno.

# Auxiliar privada: a0 e um identificador positivo e a1 e o escritor.
infoAp_emitirNumero:                       # Converte o identificador para decimal em um buffer local.
    addiu $sp, $sp, -48                    # Reserva area de argumentos, buffer de 16 bytes e retorno.
    sw $ra, 44($sp)                        # Guarda o retorno antes de chamar o escritor.
    move $t6, $a1                          # Mantem o endereco do escritor durante a conversao.
    move $t0, $a0                          # Copia o numero positivo a converter.
    li $t1, 10                             # Define a base decimal.
    addiu $t2, $sp, 31                     # Seleciona o fim do buffer depois da area de argumentos.
    sb $zero, 0($t2)                       # Inicializa o terminador nulo do numero.
infoAp_numeroDigito:                       # Produz um digito por divisao inteira.
    divu $t0, $t1                          # Divide o numero por dez.
    mfhi $t3                               # Recupera o resto correspondente ao proximo digito.
    mflo $t0                               # Mantem o quociente para a proxima iteracao.
    addiu $t3, $t3, 48                     # Converte o digito para seu caractere ASCII.
    addiu $t2, $t2, -1                     # Recua no buffer para escrever na ordem correta.
    sb $t3, 0($t2)                         # Grava o caractere decimal.
    bne $t0, $zero, infoAp_numeroDigito    # Repete ate converter todos os digitos.
    nop                                    # Protege o delay slot do desvio.
    move $a0, $t2                          # Fornece o inicio do texto decimal produzido.
    jalr $t6                               # Imprime o identificador pelo escritor selecionado.
    nop                                    # Protege o delay slot da chamada.
    lw $ra, 44($sp)                        # Recupera o retorno depois da chamada.
    addiu $sp, $sp, 48                     # Libera o buffer e o frame da conversao.
    jr $ra                                 # Retorna a consulta.
    nop                                    # Protege o delay slot do retorno.

# Escritor opcional: a0 aponta para uma string terminada em zero.
# Requer Display MMIO conectado e disponivel. Nao depende do exemplo MMIO.asm.
# Preserva argumentos, registradores salvos e pilha; modifica apenas t0-t3.
infoAp_escreverMMIO:                       # Envia uma string ao Display MMIO do MARS.
    move $t0, $a0                          # Percorre a string sem alterar o argumento original.
    li $t1, 0xFFFF0008                     # Seleciona o registrador de controle do display.
infoAp_mmioCaractere:                      # Seleciona o proximo caractere da string.
    lbu $t2, 0($t0)                        # Le o caractere atual.
    beq $t2, $zero, infoAp_mmioFim         # Finaliza sem enviar o terminador nulo.
    nop                                    # Protege o delay slot do desvio.
infoAp_mmioAguardar:                       # Aguarda o display indicar disponibilidade no bit zero.
    lw $t3, 0($t1)                         # Le o registrador de controle do display.
    andi $t3, $t3, 1                       # Isola o bit de disponibilidade.
    beq $t3, $zero, infoAp_mmioAguardar    # Continua aguardando enquanto o display estiver ocupado.
    nop                                    # Protege o delay slot do desvio.
    sw $t2, 4($t1)                         # Envia o caractere ao registrador de dados 0xFFFF000C.
    addiu $t0, $t0, 1                      # Avanca para o proximo caractere da string.
    j infoAp_mmioCaractere                 # Continua a impressao pelo display.
    nop                                    # Protege o delay slot do salto.
infoAp_mmioFim:                            # Finaliza a escrita da string.
    jr $ra                                 # Retorna ao chamador do escritor.
    nop                                    # Protege o delay slot do retorno.
