# Grupo: Brenno, Joao, Leticia e Marcos
# Projeto 01 - 1VA - Arquitetura e Organizacao de Computadores - 2026.2
# Arquivo: tabelaAp.asm
# Tabela usada pela integracao dos comandos de apartamentos.
# PROPOSTA de compatibilizacao: ID +0, moradores +4, nomes +8 em slots de 48.
# Garagem +296..447 igual ao modulo de Brenno. Nao inclui o layout do PR #7.
.eqv APARTAMENTO_PASSO 448                  # Tamanho minimo compativel com a garagem publicada.
.data                                       # Inicia a tabela em memoria.
.align 2                                    # Alinha os registros para acesso word.
ap_tabela: .space 10752                     # Reserva 24 registros de 448 bytes.
.text                                       # Inicia a rotina de identificacao.
.globl ap_inicializarTabela                 # Permite inicializar antes de entrar no shell.
ap_inicializarTabela:                       # Preenche apenas IDs; nao apaga moradores nem veiculos.
la $t0, ap_tabela                           # Aponta para o primeiro registro.
li $t1, 101                                 # Define o primeiro ID.
li $t2, 0                                   # Conta os registros inicializados.
ap_inicializarLoop:                         # Grava um ID por repeticao.
sw $t1, 0($t0)                              # Mantem o ID na primeira word.
addiu $t2, $t2, 1                           # Conta mais um registro.
li $t3, 24                                  # Define o limite da tabela.
beq $t2, $t3, ap_inicializarFim             # Para depois do ultimo AP.
nop                                         # Protege o atraso do desvio.
addiu $t0, $t0, APARTAMENTO_PASSO           # Avanca para o proximo registro.
andi $t3, $t1, 1                            # Distingue AP terminado em 01 ou 02.
beq $t3, $zero, ap_inicializarAndar         # Depois de 02, muda de andar.
nop                                         # Protege o atraso do desvio.
addiu $t1, $t1, 1                           # Passa do primeiro para o segundo AP.
j ap_inicializarLoop                        # Grava o ID seguinte.
nop                                         # Protege o atraso do salto.
ap_inicializarAndar:                        # Seleciona o primeiro AP do proximo andar.
addiu $t1, $t1, 99                          # Por exemplo, 102 passa a 201.
j ap_inicializarLoop                        # Continua ate 1202.
nop                                         # Protege o atraso do salto.
ap_inicializarFim:                          # Finaliza a identificacao da tabela.
jr $ra                                      # Retorna ao chamador.
nop                                         # Protege o atraso do retorno.
