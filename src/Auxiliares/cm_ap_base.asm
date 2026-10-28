# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: cm_ap_base.asm
# Descricao: Rotinas compartilhadas por todos os comandos que recebem um AP (cmd_*):
#            cm_ap_base (texto do AP -> endereco do registro em ap_tabela) e
#            cm_erro (imprime uma mensagem). Guarda tambem as mensagens comuns
#            "Comando invalido" e "Falha: AP invalido". Usa apenas $t0-$t5 e $v0.
# ==============================================================

.data                           # Segmento de dados
cm_invalido:   .asciiz "Comando invalido\n"      # Opcoes faltando ou sobrando
cm_ap_inval:   .asciiz "Falha: AP invalido\n"    # AP fora de 101..1202 (final 01/02)

.text                           # Segmento de codigo

# cm_erro: imprime a mensagem em $a0 (atalho usado pelos comandos)
cm_erro:                        # Entrada de cm_erro
    j    mmio_print_string          # Imprime e retorna direto a quem chamou cm_erro

# cm_ap_base: converte o texto do AP no endereco do registro do AP em ap_tabela.
# AP valido: 3 ou 4 digitos, sem zero a esquerda, andar 1..12 e final 01 ou 02.
# $a0 = texto do AP     $v0 = endereco do registro, ou 0 se o AP for invalido
cm_ap_base:                     # Entrada de cm_ap_base
    move $t0, $a0                   # $t0 percorre o texto
    li   $t1, 0                     # $t1 = valor numerico acumulado
    li   $t2, 0                     # $t2 = quantidade de digitos
    lbu  $t3, 0($t0)                # Primeiro caractere
    li   $t4, 48                    # '0'
    beq  $t3, $t4, cm_ap_inv        # Zero a esquerda: invalido
cm_ap_digito:                   # Laco: converte um digito do texto do AP
    lbu  $t3, 0($t0)                # Caractere atual
    beq  $t3, $zero, cm_ap_fim_txt  # Fim do texto
    addi $t3, $t3, -48              # Converte ASCII em valor
    sltiu $t4, $t3, 10              # E um digito (0 a 9)?
    beq  $t4, $zero, cm_ap_inv      # Nao: invalido
    addi $t2, $t2, 1                # Conta o digito
    slti $t4, $t2, 5                # No maximo 4 digitos
    beq  $t4, $zero, cm_ap_inv      # Mais que 4: invalido
    mul  $t1, $t1, 10               # Abre uma casa decimal
    add  $t1, $t1, $t3              # Soma o digito
    addi $t0, $t0, 1                # Proximo caractere
    j    cm_ap_digito               # Repete
cm_ap_fim_txt:                  # Fim do texto: valida quantidade de digitos, andar e final
    slti $t4, $t2, 3                # Menos de 3 digitos?
    bne  $t4, $zero, cm_ap_inv      # Invalido
    li   $t4, 100                   # Separa andar e final
    div  $t1, $t4                   # numero / 100
    mflo $t3                        # $t3 = andar
    mfhi $t4                        # $t4 = final
    addi $t3, $t3, -1               # andar - 1 (0..11 se valido)
    sltiu $t5, $t3, 12              # Andar entre 1 e 12?
    beq  $t5, $zero, cm_ap_inv      # Nao: invalido
    addi $t4, $t4, -1               # final - 1 (0..1 se valido)
    sltiu $t5, $t4, 2               # Final 01 ou 02?
    beq  $t5, $zero, cm_ap_inv      # Nao: invalido
    sll  $t3, $t3, 1                # (andar - 1) * 2
    add  $t3, $t3, $t4              # Indice do AP (0..23)
    li   $t5, AP_TAM                # Tamanho de cada registro
    mul  $t3, $t3, $t5              # Deslocamento dentro da tabela
    la   $v0, ap_tabela             # Inicio da tabela
    add  $v0, $v0, $t3              # Endereco do registro do AP
    jr   $ra                        # Retorna
cm_ap_inv:                      # AP invalido: retorna 0
    li   $v0, 0                     # 0 = AP invalido
    jr   $ra                        # Retorna
