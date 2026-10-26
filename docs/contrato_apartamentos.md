# Proposta de contrato para a limpeza de apartamentos

Esta proposta permite implementar e testar a limpeza do registro de um apartamento sem criar o shell, o cadastro de moradores ou uma tabela global para os outros integrantes. Os campos de identificacao e moradores abaixo ainda precisam de revisao e acordo do grupo antes da integracao. O layout da garagem ja foi publicado por Brenno em `src/automovel/addAuto.asm`, no commit `1288444580b80bdbb473b44f64249d306430207f`.

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

A limpeza nao presume a codificacao interna dos nomes: ela zera todos os 288 bytes reservados. Os exemplos de teste usam strings terminadas em zero em espacos de 48 bytes apenas como dados ficticios. O formato definitivo dos nomes ainda deve ser combinado para implementar cadastro e consulta.

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
