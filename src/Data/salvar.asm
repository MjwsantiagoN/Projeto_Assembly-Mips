# ==============================================================
# Grupo: BJLM (Brenno, Joao, Leticia, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: salvar.asm
# Descricao: cmd_8 - salvar. Grava toda a tabela de apartamentos (ap_tabela) no arquivo externo
#            "condominio.dat" usando os syscalls de arquivo do MARS (R3).
#            Formato do arquivo (binario):
#              bytes 0-3  : numero magico 0x31444E43 ("CND1")
#              bytes 4-7  : tamanho do bloco de dados (COND_TAM)
#              bytes 8... : copia exata do bloco "ap_tabela"
#            Uso: salvar        (nao tem opcoes)
# Entrada: $a0 = argc, $a1 = argv (ignorados). Preserva $s0-$s7.
# Obs.: o arquivo e criado no diretorio de trabalho do MARS.
# ==============================================================

.eqv ARQ_MAGICO 0x31444E43          # Identificador do formato do arquivo ("CND1")

.data                           # Segmento de dados
arq_base:      .asciiz "condominio.dat"   # Nome do arquivo externo (usado tambem por recarregar)
arq_nome:      .space 48            # Nome efetivo usado no syscall (prefixos "./" + arq_base)
arq_pref:      .word 0              # Quantos "./" prefixar (ver arq_abrir)
.align 2                        # Alinha em palavra (4 bytes)
arq_hdr:       .space 8             # Cabecalho do arquivo: magico + tamanho
sv_ok:         .asciiz "Dados salvos em condominio.dat\n"  # Mensagem de sucesso
sv_erro_abrir: .asciiz "Falha: nao foi possivel criar o arquivo\n"  # Mensagem de erro ao abrir
sv_erro_grava: .asciiz "Falha: erro ao gravar o arquivo\n"  # Mensagem de erro ao gravar

.text                           # Segmento de codigo
cmd_salvar:                     # Entrada do comando salvar
    addi $sp, $sp, -8              # Reserva espaco na pilha
    sw   $ra, 0($sp)               # Salva o endereco de retorno
    sw   $s0, 4($sp)               # Salva $s0 (descritor do arquivo)

    li   $a1, 1                    # Flag 1 = escrita (cria/trunca)
    jal  arq_abrir                  # Abre condominio.dat; $v0 = descritor ou negativo se erro
    bltz $v0, salvar_erro_abrir    # Se negativo, nao abriu
    move $s0, $v0                  # Guarda o descritor em $s0

    la   $t0, arq_hdr              # Endereco do cabecalho
    li   $t1, ARQ_MAGICO           # Numero magico
    sw   $t1, 0($t0)               # Cabecalho[0] = magico
    li   $t1, COND_TAM             # Tamanho do bloco de dados
    sw   $t1, 4($t0)               # Cabecalho[1] = tamanho
    move $a0, $s0                  # Descritor do arquivo
    la   $a1, arq_hdr              # Buffer = cabecalho
    li   $a2, 8                    # 8 bytes
    li   $v0, 15                   # Syscall 15 = escrever no arquivo
    syscall                         # $v0 = bytes escritos
    li   $t0, 8                    # Esperado
    bne  $v0, $t0, salvar_erro_grava # Se escreveu menos, deu erro

    move $a0, $s0                  # Descritor do arquivo
    la   $a1, ap_tabela           # Buffer = todos os dados dos apartamentos
    li   $a2, COND_TAM             # Quantidade de bytes
    li   $v0, 15                   # Syscall 15 = escrever no arquivo
    syscall                         # $v0 = bytes escritos
    li   $t0, COND_TAM             # Esperado
    bne  $v0, $t0, salvar_erro_grava # Se escreveu menos, deu erro

    move $a0, $s0                  # Descritor do arquivo
    li   $v0, 16                   # Syscall 16 = fechar arquivo
    syscall                         # Fecha (garante que os dados foram gravados)
    la   $a0, sv_ok                # Mensagem de sucesso
    j    salvar_fim                 # Vai imprimir e sair

salvar_erro_grava:              # Erro de gravacao: fecha o arquivo e escolhe a mensagem
    move $a0, $s0                  # Descritor do arquivo
    li   $v0, 16                   # Syscall 16 = fechar arquivo
    syscall                         # Fecha mesmo com erro
    la   $a0, sv_erro_grava        # Mensagem de erro de gravacao
    j    salvar_fim                 # Vai imprimir e sair
salvar_erro_abrir:              # Erro ao abrir: escolhe a mensagem
    la   $a0, sv_erro_abrir        # Mensagem de erro ao abrir
salvar_fim:                     # Imprime a mensagem escolhida e retorna
    jal  mmio_print_string          # Escreve a mensagem escolhida
    lw   $s0, 4($sp)               # Restaura $s0
    lw   $ra, 0($sp)               # Restaura o endereco de retorno
    addi $sp, $sp, 8               # Libera a pilha
    jr   $ra                       # Volta para o shell

# arq_abrir: abre condominio.dat (syscall 13).
# $a1 = flag (0 = leitura, 1 = escrita)    $v0 = descritor ou negativo se falhou
# Contorna um defeito do MARS: quando uma abertura FALHA (ex.: ler um arquivo que
# ainda nao existe), o MARS deixa aquele nome "ocupado" e nunca mais abre arquivo
# com o mesmo nome (nem para criar). Por isso, apos uma falha passamos a usar um
# nome equivalente ("./condominio.dat", ".//condominio.dat", ...) nas proximas
# aberturas. Na escrita, se o nome estiver ocupado, tenta de novo com outro (ate 3x).
arq_abrir:                      # Entrada de arq_abrir
    addi $sp, $sp, -12              # Reserva espaco na pilha
    sw   $ra, 0($sp)                # Salva o endereco de retorno
    sw   $s0, 4($sp)                # Salva $s0 (flag de abertura)
    sw   $s1, 8($sp)                # Salva $s1 (tentativas restantes)
    move $s0, $a1                   # $s0 = flag (0 leitura / 1 escrita)
    li   $s1, 3                     # Ate 3 tentativas (so usadas na escrita)
arq_abrir_tenta:                # Monta o nome do arquivo e tenta abrir
    la   $t0, arq_nome              # $t0 = onde montar o nome
    la   $t1, arq_pref              # Endereco do contador de prefixos
    lw   $t2, 0($t1)                # $t2 = quantidade de "./" a colocar
arq_abrir_pref:                 # Laco: escreve um prefixo "./" por iteracao
    beq  $t2, $zero, arq_abrir_base # Terminou os prefixos
    li   $t3, 46                    # '.'
    sb   $t3, 0($t0)                # Escreve '.'
    li   $t3, 47                    # '/'
    sb   $t3, 1($t0)                # Escreve '/'
    addi $t0, $t0, 2                # Avanca 2 bytes
    addi $t2, $t2, -1               # Um prefixo a menos
    j    arq_abrir_pref             # Repete
arq_abrir_base:                 # Completa o nome com "condominio.dat" e abre
    move $a0, $t0                   # Destino = fim dos prefixos
    la   $a1, arq_base              # Origem = "condominio.dat"
    jal  strcpy                     # Completa o nome (Auxiliares/strcpy)
    la   $a0, arq_nome              # Nome completo
    move $a1, $s0                   # Flag
    li   $a2, 0                     # Modo (ignorado pelo MARS)
    li   $v0, 13                    # Syscall 13 = abrir arquivo
    syscall                         # $v0 = descritor ou negativo
    bgez $v0, arq_abrir_ret         # Abriu: pronto
    la   $t1, arq_pref              # Falhou: o nome ficou ocupado no MARS
    lw   $t2, 0($t1)                # Prefixos atuais
    slti $t3, $t2, 16               # Limite de prefixos (cabe no buffer)
    beq  $t3, $zero, arq_abrir_ret  # Limite atingido: desiste
    addi $t2, $t2, 1                # Proxima abertura usa um nome novo
    sw   $t2, 0($t1)                # Guarda o novo contador
    beq  $s0, $zero, arq_abrir_ret  # Leitura: nao insiste (arquivo nao existe mesmo)
    addi $s1, $s1, -1               # Escrita: gasta uma tentativa
    bgtz $s1, arq_abrir_tenta       # Tenta de novo com o novo nome
arq_abrir_ret:                  # Epilogo: restaura registradores e retorna
    lw   $s1, 8($sp)                # Restaura $s1
    lw   $s0, 4($sp)                # Restaura $s0
    lw   $ra, 0($sp)                # Restaura o endereco de retorno
    addi $sp, $sp, 12               # Libera a pilha
    jr   $ra                        # Retorna ($v0 = resultado do syscall)
