# Grupo: Brenno, Joao, Leticia e Marcos
# Projeto 01 - 1VA - Arquitetura e Organizacao de Computadores - 2026.2
# Arquivo: comandosAp.asm
# Interpreta somente limparAp --AP, infoAp --AP e infoAp --all.
# Entrada: a0 aponta para a linha terminada em zero, sem a quebra de linha.
# Saida: v0 = 0 no sucesso, -1 AP invalido, -2 dados invalidos, -3 comando invalido.
# Preserva argumentos e registradores salvos. Usa a tabela ap_tabela.
# Requer tabelaAp, limparAp, infoAp, infoApTodos e ap_imprimirTexto.
.data                                       # Inicia as mensagens e os prefixos.
ap_prefixoLimpar: .asciiz "limparAp --"     # Prefixo exato do comando de limpeza.
ap_prefixoInfo: .asciiz "infoAp --"         # Prefixo exato do comando de consulta.
ap_comandoInvalido: .asciiz "Comando invalido\n"# Mensagem exigida para comando desconhecido.
ap_parametroInvalido: .asciiz "Falha: AP invalido\n"# Mensagem de argumento invalido.
.text                                       # Inicia as instrucoes do interpretador.
.globl ap_executarLinha                     # Exporta a entrada dos comandos.
ap_executarLinha:                           # Guarda os valores que modifica durante as chamadas.
addiu $sp, $sp, -40                         # Reserva dados e area de argumentos.
sw $ra, 36($sp)                             # Guarda o retorno do chamador.
sw $s0, 32($sp)                             # Preserva o registrador usado para a linha.
sw $a0, 28($sp)                             # Guarda a linha original.
sw $a1, 24($sp)                             # Guarda a1.
sw $a2, 20($sp)                             # Guarda a2.
move $s0, $a0                               # Mantem a linha para a segunda tentativa.
la $a1, ap_prefixoLimpar                    # Seleciona o prefixo de limpeza.
jal ap_testarPrefixo                        # Procura o prefixo exato no inicio da linha.
nop                                         # Protege o atraso da chamada.
beq $v0, $zero, ap_tentarInfo               # Se nao coincide, tenta o comando de consulta.
nop                                         # Protege o atraso do desvio.
move $a0, $v0                               # Seleciona o texto depois de limparAp --.
jal ap_lerNumero                            # Converte e valida o numero do AP.
nop                                         # Protege o atraso da chamada.
bltz $v0, ap_erroParametro                  # Nao executa a limpeza com numero invalido.
nop                                         # Protege o atraso do desvio.
move $a1, $v0                               # Fornece o numero convertido.
la $a0, ap_tabela                           # Fornece a tabela compartilhada desta integracao.
li $a2, APARTAMENTO_PASSO                   # Fornece a distancia entre registros.
jal limparAp_executar                       # Limpa moradores e veiculos do AP.
nop                                         # Protege o atraso da chamada.
beq $v0, $zero, ap_linhaRetornar            # Em sucesso, nao precisa mostrar mensagem.
nop                                         # Protege o atraso do desvio.
move $a0, $v1                               # Seleciona a mensagem de erro retornada pela limpeza.
li $a1, 0                                   # Imprime a mensagem ate o terminador.
jal ap_imprimirTexto                        # Mostra o erro pelo display.
nop                                         # Protege o atraso da chamada.
li $v0, -1                                  # Retorna o status de AP invalido.
j ap_linhaRetornar                          # Restaura o contexto.
nop                                         # Protege o atraso do salto.
ap_tentarInfo:                              # Tenta reconhecer o comando de consulta.
move $a0, $s0                               # Recupera o inicio da linha.
la $a1, ap_prefixoInfo                      # Seleciona o prefixo de consulta.
jal ap_testarPrefixo                        # Procura infoAp -- no inicio da linha.
nop                                         # Protege o atraso da chamada.
beq $v0, $zero, ap_erroComando              # Nenhum prefixo conhecido foi encontrado.
nop                                         # Protege o atraso do desvio.
move $a0, $v0                               # Seleciona o argumento depois do prefixo.
lbu $t0, 0($a0)                             # Le o primeiro caractere do argumento.
li $t1, 97                                  # ASCII de a.
bne $t0, $t1, ap_infoNumero                 # Se nao comeca com a, tenta numero.
nop                                         # Protege o atraso do desvio.
lbu $t0, 1($a0)                             # Le o segundo caractere.
li $t1, 108                                 # ASCII de l.
bne $t0, $t1, ap_erroParametro              # Exige a segunda letra de all.
nop                                         # Protege o atraso do desvio.
lbu $t0, 2($a0)                             # Le o terceiro caractere.
bne $t0, $t1, ap_erroParametro              # Exige a terceira letra de all.
nop                                         # Protege o atraso do desvio.
lbu $t0, 3($a0)                             # Le o caractere depois de all.
bne $t0, $zero, ap_erroParametro            # Exige que all seja o argumento completo.
nop                                         # Protege o atraso do desvio.
la $a0, ap_tabela                           # Fornece a tabela.
li $a1, APARTAMENTO_PASSO                   # Fornece o passo.
jal infoAp_listarTodos                      # Mostra os 24 APs em ordem.
nop                                         # Protege o atraso da chamada.
j ap_linhaRetornar                          # Retorna o resultado da listagem.
nop                                         # Protege o atraso do salto.
ap_infoNumero:                              # Consulta um AP especifico.
jal ap_lerNumero                            # Valida andar, lado e caracteres.
nop                                         # Protege o atraso da chamada.
bltz $v0, ap_erroParametro                  # Rejeita numero invalido.
nop                                         # Protege o atraso do desvio.
move $a1, $v0                               # Fornece o numero convertido.
la $a0, ap_tabela                           # Fornece a tabela.
li $a2, APARTAMENTO_PASSO                   # Fornece o passo.
jal infoAp_executar                         # Mostra os dados do AP.
nop                                         # Protege o atraso da chamada.
j ap_linhaRetornar                          # Retorna o resultado da consulta.
nop                                         # Protege o atraso do salto.
ap_erroComando:                             # Trata uma linha sem comando reconhecido.
la $a0, ap_comandoInvalido                  # Seleciona a mensagem de comando.
li $a1, 0                                   # Usa texto terminado em zero.
jal ap_imprimirTexto                        # Mostra a mensagem.
nop                                         # Protege o atraso da chamada.
li $v0, -3                                  # Identifica comando desconhecido ou sintaxe sem prefixo.
j ap_linhaRetornar                          # Restaura o contexto.
nop                                         # Protege o atraso do salto.
ap_erroParametro:                           # Trata o argumento de AP invalido.
la $a0, ap_parametroInvalido                # Seleciona a mensagem de AP.
li $a1, 0                                   # Usa texto terminado em zero.
jal ap_imprimirTexto                        # Mostra a mensagem.
nop                                         # Protege o atraso da chamada.
li $v0, -1                                  # Identifica AP invalido.
ap_linhaRetornar:                           # Recupera os dados guardados antes das chamadas.
lw $a2, 20($sp)                             # Recupera a2.
lw $a1, 24($sp)                             # Recupera a1.
lw $a0, 28($sp)                             # Recupera a linha original.
lw $s0, 32($sp)                             # Recupera o valor anterior de s0.
lw $ra, 36($sp)                             # Recupera o retorno.
addiu $sp, $sp, 40                          # Libera todo o espaco reservado.
jr $ra                                      # Retorna ao shell.
nop                                         # Protege o atraso do retorno.

# Auxiliar interna: compara a0 com o prefixo a1, sem alterar as strings.
# Retorna em v0 o endereco apos o prefixo, ou zero se nao coincidir.
ap_testarPrefixo:                           # Compara um caractere por repeticao.
move $t0, $a0                               # Copia o endereco da linha.
move $t1, $a1                               # Copia o endereco do prefixo.
ap_prefixoLoop:                             # Seleciona os caracteres atuais.
lbu $t2, 0($t1)                             # Le o prefixo.
beq $t2, $zero, ap_prefixoSucesso           # Fim do prefixo significa correspondencia.
nop                                         # Protege o atraso do desvio.
lbu $t3, 0($t0)                             # Le a linha.
bne $t2, $t3, ap_prefixoFalha               # Caracteres diferentes encerram a tentativa.
nop                                         # Protege o atraso do desvio.
addiu $t0, $t0, 1                           # Avanca na linha.
addiu $t1, $t1, 1                           # Avanca no prefixo.
j ap_prefixoLoop                            # Compara o proximo caractere.
nop                                         # Protege o atraso do salto.
ap_prefixoSucesso:                          # Devolve onde comeca o argumento.
move $v0, $t0                               # Retorna o endereco apos o prefixo.
jr $ra                                      # Volta ao interpretador.
nop                                         # Protege o atraso do retorno.
ap_prefixoFalha:                            # Informa que o prefixo nao coincide.
move $v0, $zero                             # Retorna zero.
jr $ra                                      # Volta ao interpretador.
nop                                         # Protege o atraso do retorno.

# Auxiliar interna: aceita 3 ou 4 digitos, andar 1..12 e lado 01 ou 02.
# Rejeita sinal, espacos, zeros iniciais, argumento extra e mais de quatro digitos.
ap_lerNumero:                               # Converte o texto do AP para inteiro.
move $t0, $a0                               # Percorre uma copia do argumento.
li $t1, 0                                   # Inicia o valor acumulado.
li $t2, 0                                   # Inicia o contador de digitos.
lbu $t3, 0($t0)                             # Le o primeiro caractere.
li $t4, 48                                  # ASCII do zero.
beq $t3, $t4, ap_numeroFalha                # Rejeita zero inicial.
nop                                         # Protege o atraso do desvio.
ap_numeroLoop:                              # Converte um digito por repeticao.
lbu $t3, 0($t0)                             # Le o caractere atual.
beq $t3, $zero, ap_numeroValidar            # Ao terminar o texto, confere o intervalo.
nop                                         # Protege o atraso do desvio.
addiu $t3, $t3, -48                         # Converte ASCII para valor numerico.
sltiu $t4, $t3, 10                          # Aceita somente valores de zero a nove.
beq $t4, $zero, ap_numeroFalha              # Rejeita letras, sinais e espacos.
nop                                         # Protege o atraso do desvio.
addiu $t2, $t2, 1                           # Conta mais um digito.
slti $t4, $t2, 5                            # No maximo quatro digitos.
beq $t4, $zero, ap_numeroFalha              # Interrompe antes de acumular numeros longos.
nop                                         # Protege o atraso do desvio.
mul $t1, $t1, 10                            # Abre uma casa decimal.
addu $t1, $t1, $t3                          # Acrescenta o novo digito.
addiu $t0, $t0, 1                           # Avanca no texto.
j ap_numeroLoop                             # Continua ate o terminador.
nop                                         # Protege o atraso do salto.
ap_numeroValidar:                           # Confere o andar e o lado.
slti $t4, $t2, 3                            # Exige pelo menos tres digitos.
bne $t4, $zero, ap_numeroFalha              # Rejeita texto curto ou vazio.
nop                                         # Protege o atraso do desvio.
li $t4, 100                                 # Separa andar e final do numero.
divu $t1, $t4                               # Divide por cem.
mflo $t3                                    # O quociente e o andar.
mfhi $t4                                    # O resto e o lado.
addiu $t3, $t3, -1                          # Transforma andares validos em 0..11.
sltiu $t5, $t3, 12                          # Verifica os doze andares.
beq $t5, $zero, ap_numeroFalha              # Rejeita andar fora do condominio.
nop                                         # Protege o atraso do desvio.
addiu $t4, $t4, -1                          # Transforma lados validos em 0..1.
sltiu $t5, $t4, 2                           # Verifica os dois apartamentos por andar.
beq $t5, $zero, ap_numeroFalha              # Rejeita finais diferentes de 01 e 02.
nop                                         # Protege o atraso do desvio.
move $v0, $t1                               # Retorna o numero validado.
jr $ra                                      # Volta ao interpretador.
nop                                         # Protege o atraso do retorno.
ap_numeroFalha:                             # Retorna erro de conversao ou intervalo.
li $v0, -1                                  # Marca o AP como invalido.
jr $ra                                      # Volta ao interpretador.
nop                                         # Protege o atraso do retorno.
