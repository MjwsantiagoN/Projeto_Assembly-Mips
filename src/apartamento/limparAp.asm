# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: limparAp.asm
# Descricao: cmd_5 - limparAp --<AP>. Exclui todos os moradores e automoveis do
#            apartamento, que passa ao estado vazio. O numero do AP (+0) e mantido.
#            AP invalido: "Falha: AP invalido". Preserva $s0-$s7.
# ==============================================================

.text                           # Segmento de codigo
cmd_limparAp:                   # Entrada do comando limparAp
    addi $sp, $sp, -4               # Reserva espaco na pilha
    sw   $ra, 0($sp)                # Salva o endereco de retorno
    li   $t0, 1                     # Este comando exige exatamente 1 opcao
    bne  $a0, $t0, limpar_invalido  # Quantidade diferente: comando invalido
    lw   $a0, 4($a1)                # $a0 = argv[1] (texto do AP)
    jal  cm_ap_base                 # $v0 = endereco do registro do AP, ou 0 se invalido
    beq  $v0, $zero, limpar_ap_inval # AP invalido
    addi $a0, $v0, AP_QTD_MOR       # Zera a partir do contador de moradores (+4): preserva o numero do AP
    li   $a1, AP_TAM                # Tamanho do registro
    addi $a1, $a1, -4               # Menos os 4 bytes do numero do AP
    jal  memzero                    # Zera contador, nomes, contador de veiculos, tipo e slots
    j    limpar_fim                 # Sucesso: nada a imprimir
limpar_ap_inval:                # AP invalido: mensagem de erro
    la   $a0, cm_ap_inval           # "Falha: AP invalido"
    jal  cm_erro                    # Imprime
    j    limpar_fim                 # Sai
limpar_invalido:                # Quantidade de opcoes errada: comando invalido
    la   $a0, cm_invalido           # "Comando invalido"
    jal  cm_erro                    # Imprime
limpar_fim:                     # Epilogo: restaura registradores e retorna
    lw   $ra, 0($sp)                # Restaura o endereco de retorno
    addi $sp, $sp, 4                # Libera a pilha
    jr   $ra                        # Volta para o shell
