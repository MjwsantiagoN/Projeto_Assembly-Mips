# Teste isolado da limpeza de dados

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
