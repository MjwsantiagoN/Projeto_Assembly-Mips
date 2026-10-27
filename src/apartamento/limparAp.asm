# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: limparAp.asm
# Descricao: limpeza de memoria, garagem e registro sob contrato proposto.
# Esta etapa ainda nao implementa o comando limparAp do shell.
# ==============================================================

# Contrato de limparAp_zerarRegiao:
# $a0 = endereco inicial de uma regiao gravavel.
# $a1 = quantidade nao negativa de bytes a zerar.
# $v0 = quantidade zerada; -1 para tamanho negativo ou endereco nulo
#       com tamanho positivo. Tamanho zero nao acessa a memoria.
# Preserva os argumentos, os registradores $s0-$s7 e a pilha.
# Altera somente $t0, $t1 e $v0, alem da regiao indicada.
#
# O chamador deve validar o AP, os limites da regiao e quais campos
# podem receber zero. Nao passar campos fixos de identificacao.
# A rotina pode ser chamada para regioes separadas de moradores,
# automoveis e contadores, conforme o layout definitivo do grupo.
# Nao imprime mensagens, nao acessa MMIO e nao salva arquivos.

.text                              # Inicia a secao de instrucoes.
.globl limparAp_zerarRegiao         # Disponibiliza a auxiliar a outros arquivos.

limparAp_zerarRegiao:               # Recebe o endereco e o tamanho da regiao.
    li    $v0, -1                  # Prepara o retorno para argumentos invalidos.
    bltz  $a1, limparAp_zerarRetorno # Rejeita uma quantidade negativa de bytes.
    nop                            # Mantem o desvio correto com delay slot ativo.
    beq   $a1, $zero, limparAp_zerarSucesso # Aceita tamanho zero sem ler o endereco.
    nop                            # Mantem o desvio correto com delay slot ativo.
    beq   $a0, $zero, limparAp_zerarRetorno # Rejeita endereco nulo com tamanho positivo.
    nop                            # Mantem o desvio correto com delay slot ativo.
    move  $t0, $a0                 # Copia o inicio sem alterar o argumento.
    move  $t1, $a1                 # Copia a quantidade de bytes restantes.

limparAp_zerarLoop:                 # Inicia uma iteracao da limpeza byte a byte.
    sb    $zero, 0($t0)            # Zera somente o byte apontado da regiao.
    addiu $t0, $t0, 1              # Avanca o ponteiro para o proximo byte.
    addiu $t1, $t1, -1             # Desconta o byte que acabou de ser zerado.
    bne   $t1, $zero, limparAp_zerarLoop # Repete ate zerar a quantidade solicitada.
    nop                            # Evita escrita adicional no delay slot.

limparAp_zerarSucesso:              # Finaliza uma solicitacao valida de limpeza.
    move  $v0, $a1                 # Retorna a quantidade de bytes zerados.

limparAp_zerarRetorno:              # Finaliza a rotina tanto no sucesso como no erro.
    jr    $ra                      # Retorna ao chamador sem usar a pilha.
    nop                            # Mantem o retorno correto com delay slot ativo.

# ==============================================================
# Contrato de limparAp_limparVeiculos:
# $a0 = endereco base de um registro de AP valido e gravavel.
# $v0 = 0 no sucesso; -1 se o endereco base recebido for nulo.
# Preserva $a0-$a3, $s0-$s7, $ra e o valor inicial de $sp.
# Altera somente $t0, $t1, $v0 e os 152 bytes da garagem.
#
# Layout de veiculos publicado por Brenno em addAuto.asm:
# +296 a +299: quantidade de veiculos (word).
# +300 a +303: tipo geral de veiculo (word).
# +304 a +447: tres slots de 48 bytes (tipo, modelo e placa).
# Sao 8 bytes de cabecalho e 3 * 48 bytes de slots: 152 bytes.
# As constantes tem prefixo proprio para nao colidir com addAuto.
#
# O chamador deve localizar e validar o AP antes da chamada.
# A rotina nao valida numero de AP nem enderecos arbitrarios.
# Limpa toda a garagem, inclusive residuos em slots nao contados.
# Nao altera moradores, identificacao ou estado de ocupacao do AP.
# Ainda nao e o comando completo limparAp --AP do shell.
# Nao imprime mensagens, nao acessa MMIO e nao salva arquivos.
# ==============================================================

.eqv LIMPAR_AP_GARAGEM_INICIO 296   # Define o inicio do cabecalho da garagem no AP.
.eqv LIMPAR_AP_GARAGEM_BYTES  152   # Define os 8 bytes do cabecalho e 144 dos slots.
.globl limparAp_limparVeiculos     # Disponibiliza a limpeza da garagem ao projeto.

limparAp_limparVeiculos:            # Recebe o endereco base do apartamento.
    li    $v0, -1                  # Prepara o retorno de erro para endereco nulo.
    beq   $a0, $zero, limparAp_veiculosRetorno # Rejeita endereco nulo antes de soma-lo.
    nop                            # Mantem o desvio correto com delay slot ativo.
    addiu $sp, $sp, -32            # Reserva frame alinhado com area para argumentos.
    sw    $ra, 28($sp)             # Guarda o retorno antes da chamada da auxiliar.
    sw    $a0, 24($sp)             # Guarda o endereco original do apartamento.
    sw    $a1, 20($sp)             # Guarda o argumento que sera usado como tamanho.
    addiu $a0, $a0, LIMPAR_AP_GARAGEM_INICIO # Aponta para o primeiro byte da garagem.
    li    $a1, LIMPAR_AP_GARAGEM_BYTES # Solicita a limpeza de toda a regiao conhecida.
    jal   limparAp_zerarRegiao      # Reutiliza a auxiliar de limpeza byte a byte.
    nop                            # Mantem a chamada correta com delay slot ativo.
    bltz  $v0, limparAp_veiculosRestaurar # Preserva eventual erro devolvido pela auxiliar.
    nop                            # Mantem o desvio correto com delay slot ativo.
    li    $v0, 0                   # Converte a quantidade limpa no status de sucesso.

limparAp_veiculosRestaurar:         # Restaura o contexto antes de sair da rotina.
    lw    $a1, 20($sp)             # Recupera o valor original do segundo argumento.
    lw    $a0, 24($sp)             # Recupera o endereco original do apartamento.
    lw    $ra, 28($sp)             # Recupera o endereco de retorno ao chamador.
    addiu $sp, $sp, 32             # Devolve o frame e restaura o valor inicial da pilha.

limparAp_veiculosRetorno:           # Finaliza o sucesso ou a rejeicao de endereco nulo.
    jr    $ra                      # Retorna ao chamador com o status em $v0.
    nop                            # Mantem o retorno correto com delay slot ativo.

# ==============================================================
# Contrato PROPOSTO de limparAp_executar, sujeito a revisao do grupo:
# $a0 = endereco alinhado de uma tabela com 24 registros validos de AP.
# $a1 = numero inteiro do apartamento procurado na tabela.
# $a2 = passo entre registros em bytes: multiplo de 4 e pelo menos 448.
# $v0 = 0 no sucesso; -1 se o AP nao existir ou os parametros forem invalidos.
# $v1 = endereco do AP limpo no sucesso; endereco da mensagem de erro na falha.
# Preserva $a0-$a3, $s0-$s7, $ra e o valor inicial de $sp.
# Modifica $t0, $t1, $v0, $v1 e somente os bytes +4 a +447 do AP encontrado.
#
# Proposta para os campos ainda nao publicados pelo grupo:
# +0 a +3: numero do apartamento (word), preservado pela limpeza.
# +4 a +7: quantidade de moradores (word); zero significa AP vazio.
# +8 a +295: area de moradores, zerada sem presumir seu formato interno.
# A garagem de +296 a +447 mantem o layout ja publicado em addAuto.asm.
# Nao existe outro campo de ocupacao neste contrato proposto.
# Campos opcionais a partir de +448 ficam preservados.
#
# O chamador garante memoria gravavel suficiente para os 24 registros,
# numeros de AP validos e unicos, e ausencia de estouro nos enderecos.
# A rotina rejeita AP nao positivo, base nula/desalinhada e passo invalido.
# Nao le comandos de texto nem imprime mensagens: o shell deve exibir
# a string de erro retornada em $v1 pela interface de saida escolhida.
# Nao acessa MMIO, nao salva arquivos e nao define uma tabela global.
# Ver docs/contrato_apartamentos.md antes de integrar com outros modulos.
# ==============================================================

.eqv LIMPAR_AP_TOTAL_REGISTROS 24   # Define a quantidade de apartamentos do enunciado.
.eqv LIMPAR_AP_REGISTRO_MINIMO 448  # Define o fim dos campos conhecidos ate a garagem.
.eqv LIMPAR_AP_MORADORES_INICIO 4   # Preserva os quatro bytes do numero do apartamento.
.eqv LIMPAR_AP_MORADORES_BYTES 292  # Abrange contador e area de moradores ate o byte 295.

.data                              # Disponibiliza a mensagem para a futura saida do shell.
limparAp_msgApInvalido: .asciiz "Falha: AP invalido\n" # Define o texto exigido para erro de AP.
.text                              # Retoma a secao de instrucoes executaveis.
.globl limparAp_executar            # Exporta a limpeza do registro pelo numero do AP.

limparAp_executar:                  # Recebe tabela, numero do AP e passo entre registros.
    li    $v0, -1                  # Prepara o retorno de falha sem alterar a tabela.
    la    $v1, limparAp_msgApInvalido # Disponibiliza a mensagem associada a falha.
    beq   $a0, $zero, limparAp_completoRetorno # Rejeita a base nula antes de acessar memoria.
    nop                            # Protege o delay slot do desvio condicional.
    andi  $t0, $a0, 3              # Verifica os dois bits inferiores do endereco base.
    bne   $t0, $zero, limparAp_completoRetorno # Rejeita base sem alinhamento para word.
    nop                            # Protege o delay slot do desvio condicional.
    blez  $a1, limparAp_completoRetorno # Rejeita numeros de AP zero ou negativos.
    nop                            # Protege o delay slot do desvio condicional.
    slti  $t0, $a2, LIMPAR_AP_REGISTRO_MINIMO # Verifica passo negativo ou menor que 448.
    bne   $t0, $zero, limparAp_completoRetorno # Rejeita um passo que nao comporta os campos.
    nop                            # Protege o delay slot do desvio condicional.
    andi  $t0, $a2, 3              # Verifica se o passo mantem os registros alinhados.
    bne   $t0, $zero, limparAp_completoRetorno # Rejeita passo nao multiplo de quatro.
    nop                            # Protege o delay slot do desvio condicional.
    addiu $sp, $sp, -64            # Reserva frame alinhado e area para chamadas auxiliares.
    sw    $ra, 60($sp)             # Guarda o retorno antes das chamadas de limpeza.
    sw    $s0, 56($sp)             # Preserva o registrador do endereco de busca.
    sw    $s1, 52($sp)             # Preserva o registrador do numero procurado.
    sw    $s2, 48($sp)             # Preserva o registrador do passo entre registros.
    sw    $s3, 44($sp)             # Preserva o registrador da quantidade restante.
    sw    $a0, 40($sp)             # Guarda a base original fornecida pelo chamador.
    sw    $a1, 36($sp)             # Guarda o numero original fornecido pelo chamador.
    move  $s0, $a0                 # Inicializa a busca no primeiro registro da tabela.
    move  $s1, $a1                 # Mantem o numero procurado durante as chamadas.
    move  $s2, $a2                 # Mantem o passo definido pelo chamador.
    li    $s3, LIMPAR_AP_TOTAL_REGISTROS # Limita a busca aos 24 apartamentos.

limparAp_completoBuscar:            # Examina um registro sem modificar seus dados.
    lw    $t0, 0($s0)              # Le o numero do AP no inicio do registro atual.
    beq   $t0, $s1, limparAp_completoEncontrado # Encerra a busca ao localizar o AP.
    nop                            # Protege o delay slot do desvio condicional.
    addiu $s3, $s3, -1             # Desconta o registro que acabou de ser examinado.
    beq   $s3, $zero, limparAp_completoFalha # Retorna falha sem limpar se nao encontrou.
    nop                            # Protege o delay slot do desvio condicional.
    addu  $s0, $s0, $s2            # Avanca usando o passo fornecido, sem fixar 512 bytes.
    j     limparAp_completoBuscar  # Continua a busca no registro seguinte.
    nop                            # Protege o delay slot do salto incondicional.

limparAp_completoEncontrado:        # Limpa somente os campos mutaveis do AP localizado.
    addiu $a0, $s0, LIMPAR_AP_MORADORES_INICIO # Aponta para o contador de moradores.
    li    $a1, LIMPAR_AP_MORADORES_BYTES # Abrange contador e toda a area de moradores.
    jal   limparAp_zerarRegiao      # Zera os dados de moradores usando a auxiliar existente.
    nop                            # Protege o delay slot da chamada.
    bltz  $v0, limparAp_completoFalha # Propaga eventual rejeicao da auxiliar de limpeza.
    nop                            # Protege o delay slot do desvio condicional.
    move  $a0, $s0                 # Fornece o endereco base do mesmo apartamento.
    jal   limparAp_limparVeiculos  # Limpa a garagem usando a rotina da etapa anterior.
    nop                            # Protege o delay slot da chamada.
    bltz  $v0, limparAp_completoFalha # Propaga eventual rejeicao da rotina da garagem.
    nop                            # Protege o delay slot do desvio condicional.
    li    $v0, 0                   # Retorna sucesso com moradores e veiculos removidos.
    move  $v1, $s0                 # Informa ao chamador qual registro foi limpo.
    j     limparAp_completoRestaurar # Segue para a restauracao do contexto original.
    nop                            # Protege o delay slot do salto incondicional.

limparAp_completoFalha:             # Prepara a falha depois de uma busca ou chamada.
    li    $v0, -1                  # Define o codigo de erro do contrato desta rotina.
    la    $v1, limparAp_msgApInvalido # Fornece ao shell o texto de erro para exibicao.

limparAp_completoRestaurar:         # Restaura os dados do chamador antes do retorno.
    lw    $a1, 36($sp)             # Recupera o numero original solicitado.
    lw    $a0, 40($sp)             # Recupera o endereco original da tabela.
    lw    $s3, 44($sp)             # Recupera o registrador salvo da quantidade restante.
    lw    $s2, 48($sp)             # Recupera o registrador salvo do passo.
    lw    $s1, 52($sp)             # Recupera o registrador salvo do numero procurado.
    lw    $s0, 56($sp)             # Recupera o registrador salvo do endereco de busca.
    lw    $ra, 60($sp)             # Recupera o endereco de retorno ao chamador.
    addiu $sp, $sp, 64             # Devolve todo o frame e restaura o valor de $sp.

limparAp_completoRetorno:           # Finaliza tanto os erros iniciais como a busca completa.
    jr    $ra                      # Retorna codigo em $v0 e registro ou mensagem em $v1.
    nop                            # Protege o delay slot do retorno.
