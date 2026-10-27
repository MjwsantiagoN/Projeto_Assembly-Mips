# Integracao dos comandos de apartamentos

Esta entrega liga `limparAp --AP`, `infoAp --AP` e `infoAp --all` ao teclado e ao display MMIO. O ponto de entrada e `src/main.asm`. A tabela comeca vazia e recebe os IDs 101, 102, 201, 202, ate 1202. O cadastro de moradores, os comandos de automoveis e os comandos administrativos nao sao chamados por este interpretador ainda. A persistencia tambem permanece a cargo da etapa do grupo.

## Executar no MARS

1. Abrir `src/main.asm` e desmarcar `Settings > Assemble all files in directory`.
2. Montar com F3.
3. Abrir `Tools > Keyboard and Display MMIO Simulator` e clicar em `Connect to MIPS`.
4. Executar com F5 e digitar na area de teclado do dispositivo.
5. Testar `infoAp --101`, `infoAp --all` e `limparAp --101`, sempre terminando com Enter.

O prompt e `LBFM-shell>> `. O shell usa MMIO para entrada e saida e aguarda a quebra de linha antes de executar. Permite backspace e aceita ate 127 caracteres. Se esse limite for ultrapassado, descarta a linha ate Enter, mostra `Comando invalido` e aguarda outra linha. CR e ignorado; LF termina a linha. O buffer nunca e executado truncado.

Os comandos sao sensiveis a maiusculas e exigem o separador ` --`. Para AP numerico, aceita tres ou quatro digitos, sem zero inicial, andar de 1 a 12 e final 01 ou 02. Parametro de AP invalido produz `Falha: AP invalido`. Outros comandos ainda produzem `Comando invalido` neste ponto de integracao parcial.

## Arquivos e responsabilidades

| Arquivo | Papel |
| --- | --- |
| `src/main.asm` | Banner e repeticao de leitura e execucao |
| `src/Auxiliares/entradaApMMIO.asm` | Recebe, edita e finaliza uma linha |
| `src/Auxiliares/saidaApMMIO.asm` | Espera o display e envia caracteres |
| `src/apartamento/tabelaAp.asm` | Reserva os 24 registros e inicializa seus IDs |
| `src/apartamento/comandosAp.asm` | Reconhece os comandos e valida o AP |
| `src/apartamento/limparAp.asm` | Faz a limpeza efetiva |
| `src/apartamento/infoAp.asm` | Mostra um registro |
| `src/apartamento/infoApTodos.asm` | Pede os 24 registros em ordem |

`ap_inicializarTabela` preenche somente os IDs. Nao apaga os campos de moradores e veiculos; uma futura carga de arquivo deve manter o contrato do registro. A area reservada por `.space` comeca zerada na inicializacao do MARS. Nenhum cadastro ficticio e inserido no programa real.

## Incompatibilidade encontrada no PR de moradores

Em 27/10/2026, a `dev` estava em `796bd4d`, e o PR #7 de moradores estava aberto na revisao `f0538bd`. A proposta daquele PR ainda nao e compativel com a garagem ja integrada:

| Campo | Apartamentos e automoveis integrados | Proposta do PR #7 |
| --- | --- | --- |
| ID do AP | +0 | Implicito pelo indice |
| Contador de moradores | +4 | +0 |
| Inicio dos nomes | +8 | +4 |
| Tamanho por nome | 48 bytes | 32 bytes |
| Inicio da garagem | +296 | +196 |
| Tamanho da garagem | 152 bytes | 140 bytes |
| Tamanho minimo do AP | 448 bytes | 336 bytes |

O comentario do layout do PR #7 atribui +196 a Brenno, mas o codigo de `addAuto.asm` e `rmvAuto.asm` realmente usa +296, +300 e +304. Um bloco de 336 bytes nao comporta a garagem que termina em +447. Combinar esses formatos diretamente pode modificar o AP vizinho.

Esta entrega oferece uma tabela executavel com o contrato que ja vinha sendo usado pelas rotinas de apartamentos e pela garagem. Isso e uma proposta de integracao para revisao, nao uma confirmacao de acordo do grupo. A branch de moradores e o PR #7 nao foram alterados nem integrados automaticamente.

Para adotar esta proposta no modulo de moradores, o grupo precisara ajustar o contador para +4, nomes para +8, capacidade do nome para 48, garagem para +296 com 152 bytes e passo para 448. Os calculos de indice de nome tambem precisam trocar multiplicacao por 32 por multiplicacao por 48; nao basta mudar as constantes. O limite do nome seria 47 caracteres. A tabela deve ser unica, e o cadastro nao deve incluir uma segunda reserva global. As chamadas, a preservacao dos argumentos e o uso de delayed branching tambem precisam ser testados em conjunto.

Outra decisao de layout e possivel, mas todas as rotinas afetadas devem ser adaptadas e verificadas juntas. O acordo entre os integrantes nao pode ser substituido pela abertura deste PR.

## Validacao

`tests/comandosAp_teste.asm` inclui o interpretador e a tabela reais, substituindo apenas a saida por captura de texto. Verifica consulta com morador e carro, limpeza com residuos, listagem completa, limites de andar e lado, sintaxe, argumento extra, argumento vazio, texto numerico longo, sinal, zero inicial e consulta do ultimo AP. Compara texto integral, todos os registros, argumentos, oito salvos e pilha nos dois modos de delayed branching.

Uma verificacao local adicional executou `src/main.asm` inteiro atraves da API do MARS, com um dispositivo MMIO simulado que fornece teclas e ocupa o display por tres consultas de disponibilidade a cada caractere. Nove linhas sucessivas verificaram eco, consulta, limpeza, listagem, erros, backspace, CR/LF e linha longa; a saida completa e a tabela foram comparadas nos dois modos. Esse ensaio nao substitui a verificacao visual da janela grafica conectada.
