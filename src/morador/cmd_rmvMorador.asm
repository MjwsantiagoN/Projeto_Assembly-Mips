# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: cmd_rmvMorador.asm
# Descricao: cmd_2 - rmvMorador --<AP> --<nome>. Remove um morador do apartamento.
#            Confere que vieram exatamente 2 opcoes, valida o AP (cm_ap_base) e chama
#            a rotina rmvMorador (morador/rmvMorador.asm), que imprime os proprios erros.
#            Em caso de sucesso nao imprime nada. Preserva $s0-$s7.
# Entrada: $a0 = argc, $a1 = argv (argv[1] = AP, argv[2] = nome do morador).
# ==============================================================

.text                           # Segmento de codigo
cmd_rmvMorador:                 # Entrada do comando rmvMorador
    addi $sp, $sp, -8               # Reserva espaco na pilha
    sw   $ra, 0($sp)                # Salva o endereco de retorno
    sw   $s0, 4($sp)                # Salva $s0 (argv)
    li   $t0, 2                     # Quantidade esperada de opcoes
    bne  $a0, $t0, cm_rmvmor_inv           # Opcoes faltando ou sobrando: comando invalido
    move $s0, $a1                   # $s0 = argv
    lw   $a0, 4($s0)                # $a0 = argv[1] (AP)
    jal  cm_ap_base                 # Valida o AP
    beq  $v0, $zero, cm_rmvmor_ap          # AP invalido
    lw   $a0, 4($s0)                # $a0 = AP (texto)
    lw   $a1, 8($s0)                # $a1 = argv[2] (nome do morador)
    jal  rmvMorador                         # Executa (a rotina imprime os proprios erros)
    j    cm_rmvmor_fim                     # Sai
cm_rmvmor_ap:                   # AP invalido: mensagem de erro
    la   $a0, cm_ap_inval           # "Falha: AP invalido"
    jal  cm_erro                    # Imprime
    j    cm_rmvmor_fim                     # Sai
cm_rmvmor_inv:                  # Quantidade de opcoes errada: comando invalido
    la   $a0, cm_invalido           # "Comando invalido"
    jal  cm_erro                    # Imprime
cm_rmvmor_fim:                  # Epilogo: restaura registradores e retorna
    lw   $s0, 4($sp)                # Restaura $s0
    lw   $ra, 0($sp)                # Restaura o endereco de retorno
    addi $sp, $sp, 8                # Libera a pilha
    jr   $ra                        # Volta para o shell
