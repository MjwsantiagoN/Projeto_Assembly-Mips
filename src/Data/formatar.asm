# Grupo: LBFM (Leticia, Brenno, Ferraz, Marcos)
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organizacao de Computadores
# Semestre letivo: 2026.2
# Arquivo: formatar.asm
# Descricao: cmd_10 - formatar. Apaga todas as informacoes da execucao atual,
#            deixando todos os apartamentos vazios (zera toda a tabela
#            ap_tabela e regrava os numeros dos APs com ap_inicializarTabela). NAO altera o arquivo externo: e preciso usar
#            "salvar" depois para gravar o estado formatado.
#            Uso: formatar        (nao tem opcoes)
# Entrada: $a0 = argc, $a1 = argv (ignorados). Preserva $s0-$s7.

.data
fm_ok: .asciiz "Dados da execucao atual apagados (use salvar para gravar no arquivo)\n"

.text
cmd_formatar:
    addi $sp, $sp, -4              # Reserva espaco na pilha
    sw   $ra, 0($sp)               # Salva o endereco de retorno
    la   $t0, ap_tabela           # $t0 = inicio do bloco de dados
    li   $t1, COND_TAM             # $t1 = tamanho em bytes
    srl  $t1, $t1, 2               # $t1 = quantidade de words (bytes / 4)
formatar_loop:
    sw   $zero, 0($t0)             # Zera uma word (0 moradores, 0 autos, nomes vazios)
    addi $t0, $t0, 4               # Avanca para a proxima word
    addi $t1, $t1, -1              # Uma word a menos
    bne  $t1, $zero, formatar_loop # Repete ate zerar tudo
    jal  ap_inicializarTabela       # Os numeros dos APs (101..1202, no inicio de cada registro) tem que continuar la
    la   $a0, fm_ok                # Mensagem de confirmacao
    jal  mmio_print_string          # Escreve no display
    lw   $ra, 0($sp)               # Restaura o endereco de retorno
    addi $sp, $sp, 4               # Libera a pilha
    jr   $ra                       # Volta para o shell
