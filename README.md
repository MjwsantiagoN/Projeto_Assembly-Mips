# Projeto_Assembly-Mips

Programa em Assembly MIPS para cadastro e consulta de apartamentos, moradores e veiculos de um condominio. Tambem permite limpar registros, consultar informacoes gerais e salvar ou recarregar os dados em `condominio.dat`.

## Como executar

1. Abra um terminal na pasta raiz do projeto (`Projeto_Assembly-Mips`).
2. Inicie o MARS pelo terminal, informando o caminho do arquivo JAR instalado no seu computador:

	```powershell
	java -jar "C:\caminho\para\Mars4_5.jar"
	```

	Iniciar o MARS pelo terminal mantem a pasta do projeto como diretorio de trabalho. Isso e necessario para que `salvar` e `recarregar` encontrem `condominio.dat` nessa pasta.
3. No MARS, abra `src/main.asm` e deixe desmarcada a opcao `Settings > Assemble all files in directory`.
4. Monte o programa com F3.
5. Abra `Tools > Keyboard and Display MMIO Simulator` e clique em `Connect to MIPS`.
6. Execute com F5 e digite os comandos na area de teclado do simulador MMIO.

Exemplos: `infoAp --101`, `infoAp --all`, `limparAp --101`, `salvar` e `recarregar`.

O arquivo `condominio.dat` e criado na pasta de trabalho do MARS. Mantenha essa pasta com permissao de escrita para salvar os dados.

## Testes

Os testes isolados e suas instrucoes estao em [tests/README.md](tests/README.md).
