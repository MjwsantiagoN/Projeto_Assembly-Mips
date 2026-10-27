# Roteiro curto para estudar sua parte

Leia primeiro este roteiro e depois abra o codigo ao lado. O guia completo esta em `docs/guia_apresentacao.md`. O objetivo e conseguir seguir cada valor, sem depender de decorar uma fala.

## O que voce implementa

- `limparAp --101`: encontra o AP 101, apaga moradores e veiculos e preserva o numero.
- `infoAp --101`: encontra e mostra o AP 101, sem alterar os cadastros.
- `infoAp --all`: mostra os 24 APs em ordem, inclusive os vazios.

Ha uma integracao desses comandos com MMIO para demonstrar a entrada de texto. O sistema inteiro do grupo ainda depende dos cadastros, administracao, persistencia e acordo sobre o layout.

## Primeiros cinco minutos: memoria e registradores

Pense no registro como uma sequencia de caixas numeradas. A base e o endereco da primeira caixa. Um deslocamento indica quantos bytes avancar.

| Posicao no AP | Conteudo |
| --- | --- |
| +0 | Numero do AP, preservado na limpeza |
| +4 | Quantidade de moradores; zero significa vazio |
| +8 | Inicio dos nomes |
| +296 | Quantidade de veiculos |
| +300 | Tipo da garagem |
| +304 | Inicio dos slots de veiculos |

Uma word ocupa quatro bytes; um caractere ocupa um byte. `$a0` e outros `$a` recebem argumentos. `$v0` devolve o resultado. `$t` guarda temporarios; `$s` mantem valores entre chamadas e precisa ser devolvido ao chamador com o valor anterior. `$ra` guarda o retorno e `$sp` aponta para a pilha.

Exercicio: se a base for 1000, em qual endereco fica o contador da garagem? Resposta: 1296. Qual instrucao le esse contador? `lw $t0, 296($s0)`, se `$s0` contiver a base.

## Mais cinco minutos: limpeza

Abra `src/apartamento/limparAp.asm` e comece por `limparAp_zerarRegiao`.

O laco faz quatro coisas: grava zero, avanca o endereco, diminui o contador e verifica se ainda falta algum byte.

```asm
sb    $zero, 0($t0)                # Zera um byte.
addiu $t0, $t0, 1                  # Avanca uma posicao.
addiu $t1, $t1, -1                 # Falta um byte a menos.
bne   $t1, $zero, limparAp_zerarLoop # Repete enquanto faltar.
nop                                # Deixa seguro o atraso do desvio.
```

Exercicio: partindo do endereco 1000 com tamanho 3, quais bytes sao zerados? Resposta: 1000, 1001 e 1002. O byte 1003 permanece intacto.

Depois leia `limparAp_executar`. Ele procura o numero nos 24 registros. Ao encontrar, limpa +4 a +295 e depois chama a limpeza da garagem, de +296 a +447. O ID em +0 a +3 permanece.

Por que salva `$ra`? Porque cada `jal` grava outro endereco de retorno nesse registrador. Por que salva `$s0`? Porque o chamador pode estar usando esse registrador e precisa recebe-lo de volta com o valor anterior.

## Mais cinco minutos: consulta

Abra `src/apartamento/infoAp.asm`. A busca e parecida com a limpeza, mas depois apenas le e imprime.

- `$s0` aponta para o AP encontrado.
- `$s1` conta nomes ou veiculos ainda nao mostrados.
- `$s2` aponta para o campo atual.

Cada nome ocupa 48 bytes. Depois de mostrar um, soma 48 para encontrar o proximo. Um slot de veiculo tambem ocupa 48 bytes; dentro dele, modelo comeca em +4 e placa em +36.

Se a quantidade de moradores for zero, mostra `Apartamento vazio`. Se nao houver veiculo, nao mostra o titulo da garagem. A rotina limita os textos para nao ler o campo seguinte.

O numero do AP precisa virar caracteres. Dividir 101 por 10 produz quociente 10 e resto 1; depois 10 produz 1 e 0; depois 1 produz 0 e 1. Os restos sao guardados de tras para frente. Somar 48 transforma cada digito no caractere ASCII correspondente.

## Mais cinco minutos: todos os APs e MMIO

Abra `src/apartamento/infoApTodos.asm`. Ele chama a consulta individual 24 vezes. Comeca em 101; soma 1 para ir a 102; soma 99 para ir a 201. Repete ate 1202. Nao ordena nem modifica os registros: pede os IDs na ordem desejada.

MMIO usa enderecos especiais para conversar com o dispositivo. A impressao espera o bit de disponibilidade em `0xFFFF0008` e escreve o caractere em `0xFFFF000C`. A leitura espera o teclado em `0xFFFF0000` e le o caractere em `0xFFFF0004`.

`main.asm` mostra o banner, le ate Enter, chama `ap_executarLinha` e repete. O interpretador identifica o comando, valida o AP e chama as funcoes que voce acabou de estudar.

## Demonstracao curta

1. No MARS, desmarque `Assemble all files in directory`.
2. Rode `tests/limparAp_zerarRegiao_teste.asm`: explique o laco de bytes.
3. Rode `tests/limparAp_executar_teste.asm`: mostre ANTES e DEPOIS e diga o que foi preservado.
4. Rode `tests/infoAp_executar_teste.asm`: mostre os exemplos vazio, com carro e com motos.
5. Rode `tests/infoApTodos_teste.asm` e `tests/comandosAp_teste.asm`: explique o que o PASS verifica.
6. Para MMIO, abra `src/main.asm`, monte, conecte o simulador do dispositivo e execute. Digite `infoAp --101` e `infoAp --all`. A tabela real comeca vazia; os dados ficticios existem apenas nos testes.

## Confira se entendeu

Tente responder sem ler as respostas anteriores:

- Qual a diferenca entre o endereco de um campo e o valor guardado nele?
- Por que nao podemos zerar a primeira word do AP?
- Como o contador impede o laco de apagar o AP vizinho?
- Por que usar `$s0` para guardar o AP entre chamadas?
- Qual a diferenca entre `j`, `jal` e `jr $ra`?
- Como `infoAp --all` consegue mostrar em ordem sem ordenar a memoria?
- O layout dos moradores ja foi combinado? Ainda precisa de acordo; veja `docs/integracao_apartamentos.md`.

Se alguma resposta travar, acompanhe o valor em um exemplo pequeno no MARS. Entender uma repeticao por vez ajuda mais do que decorar nomes de instrucoes.
