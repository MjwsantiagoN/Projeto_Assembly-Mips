# Testes isolados das rotinas de apartamentos

`limparAp_zerarRegiao_teste.asm` verifica a auxiliar `limparAp_zerarRegiao`, definida em `src/apartamento/limparAp.asm`. O teste usa sua propria memoria e nao depende do shell nem de um layout definitivo de apartamento.

Esta entrega ainda nao implementa `limparAp --AP`. A integracao devera validar o apartamento, selecionar as regioes mutaveis corretas, atualizar o estado conforme o layout do grupo e usar a saida compartilhada do sistema. Zerar bytes so e adequado para campos cuja representacao de vazio seja zero.

## Executar no MARS

Na raiz do repositorio, com Java disponivel:

```text
java -jar Mars4_5.jar nc sm ae1 se1 10000 tests/limparAp_zerarRegiao_teste.asm
java -jar Mars4_5.jar nc sm db ae1 se1 10000 tests/limparAp_zerarRegiao_teste.asm
```

A segunda execucao habilita delayed branching. As duas devem imprimir `PASS: limparAp_zerarRegiao (6 cenarios)` e terminar com codigo zero. Falhas nas verificacoes, na montagem ou na simulacao retornam codigo diferente de zero. Atingir o limite de 10000 instrucoes sem a mensagem PASS tambem indica falha.

Pela interface grafica, abrir somente o arquivo de teste e deixar desmarcada a opcao `Assemble all files in directory`. Montar e executar. O teste imprime seu resultado no terminal padrao do MARS; isso nao define a entrada e saida do shell, que o grupo escolheu implementar com MMIO.

## Cenarios

1. Limpar quatro bytes, verificar cada byte e conferir os argumentos preservados.
2. Solicitar tamanho zero sem modificar a memoria.
3. Rejeitar tamanho negativo sem modificar a memoria.
4. Rejeitar endereco nulo com tamanho positivo, sem acessar a memoria.
5. Aceitar endereco nulo com tamanho zero, sem acessar a memoria.
6. Repetir a limpeza de uma regiao ja zerada.

Ao final, verificar que as marcas imediatamente anterior e posterior e o dado representando outro apartamento permaneceram intactos.

## Teste da limpeza dos veiculos

`limparAp_limparVeiculos_teste.asm` verifica a rotina `limparAp_limparVeiculos`, que recebe o endereco base de um registro de AP valido. O retorno e zero no sucesso ou -1 para endereco nulo.

A rotina usa o layout publicado por Brenno no commit `1288444580b80bdbb473b44f64249d306430207f` da branch `feat/automovel-adicao`: contador em +296, tipo geral em +300 e tres slots de 48 bytes a partir de +304. Ela zera somente os 152 bytes de +296 a +447, inclusive residuos em slots nao contados. As constantes de limpeza possuem prefixo proprio para nao colidir com as de `addAuto.asm`.

Os 296 bytes anteriores sao dados opacos neste teste: nenhuma estrutura de moradores e presumida. A quantidade de memoria reservada para o teste tambem nao define o tamanho definitivo de um AP.

Executar separadamente do teste anterior, a partir da raiz do repositorio:

```text
java -jar Mars4_5.jar nc sm ae1 se1 100000 tests/limparAp_limparVeiculos_teste.asm
java -jar Mars4_5.jar nc sm db ae1 se1 100000 tests/limparAp_limparVeiculos_teste.asm
```

O resultado esperado em ambas as execucoes e `PASS: limparAp_limparVeiculos (6 cenarios)`, com codigo de saida zero. Montagem, simulacao ou verificacao com erro devem terminar com codigo nao zero. Atingir o limite de instrucoes sem a mensagem PASS tambem indica falha.

Os seis cenarios sao: cabecalho indicando um carro; cabecalho indicando tres motos; garagem ja vazia; contador zero com residuos nos slots; endereco nulo; repeticao da limpeza sem preparar novos dados. Os slots usam padroes artificiais de bytes para detectar qualquer dado nao limpo; o teste nao executa o comando `addAuto` nem o shell.

As verificacoes conferem todos os bytes da garagem, todos os bytes anteriores, uma marca posterior e um dado externo. Tambem conferem os quatro argumentos, dois registradores salvos e o equilibrio da pilha nas chamadas validas. No caminho de endereco nulo, conferem retorno, argumentos usados, pilha e preservacao da memoria.

A nova rotina ainda nao e o comando completo `limparAp --AP`: ela nao identifica o apartamento pelo numero, nao remove moradores nem atualiza sua ocupacao. Essas etapas dependem dos contratos restantes do grupo. O teste usa syscalls apenas para informar seu resultado; a entrada e saida do shell continua prevista por MMIO.

## Teste da limpeza do registro sob contrato proposto

`limparAp_executar_teste.asm` monta uma tabela ficticia de 24 apartamentos e verifica `limparAp_executar`. O contrato de identificacao, moradores e ocupacao e uma proposta descrita em `docs/contrato_apartamentos.md`, ainda sujeita a revisao do grupo. A garagem segue o layout ja publicado em `addAuto.asm`.

A rotina recebe a base da tabela, o numero inteiro do AP e o passo entre registros. Localiza o AP, preserva sua identificacao, limpa moradores e garagem e deixa a quantidade de moradores em zero, que neste contrato representa apartamento vazio. O retorno e zero com endereco do registro em `$v1`, ou -1 com endereco de `Falha: AP invalido\n` em `$v1`. A exibicao da mensagem pelo shell/MMIO ainda nao esta integrada.

Executar este programa separadamente dos dois testes anteriores, na raiz do repositorio:

```text
java -jar Mars4_5.jar nc sm ae1 se1 10000000 tests/limparAp_executar_teste.asm
java -jar Mars4_5.jar nc sm db ae1 se1 10000000 tests/limparAp_executar_teste.asm
```

O teste mostra ANTES e DEPOIS dos registros nos cenarios de sucesso, informa `OK cenario N` em cada verificacao e deve terminar com `PASS: limparAp_executar (12 cenarios)` e codigo zero. Erros de montagem, simulacao ou assercao devem retornar codigo nao zero. Atingir o limite sem a mensagem PASS tambem indica falha.

Os cenarios cobrem:

1. AP intermediario com dois moradores e carro.
2. Ultimo AP com seis moradores e tres motos.
3. Primeiro AP ja vazio.
4. Numero de apartamento ausente da tabela.
5. Base de tabela nula.
6. Passo menor que o tamanho minimo de 448 bytes.
7. Passo sem alinhamento de quatro bytes.
8. Base de tabela sem alinhamento de quatro bytes.
9. Numero de apartamento zero.
10. Numero de apartamento negativo.
11. Tabela compacta com passo de 448 bytes.
12. Repeticao da limpeza na tabela compacta ja limpa.

Em cada cenario sao conferidos todos os bytes dos 24 registros, preservacao dos identificadores e dados dos outros apartamentos, reserva posterior a garagem, sobra do buffer compacto, sentinelas externos, os quatro argumentos, todos os oito registradores salvos e o equilibrio da pilha. Nos erros, a mensagem retornada e comparada integralmente e toda a tabela deve permanecer inalterada.

Os nomes e veiculos sao ficticios e criados pelo proprio teste, sem chamar os cadastros do grupo. A referencia reserva 512 bytes por registro, mas os cenarios tambem montam uma tabela com passo de 448. Os espacos de 48 bytes usados para nomes no exemplo nao sao uma decisao sobre o formato definitivo do cadastro de moradores.

Este programa usa o terminal padrao do MARS somente para demonstrar e informar resultados. Nao cria um shell paralelo, nao define a tabela global do projeto, nao salva arquivos e nao comprova a integracao do comando `limparAp --AP` com MMIO. Os testes anteriores continuam necessarios para verificar os contratos das auxiliares.

## Teste da consulta individual simplificada

`infoAp_executar_teste.asm` verifica a saida completa com apartamentos ficticios. A consulta usa chamadas diretas a `ap_imprimirTexto`; o programa de teste define essa funcao para capturar texto. O modulo real de MMIO e testado separadamente.

Na raiz do repositorio:

```text
java -jar Mars4_5.jar nc sm ae1 se1 10000000 tests/infoAp_executar_teste.asm
java -jar Mars4_5.jar nc sm db ae1 se1 10000000 tests/infoAp_executar_teste.asm
```

O resultado esperado e `PASS: infoAp_executar (21 cenarios)`, com codigo zero. Atingir o limite sem PASS ou terminar com codigo diferente de zero indica falha. A opcao Assemble all files in directory deve ficar desmarcada na interface grafica.

Cenarios:

1. AP vazio.
2. morador sem veiculo.
3. dois moradores e carro.
4. seis moradores e tres motos.
5. AP ausente.
6. base nula.
7. passo insuficiente.
8. passo desalinhado.
9. base desalinhada.
10. moradores acima do limite.
11. veiculos acima dos slots.
12. tipo carro com dois veiculos.
13. nome no limite.
14. tabela compacta.
15. garagem residual em AP vazio.
16. moradores negativos.
17. veiculos negativos.
18. tipo geral desconhecido.
19. nome sem terminador.
20. AP zero.
21. AP negativo.

O teste compara todas as linhas e o retorno, confere os quatro argumentos e todos os registradores salvos, verifica a pilha e compara os 12288 bytes da tabela e reservas com um snapshot anterior. Sentinelas protegem tabela e captura. A impressao de teste preserva argumentos, salvos e pilha, mas altera temporarios, retornos e HI/LO.

## Teste da saida MMIO simplificada

```text
java -jar Mars4_5.jar nc sm ae1 se1 100000 tests/saidaApMMIO_teste.asm
java -jar Mars4_5.jar nc sm db ae1 se1 100000 tests/saidaApMMIO_teste.asm
```

Resultado esperado: `PASS: saidaApMMIO (3 cenarios)`.

1. Texto ABC sem limite: o ultimo caractere escrito e C.
2. Texto ABC com limite dois: o ultimo caractere escrito e B.
3. Texto vazio: nenhum novo caractere e enviado.

A disponibilidade do display e simulada diretamente no registrador de controle. Isso verifica os enderecos e o limite de leitura, mas nao substitui o teste com o dispositivo grafico conectado ao shell.

O contrato dos nomes continua como proposta em seis espacos contiguos de 48 bytes. Para estudar as rotinas, consultar `docs/guia_apresentacao.md`.

## Teste de infoAp --all

```text
java -jar Mars4_5.jar nc sm ae1 se1 10000000 tests/infoApTodos_teste.asm
java -jar Mars4_5.jar nc sm db ae1 se1 10000000 tests/infoApTodos_teste.asm
```

Ambos devem terminar com `PASS: infoAp_listarTodos (8 cenarios)` e codigo zero. Os casos verificam os 24 APs vazios com registros fisicamente invertidos e passos de 512 e 448 bytes, uma tabela com AP ocupado, base nula, passo insuficiente, passo desalinhado, ID ausente e contador invalido. A referencia compara o texto integral, inclusive ordem e quebras de linha. Confere argumentos, oito registradores salvos, pilha, todos os 12288 bytes reservados e sentinelas. A captura altera temporarios e HI/LO deliberadamente.

## Teste dos comandos de apartamentos integrados

```text
java -jar Mars4_5.jar nc sm ae1 se1 10000000 tests/comandosAp_teste.asm
java -jar Mars4_5.jar nc sm db ae1 se1 10000000 tests/comandosAp_teste.asm
```

Resultado esperado: `PASS: comandosAp (14 cenarios)` e codigo zero. Inclui a tabela e o interpretador reais e substitui somente a saida MMIO por captura. Verifica texto completo, consulta com morador e carro, limpeza incluindo residuos, listagem dos 24 APs, APs invalidos, sintaxe, argumento vazio, argumento extra, texto numerico longo, sinal, zero inicial e ultimo AP. Compara a tabela inteira com uma referencia independente e confere argumentos, oito registradores salvos, pilha e limites da captura.

O programa real pode ser montado com `java -jar Mars4_5.jar nc a ae1 src/main.asm`. Para executar interativamente, abrir no MARS e conectar o simulador MMIO. Ver `docs/integracao_apartamentos.md` e `docs/estudo_rapido.md`.
