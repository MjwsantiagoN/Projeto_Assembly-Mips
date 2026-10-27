# ==============================================================
# Grupo: Brenno, Joao, Leticia e Marcos
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: ap_to_index.asm
# Descricao: Converte a string do AP (ex.: "1102") em indice 0..23, ou -1 se invalido.
# Convencao: argumento em $a0, retorno em $v0. Usa apenas $t0-$t6 e $a0 (sem pilha).
# ==============================================================

.text
.globl ap_to_index

# $a0 = endereco da string do AP (ex.: "1102"), terminada em NULL
# $v0 = indice do AP (0 a 23) ou -1 se invalido
ap_to_index:
    li   $t0, 0                     # t0 = valor numerico acumulado
    li   $t1, 0                     # t1 = quantidade de digitos lidos

ap_idx_loop:
    lbu  $t2, 0($a0)                # le o caractere atual da string
    beq  $t2, $zero, ap_idx_fim     # NULL: terminou a string
    addi $t3, $t2, -48              # t3 = caractere - '0'
    bltz $t3, ap_idx_invalido       # abaixo de '0': nao e digito
    li   $t4, 9                     # t4 = 9 (maior digito valido)
    bgt  $t3, $t4, ap_idx_invalido  # acima de '9': nao e digito
    mul  $t0, $t0, 10               # valor = valor * 10
    add  $t0, $t0, $t3              # valor = valor + digito
    addi $t1, $t1, 1                # conta mais um digito
    li   $t4, 4                     # t4 = 4 (maximo de digitos)
    bgt  $t1, $t4, ap_idx_invalido  # mais de 4 digitos: invalido
    addi $a0, $a0, 1                # avanca para o proximo caractere
    j    ap_idx_loop                # repete

ap_idx_fim:
    li   $t4, 3                     # t4 = 3 (minimo de digitos)
    blt  $t1, $t4, ap_idx_invalido  # menos de 3 digitos: invalido
    li   $t4, 100                   # t4 = 100
    div  $t0, $t4                   # divide valor por 100
    mflo $t5                        # t5 = andar (quociente)
    mfhi $t6                        # t6 = final do AP (resto: 01 ou 02)
    li   $t4, 1                     # t4 = 1
    blt  $t5, $t4, ap_idx_invalido  # andar < 1: invalido
    li   $t4, 12                    # t4 = 12
    bgt  $t5, $t4, ap_idx_invalido  # andar > 12: invalido
    li   $t4, 1                     # t4 = 1
    blt  $t6, $t4, ap_idx_invalido  # final < 1: invalido
    li   $t4, 2                     # t4 = 2
    bgt  $t6, $t4, ap_idx_invalido  # final > 2: invalido
    addi $t5, $t5, -1               # andar - 1
    sll  $t5, $t5, 1                # (andar - 1) * 2
    addi $t6, $t6, -1               # final - 1
    add  $v0, $t5, $t6              # indice = (andar-1)*2 + (final-1)
    jr   $ra                        # retorna

ap_idx_invalido:
    li   $v0, -1                    # retorna -1 (AP invalido)
    jr   $ra                        # retorna
