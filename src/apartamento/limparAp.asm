# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: limparAp.asm
# Descricao: auxiliar para zerar uma regiao de dados do apartamento.
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
