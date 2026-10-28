# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: cmd_rmvAuto.asm
# Descricao: cmd_4 - rmvAuto --<AP> --<placa>. Confere que vieram exatamente 2 opcoes,
#            valida o AP (cm_ap_base) e chama rmvAuto_remover (automovel/rmvAuto.asm).
#            Placa nao encontrada: "Falha: automovel nao encontrado".
#            Em caso de sucesso nao imprime nada. Preserva $s0-$s7.
# Entrada: $a0 = argc, $a1 = argv (argv[1] = AP, argv[2] = placa).
# ==============================================================

.data                           # Segmento de dados
cm_auto_nao:   .asciiz "Falha: automovel nao encontrado\n"  # Mensagem de automovel nao encontrado

.text                           # Segmento de codigo
cmd_rmvAuto:                    # Entrada do comando rmvAuto
    addi $sp, $sp, -8               # Reserva espaco na pilha
    sw   $ra, 0($sp)                # Salva o endereco de retorno
    sw   $s0, 4($sp)                # Salva $s0 (argv)
    li   $t0, 2                     # Quantidade esperada de opcoes
    bne  $a0, $t0, cm_rmvauto_inv   # Opcoes faltando ou sobrando: comando invalido
    move $s0, $a1                   # $s0 = argv
    lw   $a0, 4($s0)                # $a0 = argv[1] (AP)
    jal  cm_ap_base                 # Valida o AP
    beq  $v0, $zero, cm_rmvauto_ap  # AP invalido
    move $a0, $v0                   # $a0 = registro do AP
    lw   $a1, 8($s0)                # $a1 = argv[2] (placa)
    jal  rmvAuto_remover            # $v0 = 0 ok, -1 nao encontrado, -2 parametro nulo
    beq  $v0, $zero, cm_rmvauto_fim # Sucesso: nada a imprimir
    la   $a0, cm_auto_nao           # "Falha: automovel nao encontrado"
    jal  cm_erro                    # Imprime
    j    cm_rmvauto_fim             # Sai
cm_rmvauto_ap:                  # AP invalido: mensagem de erro
    la   $a0, cm_ap_inval           # "Falha: AP invalido"
    jal  cm_erro                    # Imprime
    j    cm_rmvauto_fim             # Sai
cm_rmvauto_inv:                 # Quantidade de opcoes errada: comando invalido
    la   $a0, cm_invalido           # "Comando invalido"
    jal  cm_erro                    # Imprime
cm_rmvauto_fim:                 # Epilogo: restaura registradores e retorna
    lw   $s0, 4($sp)                # Restaura $s0
    lw   $ra, 0($sp)                # Restaura o endereco de retorno
    addi $sp, $sp, 8                # Libera a pilha
    jr   $ra                        # Volta para o shell
