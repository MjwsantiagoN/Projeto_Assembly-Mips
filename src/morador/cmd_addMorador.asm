# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: cmd_addMorador.asm
# Descricao: cmd_1 - addMorador --<AP> --<nome>. Adiciona um morador ao apartamento (limite de 6).
#            Confere que vieram exatamente 2 opcoes, valida o AP (cm_ap_base) e chama
#            a rotina addMorador (morador/addMorador.asm), que imprime os proprios erros.
#            Nome vazio (addMorador --101 --) e "Comando invalido".
#            Em caso de sucesso nao imprime nada. Preserva $s0-$s7.
# Entrada: $a0 = argc, $a1 = argv (argv[1] = AP, argv[2] = nome do morador).
# ==============================================================

.text                           # Segmento de codigo
cmd_addMorador:                 # Entrada do comando addMorador
    addi $sp, $sp, -8               # Reserva espaco na pilha
    sw   $ra, 0($sp)                # Salva o endereco de retorno
    sw   $s0, 4($sp)                # Salva $s0 (argv)
    li   $t0, 2                     # Quantidade esperada de opcoes
    bne  $a0, $t0, cm_addmor_inv           # Opcoes faltando ou sobrando: comando invalido
    move $s0, $a1                   # $s0 = argv
    lw   $a0, 4($s0)                # $a0 = argv[1] (AP)
    jal  cm_ap_base                 # Valida o AP
    beq  $v0, $zero, cm_addmor_ap          # AP invalido
    lw   $a0, 4($s0)                # $a0 = AP (texto)
    lw   $a1, 8($s0)                # $a1 = argv[2] (nome do morador)
    lbu  $t0, 0($a1)                # Primeiro caractere do nome
    beq  $t0, $zero, cm_addmor_inv  # Nome vazio: comando invalido
    jal  addMorador                         # Executa (a rotina imprime os proprios erros)
    j    cm_addmor_fim                     # Sai
cm_addmor_ap:                   # AP invalido: mensagem de erro
    la   $a0, cm_ap_inval           # "Falha: AP invalido"
    jal  cm_erro                    # Imprime
    j    cm_addmor_fim                     # Sai
cm_addmor_inv:                  # Quantidade de opcoes errada ou nome vazio: comando invalido
    la   $a0, cm_invalido           # "Comando invalido"
    jal  cm_erro                    # Imprime
cm_addmor_fim:                  # Epilogo: restaura registradores e retorna
    lw   $s0, 4($sp)                # Restaura $s0
    lw   $ra, 0($sp)                # Restaura o endereco de retorno
    addi $sp, $sp, 8                # Libera a pilha
    jr   $ra                        # Volta para o shell
