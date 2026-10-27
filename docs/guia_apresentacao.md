# Guia de apresentação das rotinas de apartamentos

Este guia explica a limpeza e a consulta individual de apartamentos para quem está começando em Assembly MIPS. O objetivo é acompanhar os endereços, os contadores e as chamadas de função, conseguindo explicar o que muda na memória e o que permanece intacto.

A lógica foi testada isoladamente no MARS. O formato dos moradores ainda é uma proposta para revisão do grupo, e o interpretador do shell ainda precisa chamar essas rotinas. Não apresente a demonstração isolada como se o sistema completo já estivesse integrado.

## Uma explicação inicial de trinta segundos

> Minha parte é limpar e consultar apartamentos. Cada apartamento ocupa um registro na memória. Primeiro procuro o número informado na tabela. Na limpeza, preservo a identificação e zero os campos de moradores e veículos. Na consulta, apenas leio os dados e os envio ao display. Os testes verificam que os outros apartamentos não foram alterados.

Na versão atual, `infoAp --all` ainda fica para a próxima etapa. A consulta deste guia mostra um apartamento por chamada.

## Quais arquivos explicar

| Arquivo | Papel |
| --- | --- |
| `src/apartamento/limparAp.asm` | Limpeza de bytes, da garagem e do registro encontrado |
| `src/apartamento/infoAp.asm` | Busca e exibição de um apartamento |
| `src/Auxiliares/saidaApMMIO.asm` | Envio de caracteres ao Display MMIO |
| `tests/` | Programas separados que criam dados fictícios e verificam os resultados |
| `docs/contrato_apartamentos.md` | Descrição do layout proposto e das interfaces |

Os testes são maiores porque precisam preparar dados, guardar cópias e conferir diferentes situações. Eles não são executados como parte do caminho normal do shell. Mesmo assim, saiba explicar como identificam um resultado incorreto.

## Endereço, valor e tamanho

Um endereço indica onde um dado está guardado. O valor é o conteúdo dessa posição.

Um byte ocupa uma posição de memória. Uma word ocupa quatro bytes. Os contadores e o número do AP usam words; os caracteres dos nomes usam bytes.

Se a base do AP for 1000, o contador de veículos está no endereço 1296, porque seu deslocamento é 296. O código não fixa a base em 1000: esse número serve apenas para entender a soma.

| Deslocamento a partir da base | Conteúdo | Origem |
| --- | --- | --- |
| 0 a 3 | Número do AP | Proposta da nossa parte |
| 4 a 7 | Quantidade de moradores | Proposta da nossa parte |
| 8 a 295 | Área dos seis nomes | Proposta da nossa parte |
| 296 a 299 | Quantidade de veículos | Layout publicado por Brenno |
| 300 a 303 | Tipo geral de veículo | Layout publicado por Brenno |
| 304 a 447 | Três espaços de 48 bytes para veículos | Layout publicado por Brenno |
| A partir de 448 | Reserva ou outros campos | Preservados pela limpeza |

Para consultar, propomos nomes em espaços de 48 bytes: até 47 caracteres e um byte zero para indicar o fim. Os primeiros `num_moradores` nomes são os ativos. Isso ainda precisa ser combinado com o módulo de cadastro.

O enunciado tem uma divergência entre duas e três motos. Nosso layout segue os três espaços publicados por Brenno; o limite final deve ser confirmado com o professor pelo grupo.

## Registradores que aparecem nas funções

| Registrador | Como entender neste código |
| --- | --- |
| `$zero` | Sempre fornece o valor zero |
| `$a0`, `$a1`, `$a2` | Levam os parâmetros da chamada |
| `$v0`, `$v1` | Levam o resultado de volta ao chamador |
| `$t0`, `$t1` e outros `$t` | Guardam valores temporários; uma função chamada pode alterá-los |
| `$s0`, `$s1`, `$s2` | Mantêm valores necessários durante chamadas; a função devolve seus valores anteriores |
| `$ra` | Guarda o endereço para onde retornar depois de uma chamada |
| `$sp` | Aponta para o espaço de pilha usado para guardar dados temporariamente |

Os registradores de argumentos são normalmente temporários em uma chamada MIPS. Nosso contrato escolhe devolver os valores de entrada; por isso algumas funções também guardam os argumentos que precisam modificar.

## Instruções essenciais

| Instrução | Explicação e exemplo |
| --- | --- |
| `li $t1, 24` | Coloca o número 24 em um registrador |
| `la $a0, texto` | Coloca o endereço do texto no registrador, não seus caracteres |
| `move $s0, $a0` | Copia um valor entre registradores |
| `lw $t0, 0($s0)` | Lê uma word no endereço apontado por `$s0` |
| `lbu $t2, 0($t0)` | Lê um byte, útil para um caractere |
| `sw $ra, 28($sp)` | Guarda uma word na memória, aqui na pilha |
| `sb $zero, 0($t0)` | Grava zero em apenas um byte |
| `addiu $t0, $t0, 1` | Soma uma constante ao endereço ou contador |
| `addiu $t1, $t1, -1` | Diminui o contador em um; o nome da instrução não proíbe constantes negativas |
| `addu $s0, $s0, $a2` | Soma dois registradores, aqui para avançar um registro |
| `beq` | Desvia quando dois valores são iguais |
| `bne` | Desvia quando dois valores são diferentes |
| `bltz` / `blez` | Desvia se o valor for negativo / menor ou igual a zero |
| `j` | Salta para outro trecho sem criar uma chamada de função |
| `jal` | Chama uma função e guarda em `$ra` para onde voltar |
| `jr $ra` | Retorna para o endereço guardado em `$ra` |
| `nop` | Não realiza trabalho; deixa seguro o atraso após o salto |

`addiu` e `addu` não verificam estouro aritmético. O chamador deve fornecer endereços e tamanhos válidos. `li`, `la` e `move` são formas convenientes aceitas pelo montador do MARS; não precisam representar uma única instrução básica em todos os casos.

## Explicar a auxiliar que zera bytes

Função: `limparAp_zerarRegiao`.

1. Recebe o endereço em `$a0` e a quantidade em `$a1`.
2. Rejeita tamanho negativo e endereço nulo com tamanho positivo.
3. Copia o endereço para `$t0` e o tamanho para `$t1`.
4. Grava zero, avança um byte e diminui o contador.
5. Repete até o contador chegar a zero.

Exemplo com endereço fictício 1000 e tamanho 4:

| Repetição | Endereço limpo | Contador depois da limpeza |
| --- | --- | --- |
| 1 | 1000 | 3 |
| 2 | 1001 | 2 |
| 3 | 1002 | 1 |
| 4 | 1003 | 0 |

O endereço 1004 não é limpo. Esse limite é um dos pontos conferidos pelos testes.

Frase para explicar o laço: “O endereço mostra onde escrever agora; o contador mostra quantos bytes ainda faltam.”

## Explicar a limpeza da garagem

Função: `limparAp_limparVeiculos`.

Ela recebe a base do apartamento e chama a auxiliar anterior com:

```asm
addiu $a0, $a0, LIMPAR_AP_GARAGEM_INICIO # Base do AP mais 296.
li    $a1, LIMPAR_AP_GARAGEM_BYTES      # Limpeza de 152 bytes.
jal   limparAp_zerarRegiao             # Executa a limpeza byte a byte.
nop                                  # Não faz trabalho no atraso da chamada.
```

São 152 bytes porque há duas words de cabeçalho, totalizando 8 bytes, mais três espaços de 48 bytes: `8 + 3 × 48 = 152`.

Ela zera tudo, inclusive resíduos em espaços que não estejam contados. Não procura placa nem remove apenas um veículo: essa função é usada para esvaziar a garagem inteira.

## Explicar a limpeza do apartamento por número

Função: `limparAp_executar`.

Entrada: tabela em `$a0`, número solicitado em `$a1` e passo entre registros em `$a2`.

O fluxo é:

```text
Validar parâmetros
        ↓
Procurar o número em até 24 registros
        ↓
Encontrou? ── não → retornar erro sem limpar
        ↓ sim
Limpar contador e área dos moradores
        ↓
Limpar a garagem
        ↓
Retornar sucesso e endereço do AP
```

Na busca, `$s0` aponta para o registro atual, `$t0` recebe seu identificador e `$t1` conta quantos registros ainda faltam. Não há chamada de função durante a busca; por isso o contador pode ficar em um temporário.

Depois de encontrar o AP, somente `$s0` precisa manter o endereço durante as chamadas de limpeza. Os outros registradores salvos não precisam ser usados.

Não limpamos os primeiros quatro bytes porque eles guardam a identificação. Limpamos os moradores de +4 a +295 e a garagem de +296 a +447. O contador de moradores passa a zero, que neste contrato significa apartamento vazio.

O passo não é obrigatoriamente 512: os testes usam 448 e 512 para verificar que a função respeita o valor informado.

## Entender a pilha sem decorar os números

Se uma função usa `jal`, a chamada muda `$ra`. Por isso guardamos o retorno anterior quando a função ainda precisará voltar ao seu próprio chamador.

Na limpeza completa, reservamos 32 bytes:

| Posição relativa a `$sp` | Uso |
| --- | --- |
| 0 a 15 | Área reservada para argumentos das chamadas auxiliares |
| 16 | Valor original de `$a1` |
| 20 | Valor original de `$a0` |
| 24 | Valor anterior de `$s0` |
| 28 | Endereço de retorno `$ra` |

`addiu $sp, $sp, -32` reserva esse espaço. No final, `addiu $sp, $sp, 32` o libera. O importante é guardar e recuperar nas mesmas posições e devolver exatamente o espaço reservado.

## Explicar a consulta individual

Função: `infoAp_executar`.

Ela também recebe tabela, número do AP e passo. Primeiro procura e valida o registro; depois imprime:

```text
AP: 1102
Moradores:
Morador Teste
Morador Teste
Carro:
Modelo Teste / ABC1234
```

Se não há moradores, mostra apenas o número do AP e `Apartamento vazio`. Se há moradores, mas nenhum veículo, não cria os títulos `Carro` ou `Moto`.

Os três registradores salvos têm papéis fixos durante a listagem:

| Registrador | Papel |
| --- | --- |
| `$s0` | Endereço do apartamento encontrado |
| `$s1` | Quantos moradores ou veículos ainda faltam mostrar |
| `$s2` | Endereço do nome ou slot de veículo atual |

Cada nome avança 48 bytes. Cada slot de veículo também avança 48 bytes. Dentro do slot, o modelo começa em +4 e a placa em +36.

A impressão agora é uma chamada direta:

```asm
move $a0, $s2           # Endereço do nome atual.
li   $a1, 47            # Máximo de caracteres úteis do campo.
jal  ap_imprimirTexto   # Função de impressão conhecida pelo nome.
nop                    # Atraso de chamada sem trabalho adicional.
```

Não existe mais uma função de impressão passada por endereço em `$a3`. A consulta também não precisa copiar cada nome para um buffer temporário.

## Por que converter o número para texto

O display recebe caracteres, não o inteiro 1102 diretamente como quatro dígitos. A auxiliar `infoAp_imprimirNumero` divide por dez para separar os dígitos:

| Número antes da divisão | Quociente | Resto |
| --- | --- | --- |
| 1102 | 110 | 2 |
| 110 | 11 | 0 |
| 11 | 1 | 1 |
| 1 | 0 | 1 |

Os restos aparecem na ordem 2, 0, 1, 1. Por isso são guardados de trás para frente no buffer, formando `1102`.

`mflo` lê o quociente e `mfhi` lê o resto. Somar 48 ao resto transforma o número 2 no caractere ASCII `2`, por exemplo. O byte zero termina a string. O buffer fica na pilha e não modifica o registro do AP.

## Como funciona o MMIO

MMIO significa que acessamos o dispositivo por endereços de memória. Em `ap_imprimirTexto`:

1. Ler um caractere do texto.
2. Se for zero, o texto terminou.
3. Ler o controle do display em `0xFFFF0008`.
4. Usar `andi ..., 1` para verificar o bit de disponibilidade.
5. Quando estiver livre, gravar o caractere em `0xFFFF000C`.
6. Avançar para o caractere seguinte, respeitando o limite pedido.

Essa espera repetida é chamada polling. A rotina de saída não lê teclado e não interpreta comandos.

O limite zero é usado para mensagens fixas terminadas em zero. Para campos de tamanho conhecido usamos 47 para nomes, 31 para modelos e 11 para placas. Isso evita ler o campo seguinte se o texto estiver sem terminador.

## Como demonstrar no MARS

Abra um teste por vez. Deixe `Settings → Assemble all files in directory` desmarcado, pois cada teste possui seu próprio `main`. Monte e execute.

Uma sequência curta de apresentação:

1. Rodar `tests/limparAp_zerarRegiao_teste.asm` para mostrar a auxiliar básica.
2. Rodar `tests/limparAp_executar_teste.asm` e mostrar ANTES e DEPOIS do AP com moradores e carro.
3. Rodar `tests/infoAp_executar_teste.asm` e mostrar as consultas de AP vazio, com carro e com motos.
4. Explicar que o resultado PASS só aparece depois das verificações.

O teste de consulta inclui uma função chamada `ap_imprimirTexto` que guarda texto em um buffer para compará-lo com a saída esperada. O programa real usa a implementação de `saidaApMMIO.asm`. São programas montados separadamente, sem duas definições da função no mesmo programa.

`saidaApMMIO_teste.asm` usa disponibilidade simulada no controle do display e confere o último caractere enviado, o limite e o caso de texto vazio. Ele não captura a sequência inteira de caracteres nem comprova a janela gráfica conectada ao shell real. Para a integração real, o futuro `main` deve incluir a consulta e a saída MMIO e conectar o simulador do dispositivo.

## Perguntas para praticar antes da apresentação

**Por que usar `sb` para limpar?** Porque a auxiliar trabalha byte a byte e recebe um tamanho em bytes. Gravar zero em todos os bytes também deixa os contadores word com valor zero.

**Por que não limpar o apartamento inteiro de uma vez?** Porque a identificação precisa permanecer, e campos opcionais depois da garagem não pertencem à região de limpeza definida.

**Como sei que não apaguei o AP vizinho?** Os testes comparam toda a tabela com uma referência e verificam os limites de memória. Só a região autorizada do AP escolhido pode mudar.

**Qual a diferença entre `$t` e `$s` aqui?** Temporários podem mudar durante uma chamada. Os valores em registradores salvos usados pela nossa função são guardados e devolvidos ao chamador. Usamos `$s0` para manter o AP durante as chamadas de limpeza.

**Por que salvar `$ra`?** Porque uma chamada `jal` grava um novo endereço de retorno nesse registrador. Precisamos recuperar o retorno da função que nos chamou.

**Por que há tantos `nop`?** Para que uma instrução de trabalho não seja executada acidentalmente após um salto quando o atraso estiver ligado. Os testes verificam os dois modos do MARS.

**A consulta altera os cadastros?** Não. Ela lê a tabela e imprime. Só usa buffers de saída ou pilha para valores temporários. Os testes verificam que todos os bytes da tabela permanecem iguais.

**O layout dos moradores já é o oficial do grupo?** Não. É uma proposta documentada. A parte da garagem mantém os offsets publicados por Brenno; a integração dos moradores precisa de acordo.

**O comando digitado já funciona no shell?** As funções isoladas estão testadas. O shell ainda precisa reconhecer os comandos, converter o número e passar a tabela e o passo para nossas funções.

## Roteiro de estudo

Comece pela auxiliar de bytes e faça a tabela de quatro repetições à mão. Depois acompanhe a busca de um AP e explique por que o endereço avança pelo passo. Em seguida, desenhe os quatro valores guardados na pilha da limpeza completa. Por fim, acompanhe uma consulta com um morador e um veículo.

Pratique usando o código aberto, sem tentar decorar uma fala inteira. Se conseguir explicar o endereço atual, o contador e o destino de cada chamada, terá entendido o núcleo dessas rotinas.
