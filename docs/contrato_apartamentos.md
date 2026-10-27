# Proposta de contrato dos registros e consultas de apartamentos

Esta proposta permite implementar e testar a limpeza e a consulta individual do registro de um apartamento sem criar o shell, o cadastro de moradores ou uma tabela global para os outros integrantes. Os campos de identificacao e moradores abaixo ainda precisam de revisao e acordo do grupo antes da integracao. O layout da garagem ja foi publicado por Brenno em `src/automovel/addAuto.asm`, no commit `1288444580b80bdbb473b44f64249d306430207f`.

## Layout do registro

| Deslocamento em bytes | Conteudo | Origem |
| --- | --- | --- |
| 0 a 3 | Numero do apartamento, em uma word | Proposta desta entrega |
| 4 a 7 | Quantidade de moradores, em uma word | Proposta desta entrega |
| 8 a 295 | Area de dados dos moradores, com 288 bytes | Proposta desta entrega |
| 296 a 299 | Quantidade de veiculos, em uma word | Contrato publicado por Brenno |
| 300 a 303 | Tipo geral de veiculo, em uma word | Contrato publicado por Brenno |
| 304 a 447 | Tres slots de 48 bytes para veiculos | Contrato publicado por Brenno |
| A partir de 448 | Campos ou reserva opcionais do registro | Preservados pela limpeza |

A limpeza nao presume a codificacao interna dos nomes: ela zera todos os 288 bytes reservados. Para a consulta individual, esta entrega estende a proposta com seis espacos contiguos de 48 bytes para nomes terminados em zero, com ate 47 caracteres uteis cada. Os primeiros `num_moradores` espacos sao os registros ativos. Este formato ainda precisa de acordo do grupo e pode exigir adaptacao no cadastro ou na consulta; nao se trata de uma definicao ja publicada pelos outros integrantes.

Neste contrato, a ocupacao e derivada da quantidade de moradores: zero significa apartamento vazio. Nao existe um segundo indicador de ocupacao a atualizar. Se o grupo adotar esse indicador ou outros campos mutaveis fora da regiao proposta, a rotina devera ser ajustada antes de ser integrada.

O registro precisa comportar pelo menos 448 bytes. O passo real entre registros e fornecido pelo chamador e pode ser, por exemplo, 448 ou 512 bytes. Nao se conclui que o tamanho oficial seja 512 apenas porque os testes de automoveis usam buffers desse tamanho.

## Interface de limparAp_executar

| Registrador | Significado |
| --- | --- |
| `$a0` | Base alinhada de uma tabela gravavel com 24 registros |
| `$a1` | Numero inteiro do apartamento procurado |
| `$a2` | Passo entre registros, multiplo de quatro e pelo menos 448 |
| `$v0` | Zero no sucesso; -1 para AP nao encontrado ou parametros invalidos |
| `$v1` | Endereco do registro limpo no sucesso; endereco de `Falha: AP invalido\n` no erro |

Os argumentos `$a0` a `$a3`, os registradores `$s0` a `$s7`, o retorno e o equilibrio da pilha sao preservados. Os temporarios `$t0` e `$t1` e os retornos `$v0` e `$v1` podem mudar. O chamador deve oferecer memoria valida suficiente para toda a tabela, com identificadores de apartamentos validos e unicos e sem estouro no calculo dos enderecos.

A rotina examina exatamente os 24 registros, comparando o identificador de cada um com o numero solicitado. Para um registro encontrado, preserva os bytes 0 a 3 e tudo a partir de 448, zera contador e area de moradores e reutiliza `limparAp_limparVeiculos` para zerar a garagem. Para AP nao encontrado ou parametros rejeitados na entrada, nao altera a tabela.

## Integracao com o shell

O shell ainda deve reconhecer `limparAp --AP`, converter seu argumento para numero e chamar esta rotina com a tabela e o passo aprovados pelo grupo. Em erro, deve imprimir a string apontada por `$v1` pela interface compartilhada de saida, prevista para MMIO. A rotina nao imprime por conta propria, nao salva arquivo e nao redefine o interpretador ou o MMIO.

O teste isolado demonstra a limpeza em memoria; ele nao comprova que o comando ja esta integrado ao shell. As rotinas das duas etapas anteriores continuam com seus contratos originais.

## Entrega e dependencias

Esta etapa reutiliza as auxiliares publicadas nos PRs #1 e #2. A proposta de layout, os testes e a implementacao devem ser revisados em conjunto. A publicacao desta etapa nao aprova por si so o layout para os modulos dos colegas nem autoriza merge automatico.

## Interface simplificada de infoAp_executar

| Registrador | Significado |
| --- | --- |
| `$a0` | Base alinhada de uma tabela legivel com 24 registros |
| `$a1` | Numero inteiro do apartamento procurado |
| `$a2` | Passo entre registros, multiplo de quatro e pelo menos 448 |
| `$v0` | Zero no sucesso; -1 para AP ou parametros invalidos; -2 para dados inconsistentes |
| `$v1` | Endereco do AP consultado ou endereco da mensagem de erro |

A consulta chama diretamente `ap_imprimirTexto`. Nao recebe uma funcao de impressao em `$a3` e nao usa `jalr`. O quarto registrador de argumentos nao e usado como parametro desta interface. Os argumentos de entrada, os registradores salvos e a pilha sao preservados; temporarios, retornos e HI/LO podem mudar.

A consulta usa somente tres registradores salvos: `$s0` mantem o endereco do AP, `$s1` conta nomes ou veiculos restantes e `$s2` aponta para o campo atual. Reserva 40 bytes na pilha: 24 para retorno, registradores e dois argumentos que modifica, mais 16 para argumentos de chamadas auxiliares. O restante dos argumentos nao e modificado pelas rotinas chamadas.

A tabela precisa ter memoria legivel suficiente e identificadores de apartamentos validos e unicos, sem estouro de enderecos. Nao existe verificacao geral de ponteiros arbitrarios. Contadores invalidos e tipo geral de veiculo inconsistente produzem `Falha: dados do AP invalidos` antes de qualquer cabecalho parcial.

A saida mantem o formato: `AP: numero`; para AP sem moradores, `Apartamento vazio`; para AP ocupado, `Moradores:` e nomes, seguidos de `Carro:` ou `Moto:` e linhas `modelo / placa`, se houver veiculos. Nao mostra a garagem residual de um AP sem moradores. Os dados da tabela nao sao alterados.

## Impressao direta pelo Display MMIO

`src/Auxiliares/saidaApMMIO.asm` fornece `ap_imprimirTexto`:

- `$a0`: endereco de uma string legivel.
- `$a1`: limite nao negativo de caracteres. Zero imprime ate o terminador nulo; positivo imprime ate o terminador ou esse limite.
- Argumentos, registradores salvos e pilha sao preservados. Temporarios podem mudar.

A funcao espera o bit zero de `0xFFFF0008` e envia o caractere a `0xFFFF000C`. A consulta usa limite 47 para nomes, 31 para modelos e 11 para placas, sem precisar copiar cada campo para outro buffer. Mensagens fixas usam limite zero.

O futuro `src/main.asm` deve incluir os dois modulos, por exemplo:

```asm
.include "apartamento/infoAp.asm"
.include "Auxiliares/saidaApMMIO.asm"
```

Essas inclusoes nao substituem o ponto de entrada do shell. Conectar o Keyboard and Display MMIO Simulator para a execucao real. O exemplo antigo `MMIO.asm` continua separado, com seu proprio `main`.

## Testes da interface simplificada

O teste de consulta define sua propria `ap_imprimirTexto`, que guarda os caracteres em um buffer em vez de acessar o display. O nome da chamada e o mesmo, mas os programas de teste e producao incluem implementacoes diferentes; nao devem ser montados todos juntos.

Sao 21 cenarios de consulta, com comparacao integral de texto, memoria somente leitura, argumentos, salvos e pilha. Os dois antigos casos de ponteiro de escritor invalido deixaram de existir porque esse parametro foi removido. Os testes de MMIO foram separados em tres cenarios: texto completo, limite de caracteres e string vazia.

O teste MMIO simula disponibilidade em memoria; ele nao comprova a janela grafica nem o shell integrado. As propostas de layout continuam sujeitas a revisao do grupo.

## Limpeza simplificada

`limparAp_executar` mantem a interface e os resultados anteriores. Agora usa somente `$s0` para guardar o AP entre chamadas; `$t0` le o identificador e `$t1` conta a busca antes de chamar as auxiliares. Sua pilha passou de 64 para 32 bytes. As duas auxiliares de limpeza mantem suas interfaces. Os 24 cenarios anteriores continuam validos.

## Consulta de todos os apartamentos

`infoAp_listarTodos`, em `src/apartamento/infoApTodos.asm`, recebe tabela em `$a0` e passo em `$a1`. Chama a consulta individual para os numeros 101, 102, 201, 202, ate 1201 e 1202. Assim a saida fica ordenada mesmo quando os registros estao invertidos na memoria. A tabela precisa conter exatamente esses 24 IDs, validos e unicos.

Retorna `$v0 = 0` e `$v1 = 24` ao concluir. No primeiro erro, interrompe e repassa status e mensagem da consulta individual; linhas anteriores podem ja ter sido mostradas. Preserva argumentos, registradores salvos e pilha, sem modificar a tabela. Usa quatro registradores salvos e uma pilha de 48 bytes. O chamador deve incluir consulta individual, consulta completa e impressao.
