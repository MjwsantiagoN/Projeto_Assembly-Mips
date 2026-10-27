# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: addMorador.asm
# Descricao: Comando cmd_1 (addMorador --<AP> --<nome>): adiciona um
#            morador ao apartamento, respeitando o limite de 6.
# Entrada:   $a0 = string do AP (option1), $a1 = string do nome (option2),
#            ambas terminadas em NULL (o main separa as opcoes).
# Saida:     $v0 = 0 se adicionou, 1 se deu erro (a mensagem ja e impressa aqui).
# Depende:   print_str (io.asm, $a0 = string), ap_to_index, ap_base, strlen e memcpy (Auxiliares).
# ==============================================================

.data
msg_add_ap_invalido: .asciiz "Falha: AP invalido\n"                          # erro de AP
msg_add_ap_cheio:    .asciiz "Falha: AP com numero max de moradores\n"      # erro de limite

.text
.globl addMorador

# $a0 = AP (string), $a1 = nome (string)
addMorador:
    addi $sp, $sp, -20              # reserva 5 palavras na pilha
    sw   $ra, 16($sp)               # salva o endereco de retorno
    sw   $s0, 12($sp)               # salva s0 (usaremos para o nome / tamanho)
    sw   $s1, 8($sp)                # salva s1 (base do AP)
    sw   $s2, 4($sp)                # salva s2 (quantidade de moradores)
    sw   $s3, 0($sp)                # salva s3 (endereco do slot destino)

    move $s0, $a1                   # s0 = ponteiro do nome (a1 sera sobrescrito pelas chamadas)
    jal  ap_to_index                # a0 ja tem a string do AP; v0 = indice ou -1
    bltz $v0, add_mor_ap_invalido   # indice negativo: AP invalido

    move $a0, $v0                   # a0 = indice do AP
    jal  ap_base                    # v0 = endereco do bloco do AP
    move $s1, $v0                   # s1 = base do AP

    lw   $s2, AP_QTD_MOR($s1)       # s2 = quantidade atual de moradores
    li   $t0, MAX_MORADORES         # t0 = 6
    bge  $s2, $t0, add_mor_cheio    # se ja tem 6 (ou mais), recusa

    sll  $t1, $s2, 5                # t1 = qtd * 32 (cada slot tem 32 bytes)
    add  $s3, $s1, $t1              # s3 = base + qtd*32
    addi $s3, $s3, AP_NOMES         # s3 = endereco do primeiro slot livre

    move $a0, $s0                   # a0 = nome
    jal  strlen                     # v0 = tamanho do nome
    li   $t0, 31                    # t0 = maximo de caracteres (32 - NULL)
    ble  $v0, $t0, add_mor_copia    # se cabe, segue
    li   $v0, 31                    # senao, trunca em 31 caracteres

add_mor_copia:
    move $a0, $s3                   # a0 = destino (slot livre)
    move $a1, $s0                   # a1 = origem (nome)
    move $a2, $v0                   # a2 = quantidade de bytes a copiar
    move $s0, $v0                   # s0 = tamanho (reaproveita s0, o ponteiro do nome nao e mais usado)
    jal  memcpy                     # copia o nome para o slot
    add  $t0, $s3, $s0              # t0 = fim do nome copiado
    sb   $zero, 0($t0)              # grava o NULL terminador

    addi $s2, $s2, 1                # quantidade de moradores + 1
    sw   $s2, AP_QTD_MOR($s1)       # grava a nova quantidade (AP passa a ser nao vazio)
    li   $v0, 0                     # retorno: sucesso
    j    add_mor_fim                # vai para o epilogo

add_mor_ap_invalido:
    la   $a0, msg_add_ap_invalido   # a0 = mensagem de AP invalido
    jal  print_str                  # imprime
    li   $v0, 1                     # retorno: erro
    j    add_mor_fim                # vai para o epilogo

add_mor_cheio:
    la   $a0, msg_add_ap_cheio      # a0 = mensagem de limite de moradores
    jal  print_str                  # imprime
    li   $v0, 1                     # retorno: erro

add_mor_fim:
    lw   $s3, 0($sp)                # restaura s3
    lw   $s2, 4($sp)                # restaura s2
    lw   $s1, 8($sp)                # restaura s1
    lw   $s0, 12($sp)               # restaura s0
    lw   $ra, 16($sp)               # restaura ra
    addi $sp, $sp, 20               # libera a pilha
    jr   $ra                        # retorna para o main
