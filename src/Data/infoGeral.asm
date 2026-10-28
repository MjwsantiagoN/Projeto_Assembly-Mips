# Grupo: LBFM (Leticia, Brenno, Ferraz, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: infoGeral.asm
# Descricao: cmd_7 - infoGeral. Mostra o panorama geral do condominio (R6):
#            quantos apartamentos estao nao vazios (pelo menos 1 morador) e
#            quantos estao vazios, com a porcentagem de cada um.
#            Uso: infoGeral        (nao tem opcoes)
# Entrada: $a0 = argc, $a1 = argv (ignorados). Preserva $s0-$s7.

.text
cmd_infoGeral:
    addi $sp, $sp, -12             # Reserva espaco na pilha
    sw   $ra, 0($sp)               # Salva o endereco de retorno
    sw   $s0, 4($sp)               # Salva $s0 (contador de APs nao vazios)
    sw   $s1, 8($sp)               # Salva $s1 (porcentagem de nao vazios)

    la   $t0, ap_tabela           # $t0 = endereco do primeiro apartamento
    li   $t1, N_APS                 # $t1 = apartamentos que faltam verificar
    li   $s0, 0                    # $s0 = nao vazios = 0
infoGeral_loop:
    lw   $t2, AP_QTD_MOR($t0)     # $t2 = numero de moradores do AP atual
    beq  $t2, $zero, infoGeral_prox # Se for 0, o AP esta vazio: nao conta
    addi $s0, $s0, 1               # AP nao vazio: conta mais um
infoGeral_prox:
    addi $t0, $t0, AP_TAM          # Avanca para o proximo apartamento
    addi $t1, $t1, -1              # Um AP a menos para verificar
    bne  $t1, $zero, infoGeral_loop # Repete ate verificar os N_APS apartamentos

    # porcentagem de nao vazios arredondada: (nao_vazios*100 + N_APS/2) / N_APS
    li   $t0, 100                  # Constante 100
    mul  $t1, $s0, $t0             # nao_vazios * 100
    addi $t1, $t1, 12              # Soma N_APS/2 (12) para arredondar
    li   $t2, N_APS                 # Total de apartamentos
    div  $t1, $t2                  # Divide
    mflo $s1                       # $s1 = porcentagem de nao vazios

    la   $a0, ig_nvazios           # "Nao vazios: "
    jal  mmio_print_string          # Escreve o rotulo
    move $a0, $s0                  # Quantidade de nao vazios
    jal  mmio_print_int             # Escreve o numero
    la   $a0, ig_abre              # " ("
    jal  mmio_print_string          # Escreve
    move $a0, $s1                  # Porcentagem de nao vazios
    jal  mmio_print_int             # Escreve o numero
    la   $a0, ig_fecha             # "%)\n"
    jal  mmio_print_string          # Escreve

    la   $a0, ig_vazios            # "Vazios:     "
    jal  mmio_print_string          # Escreve o rotulo
    li   $a0, N_APS                 # Total de apartamentos
    sub  $a0, $a0, $s0             # Vazios = total - nao vazios
    jal  mmio_print_int             # Escreve o numero
    la   $a0, ig_abre              # " ("
    jal  mmio_print_string          # Escreve
    li   $a0, 100                  # 100%
    sub  $a0, $a0, $s1             # Porcentagem de vazios = 100 - nao vazios (soma sempre 100)
    jal  mmio_print_int             # Escreve o numero
    la   $a0, ig_fecha             # "%)\n"
    jal  mmio_print_string          # Escreve

    lw   $s1, 8($sp)               # Restaura $s1
    lw   $s0, 4($sp)               # Restaura $s0
    lw   $ra, 0($sp)               # Restaura o endereco de retorno
    addi $sp, $sp, 12              # Libera a pilha
    jr   $ra                       # Volta para o shell

.data
ig_nvazios: .asciiz "Nao vazios: "
ig_vazios:  .asciiz "Vazios:     "
ig_abre:    .asciiz " ("
ig_fecha:   .asciiz "%)\n"
.text
