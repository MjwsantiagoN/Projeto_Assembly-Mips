# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores - 2026.2
# Arquivo: infoApTodos.asm
# Objetivo: consultar os 24 APs em ordem crescente, inclusive vazios.
# ==============================================================

# Entrada: a0 = tabela; a1 = passo entre registros (pelo menos 448).
# A tabela deve conter os 24 IDs: 101,102,201,202,...,1201,1202.
# A ordem fisica dos registros nao importa: a consulta individual busca o ID.
# Saida: v0 = 0 e v1 = 24 no sucesso; em erro, repassa v0/v1 da consulta.
# Um erro interrompe a listagem; linhas anteriores podem ja ter sido mostradas.
# Preserva argumentos, registradores salvos e pilha. Nao modifica a tabela.
# Usa s0 = tabela, s1 = passo, s2 = numero atual, s3 = quantidade mostrada.
# Requer infoAp.asm e uma implementacao de ap_imprimirTexto.

.text                                     # Inicia as instrucoes.
.globl infoAp_listarTodos                  # Exporta a consulta completa.
infoAp_listarTodos:                        # Guarda o contexto antes das consultas.
    addiu $sp, $sp, -48                    # Reserva dados salvos e 16 bytes de argumentos.
    sw $ra, 44($sp)                        # Guarda o retorno do chamador.
    sw $s0, 40($sp)                        # Preserva s0.
    sw $s1, 36($sp)                        # Preserva s1.
    sw $s2, 32($sp)                        # Preserva s2.
    sw $s3, 28($sp)                        # Preserva s3.
    sw $a0, 24($sp)                        # Guarda a tabela recebida.
    sw $a1, 20($sp)                        # Guarda o passo recebido.
    sw $a2, 16($sp)                        # Guarda a2, usado na chamada individual.
    move $s0, $a0                         # Mantem a tabela entre as chamadas.
    move $s1, $a1                         # Mantem o passo entre as chamadas.
    li $s2, 101                           # Comeca pelo primeiro AP do primeiro andar.
    li $s3, 0                             # Ainda nao mostrou nenhum AP.
infoAp_todosLoop:                         # Consulta um numero por repeticao.
    move $a0, $s0                         # Fornece a tabela.
    move $a1, $s2                         # Fornece o numero atual.
    move $a2, $s1                         # Fornece a distancia entre registros.
    jal infoAp_executar                   # Reutiliza toda a exibicao e validacao individual.
    nop                                   # Deixa o atraso da chamada sem trabalho.
    bne $v0, $zero, infoAp_todosRetornar  # Interrompe se algum registro nao puder ser consultado.
    nop                                   # Deixa o atraso do desvio sem trabalho.
    addiu $s3, $s3, 1                     # Conta mais um AP mostrado.
    li $t0, 24                            # Define o total de apartamentos.
    beq $s3, $t0, infoAp_todosSucesso     # Depois do vigesimo quarto, termina.
    nop                                   # Deixa o atraso do desvio sem trabalho.
    andi $t0, $s2, 1                      # Numero terminado em 01 e impar; em 02 e par.
    beq $t0, $zero, infoAp_todosAndar     # Depois do segundo AP, muda de andar.
    nop                                   # Deixa o atraso do desvio sem trabalho.
    addiu $s2, $s2, 1                     # Passa de 101 para 102, por exemplo.
    j infoAp_todosLoop                    # Consulta o segundo AP do mesmo andar.
    nop                                   # Deixa o atraso do salto sem trabalho.
infoAp_todosAndar:                        # Avanca do segundo AP para o primeiro do andar seguinte.
    addiu $s2, $s2, 99                    # Passa de 102 para 201, por exemplo.
    j infoAp_todosLoop                    # Consulta o primeiro AP do proximo andar.
    nop                                   # Deixa o atraso do salto sem trabalho.
infoAp_todosSucesso:                      # Prepara o resultado da listagem completa.
    li $v0, 0                             # Informa sucesso.
    move $v1, $s3                         # Retorna os 24 apartamentos mostrados.
infoAp_todosRetornar:                     # Recupera o contexto sem alterar os retornos.
    lw $a2, 16($sp)                       # Recupera a2.
    lw $a1, 20($sp)                       # Recupera o passo original.
    lw $a0, 24($sp)                       # Recupera a tabela original.
    lw $s3, 28($sp)                       # Devolve o valor anterior de s3.
    lw $s2, 32($sp)                       # Devolve o valor anterior de s2.
    lw $s1, 36($sp)                       # Devolve o valor anterior de s1.
    lw $s0, 40($sp)                       # Devolve o valor anterior de s0.
    lw $ra, 44($sp)                       # Recupera o retorno do chamador.
    addiu $sp, $sp, 48                    # Libera todo o espaco reservado.
    jr $ra                                # Volta para o chamador.
    nop                                   # Deixa o atraso do retorno sem trabalho.
