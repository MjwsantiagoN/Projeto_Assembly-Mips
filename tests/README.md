# Suíte de Testes Unitários do Projeto (MARS MIPS)

Este diretório contém os testes unitários automatizados para os módulos do sistema de gerenciamento de condomínio em Assembly MIPS.

---

## 1. Testes Disponíveis

### 1.1. Adição de Automóveis (`addAuto_teste.asm`)
Ambiente de testes unitários isolado para validar integralmente as rotinas do módulo [`src/automovel/addAuto.asm`](../src/automovel/addAuto.asm):
- `addAuto_validar_capacidade`: validação de regras de negócio, compatibilidade e capacidade da garagem (máximo 1 carro ou até 3 motos por apartamento).
- `addAuto_inserir` (e alias `addAuto_adicionar`): gravação de tipo, modelo e placa no próximo slot livre do apartamento, atualização do cabeçalho do AP e garantia de terminação nula.

### 1.2. Remoção de Automóveis (`rmvAuto_teste.asm`)
Ambiente de testes unitários isolado para validar integralmente as rotinas do módulo [`src/automovel/rmvAuto.asm`](../src/automovel/rmvAuto.asm):
- `rmvAuto_busca_placa`: rotina de localização de automóvel por placa dentro dos slots registrados do AP, com busca tolerante a maiúsculas/minúsculas (*case-insensitive*) e validações de limites.
- `rmvAuto_remover` (e alias `rmvAuto_excluir`): remoção do veículo localizado por placa, compactação do array de slots (deslocamento dos slots subsequentes à esquerda), limpeza ativa do último slot liberado (todos os 48 bytes zerados), decremento de `num_veiculos` e reset de `tipo_veiculo` para `0` quando o apartamento fica sem veículos.

Os testes alocam seus próprios buffers de apartamento em memória `.data` com sentinelas de segurança (*canary words* `0xDEADBEEF` e `0xCAFEBABE`), canários nos registradores `$s0-$s7` e não dependem do shell nem de chamadas com MMIO.

---

## 2. Como Executar no Simulador MARS

Os testes foram desenvolvidos com compatibilidade estrita para execução padrão e execução com **Delayed Branching (`-db`)** ativado (todos os desvios e saltos contêm salvaguarda de *delay slot* com `nop`).

### Execução via Linha de Comando (CLI)

Na raiz do repositório, com o Java instalado:

#### Teste de Remoção de Automóveis (`rmvAuto_teste.asm`):
- **Execução Padrão:**
  ```bash
  java -jar Mars4_5.jar nc sm ae1 se1 100000 tests/rmvAuto_teste.asm
  ```
- **Execução com Delayed Branching Habilitado:**
  ```bash
  java -jar Mars4_5.jar nc sm db ae1 se1 100000 tests/rmvAuto_teste.asm
  ```

#### Teste de Adição de Automóveis (`addAuto_teste.asm`):
- **Execução Padrão:**
  ```bash
  java -jar Mars4_5.jar nc sm ae1 se1 100000 tests/addAuto_teste.asm
  ```
- **Execução com Delayed Branching Habilitado:**
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
3. Abra o arquivo de teste desejado (`tests/rmvAuto_teste.asm` ou `tests/addAuto_teste.asm`) via **File -> Open**.
4. Monte o programa (**Run -> Assemble** ou tecla `F3`).
5. Execute (**Run -> Go** ou tecla `F5`).
6. Os resultados de cada asserção e o relatório final serão exibidos na aba **Run I/O**.

---

## 3. Cenários de Teste Cobertos para `rmvAuto_teste.asm`

| Cenário | Descrição | Comportamento Esperado |
| :---: | :--- | :--- |
| **1** | **Remoção do único carro do AP** | Sucesso (`$v0 = 0`), decremento de `num_veiculos` de 1 para 0, reset de `tipo_veiculo` para 0, limpeza completa do Slot 0 (12 words zeradas). Sentinelas e registradores salvos `$s0-$s7` intactos. |
| **2** | **Remoção de moto intermediária com compactação (M1, M2, M3)** | Sucesso (`$v0 = 0`). Remoção da moto M2 (Slot 1); translação da moto M3 do Slot 2 para o Slot 1; Slot 0 mantido intacto com M1; Slot 2 completamente zerado (12 words zeradas); `num_veiculos` atualizado para 2; `tipo_veiculo` mantido como `'m'`. |
| **3** | **Remoção da última moto** | Sucesso (`$v0 = 0`). Remoção da moto M3 (Slot 1); Slot 0 mantido intacto com M1; Slot 1 e Slot 2 completamente zerados; `num_veiculos` atualizado para 1; `tipo_veiculo` mantido como `'m'`. |
| **4** | **Remoção com busca case-insensitive** | Busca e remoção da placa `"abc1234"` (minúscula) em veículo cadastrado como `"ABC1234"` (maiúscula). Sucesso tanto em `rmvAuto_busca_placa` (`$v0 = 0`, `$v1 = +304`) quanto em `rmvAuto_remover` (`$v0 = 0`, `num_veiculos = 0`, `tipo_veiculo = 0`, slot zerado). Testes adicionais de prefixo e formato. |
| **5** | **Erro ao buscar placa inexistente no AP** | Retorno de erro (`$v0 = -1`, `$v1 = 0`) tanto em `rmvAuto_busca_placa` quanto em `rmvAuto_remover` ao pesquisar placa não cadastrada. O estado da memória do AP permanece estritamente inalterado (`num_veiculos` e dados dos slots intactos). |
| **6** | **Erro ao tentar remover em AP com 0 veículos** | Retorno de erro (`$v0 = -1`, `$v1 = 0`) para apartamento com `num_veiculos == 0`. Memória e sentinelas inalterados. |
| **7** | **Validação de limites de parâmetros (ponteiros nulos)** | Retorno de erro (`$v0 = -2`, `$v1 = 0`) para `$a0 == 0` (AP nulo) ou `$a1 == 0` (string de placa nula) em `rmvAuto_remover`, `rmvAuto_excluir` e `rmvAuto_busca_placa`. Sentinelas e memória do buffer intactos. |

---

## 4. Interpretação dos Resultados

- **Sucesso Global**:
  O teste finaliza imprimindo:
  ```text
  === INICIANDO SUITE DE TESTES UNITARIOS: rmvAuto ===
  [CENARIO 1] SUCESSO: Remocao do unico carro do AP (num: 1->0, tipo: 'c'->0, slot zerado)
  [CENARIO 2] SUCESSO: Remocao de moto do meio com compactacao (M1,M2,M3 -> M1,M3, num=2)
  [CENARIO 3] SUCESSO: Remocao da ultima moto (slot 1 mantido, slot 2 zerado, num=1)
  [CENARIO 4] SUCESSO: Remocao case-insensitive ('abc1234' vs 'ABC1234' -> remocao OK)
  [CENARIO 5] SUCESSO: Erro ao buscar placa inexistente no AP (codigo -1, memoria intacta)
  [CENARIO 6] SUCESSO: Erro ao tentar remover em AP com 0 veiculos (codigo -1)
  [CENARIO 7] SUCESSO: Validacao de ponteiros nulos (codigo -2, sentinelas intactos)

  PASS: rmvAuto_teste (todos os 7 cenarios aprovados com sucesso)
  ```
  e encerra com `syscall 17` e código `0`.

- **Falha**:
  Caso ocorra divergência em qualquer asserção, o teste imprime a mensagem específica do cenário correspondente (ex.: `FAIL: Falha detectada no Cenario X...`) e encerra com `syscall 17` e código `1`.
