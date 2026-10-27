# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: saidaApMMIO.asm
# Objetivo: imprimir um texto no Display MMIO do MARS.
# ==============================================================

# Entrada: a0 = endereco do texto; a1 = limite de caracteres.
# Limite zero significa imprimir ate encontrar o terminador nulo.
# Limite positivo permite imprimir um campo sem ler alem dele.
# Preserva argumentos, registradores salvos e pilha; usa t0 a t4.
# Requer o Keyboard and Display MMIO Simulator conectado ao programa.
# Exemplo: texto ABC e limite 2 imprime AB.

.text                                      # Inicia as instrucoes da rotina de saida.
.globl ap_imprimirTexto                    # Permite que a consulta chame a impressao diretamente.
ap_imprimirTexto:                          # Recebe o texto e a quantidade maxima de caracteres.
    move $t0, $a0                          # Usa uma copia do endereco para preservar a0.
    move $t4, $a1                          # Usa uma copia do limite para contar os caracteres.
    li $t1, 0xFFFF0008                     # Aponta para o controle do display.
ap_textoProximo:                           # Seleciona um caractere do texto.
    lbu $t2, 0($t0)                        # Le o byte atual sem alterar o texto.
    beq $t2, $zero, ap_textoFim            # O byte zero marca o fim da string.
    nop                                    # Nao faz trabalho no atraso deste desvio.
ap_textoEsperar:                           # So envia quando o display estiver disponivel.
    lw $t3, 0($t1)                         # Le o registrador de controle do display.
    andi $t3, $t3, 1                       # Isola o bit zero, que indica disponibilidade.
    beq $t3, $zero, ap_textoEsperar        # Se o display estiver ocupado, aguarda.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    sw $t2, 4($t1)                         # Escreve o caractere no registrador de dados 0xFFFF000C.
    addiu $t0, $t0, 1                      # Avanca para o caractere seguinte.
    beq $a1, $zero, ap_textoProximo        # Sem limite, continua ate o terminador nulo.
    nop                                    # Nao faz trabalho no atraso deste desvio.
    addiu $t4, $t4, -1                     # Um caractere foi impresso; falta um a menos.
    bne $t4, $zero, ap_textoProximo        # Com limite, para quando a quantidade chegar a zero.
    nop                                    # Nao faz trabalho no atraso deste desvio.
ap_textoFim:                               # Finaliza a impressao do texto.
    jr $ra                                 # Volta para a consulta que chamou esta rotina.
    nop                                    # Nao faz trabalho no atraso deste retorno.
