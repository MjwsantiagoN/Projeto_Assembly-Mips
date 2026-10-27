# Grupo: Brenno, Joao, Leticia e Marcos
# Projeto 01 - 1VA - Arquitetura e Organizacao de Computadores - 2026.2
# Teste dos comandos de apartamentos usando a tabela real da integracao.
.data                                       # Dados exclusivos do teste.
tc_idCaso: .word 0                          # Controle do cenario.
tc_proximo: .word 0                         # Controle do cenario.
tc_esperado: .word 0                        # Controle do cenario.
tc_status: .word 0                          # Controle do cenario.
tc_limpeza: .word 0                         # Controle do cenario.
tc_pilha: .word 0                           # Controle do cenario.
tc_saidaPos: .word 0                        # Controle do cenario.
tc_contexto: .space 32                      # Guarda os oito salvos.
tc_argumentos: .space 16                    # Guarda os argumentos.
tc_snapshot: .space 10752                   # Guarda os 24 registros reais.
tc_saidaAntes: .word 0x1234ABCD             # Protege a captura.
tc_saida: .space 4096                       # Captura todo o texto.
tc_saidaDepois: .word 0x5678DCBA            # Protege o fim da captura.
tc_rich: .asciiz "AP: 101\nMoradores:\nAna\nCarro:\nUno / ABC1234\n"# Mensagem ou referencia independente.
tc_all: .asciiz "AP: 101\nMoradores:\nAna\nCarro:\nUno / ABC1234\nAP: 102\nApartamento vazio\nAP: 201\nApartamento vazio\nAP: 202\nApartamento vazio\nAP: 301\nApartamento vazio\nAP: 302\nApartamento vazio\nAP: 401\nApartamento vazio\nAP: 402\nApartamento vazio\nAP: 501\nApartamento vazio\nAP: 502\nApartamento vazio\nAP: 601\nApartamento vazio\nAP: 602\nApartamento vazio\nAP: 701\nApartamento vazio\nAP: 702\nApartamento vazio\nAP: 801\nApartamento vazio\nAP: 802\nApartamento vazio\nAP: 901\nApartamento vazio\nAP: 902\nApartamento vazio\nAP: 1001\nApartamento vazio\nAP: 1002\nApartamento vazio\nAP: 1101\nApartamento vazio\nAP: 1102\nApartamento vazio\nAP: 1201\nApartamento vazio\nAP: 1202\nApartamento vazio\n"# Mensagem ou referencia independente.
tc_empty1202: .asciiz "AP: 1202\nApartamento vazio\n"# Mensagem ou referencia independente.
tc_erroAP: .asciiz "Falha: AP invalido\n"   # Mensagem ou referencia independente.
tc_invalido: .asciiz "Comando invalido\n"   # Mensagem ou referencia independente.
tc_vazio: .asciiz ""                        # Mensagem ou referencia independente.
tc_pass: .asciiz "PASS: comandosAp (14 cenarios)\n"# Mensagem ou referencia independente.
tc_fail: .asciiz "FAIL: comandosAp, cenario "# Mensagem ou referencia independente.
tc_nl: .asciiz "\n"                         # Mensagem ou referencia independente.
tc_cmd0: .asciiz "infoAp --101"             # Linha a ser interpretada.
tc_cmd1: .asciiz "limparAp --101"           # Linha a ser interpretada.
tc_cmd2: .asciiz "infoAp --all"             # Linha a ser interpretada.
tc_cmd3: .asciiz "infoAp --1301"            # Linha a ser interpretada.
tc_cmd4: .asciiz "limparAp --103"           # Linha a ser interpretada.
tc_cmd5: .asciiz "salvar"                   # Linha a ser interpretada.
tc_cmd6: .asciiz "infoAp --"                # Linha a ser interpretada.
tc_cmd7: .asciiz "infoAp --101 --x"         # Linha a ser interpretada.
tc_cmd8: .asciiz "infoAp 101"               # Linha a ser interpretada.
tc_cmd9: .asciiz "infoAp --allx"            # Linha a ser interpretada.
tc_cmd10: .asciiz "infoAp --12345678901234567890"# Linha a ser interpretada.
tc_cmd11: .asciiz "limparAp ---101"         # Linha a ser interpretada.
tc_cmd12: .asciiz "infoAp --0101"           # Linha a ser interpretada.
tc_cmd13: .asciiz "infoAp --1202"           # Linha a ser interpretada.
.align 2                                    # Alinha os descritores.
tc_casos:                                   # Linha, texto, status e indicador de limpeza.
.word tc_cmd0, tc_rich, 0, 0                # Configura o cenario 1.
.word tc_cmd1, tc_vazio, 0, 1               # Configura o cenario 2.
.word tc_cmd2, tc_all, 0, 0                 # Configura o cenario 3.
.word tc_cmd3, tc_erroAP, 0xffffffff, 0     # Configura o cenario 4.
.word tc_cmd4, tc_erroAP, 0xffffffff, 0     # Configura o cenario 5.
.word tc_cmd5, tc_invalido, 0xfffffffd, 0   # Configura o cenario 6.
.word tc_cmd6, tc_erroAP, 0xffffffff, 0     # Configura o cenario 7.
.word tc_cmd7, tc_erroAP, 0xffffffff, 0     # Configura o cenario 8.
.word tc_cmd8, tc_invalido, 0xfffffffd, 0   # Configura o cenario 9.
.word tc_cmd9, tc_erroAP, 0xffffffff, 0     # Configura o cenario 10.
.word tc_cmd10, tc_erroAP, 0xffffffff, 0    # Configura o cenario 11.
.word tc_cmd11, tc_erroAP, 0xffffffff, 0    # Configura o cenario 12.
.word tc_cmd12, tc_erroAP, 0xffffffff, 0    # Configura o cenario 13.
.word tc_cmd13, tc_empty1202, 0, 0          # Configura o cenario 14.
.text                                       # Inicia o teste independente.
.globl main                                 # Exporta a entrada.
main:                                       # Prepara os descritores.
la $t0, tc_casos                            # Seleciona o primeiro.
sw $t0, tc_proximo                          # Guarda sua posicao.
li $t0, 1                                   # Comeca pelo primeiro caso.
sw $t0, tc_idCaso                           # Guarda o numero.
tc_casoLoop:                                # Reinicia a tabela entre os casos.
la $t0, ap_tabela                           # Seleciona a tabela real.
li $t1, 2688                                # Define 10752 bytes em words.
tc_zerar:                                   # Zera todos os registros.
sw $zero, 0($t0)                            # Limpa uma word.
addiu $t0, $t0, 4                           # Avanca.
addiu $t1, $t1, -1                          # Conta o restante.
bne $t1, $zero, tc_zerar                    # Limpa toda a tabela.
nop                                         # Protege o atraso.
jal ap_inicializarTabela                    # Usa a inicializacao real dos IDs.
nop                                         # Protege o atraso.
la $t0, ap_tabela                           # Seleciona AP 101.
li $t1, 1                                   # Define um morador e um veiculo.
sw $t1, 4($t0)                              # Marca ocupacao.
sw $t1, 296($t0)                            # Marca veiculo cadastrado.
li $t1, 99                                  # Define carro.
sw $t1, 300($t0)                            # Guarda tipo geral.
sw $t1, 304($t0)                            # Guarda tipo do slot.
li $t1, 65                                  # Define caractere ficticio.
sb $t1, 8($t0)                              # Guarda no campo.
li $t1, 110                                 # Define caractere ficticio.
sb $t1, 9($t0)                              # Guarda no campo.
li $t1, 97                                  # Define caractere ficticio.
sb $t1, 10($t0)                             # Guarda no campo.
li $t1, 85                                  # Define caractere ficticio.
sb $t1, 308($t0)                            # Guarda no campo.
li $t1, 110                                 # Define caractere ficticio.
sb $t1, 309($t0)                            # Guarda no campo.
li $t1, 111                                 # Define caractere ficticio.
sb $t1, 310($t0)                            # Guarda no campo.
li $t1, 65                                  # Define caractere ficticio.
sb $t1, 340($t0)                            # Guarda no campo.
li $t1, 66                                  # Define caractere ficticio.
sb $t1, 341($t0)                            # Guarda no campo.
li $t1, 67                                  # Define caractere ficticio.
sb $t1, 342($t0)                            # Guarda no campo.
li $t1, 49                                  # Define caractere ficticio.
sb $t1, 343($t0)                            # Guarda no campo.
li $t1, 50                                  # Define caractere ficticio.
sb $t1, 344($t0)                            # Guarda no campo.
li $t1, 51                                  # Define caractere ficticio.
sb $t1, 345($t0)                            # Guarda no campo.
li $t1, 52                                  # Define caractere ficticio.
sb $t1, 346($t0)                            # Guarda no campo.
li $t1, 90                                  # Marca residuo fora dos campos ativos.
sb $t1, 295($t0)                            # Marca o fim dos dados de moradores.
sb $t1, 447($t0)                            # Marca o fim da garagem.
la $t0, ap_tabela                           # Seleciona a origem.
la $t1, tc_snapshot                         # Seleciona a referencia.
li $t2, 2688                                # Define todas as words.
tc_copiar:                                  # Guarda a tabela antes da chamada.
lw $t3, 0($t0)                              # Le a word.
sw $t3, 0($t1)                              # Copia a word.
addiu $t0, $t0, 4                           # Avanca origem.
addiu $t1, $t1, 4                           # Avanca copia.
addiu $t2, $t2, -1                          # Conta o restante.
bne $t2, $zero, tc_copiar                   # Copia tudo.
nop                                         # Protege o atraso.
lw $t0, tc_proximo                          # Seleciona o descritor.
lw $a0, 0($t0)                              # Seleciona a linha.
lw $t1, 4($t0)                              # Le a referencia de texto.
sw $t1, tc_esperado                         # Guarda o texto.
lw $t1, 8($t0)                              # Le o status.
sw $t1, tc_status                           # Guarda o status.
lw $t1, 12($t0)                             # Le o indicador de limpeza.
sw $t1, tc_limpeza                          # Guarda o indicador.
addiu $t0, $t0, 16                          # Avanca o descritor.
sw $t0, tc_proximo                          # Guarda para o caso seguinte.
sw $zero, tc_saidaPos                       # Reinicia a captura.
sb $zero, tc_saida                          # Comeca com texto vazio.
li $a1, 111                                 # Marca um argumento.
li $a2, 222                                 # Marca outro argumento.
li $a3, 333                                 # Marca outro argumento.
sw $a0, tc_argumentos+0                     # Guarda argumento.
sw $a1, tc_argumentos+4                     # Guarda argumento.
sw $a2, tc_argumentos+8                     # Guarda argumento.
sw $a3, tc_argumentos+12                    # Guarda argumento.
li $s0, 2000                                # Marca registrador salvo.
sw $s0, tc_contexto+0                       # Guarda marca esperada.
li $s1, 2001                                # Marca registrador salvo.
sw $s1, tc_contexto+4                       # Guarda marca esperada.
li $s2, 2002                                # Marca registrador salvo.
sw $s2, tc_contexto+8                       # Guarda marca esperada.
li $s3, 2003                                # Marca registrador salvo.
sw $s3, tc_contexto+12                      # Guarda marca esperada.
li $s4, 2004                                # Marca registrador salvo.
sw $s4, tc_contexto+16                      # Guarda marca esperada.
li $s5, 2005                                # Marca registrador salvo.
sw $s5, tc_contexto+20                      # Guarda marca esperada.
li $s6, 2006                                # Marca registrador salvo.
sw $s6, tc_contexto+24                      # Guarda marca esperada.
li $s7, 2007                                # Marca registrador salvo.
sw $s7, tc_contexto+28                      # Guarda marca esperada.
sw $sp, tc_pilha                            # Guarda a pilha.
jal ap_executarLinha                        # Interpreta e executa a linha real.
nop                                         # Protege o atraso.
lw $t0, tc_status                           # Le o status esperado.
bne $v0, $t0, tc_falha                      # Exige status correto.
nop                                         # Protege o atraso.
lw $t0, tc_argumentos+0                     # Recupera marca esperada.
bne $a0, $t0, tc_falha                      # Exige preservacao.
nop                                         # Protege o atraso.
lw $t0, tc_argumentos+4                     # Recupera marca esperada.
bne $a1, $t0, tc_falha                      # Exige preservacao.
nop                                         # Protege o atraso.
lw $t0, tc_argumentos+8                     # Recupera marca esperada.
bne $a2, $t0, tc_falha                      # Exige preservacao.
nop                                         # Protege o atraso.
lw $t0, tc_argumentos+12                    # Recupera marca esperada.
bne $a3, $t0, tc_falha                      # Exige preservacao.
nop                                         # Protege o atraso.
lw $t0, tc_contexto+0                       # Recupera marca esperada.
bne $s0, $t0, tc_falha                      # Exige preservacao.
nop                                         # Protege o atraso.
lw $t0, tc_contexto+4                       # Recupera marca esperada.
bne $s1, $t0, tc_falha                      # Exige preservacao.
nop                                         # Protege o atraso.
lw $t0, tc_contexto+8                       # Recupera marca esperada.
bne $s2, $t0, tc_falha                      # Exige preservacao.
nop                                         # Protege o atraso.
lw $t0, tc_contexto+12                      # Recupera marca esperada.
bne $s3, $t0, tc_falha                      # Exige preservacao.
nop                                         # Protege o atraso.
lw $t0, tc_contexto+16                      # Recupera marca esperada.
bne $s4, $t0, tc_falha                      # Exige preservacao.
nop                                         # Protege o atraso.
lw $t0, tc_contexto+20                      # Recupera marca esperada.
bne $s5, $t0, tc_falha                      # Exige preservacao.
nop                                         # Protege o atraso.
lw $t0, tc_contexto+24                      # Recupera marca esperada.
bne $s6, $t0, tc_falha                      # Exige preservacao.
nop                                         # Protege o atraso.
lw $t0, tc_contexto+28                      # Recupera marca esperada.
bne $s7, $t0, tc_falha                      # Exige preservacao.
nop                                         # Protege o atraso.
lw $t0, tc_pilha                            # Le o topo original.
bne $sp, $t0, tc_falha                      # Exige equilibrio da pilha.
nop                                         # Protege o atraso.
la $a0, tc_saida                            # Seleciona o texto capturado.
lw $a1, tc_esperado                         # Seleciona a referencia.
jal tc_compararStrings                      # Compara o texto completo.
nop                                         # Protege o atraso.
bne $v0, $zero, tc_falha                    # Rejeita qualquer diferenca.
nop                                         # Protege o atraso.
lw $t0, tc_limpeza                          # Le se o comando deve limpar.
beq $t0, $zero, tc_compararMemoria          # Consultas e erros nao podem mudar a tabela.
nop                                         # Protege o atraso.
la $t0, tc_snapshot+4                       # Pula o ID na copia esperada.
li $t1, 444                                 # Limpa somente moradores e garagem do AP 101.
tc_limparEsperado:                          # Ajusta a referencia independentemente da rotina real.
sb $zero, 0($t0)                            # Zera um byte esperado.
addiu $t0, $t0, 1                           # Avanca um byte.
addiu $t1, $t1, -1                          # Conta o restante.
bne $t1, $zero, tc_limparEsperado           # Limpa exatamente a regiao permitida.
nop                                         # Protege o atraso.
tc_compararMemoria:                         # Confere todos os apartamentos.
la $t0, ap_tabela                           # Seleciona a tabela real.
la $t1, tc_snapshot                         # Seleciona a referencia.
li $t2, 2688                                # Conta todas as words.
tc_memoriaLoop:                             # Compara word a word.
lw $t3, 0($t0)                              # Le a tabela.
lw $t4, 0($t1)                              # Le a referencia.
bne $t3, $t4, tc_falha                      # Detecta alteracao incorreta.
nop                                         # Protege o atraso.
addiu $t0, $t0, 4                           # Avanca na tabela.
addiu $t1, $t1, 4                           # Avanca na referencia.
addiu $t2, $t2, -1                          # Conta o restante.
bne $t2, $zero, tc_memoriaLoop              # Compara a tabela inteira.
nop                                         # Protege o atraso.
lw $t0, tc_saidaAntes                       # Le sentinela inicial.
li $t1, 0x1234ABCD                          # Define marca esperada.
bne $t0, $t1, tc_falha                      # Protege inicio da captura.
nop                                         # Protege o atraso.
lw $t0, tc_saidaDepois                      # Le sentinela final.
li $t1, 0x5678DCBA                          # Define marca esperada.
bne $t0, $t1, tc_falha                      # Protege fim da captura.
nop                                         # Protege o atraso.
lw $t0, tc_idCaso                           # Le o numero atual.
addiu $t0, $t0, 1                           # Avanca um caso.
sw $t0, tc_idCaso                           # Guarda o numero.
li $t1, 15                                  # Define o fim dos 14 cenarios.
bne $t0, $t1, tc_casoLoop                   # Executa o caso seguinte.
nop                                         # Protege o atraso.
la $a0, tc_pass                             # Seleciona sucesso.
li $v0, 4                                   # Imprime apenas no teste.
syscall                                     # Mostra PASS.
move $a0, $zero                             # Define codigo zero.
li $v0, 17                                  # Encerra com codigo.
syscall                                     # Finaliza o teste.
ap_imprimirTexto:                        # No teste, guarda o texto no buffer em vez de acessar MMIO.
    move $t0, $a0                        # Percorre uma copia do endereco, preservando o argumento.
    move $t4, $a1                        # Usa uma copia do limite.
    sw $a0, 0($sp)                       # Exercita a area de argumentos reservada pelo chamador.
    sw $a1, 4($sp)                       # Exercita a area de argumentos reservada pelo chamador.
    sw $a2, 8($sp)                       # Exercita a area de argumentos reservada pelo chamador.
    sw $a3, 12($sp)                      # Exercita a area de argumentos reservada pelo chamador.
tc_imprimirProximo:                      # Seleciona um caractere solicitado pela consulta.
    lbu $t2, 0($t0)                      # Le o caractere atual.
    beq $t2, $zero, tc_imprimirFim       # Finaliza ao encontrar o terminador.
    nop                                  # Nao faz trabalho no atraso deste desvio.
    lw $t3, tc_saidaPos                  # Le quantos caracteres foram guardados.
    li $t1, 4095                         # Reserva o ultimo byte para o terminador.
    bge $t3, $t1, tc_falha               # Detecta texto maior que o buffer.
    nop                                  # Nao faz trabalho no atraso deste desvio.
    la $t1, tc_saida                     # Seleciona o inicio da captura.
    addu $t1, $t1, $t3                   # Localiza a posicao seguinte.
    sb $t2, 0($t1)                       # Guarda o caractere que seria mostrado.
    sb $zero, 1($t1)                     # Mantem a captura terminada em zero.
    addiu $t3, $t3, 1                    # Atualiza o total guardado.
    sw $t3, tc_saidaPos                  # Guarda o tamanho atualizado.
    addiu $t0, $t0, 1                    # Avanca no texto original.
    beq $a1, $zero, tc_imprimirProximo   # Limite zero permite continuar ate o terminador.
    nop                                  # Nao faz trabalho no atraso deste desvio.
    addiu $t4, $t4, -1                   # Desconta um caractere do limite.
    bne $t4, $zero, tc_imprimirProximo   # Continua enquanto ainda pode imprimir caracteres.
    nop                                  # Nao faz trabalho no atraso deste desvio.
tc_imprimirFim:                          # Preserva argumentos, salvos e pilha, como a saida real.
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

tc_compararStrings:                      # Compara textos sem chamar as rotinas do projeto.
    lbu $t0, 0($a0)                      # Le um byte do texto real.
    lbu $t1, 0($a1)                      # Le um byte do texto esperado.
    bne $t0, $t1, tc_stringsDiferentes   # Identifica uma divergencia.
    nop                                  # Nao faz trabalho no atraso do salto.
    beq $t0, $zero, tc_stringsIguais     # Finaliza quando ambos chegam ao terminador.
    nop                                  # Nao faz trabalho no atraso do salto.
    addiu $a0, $a0, 1                    # Avanca no texto real.
    addiu $a1, $a1, 1                    # Avanca no texto esperado.
    j tc_compararStrings                 # Continua a comparacao integral.
    nop                                  # Nao faz trabalho no atraso do salto.
tc_stringsDiferentes:                    # Retorna divergencia.
    li $v0, 1                            # Informa que os textos diferem.
    jr $ra                               # Retorna ao verificador.
    nop                                  # Nao faz trabalho no atraso do salto.
tc_stringsIguais:                        # Retorna igualdade.
    move $v0, $zero                      # Informa que os textos sao identicos.
    jr $ra                               # Retorna ao verificador.
    nop                                  # Nao faz trabalho no atraso do salto.

tc_falha:                                # Encerra ao encontrar qualquer resultado incorreto.
    la $a0, tc_fail                      # Seleciona a mensagem de falha.
    li $v0, 4                            # Seleciona impressao de string.
    syscall                              # Informa a falha.
    lw $a0, tc_idCaso                    # Recupera o cenario fora dos salvos em teste.
    li $v0, 1                            # Seleciona impressao de inteiro.
    syscall                              # Identifica o cenario.
    la $a0, tc_nl                        # Seleciona a quebra de linha.
    li $v0, 4                            # Seleciona impressao de string.
    syscall                              # Finaliza a mensagem.
    li $a0, 1                            # Define codigo de falha.
    li $v0, 17                           # Seleciona encerramento com codigo.
    syscall                              # Encerra o teste com falha.

.include "../src/apartamento/tabelaAp.asm" # Inclui o modulo real da integracao.
.include "../src/apartamento/comandosAp.asm" # Inclui o modulo real da integracao.
.include "../src/apartamento/limparAp.asm" # Inclui o modulo real da integracao.
.include "../src/apartamento/infoAp.asm" # Inclui o modulo real da integracao.
.include "../src/apartamento/infoApTodos.asm" # Inclui o modulo real da integracao.
