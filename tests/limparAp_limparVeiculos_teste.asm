# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: limparAp_limparVeiculos_teste.asm
# Descricao: teste isolado da limpeza da garagem no layout de addAuto.
# Os bytes anteriores a garagem sao opacos: nao definem moradores.
# O teste nao define o tamanho definitivo de um registro de AP.
# ==============================================================

.data                              # Inicia os dados exclusivos do teste isolado.
.align 2                           # Alinha os registros artificiais para acesso por word.
testeVeic_outroDado: .word 0x13579BDF # Representa dados externos que nao podem mudar.
testeVeic_ap: .space 296            # Reserva os bytes desconhecidos anteriores a garagem.
testeVeic_garagem: .space 152       # Reserva somente a regiao de veiculos conhecida.
testeVeic_depois: .byte 107         # Marca o primeiro byte posterior a garagem.
testeVeic_pass: .asciiz "PASS: limparAp_limparVeiculos (6 cenarios)\n" # Informa sucesso.
testeVeic_fail: .asciiz "FAIL: limparAp_limparVeiculos, cenario " # Identifica a falha.
testeVeic_novaLinha: .asciiz "\n"   # Finaliza a mensagem de falha no terminal.

.text                              # Inicia as instrucoes do programa de teste.
.globl main                        # Disponibiliza a entrada do programa isolado.

main:                              # Executa os seis cenarios em sequencia.
    li    $s6, 1                   # Identifica o cenario de garagem com carro.
    li    $a0, 1                   # Define a quantidade artificial de um veiculo.
    li    $a1, 99                  # Define o tipo geral como carro ('c').
    li    $a2, 51                  # Preenche os bytes dos slots com valores nao nulos.
    jal   testeVeic_preparar        # Monta dados artificiais para o primeiro cenario.
    nop                            # Protege o delay slot da chamada.
    jal   testeVeic_limparEConferir # Executa a limpeza e verifica contexto e memoria.
    nop                            # Protege o delay slot da chamada.

    li    $s6, 2                   # Identifica o cenario de garagem com tres motos.
    li    $a0, 3                   # Define a quantidade artificial de tres veiculos.
    li    $a1, 109                 # Define o tipo geral como moto ('m').
    li    $a2, 85                  # Usa outro padrao nao nulo nos bytes dos slots.
    jal   testeVeic_preparar        # Monta dados artificiais para o segundo cenario.
    nop                            # Protege o delay slot da chamada.
    jal   testeVeic_limparEConferir # Exige limpeza de todos os slots, tipos e contador.
    nop                            # Protege o delay slot da chamada.

    li    $s6, 3                   # Identifica o cenario de garagem ja vazia.
    move  $a0, $zero               # Define quantidade zero de veiculos.
    move  $a1, $zero               # Define tipo geral vazio.
    move  $a2, $zero               # Preenche toda a regiao da garagem com zeros.
    jal   testeVeic_preparar        # Monta uma garagem artificial totalmente vazia.
    nop                            # Protege o delay slot da chamada.
    jal   testeVeic_limparEConferir # Exige sucesso e preservacao das regioes externas.
    nop                            # Protege o delay slot da chamada.

    li    $s6, 4                   # Identifica o cenario de residuos sem veiculos contados.
    move  $a0, $zero               # Define contador zero apesar dos residuos nos slots.
    move  $a1, $zero               # Define tipo geral vazio.
    li    $a2, 204                 # Deixa residuos nao nulos em todos os slots.
    jal   testeVeic_preparar        # Monta a garagem com bytes residuais artificiais.
    nop                            # Protege o delay slot da chamada.
    jal   testeVeic_limparEConferir # Confirma que a limpeza nao depende do contador.
    nop                            # Protege o delay slot da chamada.

    li    $s6, 5                   # Identifica o cenario de endereco nulo.
    move  $a0, $zero               # Fornece um endereco base invalido.
    li    $a1, 4660                # Prepara um argumento que deve ser preservado.
    move  $s7, $sp                 # Guarda a posicao original da pilha.
    jal   limparAp_limparVeiculos  # Solicita a limpeza com endereco nulo.
    nop                            # Protege o delay slot da chamada.
    li    $t2, -1                  # Define o retorno esperado para endereco nulo.
    bne   $v0, $t2, testeVeic_falha # Exige rejeicao do endereco nulo.
    nop                            # Protege o delay slot do desvio.
    bne   $a0, $zero, testeVeic_falha # Exige preservacao do primeiro argumento.
    nop                            # Protege o delay slot do desvio.
    li    $t2, 4660                # Recupera o valor original do segundo argumento.
    bne   $a1, $t2, testeVeic_falha # Exige preservacao do segundo argumento.
    nop                            # Protege o delay slot do desvio.
    bne   $sp, $s7, testeVeic_falha # Detecta desequilibrio da pilha no caminho de erro.
    nop                            # Protege o delay slot do desvio.
    jal   testeVeic_conferirMemoria # Exige que a rejeicao nao altere os dados anteriores.
    nop                            # Protege o delay slot da chamada.

    li    $s6, 6                   # Identifica a repeticao sem preparar novos dados.
    jal   testeVeic_limparEConferir # Limpa novamente a mesma garagem ja zerada.
    nop                            # Protege o delay slot da chamada.
    la    $a0, testeVeic_pass        # Seleciona a mensagem de sucesso dos seis cenarios.
    li    $v0, 4                   # Seleciona impressao de string apenas para o teste.
    syscall                        # Imprime o resultado no terminal padrao do MARS.
    move  $a0, $zero               # Define codigo de saida zero para sucesso.
    li    $v0, 17                  # Seleciona encerramento com codigo de saida.
    syscall                        # Encerra o programa de teste com sucesso.

testeVeic_preparar:                # Recebe quantidade, tipo e padrao nos argumentos.
    move  $t6, $a0                 # Guarda a quantidade artificial de veiculos.
    move  $t7, $a1                 # Guarda o tipo geral artificial de veiculo.
    move  $t8, $a2                 # Guarda o padrao de preenchimento da garagem.
    la    $t0, testeVeic_ap         # Aponta para o inicio da regiao anterior a garagem.
    li    $t1, 296                 # Define o total de bytes opacos a preservar.
    li    $t2, 90                  # Define a marca de preservacao desses bytes.

testeVeic_prepararPrefixo:          # Preenche os bytes anteriores a garagem.
    sb    $t2, 0($t0)              # Grava a marca em um byte da regiao opaca.
    addiu $t0, $t0, 1              # Avanca para o proximo byte dessa regiao.
    addiu $t1, $t1, -1             # Desconta o byte que acabou de ser preparado.
    bne   $t1, $zero, testeVeic_prepararPrefixo # Repete ate preencher os 296 bytes.
    nop                            # Protege o delay slot do desvio.
    la    $t0, testeVeic_garagem    # Aponta para o inicio da garagem artificial.
    li    $t1, 152                 # Define o tamanho conhecido da garagem.

testeVeic_prepararGaragem:          # Preenche todos os bytes da garagem artificial.
    sb    $t8, 0($t0)              # Grava o padrao solicitado para este cenario.
    addiu $t0, $t0, 1              # Avanca para o proximo byte da garagem.
    addiu $t1, $t1, -1             # Desconta o byte que acabou de ser preparado.
    bne   $t1, $zero, testeVeic_prepararGaragem # Repete ate preparar toda a garagem.
    nop                            # Protege o delay slot do desvio.
    la    $t0, testeVeic_ap         # Recupera o endereco base do registro artificial.
    sw    $t6, 296($t0)            # Grava o contador no offset publicado em addAuto.
    sw    $t7, 300($t0)            # Grava o tipo geral no offset publicado em addAuto.
    li    $t2, 107                 # Define a marca do primeiro byte depois da garagem.
    sb    $t2, testeVeic_depois     # Inicializa o limite posterior para detectar excessos.
    jr    $ra                      # Retorna ao cenario que preparou os argumentos.
    nop                            # Protege o delay slot do retorno.

testeVeic_limparEConferir:          # Executa e verifica uma chamada com registro valido.
    addiu $sp, $sp, -24            # Reserva frame alinhado e area para argumentos.
    sw    $ra, 20($sp)             # Guarda o retorno antes das chamadas do verificador.
    la    $a0, testeVeic_ap         # Seleciona o registro artificial do apartamento.
    li    $a1, 4660                # Define uma marca para verificar o segundo argumento.
    li    $a2, 9029                # Define uma marca para verificar o terceiro argumento.
    li    $a3, 13398               # Define uma marca para verificar o quarto argumento.
    li    $s0, 17767               # Define uma marca em um registrador salvo.
    li    $s1, 22136               # Define uma marca em outro registrador salvo.
    move  $s7, $sp                 # Guarda a posicao da pilha antes da rotina real.
    jal   limparAp_limparVeiculos  # Executa a rotina real de limpeza da garagem.
    nop                            # Protege o delay slot da chamada.
    bne   $v0, $zero, testeVeic_falha # Exige status zero para o registro valido.
    nop                            # Protege o delay slot do desvio.
    la    $t2, testeVeic_ap         # Recupera o endereco esperado do primeiro argumento.
    bne   $a0, $t2, testeVeic_falha # Verifica preservacao do endereco base original.
    nop                            # Protege o delay slot do desvio.
    li    $t2, 4660                # Recupera o valor esperado do segundo argumento.
    bne   $a1, $t2, testeVeic_falha # Verifica preservacao do segundo argumento.
    nop                            # Protege o delay slot do desvio.
    li    $t2, 9029                # Recupera o valor esperado do terceiro argumento.
    bne   $a2, $t2, testeVeic_falha # Verifica preservacao do terceiro argumento.
    nop                            # Protege o delay slot do desvio.
    li    $t2, 13398               # Recupera o valor esperado do quarto argumento.
    bne   $a3, $t2, testeVeic_falha # Verifica preservacao do quarto argumento.
    nop                            # Protege o delay slot do desvio.
    li    $t2, 17767               # Recupera a marca esperada no registrador salvo.
    bne   $s0, $t2, testeVeic_falha # Detecta alteracao indevida de um registrador salvo.
    nop                            # Protege o delay slot do desvio.
    li    $t2, 22136               # Recupera a outra marca de registrador salvo.
    bne   $s1, $t2, testeVeic_falha # Detecta alteracao indevida do outro registrador salvo.
    nop                            # Protege o delay slot do desvio.
    bne   $sp, $s7, testeVeic_falha # Exige que a rotina real tenha restaurado a pilha.
    nop                            # Protege o delay slot do desvio.
    jal   testeVeic_conferirMemoria # Verifica limpeza e preservacao de todas as sentinelas.
    nop                            # Protege o delay slot da chamada.
    lw    $ra, 20($sp)             # Recupera o retorno ao cenario que chamou o verificador.
    addiu $sp, $sp, 24             # Libera o frame usado somente pelo teste.
    jr    $ra                      # Retorna ao proximo cenario do programa de teste.
    nop                            # Protege o delay slot do retorno.

testeVeic_conferirMemoria:          # Verifica os dados sem executar outra limpeza.
    la    $t0, testeVeic_garagem    # Aponta para o primeiro byte que deveria estar zerado.
    li    $t1, 152                 # Define a quantidade esperada de bytes limpos.

testeVeic_conferirGaragem:          # Percorre toda a regiao conhecida da garagem.
    lbu   $t2, 0($t0)              # Le um byte da garagem depois da limpeza.
    bne   $t2, $zero, testeVeic_falha # Falha se qualquer contador, tipo ou slot nao zerou.
    nop                            # Protege o delay slot do desvio.
    addiu $t0, $t0, 1              # Avanca para conferir o proximo byte.
    addiu $t1, $t1, -1             # Desconta o byte que acabou de ser conferido.
    bne   $t1, $zero, testeVeic_conferirGaragem # Continua ate conferir os 152 bytes.
    nop                            # Protege o delay slot do desvio.
    la    $t0, testeVeic_ap         # Aponta para os dados anteriores a garagem.
    li    $t1, 296                 # Define quantos bytes anteriores devem ser preservados.
    li    $t3, 90                  # Define a marca original desses dados opacos.

testeVeic_conferirPrefixo:          # Confere todos os bytes anteriores a garagem.
    lbu   $t2, 0($t0)              # Le um byte externo a regiao autorizada de limpeza.
    bne   $t2, $t3, testeVeic_falha # Falha se a limpeza alterou os dados anteriores.
    nop                            # Protege o delay slot do desvio.
    addiu $t0, $t0, 1              # Avanca para o proximo byte a preservar.
    addiu $t1, $t1, -1             # Desconta o byte que acabou de ser conferido.
    bne   $t1, $zero, testeVeic_conferirPrefixo # Continua ate conferir os 296 bytes.
    nop                            # Protege o delay slot do desvio.
    lbu   $t2, testeVeic_depois     # Le a marca imediatamente posterior a garagem.
    li    $t3, 107                 # Recupera o valor original da marca posterior.
    bne   $t2, $t3, testeVeic_falha # Detecta limpeza alem do ultimo byte autorizado.
    nop                            # Protege o delay slot do desvio.
    lw    $t2, testeVeic_outroDado  # Le o dado externo anterior ao registro artificial.
    li    $t3, 0x13579BDF          # Recupera o valor original desse dado externo.
    bne   $t2, $t3, testeVeic_falha # Detecta alteracao fora do apartamento em teste.
    nop                            # Protege o delay slot do desvio.
    jr    $ra                      # Retorna sem alterar os dados que foram verificados.
    nop                            # Protege o delay slot do retorno.

testeVeic_falha:                   # Identifica qual cenario encontrou uma divergencia.
    la    $a0, testeVeic_fail        # Seleciona o prefixo da mensagem de falha.
    li    $v0, 4                   # Seleciona impressao de string apenas para o teste.
    syscall                        # Imprime a descricao da falha no terminal do MARS.
    move  $a0, $s6                 # Seleciona o numero do cenario que estava em execucao.
    li    $v0, 1                   # Seleciona impressao de numero inteiro no teste.
    syscall                        # Imprime o numero do cenario que falhou.
    la    $a0, testeVeic_novaLinha   # Seleciona a quebra de linha da mensagem.
    li    $v0, 4                   # Seleciona impressao da string de quebra de linha.
    syscall                        # Finaliza a mensagem de falha.
    li    $a0, 1                   # Define codigo de saida nao zero para falha.
    li    $v0, 17                  # Seleciona encerramento com codigo de saida.
    syscall                        # Encerra o teste com indicacao de falha.

.include "../src/apartamento/limparAp.asm" # Inclui somente as rotinas locais de limpeza.
