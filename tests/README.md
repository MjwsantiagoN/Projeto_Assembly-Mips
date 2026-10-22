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
