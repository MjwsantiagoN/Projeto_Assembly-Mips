# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: saidaApMMIO_teste.asm
# Objetivo: testar a saida com o bit de disponibilidade simulado.
# Nao valida a janela grafica do dispositivo nem o shell completo.
# ==============================================================

.data                                      # Inicia os dados de teste.
saida_caso: .word 0                        # Guarda o cenario em execucao.
saida_controle: .word 0                    # Guarda o valor original do controle MMIO.
saida_texto: .asciiz "ABC"                 # Texto usado nos dois primeiros testes.
saida_vazio: .asciiz ""                    # String que nao deve enviar nenhum caractere.
saida_ok: .asciiz "PASS: saidaApMMIO (3 cenarios)\n" # Mensagem de sucesso.
saida_erro: .asciiz "FAIL: saidaApMMIO, cenario " # Prefixo da mensagem de erro.
saida_nl: .asciiz "\n"                     # Finaliza a mensagem de erro.
.text                                      # Inicia as instrucoes do teste.
.globl main                                # Define a entrada do teste independente.
main:                                      # Simula um display continuamente disponivel.
    li $t7, 0xFFFF0008                     # Seleciona o controle do display.
    lw $t6, 0($t7)                         # Le o valor anterior do controle.
    sw $t6, saida_controle                 # Preserva o valor para o fim do teste.
    li $t6, 1                              # Define o bit zero de disponibilidade.
    sw $t6, 0($t7)                         # Simula um display que sempre aceita caracteres.

# Sem limite, envia ABC e deixa C no registrador de dados.
    li $t0, 1                              # Identifica este cenario.
    sw $t0, saida_caso                     # Guarda o identificador.
    la $a0, saida_texto                    # Seleciona o texto a imprimir.
    li $a1, 0                              # Seleciona o limite pedido.
    move $s0, $a0                          # Guarda o argumento de endereco.
    move $s1, $a1                          # Guarda o argumento de limite.
    move $s2, $sp                          # Guarda a posicao da pilha.
    jal ap_imprimirTexto                   # Executa a saida real sobre o MMIO simulado.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    li $t7, 0xFFFF000C                     # Seleciona os dados do display.
    lw $t0, 0($t7)                         # Le o ultimo caractere enviado.
    li $t1, 67                             # Define o ultimo caractere esperado.
    bne $t0, $t1, saida_falhou             # Detecta escrita diferente da esperada.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    bne $a0, $s0, saida_falhou             # Confere preservacao do endereco.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    bne $a1, $s1, saida_falhou             # Confere preservacao do limite.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    bne $sp, $s2, saida_falhou             # Confere que a rotina nao alterou a pilha.
    nop                                    # Nao faz trabalho no atraso deste desvio.

# Com limite dois, envia AB e deixa B no registrador de dados.
    li $t0, 2                              # Identifica este cenario.
    sw $t0, saida_caso                     # Guarda o identificador.
    la $a0, saida_texto                    # Seleciona o texto a imprimir.
    li $a1, 2                              # Seleciona o limite pedido.
    move $s0, $a0                          # Guarda o argumento de endereco.
    move $s1, $a1                          # Guarda o argumento de limite.
    move $s2, $sp                          # Guarda a posicao da pilha.
    jal ap_imprimirTexto                   # Executa a saida real sobre o MMIO simulado.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    li $t7, 0xFFFF000C                     # Seleciona os dados do display.
    lw $t0, 0($t7)                         # Le o ultimo caractere enviado.
    li $t1, 66                             # Define o ultimo caractere esperado.
    bne $t0, $t1, saida_falhou             # Detecta escrita diferente da esperada.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    bne $a0, $s0, saida_falhou             # Confere preservacao do endereco.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    bne $a1, $s1, saida_falhou             # Confere preservacao do limite.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    bne $sp, $s2, saida_falhou             # Confere que a rotina nao alterou a pilha.
    nop                                    # Nao faz trabalho no atraso deste desvio.

# Texto vazio nao envia nada e deixa o B anterior intacto.
    li $t0, 3                              # Identifica este cenario.
    sw $t0, saida_caso                     # Guarda o identificador.
    la $a0, saida_vazio                    # Seleciona o texto a imprimir.
    li $a1, 0                              # Seleciona o limite pedido.
    move $s0, $a0                          # Guarda o argumento de endereco.
    move $s1, $a1                          # Guarda o argumento de limite.
    move $s2, $sp                          # Guarda a posicao da pilha.
    jal ap_imprimirTexto                   # Executa a saida real sobre o MMIO simulado.
    nop                                    # Nao faz trabalho no atraso desta chamada.
    li $t7, 0xFFFF000C                     # Seleciona os dados do display.
    lw $t0, 0($t7)                         # Le o ultimo caractere enviado.
    li $t1, 66                             # Define o ultimo caractere esperado.
    bne $t0, $t1, saida_falhou             # Detecta escrita diferente da esperada.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    bne $a0, $s0, saida_falhou             # Confere preservacao do endereco.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    bne $a1, $s1, saida_falhou             # Confere preservacao do limite.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    bne $sp, $s2, saida_falhou             # Confere que a rotina nao alterou a pilha.
    nop                                    # Nao faz trabalho no atraso deste desvio.

    li $t7, 0xFFFF0008                     # Recupera o controle do display.
    lw $t6, saida_controle                 # Recupera o valor anterior.
    sw $t6, 0($t7)                         # Restaura o controle apos os testes.
    la $a0, saida_ok                       # Seleciona a mensagem de sucesso.
    li $v0, 4                              # Seleciona impressao apenas para o teste.
    syscall                                # Mostra a aprovacao dos tres cenarios.
    move $a0, $zero                        # Define codigo de sucesso.
    li $v0, 17                             # Seleciona encerramento com codigo.
    syscall                                # Finaliza o teste.
saida_falhou:                              # Identifica um resultado incorreto.
    la $a0, saida_erro                     # Seleciona a mensagem de erro.
    li $v0, 4                              # Seleciona impressao de string.
    syscall                                # Mostra o prefixo do erro.
    lw $a0, saida_caso                     # Seleciona o numero do cenario.
    li $v0, 1                              # Seleciona impressao de inteiro.
    syscall                                # Mostra o cenario que falhou.
    la $a0, saida_nl                       # Seleciona a quebra de linha.
    li $v0, 4                              # Seleciona impressao de string.
    syscall                                # Finaliza a mensagem.
    li $a0, 1                              # Define codigo de falha.
    li $v0, 17                             # Seleciona encerramento com codigo.
    syscall                                # Encerra com falha.

.include "../src/Auxiliares/saidaApMMIO.asm" # Inclui a rotina real de saida, sem a consulta.
