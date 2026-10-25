# Suíte de Testes Unitários do Projeto (MARS MIPS)

Este diretório contém os testes unitários automatizados para os módulos do sistema de gerenciamento de condomínio em Assembly MIPS.

---

## 1. Teste de Adição de Automóveis (`addAuto_teste.asm`)

O arquivo [`addAuto_teste.asm`](addAuto_teste.asm) é um ambiente de testes unitários isolado e automatizado para validar integralmente as rotinas do módulo [`src/automovel/addAuto.asm`](../src/automovel/addAuto.asm):
- `addAuto_validar_capacidade`: validação de regras de negócio, compatibilidade e capacidade da garagem.
- `addAuto_inserir` (e alias `addAuto_adicionar`): gravação de tipo, modelo e placa no próximo slot livre do apartamento, atualização do cabeçalho do AP e garantia de terminação nula.

O teste aloca seus próprios buffers de apartamento em memória `.data` com sentinelas de segurança (*canary words*), não dependendo do shell nem de chamadas com MMIO.

---

## 2. Como Executar no Simulador MARS

Os testes foram desenvolvidos com compatibilidade estrita para execução padrão e execução com **Delayed Branching (`-db`)** ativado (todos os desvios e saltos contêm salvaguarda de *delay slot*).

### Execução via Linha de Comando (CLI)

Na raiz do repositório, com o Java instalado:

#### Execução Padrão:
```bash
java -jar Mars4_5.jar nc sm ae1 se1 100000 tests/addAuto_teste.asm
```

#### Execução com Delayed Branching Habilitado:
```bash
java -jar Mars4_5.jar nc sm db ae1 se1 100000 tests/addAuto_teste.asm
```

#### Parâmetros Utilizados:
- `nc`: suprime avisos de copyright do simulador MARS.
- `sm`: inicia a execução diretamente no rótulo `main`.
- `db`: ativa a emulação de *Delayed Branching* da arquitetura MIPS (executa instrução no slot de atraso).
- `ae1`: encerra o simulador com código de erro 1 em caso de exceção na montagem/execução.
- `se1`: direciona mensagens do MARS para o fluxo de erro padrão (stderr).
- `100000`: limite máximo de instruções executadas (evita laços infinitos em caso de regressão).

Ambas as execuções devem imprimir a confirmação de aprovação dos 7 cenários e retornar **código de saída 0**.

### Execução via Interface Gráfica (GUI) do MARS

1. Abra o simulador MARS:
   ```bash
   java -jar Mars4_5.jar
   ```
2. No menu **Settings**, certifique-se de que a opção **"Assemble all files in directory"** esteja **desmarcada**.
3. Abra exclusivamente o arquivo `tests/addAuto_teste.asm` (**File -> Open**).
4. Monte o programa (**Run -> Assemble** ou tecla `F3`).
5. Execute (**Run -> Go** ou tecla `F5`).
6. Os resultados de cada asserção e o relatório final serão exibidos na aba **Run I/O**.

---

## 3. Cenários de Teste Cobertos

| Cenário | Descrição | Comportamento Esperado |
| :---: | :--- | :--- |
| **1** | **Adição de 1 carro em AP vazio** | Sucesso (`$v0 = 0`), slot alocado em `AP + 304`, `num_veiculos = 1`, `tipo_veiculo = 'c'`. Modelo e placa copiados corretamente. Verificação estrita de preservação dos registradores salvos `$s0-$s7` e argumentos `$a0-$a1`. |
| **2** | **Rejeição de 2º carro em AP com carro** | Erro de capacidade esgotada (`$v0 = -2`, `$v1 = 0`) tanto em `addAuto_validar_capacidade` quanto em `addAuto_inserir`. Estado do AP inalterado. |
| **3** | **Rejeição de moto em AP com carro** | Erro de mútua exclusão (`$v0 = -2`, `$v1 = 0`) tanto com `'m'` quanto `'M'`. Estado do AP permanece com 1 carro e tipo `'c'`. |
| **4** | **Adição de 3 motos consecutivas em AP vazio** | Sucesso nas 3 inserções (`$v0 = 0`), preenchendo os slots `+304`, `+352` e `+400`. Normalização de `'M'` maiúsculo para `'m'`. Ao final, `num_veiculos = 3` e `tipo_veiculo = 'm'`. |
| **5** | **Rejeição de 4ª moto e mútua exclusão em AP com motos** | Erro de limite regulamentar (`$v0 = -2`, `$v1 = 0`) para 4ª moto e erro de incompatibilidade/mútua exclusão ao tentar adicionar carro em AP com motos. Quantidade de veículos permanece fixada em 3. |
| **6** | **Rejeição de tipos inválidos e AP corrompido** | Erro de parâmetro inválido (`$v0 = -1`, `$v1 = 0`) para tipo `'x'`, tipo numérico `0` (validado em `addAuto_validar_capacidade` e `addAuto_inserir`), ponteiro de AP nulo (`$a0 = 0`) e registro com `num_veiculos < 0`. |
| **7** | **Integridade de memória, offsets, truncamento e limpeza ativa** | Verificação dos offsets dos 3 slots (`+304`, `+352`, `+400`); garantia de limpeza ativa de todo o slot (12 words zeradas) sobre memória suja pré-preenchida (`0xAAAAAAAA`) com ponteiros nulos via alias `addAuto_adicionar`; teste de truncamento seguro sobre memória suja (`0xFFFFFFFF`) com verificação dos prefixos exatos de 31 chars (modelo) e 11 chars (placa) e terminação `\0`; inviolabilidade dos sentinelas de borda (`0xDEADBEEF` e `0xCAFEBABE`). |

---

## 4. Interpretação dos Resultados

- **Sucesso Global**:
  O teste finaliza imprimindo:
  ```text
  [CENARIO 1] SUCESSO: Adicao de 1 carro em AP vazio (num=1, tipo='c', slot=+304)
  [CENARIO 2] SUCESSO: Rejeicao de 2o carro em AP com carro (codigo -2)
  [CENARIO 3] SUCESSO: Rejeicao de moto em AP com carro (codigo -2)
  [CENARIO 4] SUCESSO: Adicao de 3 motos em AP vazio (num=3, tipo='m', slots=+304, +352, +400)
  [CENARIO 5] SUCESSO: Rejeicao de 4a moto em AP com 3 motos (codigo -2)
  [CENARIO 6] SUCESSO: Rejeicao de tipos invalidos ('x', 0, AP nulo/invalido) com codigo -1
  [CENARIO 7] SUCESSO: Integridade de memoria, offsets e terminadores nulos verificados

  PASS: addAuto_teste (todos os 7 cenarios aprovados com sucesso)
  ```
  e encerra com `syscall 17` e código `0`.

- **Falha**:
  Caso ocorra divergência em qualquer asserção, o teste imprime a mensagem específica do cenário correspondente (ex.: `FAIL: Falha detectada no Cenario X...`) e encerra com `syscall 17` e código `1`.
