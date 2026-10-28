# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: main.asm
# Descricao: Shell do condominio: le a linha pelo MMIO, separa comando e opcoes (" --") e chama o cmd_*.
#            Cada comando recebe $a0 = argc e $a1 = argv (argv[0] = nome, argv[1..] = opcoes) e termina com jr $ra.
#            No MARS: desmarcar "Assemble all files in directory", conectar o MMIO e manter delayed branching desligado.
# ==============================================================

.include "Data/layout.asm"          # so .eqv; precisa vir antes de qualquer uso

.eqv LINHA_TAM 256              # Tamanho do buffer da linha digitada (com o NUL)
.eqv MAX_ARGS  8                # Maximo de opcoes (" --") por comando

.data                           # Segmento de dados
.align 2                        # Alinha em palavra (4 bytes)
linha:        .space 256        # Buffer da linha digitada
argv:         .space 36             # comando + ate 8 opcoes

banner:       .asciiz "BJLM-shell>> "  # Banner do shell (R5): iniciais do grupo
msg_invalido: .asciiz "Comando invalido\n"  # Mensagem para comando inexistente (R7)
msg_bemvindo: .asciiz "Sistema de cadastro do condominio. Digite um comando.\n"  # Mensagem de boas-vindas

n_addMorador: .asciiz "addmorador"  # nomes em minusculo: a comparacao ignora maiusculas
n_rmvMorador: .asciiz "rmvmorador"  # Nome do comando rmvMorador
n_addAuto:    .asciiz "addauto" # Nome do comando addAuto
n_rmvAuto:    .asciiz "rmvauto" # Nome do comando rmvAuto
n_limparAp:   .asciiz "limparap"  # Nome do comando limparAp
n_infoAp:     .asciiz "infoap"  # Nome do comando infoAp
n_infoGeral:  .asciiz "infogeral"  # Nome do comando infoGeral
n_salvar:     .asciiz "salvar"  # Nome do comando salvar
n_recarregar: .asciiz "recarregar"  # Nome do comando recarregar
n_formatar:   .asciiz "formatar"  # Nome do comando formatar

.align 2                        # Alinha em palavra (a tabela guarda words)
ap_tabela:    .space 10752          # os 24 apartamentos: 24 x AP_TAM (448) bytes, tudo zero = vazio

tabela_cmds:                        # {nome, rotina}; termina com {0, 0}
    .word n_addMorador, cmd_addMorador  # Entrada: addMorador -> cmd_addMorador
    .word n_rmvMorador, cmd_rmvMorador  # Entrada: rmvMorador -> cmd_rmvMorador
    .word n_addAuto,    cmd_addAuto  # Entrada: addAuto -> cmd_addAuto
    .word n_rmvAuto,    cmd_rmvAuto  # Entrada: rmvAuto -> cmd_rmvAuto
    .word n_limparAp,   cmd_limparAp  # Entrada: limparAp -> cmd_limparAp
    .word n_infoAp,     cmd_infoAp  # Entrada: infoAp -> cmd_infoAp
    .word n_infoGeral,  cmd_infoGeral  # Entrada: infoGeral -> cmd_infoGeral
    .word n_salvar,     cmd_salvar  # Entrada: salvar -> cmd_salvar
    .word n_recarregar, cmd_recarregar  # Entrada: recarregar -> cmd_recarregar
    .word n_formatar,   cmd_formatar  # Entrada: formatar -> cmd_formatar
    .word 0, 0                  # Sentinela: fim da tabela

.text                           # Segmento de codigo
.globl main                     # Torna main visivel (ponto de entrada)

main:                           # Inicio do programa
    jal  ap_inicializarTabela       # grava os numeros dos APs (101..1202)
    jal  carregar_arquivo           # R3: 0 ok, 1 sem arquivo, 2 invalido
    bne  $v0, $zero, main_sem_dados  # Se nao carregou (sem arquivo ou invalido), pula a mensagem
    la   $a0, msg_carregado     # $a0 = "Dados carregados..."
    jal  mmio_print_string      # Imprime a mensagem de carga
main_sem_dados:                 # Segue sem dados carregados
    la   $a0, msg_bemvindo      # $a0 = mensagem de boas-vindas
    jal  mmio_print_string      # Imprime a mensagem de boas-vindas

shell_loop:                     # Laco principal do shell: um comando por iteracao
    la   $a0, banner            # $a0 = banner
    jal  mmio_print_string      # Imprime o banner
    la   $a0, linha             # $a0 = buffer da linha
    li   $a1, LINHA_TAM         # $a1 = capacidade do buffer
    jal  mmio_read_line         # Le a linha ate o Enter (MMIO)
    li   $a0, 10                    # a digitacao nao e ecoada: pula a linha do banner
    jal  mmio_putchar           # Imprime a quebra de linha
    la   $a0, linha             # $a0 = buffer da linha
    jal  trim                   # Remove espacos das pontas; $v0 = inicio util
    move $s0, $v0                   # inicio da linha sem espacos
    lbu  $t0, 0($s0)            # Primeiro caractere da linha
    beq  $t0, $zero, shell_loop     # linha vazia
    move $a0, $s0               # $a0 = inicio da linha
    jal  parse_linha                # preenche argv; $v0 = argc
    move $s1, $v0               # $s1 = argc (quantidade de opcoes)

    la   $t0, argv              # $t0 = endereco de argv
    lw   $a0, 0($t0)            # $a0 = argv[0] (nome do comando)
    jal  minusculas                 # nome do comando em minusculo

    la   $s2, tabela_cmds       # $s2 = primeira entrada da tabela de comandos
dispatch_loop:                  # Laco: compara o comando com uma entrada da tabela
    lw   $t0, 0($s2)            # $t0 = nome do comando da entrada
    beq  $t0, $zero, cmd_nao_existe  # Fim da tabela: comando inexistente
    la   $t1, argv              # $t1 = endereco de argv
    lw   $a0, 0($t1)            # $a0 = comando digitado
    move $a1, $t0               # $a1 = nome da entrada
    jal  strcmp                 # Compara as strings ($v0 = 0 se iguais)
    beq  $v0, $zero, dispatch_achou  # Iguais: achou o comando
    addi $s2, $s2, 8            # Proxima entrada (8 bytes: nome + rotina)
    j    dispatch_loop          # Repete a busca
dispatch_achou:                 # Comando encontrado
    lw   $t0, 4($s2)            # $t0 = rotina do comando
    move $a0, $s1                   # argc
    la   $a1, argv              # $a1 = argv
    jalr $t0                    # Chama o comando (argc em $a0, argv em $a1)
    j    shell_loop             # Volta a esperar o proximo comando
cmd_nao_existe:                 # Comando inexistente
    la   $a0, msg_invalido      # $a0 = "Comando invalido"
    jal  mmio_print_string      # Imprime a mensagem
    j    shell_loop             # Volta ao laco do shell

# trim: remove espacos/tabs das pontas, no proprio buffer. $a0 = string, $v0 = inicio util
trim:                           # Entrada de trim
trim_ini:                       # Laco: pula espacos/tabs do inicio
    lbu  $t0, 0($a0)            # Caractere atual
    li   $t1, 32                # 32 = espaco
    beq  $t0, $t1, trim_pula    # Espaco: pula
    li   $t1, 9                 # 9 = tab
    bne  $t0, $t1, trim_fim_ini # Nao e espaco nem tab: fim do inicio
trim_pula:                      # Pula um caractere do inicio
    addi $a0, $a0, 1            # Avanca o ponteiro
    j    trim_ini               # Repete
trim_fim_ini:                   # Achou o primeiro caractere util
    move $v0, $a0               # $v0 = inicio util da string
    move $t2, $a0               # $t2 vai ate o fim da string
trim_acha_fim:                  # Laco: procura o NUL do final
    lbu  $t0, 0($t2)            # Caractere atual
    beq  $t0, $zero, trim_corta # NUL: achou o fim
    addi $t2, $t2, 1            # Avanca
    j    trim_acha_fim          # Repete
trim_corta:                     # Laco: remove espacos/tabs do final
    beq  $t2, $v0, trim_ret         # string vazia
    addi $t2, $t2, -1           # Volta um caractere
    lbu  $t0, 0($t2)            # Le o caractere
    li   $t1, 32                # 32 = espaco
    beq  $t0, $t1, trim_zera    # Espaco: remove
    li   $t1, 9                 # 9 = tab
    bne  $t0, $t1, trim_ret     # Nao e espaco nem tab: terminou
trim_zera:                      # Troca o espaco/tab por NUL
    sb   $zero, 0($t2)          # Grava o NUL
    j    trim_corta             # Repete
trim_ret:                       # Fim do trim
    jr   $ra                    # Retorna

# parse_linha (R7): cada " --" vira NUL e o texto seguinte e uma opcao (pode ter espacos).
# $a0 = linha, $v0 = argc. argv[0] = comando, argv[i] = opcao i.
parse_linha:                    # Entrada de parse_linha
    la   $t4, argv              # $t4 = endereco de argv
    sw   $a0, 0($t4)            # argv[0] = inicio da linha (comando)
    li   $v0, 0                 # argc = 0
parse_loop:                     # Laco: percorre a linha caractere a caractere
    lbu  $t0, 0($a0)            # Caractere atual
    beq  $t0, $zero, parse_fim  # NUL: fim da linha
    li   $t1, 32                # 32 = espaco
    bne  $t0, $t1, parse_prox   # Nao e espaco: segue
    lbu  $t2, 1($a0)            # Caractere seguinte ao espaco
    li   $t1, 45                # 45 = "-"
    bne  $t2, $t1, parse_prox   # Nao e "-": segue
    lbu  $t2, 2($a0)            # Segundo caractere apos o espaco
    bne  $t2, $t1, parse_prox   # Nao e "-": segue
    li   $t3, MAX_ARGS          # $t3 = limite de opcoes
    bge  $v0, $t3, parse_prox       # opcoes demais: o resto fica no texto
    sb   $zero, 0($a0)          # Troca o espaco do " --" por NUL (encerra o texto anterior)
    addi $v0, $v0, 1            # argc = argc + 1
    sll  $t3, $v0, 2            # $t3 = argc * 4
    add  $t3, $t4, $t3          # $t3 = endereco de argv[argc]
    addi $t2, $a0, 3            # $t2 = texto depois do " --"
    sw   $t2, 0($t3)                # argv[argc] = texto depois de " --"
    addi $a0, $a0, 3            # Pula os 3 caracteres do " --"
    j    parse_loop             # Repete
parse_prox:                     # Caractere comum
    addi $a0, $a0, 1            # Avanca um caractere
    j    parse_loop             # Repete
parse_fim:                      # Fim da linha
    jr   $ra                    # Retorna ($v0 = argc)

# minusculas: converte a string $a0 para minusculo no proprio buffer
minusculas:                     # Entrada de minusculas
minusculas_loop:                # Laco: converte um caractere por iteracao
    lbu  $t0, 0($a0)            # Caractere atual
    beq  $t0, $zero, minusculas_fim  # NUL: terminou
    slti $t1, $t0, 65           # Menor que "A" (65)?
    bne  $t1, $zero, minusculas_prox  # Sim: nao e maiuscula
    li   $t2, 90                # 90 = "Z"
    bgt  $t0, $t2, minusculas_prox  # Maior que "Z": nao e maiuscula
    addi $t0, $t0, 32           # Soma 32: letra minuscula
    sb   $t0, 0($a0)            # Grava o caractere convertido
minusculas_prox:                # Proximo caractere
    addi $a0, $a0, 1            # Avanca
    j    minusculas_loop        # Repete
minusculas_fim:                 # Fim da conversao
    jr   $ra                    # Retorna

# ap_inicializarTabela: grava o numero de cada AP no inicio do seu registro
# (101, 102, 201, 202, ..., 1202). Nao mexe nos demais campos.
ap_inicializarTabela:           # Entrada de ap_inicializarTabela
    la   $t0, ap_tabela             # registro atual
    li   $t1, 0                     # indice do AP (0..23)
ap_init_loop:                   # Laco: grava o numero de um AP por iteracao
    srl  $t2, $t1, 1                # andar - 1
    addi $t2, $t2, 1                # andar
    li   $t3, 100               # $t3 = 100
    mul  $t2, $t2, $t3              # andar * 100
    andi $t3, $t1, 1                # 0 ou 1
    addi $t3, $t3, 1                # final: 1 ou 2
    add  $t2, $t2, $t3              # numero do AP, ex.: 1102
    sw   $t2, AP_ID($t0)        # Grava o numero do AP no inicio do registro
    addi $t0, $t0, AP_TAM           # proximo registro
    addi $t1, $t1, 1            # Proximo indice de AP
    li   $t3, N_APS             # $t3 = total de APs
    bne  $t1, $t3, ap_init_loop # Repete ate os 24 APs
    jr   $ra                    # Retorna

.include "Auxiliares/MMIO.asm"  # Inclui teclado/display MMIO
.include "Auxiliares/strcmp.asm"  # Inclui strcmp
.include "Auxiliares/strcpy.asm"  # Inclui strcpy
.include "Auxiliares/strcat.asm"  # Inclui strcat
.include "Auxiliares/strncmp.asm"  # Inclui strncmp
.include "Auxiliares/memcpy.asm"  # Inclui memcpy
.include "Auxiliares/memzero.asm"  # Inclui memzero
.include "Auxiliares/strlen.asm"  # Inclui strlen
.include "Auxiliares/ap_to_index.asm"  # Inclui ap_to_index
.include "Auxiliares/ap_base.asm"  # Inclui ap_base
.include "Auxiliares/cm_ap_base.asm"  # Inclui cm_ap_base e cm_erro
.include "apartamento/limparAp.asm"  # Inclui o comando limparAp
.include "apartamento/infoAp.asm"  # Inclui o comando infoAp
.include "automovel/addAuto.asm"  # Inclui o modulo addAuto
.include "automovel/cmd_addAuto.asm"  # Inclui o comando addAuto
.include "automovel/rmvAuto.asm"  # Inclui o modulo rmvAuto
.include "automovel/cmd_rmvAuto.asm"  # Inclui o comando rmvAuto
.include "morador/addMorador.asm"  # Inclui o modulo addMorador
.include "morador/cmd_addMorador.asm"  # Inclui o comando addMorador
.include "morador/rmvMorador.asm"  # Inclui o modulo rmvMorador
.include "morador/cmd_rmvMorador.asm"  # Inclui o comando rmvMorador

.include "Data/infoGeral.asm"   # Inclui o comando infoGeral
.include "Data/salvar.asm"      # Inclui o comando salvar e arq_abrir
.include "Data/recarregar.asm"  # Inclui o comando recarregar e carregar_arquivo
.include "Data/formatar.asm"    # Inclui o comando formatar
