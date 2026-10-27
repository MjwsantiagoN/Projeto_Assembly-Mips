# Grupo: Brenno, Joao, Leticia e Marcos
# Projeto 01 - 1VA - Arquitetura e Organizacao de Computadores - 2026.2
# Arquivo: main.asm
# Integracao dos comandos de apartamentos: limparAp, infoAp e infoAp --all.
# Montar apenas este arquivo; desmarcar Assemble all files in directory.
# Conectar Tools > Keyboard and Display MMIO Simulator > Connect to MIPS.
# Esta etapa nao inclui cadastro, administracao nem persistencia dos colegas.
.data                                       # Inicia as mensagens do shell.
ap_banner: .asciiz "LBFM-shell>> "          # Banner com as iniciais do grupo.
ap_erroLinhaLonga: .asciiz "Comando invalido\n"# Uma linha longa e rejeitada por inteiro.
.text                                       # Inicia a entrada do programa.
.globl main                                 # Exporta o ponto inicial.
main:                                       # Prepara os identificadores antes da primeira leitura.
jal ap_inicializarTabela                    # Inicializa 101,102,...,1202 sem alterar os campos de cadastro.
nop                                         # Protege o atraso da chamada.
ap_shellLoop:                               # Aguarda e executa uma linha por vez.
la $a0, ap_banner                           # Seleciona o banner.
li $a1, 0                                   # Imprime ate o terminador.
jal ap_imprimirTexto                        # Mostra o prompt no display MMIO.
nop                                         # Protege o atraso da chamada.
jal ap_lerLinha                             # Le a linha completa pelo teclado MMIO.
nop                                         # Protege o atraso da chamada.
bne $v0, $zero, ap_shellLinhaLonga          # Nao executa um prefixo truncado de uma linha longa.
nop                                         # Protege o atraso do desvio.
la $a0, ap_linha                            # Seleciona a linha terminada em zero.
jal ap_executarLinha                        # Interpreta os comandos de apartamentos.
nop                                         # Protege o atraso da chamada.
j ap_shellLoop                              # Volta a aguardar outra linha.
nop                                         # Protege o atraso do salto.
ap_shellLinhaLonga:                         # Informa a linha que ultrapassou o limite.
la $a0, ap_erroLinhaLonga                   # Seleciona o erro.
li $a1, 0                                   # Usa texto terminado em zero.
jal ap_imprimirTexto                        # Mostra a rejeicao.
nop                                         # Protege o atraso da chamada.
j ap_shellLoop                              # Retoma com um novo banner.
nop                                         # Protege o atraso do salto.

.include "apartamento/tabelaAp.asm"         # Inclui a tabela desta proposta de integracao.
.include "apartamento/comandosAp.asm"       # Inclui o interpretador dos comandos de apartamentos.
.include "apartamento/limparAp.asm"         # Inclui as rotinas de limpeza.
.include "apartamento/infoAp.asm"           # Inclui a consulta individual.
.include "apartamento/infoApTodos.asm"      # Inclui a listagem completa.
.include "Auxiliares/saidaApMMIO.asm"       # Inclui a saida por MMIO.
.include "Auxiliares/entradaApMMIO.asm"     # Inclui a leitura por MMIO.
