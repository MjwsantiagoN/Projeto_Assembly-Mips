# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: rmvMorador.asm
# Descricao: Comando cmd_2 (rmvMorador --<AP> --<nome>): remove um morador
#            do apartamento, compacta a lista de nomes e, se o AP ficar
#            vazio, apaga tambem os automoveis cadastrados.
# Entrada:   $a0 = string do AP (option1), $a1 = string do nome (option2),
#            ambas terminadas em NULL (o main separa as opcoes).
# Saida:     $v0 = 0 se removeu, 1 se deu erro (a mensagem ja e impressa aqui).
# Depende:   print_str (io.asm), ap_to_index, ap_base, strcmp, memcpy e
#            memzero (Auxiliares) e as constantes do layout.asm.
# ==============================================================

.data
msg_rmv_ap_invalido: .asciiz "Falha: AP invalido\n"                  # erro de AP
msg_rmv_nao_achou:   .asciiz "Falha: morador nao encontrado\n"       # erro de nome

.text
.globl rmvMorador

# $a0 = AP (string), $a1 = nome (string)
rmvMorador:
    addi $sp, $sp, -24              # reserva 6 palavras na pilha
    sw   $ra, 20($sp)               # salva o endereco de retorno
    sw   $s0, 16($sp)               # salva s0 (ponteiro do nome)
    sw   $s1, 12($sp)               # salva s1 (base do AP)
    sw   $s2, 8($sp)                # salva s2 (quantidade de moradores)
    sw   $s3, 4($sp)                # salva s3 (indice do slot em analise)
    sw   $s4, 0($sp)                # salva s4 (endereco do slot em analise)

    move $s0, $a1                   # s0 = nome (a1 sera sobrescrito pelas chamadas)
    jal  ap_to_index                # a0 ja tem a string do AP; v0 = indice ou -1
    bltz $v0, rmv_mor_ap_invalido   # indice negativo: AP invalido

    move $a0, $v0                   # a0 = indice do AP
    jal  ap_base                    # v0 = endereco do bloco do AP
    move $s1, $v0                   # s1 = base do AP
    lw   $s2, AP_QTD_MOR($s1)       # s2 = quantidade atual de moradores
    li   $s3, 0                     # s3 = 0 (comeca pelo primeiro slot)

rmv_mor_busca:
    bge  $s3, $s2, rmv_mor_nao_achou  # passou do ultimo morador: nao encontrou
    sll  $t0, $s3, 5                # t0 = indice * 32
    add  $s4, $s1, $t0              # s4 = base + indice*32
    addi $s4, $s4, AP_NOMES         # s4 = endereco do slot do morador atual
    move $a0, $s4                   # a0 = nome cadastrado
    move $a1, $s0                   # a1 = nome digitado
    jal  strcmp                     # compara as duas strings (v0 = 0 se iguais)
    beq  $v0, $zero, rmv_mor_achou  # iguais: achou o morador
    addi $s3, $s3, 1                # proximo slot
    j    rmv_mor_busca              # continua procurando

rmv_mor_achou:
    sub  $t0, $s2, $s3              # t0 = qtd - indice
    addi $t0, $t0, -1               # t0 = quantos slots existem depois do removido
    sll  $a2, $t0, 5                # a2 = bytes a mover (slots * 32)
    move $a0, $s4                   # a0 = destino: slot do removido
    addi $a1, $s4, NOME_TAM         # a1 = origem: slot seguinte
    jal  memcpy                     # puxa os slots seguintes uma posicao para tras

    addi $t0, $s2, -1               # t0 = indice do ultimo slot ocupado
    sll  $t0, $t0, 5                # t0 = indice * 32
    add  $t0, $s1, $t0              # t0 = base + indice*32
    addi $a0, $t0, AP_NOMES         # a0 = endereco do ultimo slot (agora duplicado)
    li   $a1, NOME_TAM              # a1 = 32 bytes a zerar
    jal  memzero                    # zera o slot

    addi $s2, $s2, -1               # quantidade de moradores - 1
    sw   $s2, AP_QTD_MOR($s1)       # grava a nova quantidade
    bne  $s2, $zero, rmv_mor_ok     # ainda tem moradores: terminou

    addi $a0, $s1, AP_AUTOS         # AP ficou vazio: a0 = inicio da area de automoveis
    li   $a1, AP_AUTOS_TAM          # a1 = tamanho da area de automoveis
    jal  memzero                    # zera toda a area de automoveis

rmv_mor_ok:
    li   $v0, 0                     # retorno: sucesso
    j    rmv_mor_fim                # vai para o epilogo

rmv_mor_ap_invalido:
    la   $a0, msg_rmv_ap_invalido   # a0 = mensagem de AP invalido
    jal  print_str                  # imprime
    li   $v0, 1                     # retorno: erro
    j    rmv_mor_fim                # vai para o epilogo

rmv_mor_nao_achou:
    la   $a0, msg_rmv_nao_achou     # a0 = mensagem de morador nao encontrado
    jal  print_str                  # imprime
    li   $v0, 1                     # retorno: erro

rmv_mor_fim:
    lw   $s4, 0($sp)                # restaura s4
    lw   $s3, 4($sp)                # restaura s3
    lw   $s2, 8($sp)                # restaura s2
    lw   $s1, 12($sp)               # restaura s1
    lw   $s0, 16($sp)               # restaura s0
    lw   $ra, 20($sp)               # restaura ra
    addi $sp, $sp, 24               # libera a pilha
    jr   $ra                        # retorna para o main
