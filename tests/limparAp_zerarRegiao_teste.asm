# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: limparAp_zerarRegiao_teste.asm
# Descricao: teste isolado da limpeza sem depender do layout do AP.
# Executar este arquivo separadamente do shell no simulador MARS.
# ==============================================================

.data                              # Inicia os dados exclusivos do teste.
teste_guardaAntes: .byte 90         # Marca o byte anterior que deve ser preservado.
teste_regiao: .byte 11, 22, 33, 44  # Reserva quatro bytes nao zerados para limpar.
teste_guardaDepois: .byte 107       # Marca o byte posterior que deve ser preservado.
teste_outroAp: .byte 77             # Representa dados fora da regiao solicitada.
teste_pass: .asciiz "PASS: limparAp_zerarRegiao (6 cenarios)\n" # Identifica o sucesso.
teste_fail: .asciiz "FAIL: limparAp_zerarRegiao\n" # Identifica uma falha.

.text                              # Inicia as instrucoes do teste isolado.
.globl main                        # Disponibiliza a entrada do programa de teste.

main:                              # Inicia a sequencia dos seis cenarios de teste.
    la    $a0, teste_regiao         # Seleciona a regiao que deve ser limpa.
    li    $a1, 4                   # Solicita a limpeza de exatamente quatro bytes.
    jal   limparAp_zerarRegiao      # Executa o cenario de limpeza normal.
    nop                            # Permite executar com delayed branching.
    li    $t2, 4                   # Define a quantidade esperada no retorno.
    bne   $v0, $t2, teste_falha     # Falha se a rotina nao informou quatro bytes.
    nop                            # Protege o delay slot do desvio.
    la    $t2, teste_regiao         # Recupera o endereco esperado do argumento.
    bne   $a0, $t2, teste_falha     # Verifica que o endereco original foi preservado.
    nop                            # Protege o delay slot do desvio.
    li    $t2, 4                   # Recupera o tamanho esperado do argumento.
    bne   $a1, $t2, teste_falha     # Verifica que o tamanho original foi preservado.
    nop                            # Protege o delay slot do desvio.
    lbu   $t2, teste_regiao         # Le o primeiro byte da regiao limpa.
    lbu   $t3, teste_regiao+1       # Le o segundo byte da regiao limpa.
    or    $t2, $t2, $t3            # Acumula qualquer bit que nao tenha sido zerado.
    lbu   $t3, teste_regiao+2       # Le o terceiro byte da regiao limpa.
    or    $t2, $t2, $t3            # Acumula qualquer bit restante do terceiro byte.
    lbu   $t3, teste_regiao+3       # Le o quarto byte da regiao limpa.
    or    $t2, $t2, $t3            # Acumula qualquer bit restante do quarto byte.
    bne   $t2, $zero, teste_falha   # Exige que todos os quatro bytes estejam zerados.
    nop                            # Protege o delay slot do desvio.

    la    $a0, teste_guardaAntes    # Seleciona um byte que deve continuar preenchido.
    li    $a1, 0                   # Solicita uma limpeza de tamanho zero.
    jal   limparAp_zerarRegiao      # Executa o cenario sem bytes a limpar.
    nop                            # Protege o delay slot da chamada.
    bne   $v0, $zero, teste_falha   # Exige retorno zero para o tamanho zero.
    nop                            # Protege o delay slot do desvio.

    la    $a0, teste_outroAp        # Seleciona dados que nao podem ser modificados.
    li    $a1, -1                  # Fornece uma quantidade invalida de bytes.
    jal   limparAp_zerarRegiao      # Executa o cenario de tamanho negativo.
    nop                            # Protege o delay slot da chamada.
    li    $t2, -1                  # Define o retorno esperado para argumento invalido.
    bne   $v0, $t2, teste_falha     # Exige que o tamanho negativo seja rejeitado.
    nop                            # Protege o delay slot do desvio.

    move  $a0, $zero               # Fornece um endereco nulo para a rotina.
    li    $a1, 1                   # Solicita acesso a um byte nesse endereco invalido.
    jal   limparAp_zerarRegiao      # Executa o cenario de endereco nulo e tamanho positivo.
    nop                            # Protege o delay slot da chamada.
    li    $t2, -1                  # Define o retorno esperado para argumento invalido.
    bne   $v0, $t2, teste_falha     # Exige rejeicao sem tentar acessar o endereco nulo.
    nop                            # Protege o delay slot do desvio.

    move  $a0, $zero               # Mantem o endereco nulo para o proximo cenario.
    move  $a1, $zero               # Define tamanho zero, que dispensa acesso a memoria.
    jal   limparAp_zerarRegiao      # Executa o cenario de endereco nulo e tamanho zero.
    nop                            # Protege o delay slot da chamada.
    bne   $v0, $zero, teste_falha   # Exige sucesso sem acesso a memoria.
    nop                            # Protege o delay slot do desvio.

    la    $a0, teste_regiao         # Seleciona novamente a regiao que ja esta zerada.
    li    $a1, 4                   # Solicita novamente os mesmos quatro bytes.
    jal   limparAp_zerarRegiao      # Executa o cenario de repeticao da limpeza.
    nop                            # Protege o delay slot da chamada.
    li    $t2, 4                   # Define o retorno esperado para a segunda limpeza.
    bne   $v0, $t2, teste_falha     # Exige sucesso tambem para uma regiao ja zerada.
    nop                            # Protege o delay slot do desvio.

    lbu   $t2, teste_guardaAntes    # Recupera a marca anterior a regiao limpa.
    li    $t3, 90                  # Define o valor original dessa marca.
    bne   $t2, $t3, teste_falha     # Detecta escrita antes do inicio solicitado.
    nop                            # Protege o delay slot do desvio.
    lbu   $t2, teste_guardaDepois   # Recupera a marca posterior a regiao limpa.
    li    $t3, 107                 # Define o valor original da marca posterior.
    bne   $t2, $t3, teste_falha     # Detecta escrita depois do limite solicitado.
    nop                            # Protege o delay slot do desvio.
    lbu   $t2, teste_outroAp        # Recupera o dado que representa outro apartamento.
    li    $t3, 77                  # Define o valor original desse dado externo.
    bne   $t2, $t3, teste_falha     # Detecta alteracoes fora da regiao autorizada.
    nop                            # Protege o delay slot do desvio.
    la    $a0, teste_pass           # Seleciona a mensagem de sucesso dos seis cenarios.
    li    $v0, 4                   # Seleciona a impressao de string do teste no MARS.
    syscall                        # Imprime o resultado do teste isolado.
    li    $a0, 0                   # Define o codigo de saida de sucesso.
    li    $v0, 17                  # Seleciona o encerramento com codigo de saida.
    syscall                        # Encerra o programa de teste com sucesso.

teste_falha:                       # Trata qualquer verificacao que nao passou.
    la    $a0, teste_fail           # Seleciona a mensagem de falha do teste.
    li    $v0, 4                   # Seleciona a impressao de string do MARS.
    syscall                        # Informa que algum resultado divergiu do esperado.
    li    $a0, 1                   # Define um codigo de saida indicando falha.
    li    $v0, 17                  # Seleciona o encerramento com codigo de saida.
    syscall                        # Encerra o teste informando a falha.

.include "../src/apartamento/limparAp.asm" # Inclui apenas a rotina em teste.
