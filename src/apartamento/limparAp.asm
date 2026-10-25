# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: limparAp.asm
# Descricao: auxiliares para zerar memoria e limpar a garagem do AP.
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
