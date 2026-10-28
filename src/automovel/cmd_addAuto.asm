# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: cmd_addAuto.asm
# Descricao: cmd_3 - addAuto --<AP> --<tipo c|m> --<modelo> --<placa>. Confere que vieram
#            exatamente 4 opcoes, valida o AP (cm_ap_base) e o tipo, aplica o limite de motos
#            do enunciado (R2) e chama addAuto_inserir (automovel/addAuto.asm).
#            Erros: "Falha: AP invalido", "Falha: tipo invalido", "Falha: AP vazio" (AP sem
#            moradores nao pode ter automovel) e "Falha: AP com numero max de automoveis".
#            Modelo ou placa vazios (addAuto --101 --c -- --) sao "Comando invalido".
#            Sucesso: nao imprime nada.
#            Regra R2: 1 carro OU ate 2 motos. O modulo addAuto foi feito (e testado) para ate 3 motos;
#            o limite de 2 e aplicado aqui, em MAX_MOTOS_CMD, antes de chamar addAuto_inserir.
# Entrada: $a0 = argc, $a1 = argv (argv[1] = AP, [2] = tipo, [3] = modelo, [4] = placa).
#            Preserva $s0-$s7.
# ==============================================================

.eqv MAX_MOTOS_CMD   2              # R2: no maximo 2 motos por apartamento

.data                           # Segmento de dados
cm_tipo_inval: .asciiz "Falha: tipo invalido\n"  # Mensagem de tipo invalido
cm_auto_max:   .asciiz "Falha: AP com numero max de automoveis\n"  # Mensagem de limite de automoveis
cm_ap_vazio:   .asciiz "Falha: AP vazio (cadastre um morador antes)\n"  # Mensagem de AP sem moradores

.text                           # Segmento de codigo
cmd_addAuto:                    # Entrada do comando addAuto
    addi $sp, $sp, -12              # Reserva espaco na pilha
    sw   $ra, 0($sp)                # Salva o endereco de retorno
    sw   $s0, 4($sp)                # Salva $s0 (argv)
    sw   $s1, 8($sp)                # Salva $s1 (registro do AP)
    li   $t0, 4                     # Quantidade esperada de opcoes
    bne  $a0, $t0, cm_addauto_inv   # Opcoes faltando ou sobrando: comando invalido
    move $s0, $a1                   # $s0 = argv
    lw   $a0, 4($s0)                # $a0 = argv[1] (AP)
    jal  cm_ap_base                 # Valida o AP
    beq  $v0, $zero, cm_addauto_ap  # AP invalido
    move $s1, $v0                   # $s1 = registro do AP
    lw   $t0, 12($s0)               # $t0 = argv[3] (modelo)
    lbu  $t1, 0($t0)                # Primeiro caractere do modelo
    beq  $t1, $zero, cm_addauto_inv # Modelo vazio: comando invalido
    lw   $t0, 16($s0)               # $t0 = argv[4] (placa)
    lbu  $t1, 0($t0)                # Primeiro caractere da placa
    beq  $t1, $zero, cm_addauto_inv # Placa vazia: comando invalido
    lw   $t0, 8($s0)                # $t0 = argv[2] (tipo, texto)
    lbu  $a1, 0($t0)                # $a1 = primeiro caractere do tipo
    lbu  $t1, 1($t0)                # Segundo caractere
    bne  $t1, $zero, cm_addauto_tipo # Tipo com mais de 1 caractere: invalido
    ori  $t2, $a1, 32               # Passa para minuscula
    li   $t3, 109                   # 'm'
    beq  $t2, $t3, cm_addauto_tipo_ok # E moto: tipo valido
    li   $t3, 99                    # 'c'
    bne  $t2, $t3, cm_addauto_tipo  # Nao e carro nem moto: tipo invalido
cm_addauto_tipo_ok:             # Tipo valido (c ou m): segue as demais validacoes
    lw   $t4, AP_QTD_MOR($s1)       # Quantidade de moradores do AP (+4)
    beq  $t4, $zero, cm_addauto_vazio # AP sem moradores: nao pode ter automovel
    li   $t3, 109                   # 'm'
    bne  $t2, $t3, cm_addauto_chama # Nao e moto: deixa o modulo validar a capacidade do carro
    lw   $t4, AP_AUTOS($s1)         # Quantidade de veiculos ja cadastrados (+296)
    li   $t5, MAX_MOTOS_CMD         # Limite de motos do enunciado (2)
    bge  $t4, $t5, cm_addauto_max   # Ja tem 2 veiculos: nao cabe outra moto
cm_addauto_chama:               # Chama a rotina do modulo addAuto
    move $a0, $s1                   # $a0 = registro do AP
    lw   $a2, 12($s0)               # $a2 = argv[3] (modelo)
    lw   $a3, 16($s0)               # $a3 = argv[4] (placa)
    jal  addAuto_inserir            # $v0 = 0 ok, -1 tipo invalido, -2 sem vaga
    beq  $v0, $zero, cm_addauto_fim # Sucesso: nada a imprimir
    li   $t0, -2                    # Codigo de AP sem vaga
    beq  $v0, $t0, cm_addauto_max   # Sem vaga
cm_addauto_tipo:                # Tipo invalido: mensagem de erro
    la   $a0, cm_tipo_inval         # "Falha: tipo invalido"
    jal  cm_erro                    # Imprime
    j    cm_addauto_fim             # Sai
cm_addauto_vazio:               # AP vazio: mensagem de erro
    la   $a0, cm_ap_vazio           # "Falha: AP vazio"
    jal  cm_erro                    # Imprime
    j    cm_addauto_fim             # Sai
cm_addauto_max:                 # Sem vaga: mensagem de erro
    la   $a0, cm_auto_max           # "Falha: AP com numero max de automoveis"
    jal  cm_erro                    # Imprime
    j    cm_addauto_fim             # Sai
cm_addauto_ap:                  # AP invalido: mensagem de erro
    la   $a0, cm_ap_inval           # "Falha: AP invalido"
    jal  cm_erro                    # Imprime
    j    cm_addauto_fim             # Sai
cm_addauto_inv:                 # Quantidade de opcoes errada: comando invalido
    la   $a0, cm_invalido           # "Comando invalido"
    jal  cm_erro                    # Imprime
cm_addauto_fim:                 # Epilogo: restaura registradores e retorna
    lw   $s1, 8($sp)                # Restaura $s1
    lw   $s0, 4($sp)                # Restaura $s0
    lw   $ra, 0($sp)                # Restaura o endereco de retorno
    addi $sp, $sp, 12               # Libera a pilha
    jr   $ra                        # Volta para o shell

