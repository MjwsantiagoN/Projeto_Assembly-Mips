# Grupo: LBFM (Leticia, Brenno, Ferraz, Marcos)
# Projeto 01 - 1VA | Arquitetura e Organizacao de Computadores | 2026.2
# Arquivo: main.asm
# Shell do condominio: le a linha pelo MMIO, separa comando e opcoes (" --") e chama o cmd_*.
# Cada comando recebe $a0 = argc e $a1 = argv (argv[0] = nome, argv[1..] = opcoes) e termina com jr $ra.
# No MARS: desmarcar "Assemble all files in directory", conectar o MMIO e manter delayed branching desligado.

.include "Data/layout.asm"          # so .eqv; precisa vir antes de qualquer uso

.eqv LINHA_TAM 256
.eqv MAX_ARGS  8

.data
.align 2
linha:        .space 256
argv:         .space 36             # comando + ate 8 opcoes

banner:       .asciiz "LBFM-shell>> "
msg_invalido: .asciiz "Comando invalido\n"
msg_bemvindo: .asciiz "Sistema de cadastro do condominio. Digite um comando.\n"

n_addMorador: .asciiz "addmorador"  # nomes em minusculo: a comparacao ignora maiusculas
n_rmvMorador: .asciiz "rmvmorador"
n_addAuto:    .asciiz "addauto"
n_rmvAuto:    .asciiz "rmvauto"
n_limparAp:   .asciiz "limparap"
n_infoAp:     .asciiz "infoap"
n_infoGeral:  .asciiz "infogeral"
n_salvar:     .asciiz "salvar"
n_recarregar: .asciiz "recarregar"
n_formatar:   .asciiz "formatar"

.align 2
ap_tabela:    .space 10752          # os 24 apartamentos: 24 x AP_TAM (448) bytes, tudo zero = vazio

tabela_cmds:                        # {nome, rotina}; termina com {0, 0}
    .word n_addMorador, cmd_addMorador
    .word n_rmvMorador, cmd_rmvMorador
    .word n_addAuto,    cmd_addAuto
    .word n_rmvAuto,    cmd_rmvAuto
    .word n_limparAp,   cmd_limparAp
    .word n_infoAp,     cmd_infoAp
    .word n_infoGeral,  cmd_infoGeral
    .word n_salvar,     cmd_salvar
    .word n_recarregar, cmd_recarregar
    .word n_formatar,   cmd_formatar
    .word 0, 0

.text
.globl main

main:
    jal  ap_inicializarTabela       # grava os numeros dos APs (101..1202)
    jal  carregar_arquivo           # R3: 0 ok, 1 sem arquivo, 2 invalido
    bne  $v0, $zero, main_sem_dados
    la   $a0, msg_carregado
    jal  mmio_print_string
main_sem_dados:
    la   $a0, msg_bemvindo
    jal  mmio_print_string

shell_loop:
    la   $a0, banner
    jal  mmio_print_string
    la   $a0, linha
    li   $a1, LINHA_TAM
    jal  mmio_read_line
    li   $a0, 10                    # a digitacao nao e ecoada: pula a linha do banner
    jal  mmio_putchar
    la   $a0, linha
    jal  trim
    move $s0, $v0                   # inicio da linha sem espacos
    lbu  $t0, 0($s0)
    beq  $t0, $zero, shell_loop     # linha vazia
    move $a0, $s0
    jal  parse_linha                # preenche argv; $v0 = argc
    move $s1, $v0

    la   $t0, argv
    lw   $a0, 0($t0)
    jal  minusculas                 # nome do comando em minusculo

    la   $s2, tabela_cmds
dispatch_loop:
    lw   $t0, 0($s2)
    beq  $t0, $zero, cmd_nao_existe
    la   $t1, argv
    lw   $a0, 0($t1)
    move $a1, $t0
    jal  strcmp
    beq  $v0, $zero, dispatch_achou
    addi $s2, $s2, 8
    j    dispatch_loop
dispatch_achou:
    lw   $t0, 4($s2)
    move $a0, $s1                   # argc
    la   $a1, argv
    jalr $t0
    j    shell_loop
cmd_nao_existe:
    la   $a0, msg_invalido
    jal  mmio_print_string
    j    shell_loop

# trim: remove espacos/tabs das pontas, no proprio buffer. $a0 = string, $v0 = inicio util
trim:
trim_ini:
    lbu  $t0, 0($a0)
    li   $t1, 32
    beq  $t0, $t1, trim_pula
    li   $t1, 9
    bne  $t0, $t1, trim_fim_ini
trim_pula:
    addi $a0, $a0, 1
    j    trim_ini
trim_fim_ini:
    move $v0, $a0
    move $t2, $a0
trim_acha_fim:
    lbu  $t0, 0($t2)
    beq  $t0, $zero, trim_corta
    addi $t2, $t2, 1
    j    trim_acha_fim
trim_corta:
    beq  $t2, $v0, trim_ret         # string vazia
    addi $t2, $t2, -1
    lbu  $t0, 0($t2)
    li   $t1, 32
    beq  $t0, $t1, trim_zera
    li   $t1, 9
    bne  $t0, $t1, trim_ret
trim_zera:
    sb   $zero, 0($t2)
    j    trim_corta
trim_ret:
    jr   $ra

# parse_linha (R7): cada " --" vira NUL e o texto seguinte e uma opcao (pode ter espacos).
# $a0 = linha, $v0 = argc. argv[0] = comando, argv[i] = opcao i.
parse_linha:
    la   $t4, argv
    sw   $a0, 0($t4)
    li   $v0, 0
parse_loop:
    lbu  $t0, 0($a0)
    beq  $t0, $zero, parse_fim
    li   $t1, 32
    bne  $t0, $t1, parse_prox
    lbu  $t2, 1($a0)
    li   $t1, 45
    bne  $t2, $t1, parse_prox
    lbu  $t2, 2($a0)
    bne  $t2, $t1, parse_prox
    li   $t3, MAX_ARGS
    bge  $v0, $t3, parse_prox       # opcoes demais: o resto fica no texto
    sb   $zero, 0($a0)
    addi $v0, $v0, 1
    sll  $t3, $v0, 2
    add  $t3, $t4, $t3
    addi $t2, $a0, 3
    sw   $t2, 0($t3)                # argv[argc] = texto depois de " --"
    addi $a0, $a0, 3
    j    parse_loop
parse_prox:
    addi $a0, $a0, 1
    j    parse_loop
parse_fim:
    jr   $ra

# minusculas: converte a string $a0 para minusculo no proprio buffer
minusculas:
minusculas_loop:
    lbu  $t0, 0($a0)
    beq  $t0, $zero, minusculas_fim
    slti $t1, $t0, 65
    bne  $t1, $zero, minusculas_prox
    li   $t2, 90
    bgt  $t0, $t2, minusculas_prox
    addi $t0, $t0, 32
    sb   $t0, 0($a0)
minusculas_prox:
    addi $a0, $a0, 1
    j    minusculas_loop
minusculas_fim:
    jr   $ra

# ap_inicializarTabela: grava o numero de cada AP no inicio do seu registro
# (101, 102, 201, 202, ..., 1202). Nao mexe nos demais campos.
ap_inicializarTabela:
    la   $t0, ap_tabela             # registro atual
    li   $t1, 0                     # indice do AP (0..23)
ap_init_loop:
    srl  $t2, $t1, 1                # andar - 1
    addi $t2, $t2, 1                # andar
    li   $t3, 100
    mul  $t2, $t2, $t3              # andar * 100
    andi $t3, $t1, 1                # 0 ou 1
    addi $t3, $t3, 1                # final: 1 ou 2
    add  $t2, $t2, $t3              # numero do AP, ex.: 1102
    sw   $t2, AP_ID($t0)
    addi $t0, $t0, AP_TAM           # proximo registro
    addi $t1, $t1, 1
    li   $t3, N_APS
    bne  $t1, $t3, ap_init_loop
    jr   $ra

.include "Auxiliares/MMIO.asm"
.include "Auxiliares/strcmp(1).asm"
.include "Auxiliares/strcpy(1).asm"
.include "Auxiliares/strcat(1).asm"
.include "Auxiliares/strncmp.asm"
.include "Auxiliares/memcpy.asm"
.include "Auxiliares/memzero.asm"
.include "Auxiliares/strlen.asm"
.include "Auxiliares/ap_to_index.asm"
.include "Auxiliares/ap_base.asm"
.include "apartamento/limparAp.asm"
.include "apartamento/infoAp.asm"
.include "automovel/addAuto.asm"
.include "automovel/rmvAuto.asm"
.include "morador/addMorador.asm"
.include "morador/rmvMorador.asm"
.include "comandos.asm"
.include "Data/infoGeral.asm"
.include "Data/salvar.asm"
.include "Data/recarregar.asm"
.include "Data/formatar.asm"
