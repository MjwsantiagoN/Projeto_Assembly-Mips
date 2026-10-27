# Grupo: Brenno, Joao, Leticia e Marcos
# Projeto 01 - 1VA - Arquitetura e Organizacao de Computadores - 2026.2
# Teste infoAp --all: ordem inversa na memoria, texto, erros e preservacao.
.data                                      # Inicia os dados do teste.
ta_caso: .word 0                           # Identifica o cenario.
ta_proximo: .word 0                        # Guarda o descritor seguinte.
ta_passo: .word 0                          # Guarda o passo.
ta_modo: .word 0                           # Seleciona a preparacao.
ta_esperado: .word 0                       # Guarda o texto esperado.
ta_status: .word 0                         # Guarda o status esperado.
ta_pilha: .word 0                          # Guarda a posicao da pilha.
ta_saidaPos: .word 0                       # Conta os caracteres capturados.
ta_argumentos: .space 16                   # Guarda os quatro argumentos.
ta_contexto: .space 32                     # Guarda os oito salvos.
ta_guardaAntes: .word 0x13579BDF           # Protege o inicio da tabela.
ta_tabela: .space 12288                    # Reserva ate 24 registros de 512 bytes.
ta_guardaDepois: .word 0x2468ACE0          # Protege o fim da tabela.
ta_snapshot: .space 12288                  # Guarda a tabela antes da consulta.
ta_saidaAntes: .word 0x1234ABCD            # Protege o inicio da captura.
ta_saida: .space 4096                      # Guarda a saida completa.
ta_saidaDepois: .word 0x5678DCBA           # Protege o fim da captura.
ta_vazio: .asciiz "AP: 101\nApartamento vazio\nAP: 102\nApartamento vazio\nAP: 201\nApartamento vazio\nAP: 202\nApartamento vazio\nAP: 301\nApartamento vazio\nAP: 302\nApartamento vazio\nAP: 401\nApartamento vazio\nAP: 402\nApartamento vazio\nAP: 501\nApartamento vazio\nAP: 502\nApartamento vazio\nAP: 601\nApartamento vazio\nAP: 602\nApartamento vazio\nAP: 701\nApartamento vazio\nAP: 702\nApartamento vazio\nAP: 801\nApartamento vazio\nAP: 802\nApartamento vazio\nAP: 901\nApartamento vazio\nAP: 902\nApartamento vazio\nAP: 1001\nApartamento vazio\nAP: 1002\nApartamento vazio\nAP: 1101\nApartamento vazio\nAP: 1102\nApartamento vazio\nAP: 1201\nApartamento vazio\nAP: 1202\nApartamento vazio\n"# Define uma mensagem ou referencia completa.
ta_misto: .asciiz "AP: 101\nMoradores:\nAna\nAP: 102\nApartamento vazio\nAP: 201\nApartamento vazio\nAP: 202\nApartamento vazio\nAP: 301\nApartamento vazio\nAP: 302\nApartamento vazio\nAP: 401\nApartamento vazio\nAP: 402\nApartamento vazio\nAP: 501\nApartamento vazio\nAP: 502\nApartamento vazio\nAP: 601\nApartamento vazio\nAP: 602\nApartamento vazio\nAP: 701\nApartamento vazio\nAP: 702\nApartamento vazio\nAP: 801\nApartamento vazio\nAP: 802\nApartamento vazio\nAP: 901\nApartamento vazio\nAP: 902\nApartamento vazio\nAP: 1001\nApartamento vazio\nAP: 1002\nApartamento vazio\nAP: 1101\nApartamento vazio\nAP: 1102\nApartamento vazio\nAP: 1201\nApartamento vazio\nAP: 1202\nApartamento vazio\n"# Define uma mensagem ou referencia completa.
ta_erroAP: .asciiz "Falha: AP invalido\n"  # Define uma mensagem ou referencia completa.
ta_erroDados: .asciiz "Falha: dados do AP invalidos\n"# Define uma mensagem ou referencia completa.
ta_pass: .asciiz "PASS: infoAp_listarTodos (8 cenarios)\n"# Define uma mensagem ou referencia completa.
ta_fail: .asciiz "FAIL: infoAp_listarTodos, cenario "# Define uma mensagem ou referencia completa.
ta_nl: .asciiz "\n"                        # Define uma mensagem ou referencia completa.
.align 2                                   # Alinha os descritores.
ta_casos:                                  # Cada linha tem passo, modo, texto e status.
.word 512, 0, ta_vazio, 0                  # Todos vazios, com registros invertidos.
.word 448, 0, ta_vazio, 0                  # Passo compacto e registros invertidos.
.word 512, 1, ta_misto, 0                  # Primeiro AP ocupado, demais vazios.
.word 512, 2, ta_erroAP, 0xFFFFFFFF                # Base nula.
.word 444, 3, ta_erroAP, 0xFFFFFFFF                # Passo insuficiente.
.word 450, 3, ta_erroAP, 0xFFFFFFFF                # Passo desalinhado.
.word 512, 4, ta_erroAP, 0xFFFFFFFF                # Primeiro ID ausente.
.word 512, 5, ta_erroDados, 0xFFFFFFFE             # Contador invalido no primeiro ID.
.text                                      # Inicia o teste.
.globl main                                # Exporta a entrada.
main:                                      # Prepara o primeiro descritor.
la $t0, ta_casos                           # Seleciona o primeiro cenario.
sw $t0, ta_proximo                         # Guarda o descritor.
li $t0, 1                                  # Comeca pelo primeiro cenario.
sw $t0, ta_caso                            # Guarda o numero.
ta_casoLoop:                               # Carrega os parametros.
lw $t0, ta_proximo                         # Seleciona o descritor atual.
lw $t1, 0($t0)                             # Le o parametro.
sw $t1, ta_passo                           # Guarda para conferir depois.
lw $t1, 4($t0)                             # Le o parametro.
sw $t1, ta_modo                            # Guarda para conferir depois.
lw $t1, 8($t0)                             # Le o parametro.
sw $t1, ta_esperado                        # Guarda para conferir depois.
lw $t1, 12($t0)                            # Le o parametro.
sw $t1, ta_status                          # Guarda para conferir depois.
addiu $t0, $t0, 16                         # Avanca um descritor.
sw $t0, ta_proximo                         # Guarda o proximo.
la $t0, ta_tabela                          # Seleciona a reserva.
li $t1, 3072                               # Conta as words.
ta_zerar:                                  # Reinicia a memoria entre os casos.
sw $zero, 0($t0)                           # Zera uma word.
addiu $t0, $t0, 4                          # Avanca na reserva.
addiu $t1, $t1, -1                         # Diminui o restante.
bne $t1, $zero, ta_zerar                   # Limpa a reserva inteira.
nop                                        # Protege o atraso.
la $s0, ta_tabela                          # Aponta para o primeiro registro.
li $s1, 23                                 # Comeca pelo ID numerico maior.
lw $s2, ta_passo                           # Seleciona o passo.
lw $t0, ta_modo                            # Seleciona o modo.
li $t1, 3                                  # Marca o teste com passo invalido.
bne $t0, $t1, ta_criar                     # Nos demais casos usa o passo recebido.
nop                                        # Protege o atraso.
li $s2, 512                                # Cria dados validos antes de passar o passo invalido.
ta_criar:                                  # Cria os IDs em ordem fisica inversa.
li $t0, 2                                  # Dois apartamentos por andar.
divu $s1, $t0                              # Separa andar e lado.
mflo $t1                                   # Recebe andar menos um.
mfhi $t2                                   # Recebe lado menos um.
addiu $t1, $t1, 1                          # Conta andares desde um.
mul $t1, $t1, 100                          # Forma as centenas.
addiu $t2, $t2, 1                          # Conta os lados desde um.
addu $t1, $t1, $t2                         # Forma o ID.
sw $t1, 0($s0)                             # Guarda o ID.
move $t5, $s0                              # Ao terminar, mantem o endereco do AP 101.
addu $s0, $s0, $s2                         # Avanca um registro.
addiu $s1, $s1, -1                         # Seleciona o ID anterior.
bgez $s1, ta_criar                         # Cria os 24 registros.
nop                                        # Protege o atraso.
lw $t0, ta_modo                            # Le o modo da preparacao.
li $t1, 1                                  # Seleciona primeiro AP ocupado.
bne $t0, $t1, ta_semNome                   # Nao cadastra nos outros casos.
nop                                        # Protege o atraso.
li $t1, 1                                  # Um morador.
sw $t1, 4($t5)                             # Marca o AP como ocupado.
li $t1, 65                                 # ASCII A.
sb $t1, 8($t5)                             # Guarda a primeira letra.
li $t1, 110                                # ASCII n.
sb $t1, 9($t5)                             # Guarda a segunda letra.
li $t1, 97                                 # ASCII a.
sb $t1, 10($t5)                            # Guarda a terceira letra.
ta_semNome:                                # Pode remover o ID esperado.
li $t1, 4                                  # Seleciona ID ausente.
bne $t0, $t1, ta_comID                     # Nao remove nos demais casos.
nop                                        # Protege o atraso.
li $t1, 9999                               # Define um ID diferente de 101.
sw $t1, 0($t5)                             # Retira 101 da tabela.
ta_comID:                                  # Pode injetar contador invalido.
li $t1, 5                                  # Seleciona contador fora do limite.
bne $t0, $t1, ta_copiarInicio              # Nao corrompe nos outros casos.
nop                                        # Protege o atraso.
li $t1, 7                                  # Mais de seis moradores.
sw $t1, 4($t5)                             # Injeta o erro no AP 101.
ta_copiarInicio:                           # Guarda toda a memoria antes da consulta.
la $t0, ta_tabela                          # Seleciona a origem.
la $t1, ta_snapshot                        # Seleciona a copia.
li $t2, 3072                               # Conta as words.
ta_copiar:                                 # Copia uma word por vez.
lw $t3, 0($t0)                             # Le uma word.
sw $t3, 0($t1)                             # Guarda a referencia.
addiu $t0, $t0, 4                          # Avanca a origem.
addiu $t1, $t1, 4                          # Avanca a copia.
addiu $t2, $t2, -1                         # Conta o restante.
bne $t2, $zero, ta_copiar                  # Copia os 12288 bytes.
nop                                        # Protege o atraso.
sw $zero, ta_saidaPos                      # Reinicia a captura.
sb $zero, ta_saida                         # Inicia string vazia.
la $a0, ta_tabela                          # Fornece a tabela.
lw $a1, ta_passo                           # Fornece o passo.
li $a2, 222                                # Marca argumento nao utilizado.
li $a3, 333                                # Marca argumento nao utilizado.
lw $t0, ta_modo                            # Seleciona o modo.
li $t1, 2                                  # Seleciona base nula.
bne $t0, $t1, ta_argumentosProntos         # Preserva a base nos demais casos.
nop                                        # Protege o atraso.
move $a0, $zero                            # Injeta o parametro nulo.
ta_argumentosProntos:                      # Guarda o contexto esperado.
sw $a0, ta_argumentos+0                    # Guarda o argumento.
sw $a1, ta_argumentos+4                    # Guarda o argumento.
sw $a2, ta_argumentos+8                    # Guarda o argumento.
sw $a3, ta_argumentos+12                   # Guarda o argumento.
li $s0, 1000                               # Marca um registrador salvo.
sw $s0, ta_contexto+0                      # Guarda seu valor esperado.
li $s1, 1001                               # Marca um registrador salvo.
sw $s1, ta_contexto+4                      # Guarda seu valor esperado.
li $s2, 1002                               # Marca um registrador salvo.
sw $s2, ta_contexto+8                      # Guarda seu valor esperado.
li $s3, 1003                               # Marca um registrador salvo.
sw $s3, ta_contexto+12                     # Guarda seu valor esperado.
li $s4, 1004                               # Marca um registrador salvo.
sw $s4, ta_contexto+16                     # Guarda seu valor esperado.
li $s5, 1005                               # Marca um registrador salvo.
sw $s5, ta_contexto+20                     # Guarda seu valor esperado.
li $s6, 1006                               # Marca um registrador salvo.
sw $s6, ta_contexto+24                     # Guarda seu valor esperado.
li $s7, 1007                               # Marca um registrador salvo.
sw $s7, ta_contexto+28                     # Guarda seu valor esperado.
sw $sp, ta_pilha                           # Guarda a pilha.
jal infoAp_listarTodos                     # Executa a listagem real.
nop                                        # Protege o atraso.
lw $t0, ta_argumentos+0                    # Recupera a marca esperada.
bne $a0, $t0, ta_falha                     # Exige preservacao.
nop                                        # Protege o atraso.
lw $t0, ta_argumentos+4                    # Recupera a marca esperada.
bne $a1, $t0, ta_falha                     # Exige preservacao.
nop                                        # Protege o atraso.
lw $t0, ta_argumentos+8                    # Recupera a marca esperada.
bne $a2, $t0, ta_falha                     # Exige preservacao.
nop                                        # Protege o atraso.
lw $t0, ta_argumentos+12                   # Recupera a marca esperada.
bne $a3, $t0, ta_falha                     # Exige preservacao.
nop                                        # Protege o atraso.
lw $t0, ta_contexto+0                      # Recupera a marca esperada.
bne $s0, $t0, ta_falha                     # Exige preservacao.
nop                                        # Protege o atraso.
lw $t0, ta_contexto+4                      # Recupera a marca esperada.
bne $s1, $t0, ta_falha                     # Exige preservacao.
nop                                        # Protege o atraso.
lw $t0, ta_contexto+8                      # Recupera a marca esperada.
bne $s2, $t0, ta_falha                     # Exige preservacao.
nop                                        # Protege o atraso.
lw $t0, ta_contexto+12                     # Recupera a marca esperada.
bne $s3, $t0, ta_falha                     # Exige preservacao.
nop                                        # Protege o atraso.
lw $t0, ta_contexto+16                     # Recupera a marca esperada.
bne $s4, $t0, ta_falha                     # Exige preservacao.
nop                                        # Protege o atraso.
lw $t0, ta_contexto+20                     # Recupera a marca esperada.
bne $s5, $t0, ta_falha                     # Exige preservacao.
nop                                        # Protege o atraso.
lw $t0, ta_contexto+24                     # Recupera a marca esperada.
bne $s6, $t0, ta_falha                     # Exige preservacao.
nop                                        # Protege o atraso.
lw $t0, ta_contexto+28                     # Recupera a marca esperada.
bne $s7, $t0, ta_falha                     # Exige preservacao.
nop                                        # Protege o atraso.
lw $t0, ta_pilha                           # Recupera a pilha.
bne $sp, $t0, ta_falha                     # Exige equilibrio da pilha.
nop                                        # Protege o atraso.
lw $t0, ta_status                          # Le o retorno esperado.
bne $v0, $t0, ta_falha                     # Exige status correto.
nop                                        # Protege o atraso.
bne $v0, $zero, ta_erroRetorno             # Confere mensagem nos erros.
nop                                        # Protege o atraso.
li $t0, 24                                 # Espera 24 apartamentos.
bne $v1, $t0, ta_falha                     # Exige o total no sucesso.
nop                                        # Protege o atraso.
j ta_conferirTexto                         # Segue para o texto.
nop                                        # Protege o atraso.
ta_erroRetorno:                            # Confere a mensagem apontada por v1.
move $a0, $v1                              # Seleciona a mensagem retornada.
la $a1, ta_erroAP                          # Assume erro de AP.
li $t0, -2                                 # Identifica dados invalidos.
bne $v0, $t0, ta_compararErro              # Mantem erro de AP nos outros casos.
nop                                        # Protege o atraso.
la $a1, ta_erroDados                       # Seleciona erro de dados.
ta_compararErro:                           # Compara a mensagem inteira.
jal ta_compararStrings                     # Compara caracteres e terminador.
nop                                        # Protege o atraso.
bne $v0, $zero, ta_falha                   # Exige mensagem correta.
nop                                        # Protege o atraso.
ta_conferirTexto:                          # Confere todas as linhas produzidas.
la $a0, ta_saida                           # Seleciona a captura.
lw $a1, ta_esperado                        # Seleciona o texto esperado.
jal ta_compararStrings                     # Compara a saida inteira.
nop                                        # Protege o atraso.
bne $v0, $zero, ta_falha                   # Detecta falta, excesso ou ordem errada.
nop                                        # Protege o atraso.
la $t0, ta_tabela                          # Seleciona a tabela atual.
la $t1, ta_snapshot                        # Seleciona a copia anterior.
li $t2, 3072                               # Confere toda a reserva.
ta_memoria:                                # Exige somente leitura.
lw $t3, 0($t0)                             # Le a word atual.
lw $t4, 0($t1)                             # Le a referencia.
bne $t3, $t4, ta_falha                     # Detecta escrita indevida.
nop                                        # Protege o atraso.
addiu $t0, $t0, 4                          # Avanca na tabela.
addiu $t1, $t1, 4                          # Avanca na referencia.
addiu $t2, $t2, -1                         # Conta o restante.
bne $t2, $zero, ta_memoria                 # Confere as 3072 words.
nop                                        # Protege o atraso.
lw $t0, ta_guardaAntes                     # Le a sentinela.
li $t1, 0x13579BDF                         # Define a marca esperada.
bne $t0, $t1, ta_falha                     # Protege os limites.
nop                                        # Protege o atraso.
lw $t0, ta_guardaDepois                    # Le a sentinela.
li $t1, 0x2468ACE0                         # Define a marca esperada.
bne $t0, $t1, ta_falha                     # Protege os limites.
nop                                        # Protege o atraso.
lw $t0, ta_saidaAntes                      # Le a sentinela.
li $t1, 0x1234ABCD                         # Define a marca esperada.
bne $t0, $t1, ta_falha                     # Protege os limites.
nop                                        # Protege o atraso.
lw $t0, ta_saidaDepois                     # Le a sentinela.
li $t1, 0x5678DCBA                         # Define a marca esperada.
bne $t0, $t1, ta_falha                     # Protege os limites.
nop                                        # Protege o atraso.
lw $t0, ta_caso                            # Le o numero do caso.
addiu $t0, $t0, 1                          # Avanca um caso.
sw $t0, ta_caso                            # Guarda o numero.
li $t1, 9                                  # Depois do oitavo, termina.
bne $t0, $t1, ta_casoLoop                  # Executa os oito casos.
nop                                        # Protege o atraso.
la $a0, ta_pass                            # Seleciona o sucesso.
li $v0, 4                                  # Mostra texto apenas no teste.
syscall                                    # Mostra PASS.
move $a0, $zero                            # Define codigo zero.
li $v0, 17                                 # Encerra com codigo.
syscall                                    # Termina o teste.
ap_imprimirTexto:                        # No teste, guarda o texto no buffer em vez de acessar MMIO.
    move $t0, $a0                        # Percorre uma copia do endereco, preservando o argumento.
    move $t4, $a1                        # Usa uma copia do limite.
    sw $a0, 0($sp)                       # Exercita a area de argumentos reservada pelo chamador.
    sw $a1, 4($sp)                       # Exercita a area de argumentos reservada pelo chamador.
    sw $a2, 8($sp)                       # Exercita a area de argumentos reservada pelo chamador.
    sw $a3, 12($sp)                      # Exercita a area de argumentos reservada pelo chamador.
ta_imprimirProximo:                      # Seleciona um caractere solicitado pela consulta.
    lbu $t2, 0($t0)                      # Le o caractere atual.
    beq $t2, $zero, ta_imprimirFim       # Finaliza ao encontrar o terminador.
    nop                                  # Nao faz trabalho no atraso deste desvio.
    lw $t3, ta_saidaPos                  # Le quantos caracteres foram guardados.
    li $t1, 4095                         # Reserva o ultimo byte para o terminador.
    bge $t3, $t1, ta_falha               # Detecta texto maior que o buffer.
    nop                                  # Nao faz trabalho no atraso deste desvio.
    la $t1, ta_saida                     # Seleciona o inicio da captura.
    addu $t1, $t1, $t3                   # Localiza a posicao seguinte.
    sb $t2, 0($t1)                       # Guarda o caractere que seria mostrado.
    sb $zero, 1($t1)                     # Mantem a captura terminada em zero.
    addiu $t3, $t3, 1                    # Atualiza o total guardado.
    sw $t3, ta_saidaPos                  # Guarda o tamanho atualizado.
    addiu $t0, $t0, 1                    # Avanca no texto original.
    beq $a1, $zero, ta_imprimirProximo   # Limite zero permite continuar ate o terminador.
    nop                                  # Nao faz trabalho no atraso deste desvio.
    addiu $t4, $t4, -1                   # Desconta um caractere do limite.
    bne $t4, $zero, ta_imprimirProximo   # Continua enquanto ainda pode imprimir caracteres.
    nop                                  # Nao faz trabalho no atraso deste desvio.
ta_imprimirFim:                          # Preserva argumentos, salvos e pilha, como a saida real.
    li $t0, 100                          # Altera $t0 para verificar que o chamador nao depende dele.
    li $t1, 101                          # Altera $t1 para verificar que o chamador nao depende dele.
    li $t2, 102                          # Altera $t2 para verificar que o chamador nao depende dele.
    li $t3, 103                          # Altera $t3 para verificar que o chamador nao depende dele.
    li $t4, 104                          # Altera $t4 para verificar que o chamador nao depende dele.
    li $t5, 105                          # Altera $t5 para verificar que o chamador nao depende dele.
    li $t6, 106                          # Altera $t6 para verificar que o chamador nao depende dele.
    li $t7, 107                          # Altera $t7 para verificar que o chamador nao depende dele.
    li $t8, 108                          # Altera $t8 para verificar que o chamador nao depende dele.
    li $t9, 109                          # Altera $t9 para verificar que o chamador nao depende dele.
    li $v0, 300                          # Altera um retorno temporario.
    li $v1, 301                          # Altera o outro retorno temporario.
    multu $t0, $t1                       # Altera HI e LO, que tambem sao temporarios.
    jr $ra                               # Volta para a consulta.
    nop                                  # Nao faz trabalho no atraso deste retorno.

ta_compararStrings:                      # Compara textos sem chamar as rotinas do projeto.
    lbu $t0, 0($a0)                      # Le um byte do texto real.
    lbu $t1, 0($a1)                      # Le um byte do texto esperado.
    bne $t0, $t1, ta_stringsDiferentes   # Identifica uma divergencia.
    nop                                  # Nao faz trabalho no atraso do salto.
    beq $t0, $zero, ta_stringsIguais     # Finaliza quando ambos chegam ao terminador.
    nop                                  # Nao faz trabalho no atraso do salto.
    addiu $a0, $a0, 1                    # Avanca no texto real.
    addiu $a1, $a1, 1                    # Avanca no texto esperado.
    j ta_compararStrings                 # Continua a comparacao integral.
    nop                                  # Nao faz trabalho no atraso do salto.
ta_stringsDiferentes:                    # Retorna divergencia.
    li $v0, 1                            # Informa que os textos diferem.
    jr $ra                               # Retorna ao verificador.
    nop                                  # Nao faz trabalho no atraso do salto.
ta_stringsIguais:                        # Retorna igualdade.
    move $v0, $zero                      # Informa que os textos sao identicos.
    jr $ra                               # Retorna ao verificador.
    nop                                  # Nao faz trabalho no atraso do salto.

ta_falha:                                # Encerra ao encontrar qualquer resultado incorreto.
    la $a0, ta_fail                      # Seleciona a mensagem de falha.
    li $v0, 4                            # Seleciona impressao de string.
    syscall                              # Informa a falha.
    lw $a0, ta_caso                      # Recupera o cenario fora dos salvos em teste.
    li $v0, 1                            # Seleciona impressao de inteiro.
    syscall                              # Identifica o cenario.
    la $a0, ta_nl                        # Seleciona a quebra de linha.
    li $v0, 4                            # Seleciona impressao de string.
    syscall                              # Finaliza a mensagem.
    li $a0, 1                            # Define codigo de falha.
    li $v0, 17                           # Seleciona encerramento com codigo.
    syscall                              # Encerra o teste com falha.


.include "../src/apartamento/infoAp.asm" # Inclui a consulta individual.
.include "../src/apartamento/infoApTodos.asm" # Inclui a listagem completa.

