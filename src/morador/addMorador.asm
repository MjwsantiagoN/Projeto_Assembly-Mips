# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: addMorador.asm
# Descricao: Comando cmd_1 (addMorador --<AP> --<nome>): adiciona um
#            morador ao apartamento, respeitando o limite de 6.
# Entrada:   $a0 = string do AP (option1), $a1 = string do nome (option2),
#            ambas terminadas em NULL (o main separa as opcoes).
# Saida:     $v0 = 0 se adicionou, 1 se deu erro (a mensagem ja e impressa aqui).
# Depende:   print_str (Auxiliares/MMIO.asm, $a0 = string), ap_to_index, ap_base, strlen e memcpy (Auxiliares).
# ==============================================================

.data                           # Segmento de dados
msg_add_ap_invalido: .asciiz "Falha: AP invalido\n"                          # erro de AP
msg_add_ap_cheio:    .asciiz "Falha: AP com numero max de moradores\n"      # erro de limite

.text                           # Segmento de codigo
.globl addMorador               # Torna addMorador visivel para os outros arquivos

# $a0 = AP (string), $a1 = nome (string)
addMorador:                     # Entrada da rotina addMorador
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

    li   $t1, NOME_TAM              # t1 = tamanho de cada slot de nome (48 bytes)
    mul  $t1, $s2, $t1              # t1 = qtd * NOME_TAM
    add  $s3, $s1, $t1              # s3 = base + qtd*NOME_TAM
    addi $s3, $s3, AP_NOMES         # s3 = endereco do primeiro slot livre

    move $a0, $s0                   # a0 = nome
    jal  strlen                     # v0 = tamanho do nome
    li   $t0, NOME_TAM              # t0 = tamanho do slot
    addi $t0, $t0, -1               # t0 = maximo de caracteres (slot - NULL = 47)
    ble  $v0, $t0, add_mor_copia    # se cabe, segue
    move $v0, $t0                   # senao, trunca no maximo de caracteres

add_mor_copia:                  # Copia o nome para o slot livre
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

add_mor_ap_invalido:            # AP invalido: mensagem de erro
    la   $a0, msg_add_ap_invalido   # a0 = mensagem de AP invalido
    jal  print_str                  # imprime
    li   $v0, 1                     # retorno: erro
    j    add_mor_fim                # vai para o epilogo

add_mor_cheio:                  # AP cheio: mensagem de erro
    la   $a0, msg_add_ap_cheio      # a0 = mensagem de limite de moradores
    jal  print_str                  # imprime
    li   $v0, 1                     # retorno: erro

add_mor_fim:                    # Epilogo: restaura registradores e retorna
    lw   $s3, 0($sp)                # restaura s3
    lw   $s2, 4($sp)                # restaura s2
    lw   $s1, 8($sp)                # restaura s1
    lw   $s0, 12($sp)               # restaura s0
    lw   $ra, 16($sp)               # restaura ra
    addi $sp, $sp, 20               # libera a pilha
    jr   $ra                        # retorna para o main
