# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: infoAp.asm
# Descricao: cmd_6 - infoAp --<AP> | infoAp --all. Imprime as informacoes cadastradas
#            de um apartamento (ou de todos, em ordem crescente). Padrao do enunciado:
#              AP: numero            AP: numero
#              Apartamento vazio     Moradores:
#                                    <nomes, um por linha>
#                                    Carro: | Moto:
#                                    <modelo> / <placa>
#            Apenas o que esta cadastrado e mostrado. AP invalido: "Falha: AP invalido".
#            Preserva $s0-$s7.
# ==============================================================

.data                           # Segmento de dados
ia_ap:      .asciiz "AP: "      # Texto "AP: "
ia_vazio:   .asciiz "Apartamento vazio\n"  # Texto de AP vazio
ia_morad:   .asciiz "Moradores:\n"  # Titulo da lista de moradores
ia_carro:   .asciiz "Carro:\n"  # Titulo da lista de carro
ia_moto:    .asciiz "Moto:\n"   # Titulo da lista de motos
ia_sep:     .asciiz " / "       # Separador entre modelo e placa
ia_nl:      .asciiz "\n"        # Quebra de linha
ia_all:     .asciiz "all"       # Texto da opcao "all"

.text                           # Segmento de codigo
cmd_infoAp:                     # Entrada do comando infoAp
    addi $sp, $sp, -12              # Reserva espaco na pilha
    sw   $ra, 0($sp)                # Salva o endereco de retorno
    sw   $s0, 4($sp)                # Salva $s0 (argumento / contador)
    sw   $s1, 8($sp)                # Salva $s1 (registro atual)
    li   $t0, 1                     # Este comando exige exatamente 1 opcao
    bne  $a0, $t0, info_invalido    # Quantidade diferente: comando invalido
    lw   $s0, 4($a1)                # $s0 = argv[1]
    move $a0, $s0                   # Compara a opcao com "all"
    la   $a1, ia_all                # $a1 = "all"
    jal  strcmp                     # $v0 = 0 se iguais
    beq  $v0, $zero, info_todos     # "all": lista todos os apartamentos
    move $a0, $s0                   # Caso contrario, a opcao e o numero do AP
    jal  cm_ap_base                 # $v0 = registro do AP, ou 0 se invalido
    beq  $v0, $zero, info_ap_inval  # AP invalido
    move $a0, $v0                   # $a0 = registro do AP
    jal  infoAp_registro            # Imprime o apartamento
    j    info_fim                   # Sai
info_todos:                     # Opcao "all": lista os 24 apartamentos
    la   $s1, ap_tabela             # $s1 = primeiro registro (101)
    li   $s0, N_APS                 # $s0 = apartamentos que faltam imprimir
info_todos_loop:                # Laco: imprime um apartamento por iteracao
    move $a0, $s1                   # Registro atual
    jal  infoAp_registro            # Imprime o apartamento
    addi $s1, $s1, AP_TAM           # Proximo registro (a tabela esta em ordem crescente)
    addi $s0, $s0, -1               # Um apartamento a menos
    bne  $s0, $zero, info_todos_loop # Repete ate imprimir os 24
    j    info_fim                   # Sai
info_ap_inval:                  # AP invalido: mensagem de erro
    la   $a0, cm_ap_inval           # "Falha: AP invalido"
    jal  cm_erro                    # Imprime
    j    info_fim                   # Sai
info_invalido:                  # Quantidade de opcoes errada: comando invalido
    la   $a0, cm_invalido           # "Comando invalido"
    jal  cm_erro                    # Imprime
info_fim:                       # Epilogo: restaura registradores e retorna
    lw   $s1, 8($sp)                # Restaura $s1
    lw   $s0, 4($sp)                # Restaura $s0
    lw   $ra, 0($sp)                # Restaura o endereco de retorno
    addi $sp, $sp, 12               # Libera a pilha
    jr   $ra                        # Volta para o shell

# infoAp_registro: imprime um apartamento. $a0 = endereco do registro do AP
infoAp_registro:                # Entrada de infoAp_registro (imprime um apartamento)
    addi $sp, $sp, -16              # Reserva espaco na pilha
    sw   $ra, 0($sp)                # Salva o endereco de retorno
    sw   $s0, 4($sp)                # Salva $s0 (registro)
    sw   $s1, 8($sp)                # Salva $s1 (indice do item)
    sw   $s2, 12($sp)               # Salva $s2 (quantidade de itens)
    move $s0, $a0                   # $s0 = registro do AP
    la   $a0, ia_ap                 # "AP: "
    jal  mmio_print_string          # Imprime
    lw   $a0, AP_ID($s0)            # Numero do AP (101..1202)
    jal  mmio_print_int             # Imprime o numero
    la   $a0, ia_nl                 # Quebra de linha
    jal  mmio_print_string          # Imprime
    lw   $s2, AP_QTD_MOR($s0)       # $s2 = quantidade de moradores
    bne  $s2, $zero, info_reg_moradores # Tem moradores: lista tudo
    la   $a0, ia_vazio              # "Apartamento vazio"
    jal  mmio_print_string          # Imprime
    j    info_reg_fim               # AP vazio: nao ha mais nada a mostrar
info_reg_moradores:             # AP com moradores: lista os nomes
    la   $a0, ia_morad              # "Moradores:"
    jal  mmio_print_string          # Imprime
    li   $s1, 0                     # $s1 = indice do morador
info_reg_mor_loop:              # Laco: imprime um morador por iteracao
    li   $t0, NOME_TAM              # Tamanho de cada slot de nome
    mul  $t0, $s1, $t0              # Deslocamento do morador dentro da area de nomes
    add  $a0, $s0, $t0              # Registro + deslocamento
    addi $a0, $a0, AP_NOMES         # Endereco do nome do morador
    jal  mmio_print_string          # Imprime o nome
    la   $a0, ia_nl                 # Quebra de linha
    jal  mmio_print_string          # Imprime
    addi $s1, $s1, 1                # Proximo morador
    bne  $s1, $s2, info_reg_mor_loop # Repete ate o ultimo morador
    lw   $s2, AP_AUTOS($s0)         # $s2 = quantidade de veiculos (+296)
    beq  $s2, $zero, info_reg_fim   # Sem veiculos: terminou
    lw   $t0, AP_AUTOS_TIPO($s0)    # $t0 = tipo geral dos veiculos (+300): 'c' ou 'm'
    la   $a0, ia_moto               # Titulo "Moto:" por padrao
    li   $t1, 99                    # 'c'
    bne  $t0, $t1, info_reg_titulo  # Nao e carro: fica "Moto:"
    la   $a0, ia_carro              # E carro: titulo "Carro:"
info_reg_titulo:                # Imprime o titulo "Carro:" ou "Moto:"
    jal  mmio_print_string          # Imprime o titulo
    li   $s1, 0                     # $s1 = indice do veiculo
info_reg_veic_loop:             # Laco: imprime um veiculo por iteracao
    li   $t0, AUTO_SLOT_TAM         # Tamanho de cada slot de veiculo
    mul  $t0, $s1, $t0              # Deslocamento do veiculo
    add  $t0, $s0, $t0              # Registro + deslocamento
    addi $t0, $t0, AP_AUTOS_SLOTS   # Inicio do slot (+304 + indice*48)
    addi $a0, $t0, AUTO_OFF_MODELO  # Endereco do modelo
    addi $t1, $t0, AUTO_OFF_PLACA   # Endereco da placa
    addi $sp, $sp, -4               # Guarda o endereco da placa durante as chamadas
    sw   $t1, 0($sp)                # (as rotinas de impressao alteram os $t)
    jal  mmio_print_string          # Imprime o modelo
    la   $a0, ia_sep                # " / "
    jal  mmio_print_string          # Imprime
    lw   $a0, 0($sp)                # Recupera o endereco da placa
    addi $sp, $sp, 4                # Libera o espaco temporario
    jal  mmio_print_string          # Imprime a placa
    la   $a0, ia_nl                 # Quebra de linha
    jal  mmio_print_string          # Imprime
    addi $s1, $s1, 1                # Proximo veiculo
    lw   $t0, AP_AUTOS($s0)         # Quantidade de veiculos
    bne  $s1, $t0, info_reg_veic_loop # Repete ate o ultimo veiculo
info_reg_fim:                   # Epilogo: restaura registradores e retorna
    lw   $s2, 12($sp)               # Restaura $s2
    lw   $s1, 8($sp)                # Restaura $s1
    lw   $s0, 4($sp)                # Restaura $s0
    lw   $ra, 0($sp)                # Restaura o endereco de retorno
    addi $sp, $sp, 16               # Libera a pilha
    jr   $ra                        # Retorna
