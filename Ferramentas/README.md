# Ferramentas

Scripts e utilitarios de apoio (nao relacionados ao site/marketing do MrPress).

## Auditoria-Diagnostico-Windows.ps1

Script PowerShell somente leitura para diagnostico completo de um PC Windows
(hardware, memoria, disco/SSD, rede, drivers, servicos, seguranca basica,
logs de erro e programas instalados). Gera um relatorio `.txt` na area de
trabalho para analise posterior.

**Nao altera nada no sistema** — nao desinstala, nao apaga, nao mexe em
registro/servicos/drivers/rede/BIOS, nao finaliza processos e nao executa
comandos de reparo (SFC/DISM/CHKDSK).

### Como usar
1. Copie o arquivo `Auditoria-Diagnostico-Windows.ps1` para o PC Windows.
2. Clique com o botao direito > "Executar com PowerShell" (ou abra o
   PowerShell como Administrador e rode:
   `powershell -ExecutionPolicy Bypass -File .\Auditoria-Diagnostico-Windows.ps1`).
3. Aguarde a conclusao (3 a 10 minutos).
4. O relatorio `Auditoria_PC_<data_hora>.txt` sera salvo na area de trabalho.
