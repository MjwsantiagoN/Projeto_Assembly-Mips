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

## Interface proposta de infoAp_executar

| Registrador | Significado |
| --- | --- |
| `$a0` | Base alinhada de uma tabela legivel com 24 registros |
| `$a1` | Numero inteiro do apartamento procurado |
| `$a2` | Passo entre registros, multiplo de quatro e pelo menos 448 |
| `$a3` | Endereco alinhado de uma rotina que imprime a string recebida em `$a0` |
| `$v0` | Zero no sucesso; -1 para AP ou parametros invalidos; -2 para contadores ou tipo inconsistentes |
| `$v1` | Endereco do AP consultado no sucesso; endereco da mensagem no erro |

O escritor e obrigatorio e deve ser uma rotina executavel valida. Deve preservar os registradores salvos e a pilha e retornar normalmente. Seus argumentos, temporarios, retornos e HI/LO podem ser modificados; seus valores de retorno sao ignorados pela consulta. O escritor nao deve alterar a tabela consultada. A consulta preserva os quatro argumentos e todos os registradores salvos do seu chamador. A validacao nao comprova a legibilidade de ponteiros arbitrarios ou a existencia de uma funcao em qualquer endereco alinhado; essas sao responsabilidades do chamador.

Com escritor valido, erros de AP e parametros exibem `Falha: AP invalido`. Contadores fora de 0 a 6 moradores ou 0 a 3 veiculos, tipo geral desconhecido e varios veiculos sob o tipo de carro retornam -2 e exibem `Falha: dados do AP invalidos`. Essa verificacao acontece antes do cabecalho para evitar saida parcial de registro inconsistente. Com escritor nulo ou desalinhado, a rotina retorna -1 e a mensagem em `$v1`, sem tentar imprimir.

A consulta imprime `AP: numero`, seguido de `Apartamento vazio` quando nao ha moradores. Com moradores, imprime `Moradores:` e os nomes ativos. Se houver veiculos, imprime `Carro:` ou `Moto:` e as linhas `modelo / placa`. Nao lista garagem residual de apartamento sem moradores. Os campos sao lidos e copiados para buffers locais limitados, sem modificar os registros, e sao impressos ate o terminador ou no maximo ate a capacidade util de cada campo. A opcao `all` nao faz parte desta entrega.

## Saida MMIO e testes da consulta

O arquivo `infoAp.asm` disponibiliza `infoAp_escreverMMIO`, que recebe uma string em `$a0`, aguarda o bit de disponibilidade em `0xFFFF0008` e escreve cada caractere em `0xFFFF000C`. Para usa-lo, o chamador deve passar seu endereco em `$a3` e conectar o Keyboard and Display MMIO Simulator do MARS. Ele nao depende da inclusao do exemplo `Auxiliares/MMIO.asm`, que possui seu proprio `main` e laco infinito de eco.

Os testes passam outro escritor em `$a3`, capturam todo o texto e comparam com strings esperadas independentes. Esse escritor usa a area de argumentos e sobrescreve registradores temporarios, argumentos, retornos e HI/LO, exercitando a convencao de chamadas. A captura nao faz parte do codigo de producao. Um cenario separado testa a escrita nos enderecos MMIO com disponibilidade simulada em memoria; isso nao comprova o funcionamento da janela grafica nem a integracao com o shell completo.
