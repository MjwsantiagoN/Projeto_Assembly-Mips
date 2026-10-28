# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: recarregar.asm
# Descricao: cmd_9 - recarregar. Le "condominio.dat" e substitui os dados da
#            execucao atual (alteracoes nao salvas sao perdidas).
#            Contem tambem carregar_arquivo, usada pelo main na inicializacao (R3).
#            Os dados so sao substituidos se o arquivo estiver integro: o bloco
#            e lido para um buffer temporario e validado antes da copia.
#            Uso: recarregar        (nao tem opcoes)
# Entrada: $a0 = argc, $a1 = argv (ignorados). Preserva $s0-$s7.
# ==============================================================

.data                           # Segmento de dados
.align 2                        # Alinha em palavra (4 bytes)
cond_tmp:        .space 10752        # Buffer temporario (COND_TAM bytes)
msg_carregado:   .asciiz "Dados carregados de condominio.dat\n"  # Mensagem de sucesso
rc_sem_arq:      .asciiz "Falha: arquivo condominio.dat nao encontrado\n"  # Mensagem de arquivo inexistente
rc_invalido:     .asciiz "Falha: arquivo condominio.dat invalido ou corrompido\n"  # Mensagem de arquivo invalido

.text                           # Segmento de codigo
cmd_recarregar:                 # Entrada do comando recarregar
    addi $sp, $sp, -4              # Reserva espaco na pilha
    sw   $ra, 0($sp)               # Salva o endereco de retorno
    jal  carregar_arquivo           # $v0 = 0 ok, 1 sem arquivo, 2 invalido
    la   $a0, msg_carregado        # Mensagem de sucesso
    beq  $v0, $zero, recarregar_fim # Carregou: imprime sucesso
    li   $t0, 1                    # Codigo "arquivo inexistente"
    la   $a0, rc_sem_arq           # Mensagem de arquivo inexistente
    beq  $v0, $t0, recarregar_fim  # Imprime essa mensagem
    la   $a0, rc_invalido          # Caso contrario: arquivo invalido
recarregar_fim:                 # Imprime a mensagem escolhida e retorna
    jal  mmio_print_string          # Escreve a mensagem escolhida
    lw   $ra, 0($sp)               # Restaura o endereco de retorno
    addi $sp, $sp, 4               # Libera a pilha
    jr   $ra                       # Volta para o shell

# carregar_arquivo: le condominio.dat para o bloco "ap_tabela"
# $v0 = 0 sucesso | 1 arquivo nao existe | 2 arquivo invalido
# Em caso de erro os dados atuais ficam intactos.
carregar_arquivo:               # Entrada de carregar_arquivo (usada tambem pelo main)
    addi $sp, $sp, -8              # Reserva espaco na pilha
    sw   $ra, 0($sp)               # Salva o endereco de retorno
    sw   $s0, 4($sp)               # Salva $s0 (descritor do arquivo)

    li   $a1, 0                    # Flag 0 = leitura
    jal  arq_abrir                  # Abre condominio.dat (salvar.asm); $v0 = descritor ou negativo
    bltz $v0, carregar_sem_arq     # Negativo: arquivo nao existe
    move $s0, $v0                  # Guarda o descritor

    move $a0, $s0                  # Descritor
    la   $a1, arq_hdr              # Buffer = cabecalho
    li   $a2, 8                    # 8 bytes
    li   $v0, 14                   # Syscall 14 = ler do arquivo
    syscall                         # $v0 = bytes lidos
    li   $t0, 8                    # Esperado
    bne  $v0, $t0, carregar_invalido # Cabecalho incompleto
    la   $t0, arq_hdr              # Endereco do cabecalho
    lw   $t1, 0($t0)               # Numero magico lido
    li   $t2, ARQ_MAGICO           # Numero magico esperado
    bne  $t1, $t2, carregar_invalido # Formato diferente
    lw   $t1, 4($t0)               # Tamanho gravado
    li   $t2, COND_TAM             # Tamanho esperado
    bne  $t1, $t2, carregar_invalido # Tamanho diferente (arquivo de outra versao)

    move $a0, $s0                  # Descritor
    la   $a1, cond_tmp             # Le primeiro para o buffer temporario
    li   $a2, COND_TAM             # Quantidade de bytes
    li   $v0, 14                   # Syscall 14 = ler do arquivo
    syscall                         # $v0 = bytes lidos
    li   $t0, COND_TAM             # Esperado
    bne  $v0, $t0, carregar_invalido # Arquivo truncado

    move $a0, $s0                  # Descritor
    li   $v0, 16                   # Syscall 16 = fechar arquivo
    syscall                         # Fecha o arquivo
    la   $a0, ap_tabela           # Destino = dados do programa
    la   $a1, cond_tmp             # Origem = buffer validado
    li   $a2, COND_TAM             # Quantidade de bytes
    jal  memcpy                     # Copia (Auxiliares/memcpy.asm)
    li   $v0, 0                    # Retorno: sucesso
    j    carregar_ret               # Sai

carregar_invalido:              # Arquivo invalido: fecha e retorna 2
    move $a0, $s0                  # Descritor
    li   $v0, 16                   # Syscall 16 = fechar arquivo
    syscall                         # Fecha o arquivo
    li   $v0, 2                    # Retorno: arquivo invalido
    j    carregar_ret               # Sai
carregar_sem_arq:               # Arquivo inexistente: retorna 1
    li   $v0, 1                    # Retorno: arquivo nao existe
carregar_ret:                   # Epilogo: restaura registradores e retorna
    lw   $s0, 4($sp)               # Restaura $s0
    lw   $ra, 0($sp)               # Restaura o endereco de retorno
    addi $sp, $sp, 8               # Libera a pilha
    jr   $ra                       # Retorna para quem chamou
