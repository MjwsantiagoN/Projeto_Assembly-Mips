# Grupo: Brenno, Joao, Leticia e Marcos
# Projeto 01 - 1VA - Arquitetura e Organizacao de Computadores - 2026.2
# Arquivo: entradaApMMIO.asm
# Le uma linha de ate 127 caracteres pelo teclado MMIO, com eco no display.
# Backspace apaga o ultimo caractere. CR e ignorado; LF encerra a linha.
# Se ultrapassar 127 caracteres, descarta a linha inteira ate LF e retorna -1.
# Entrada: nenhuma. Saida: v0 = 0 ou -1; texto em ap_linha.
# Preserva registradores salvos e pilha. Usa ap_imprimirTexto para o eco.
.data                                       # Inicia o buffer e as mensagens de eco.
ap_linha: .space 128                        # Reserva 127 caracteres e o byte zero.
ap_eco: .space 2                            # Reserva um caractere e seu terminador.
ap_ecoNovaLinha: .asciiz "\n"               # Texto para ecoar Enter.
ap_ecoApagar: .asciiz "\b \b"               # Recua, apaga visualmente e recua outra vez.
.text                                       # Inicia a leitura por polling.
.globl ap_lerLinha                          # Exporta a entrada MMIO.
ap_lerLinha:                                # Guarda os dados usados entre as impressoes.
addiu $sp, $sp, -32                         # Reserva dados salvos e argumentos.
sw $ra, 28($sp)                             # Guarda o retorno.
sw $s0, 24($sp)                             # Preserva o contador de caracteres.
sw $s1, 20($sp)                             # Preserva o indicador de linha longa.
li $s0, 0                                   # Comeca com linha vazia.
li $s1, 0                                   # A linha ainda cabe no buffer.
ap_tecladoEsperar:                          # Aguarda um caractere.
li $t0, 0xFFFF0000                          # Seleciona o controle do teclado.
lw $t1, 0($t0)                              # Le a disponibilidade.
andi $t1, $t1, 1                            # Isola o bit de caractere pronto.
beq $t1, $zero, ap_tecladoEsperar           # Continua aguardando.
nop                                         # Protege o atraso do desvio.
lw $t2, 4($t0)                              # Le o caractere e libera o teclado para o proximo.
li $t1, 10                                  # ASCII de LF, a quebra de linha.
beq $t2, $t1, ap_tecladoTerminar            # So interpreta depois de receber Enter.
nop                                         # Protege o atraso do desvio.
bne $s1, $zero, ap_tecladoEsperar           # Depois de estourar o limite, descarta ate Enter.
nop                                         # Protege o atraso do desvio.
li $t1, 13                                  # ASCII de CR.
beq $t2, $t1, ap_tecladoEsperar             # Ignora CR para aceitar entradas com CR e LF.
nop                                         # Protege o atraso do desvio.
li $t1, 8                                   # ASCII de backspace.
beq $t2, $t1, ap_tecladoApagar              # Permite corrigir o ultimo caractere.
nop                                         # Protege o atraso do desvio.
li $t1, 127                                 # Codigo alternativo de apagar.
beq $t2, $t1, ap_tecladoApagar              # Trata tambem Delete como backspace.
nop                                         # Protege o atraso do desvio.
sltiu $t1, $t2, 32                          # Detecta outros controles.
bne $t1, $zero, ap_tecladoEsperar           # Ignora controles que nao sao texto.
nop                                         # Protege o atraso do desvio.
li $t1, 127                                 # Define a capacidade util.
beq $s0, $t1, ap_tecladoLonga               # Nao deixa ultrapassar o buffer.
nop                                         # Protege o atraso do desvio.
la $t0, ap_linha                            # Seleciona o inicio do buffer.
addu $t0, $t0, $s0                          # Localiza a posicao livre.
sb $t2, 0($t0)                              # Guarda o caractere.
addiu $s0, $s0, 1                           # Conta mais um caractere.
sb $t2, ap_eco                              # Prepara o eco.
sb $zero, ap_eco+1                          # Termina o texto de um caractere.
la $a0, ap_eco                              # Seleciona o caractere recebido.
li $a1, 0                                   # Imprime ate o terminador.
jal ap_imprimirTexto                        # Mostra o caractere digitado.
nop                                         # Protege o atraso da chamada.
j ap_tecladoEsperar                         # Aguarda o proximo caractere.
nop                                         # Protege o atraso do salto.
ap_tecladoApagar:                           # Corrige a linha e a sua exibicao.
beq $s0, $zero, ap_tecladoEsperar           # Nao apaga antes do inicio do buffer.
nop                                         # Protege o atraso do desvio.
addiu $s0, $s0, -1                          # A proxima letra substituira a ultima.
la $a0, ap_ecoApagar                        # Seleciona o eco de apagar.
li $a1, 0                                   # Usa texto terminado em zero.
jal ap_imprimirTexto                        # Apaga visualmente o caractere.
nop                                         # Protege o atraso da chamada.
j ap_tecladoEsperar                         # Retoma a leitura.
nop                                         # Protege o atraso do salto.
ap_tecladoLonga:                            # Descarta uma linha que nao cabe.
li $s1, 1                                   # Marca a linha como invalida.
j ap_tecladoEsperar                         # Descarta os proximos caracteres ate LF.
nop                                         # Protege o atraso do salto.
ap_tecladoTerminar:                         # Finaliza a string somente ao receber LF.
la $t0, ap_linha                            # Seleciona o buffer.
addu $t0, $t0, $s0                          # Seleciona a posicao depois do texto.
sb $zero, 0($t0)                            # Fecha a string para o interpretador.
la $a0, ap_ecoNovaLinha                     # Seleciona a quebra de linha visual.
li $a1, 0                                   # Usa texto terminado em zero.
jal ap_imprimirTexto                        # Ecoa Enter.
nop                                         # Protege o atraso da chamada.
subu $v0, $zero, $s1                        # Retorna zero se coube ou -1 se ultrapassou o limite.
lw $s1, 20($sp)                             # Recupera s1.
lw $s0, 24($sp)                             # Recupera s0.
lw $ra, 28($sp)                             # Recupera o retorno.
addiu $sp, $sp, 32                          # Libera toda a pilha reservada.
jr $ra                                      # Volta ao shell.
nop                                         # Protege o atraso do retorno.
