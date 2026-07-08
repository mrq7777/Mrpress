# Modelo de Ordem de Serviço Mr.Press

**Uso:** Estrutura da OS no sistema (NocoDB). Reflete os campos e a ordem reais.
**Regra:** campos não informados ficam vazios. Não inventar dados.

---

## Campos da OS (na ordem do sistema)

| # | Campo | Tipo | Observação |
| :-- | :--- | :--- | :--- |
| 1 | Data de abertura | Auto | Preenchida sozinha na criação |
| 2 | Número OS | Auto | Sequencial: OS-1, OS-2... |
| 3 | Cliente | Texto | Título do card no quadro |
| 4 | Celular / Telefone (WhatsApp) | Telefone | |
| 5 | E-mail | E-mail | |
| 6 | VIP | Sim/Não | Se sim, sinal dispensado |
| 7 | Produto | Texto | |
| 8 | Quantidade | Número | |
| 9 | Especificações | Texto longo | Tamanho, gramatura, frente/verso, acabamento |
| 10 | Aguardando arquivo | Checkbox | Default desmarcado (95% abrem com arquivo pronto) |
| 11 | Produção | Lista | Local / Terceirizada |
| 12 | Fornecedor | Lista | Imprime Sim, Grupo Selva, Atual Card, Padrão Color, Print, M2, Rafael, Carlos, Chico |
| 13 | Prazo | Lista | Normal / Urgente |
| 14 | Data de entrega | Data | |
| 15 | Entrega | Lista | Retirada na loja / Motoboy / Transportadora |
| 16 | Responsável | Lista | Definido pela Cintia (arrastando no quadro), não no formulário |
| 17 | Status | Lista | A fazer (padrão), Em produção, Com fornecedor, Acabamento, Pronta, Entregue, Finalizada |
| 18 | Valor total | R$ | Local: tabela. Terceirizado: informado |
| 19 | Sinal | R$ | |
| 20 | Data pagamento do sinal | Data | |
| 21 | Forma de pagamento do sinal | Lista | Cartão, Depósito, Boleto, PIX, Link de pagamento, Pendente, Dispensado |
| 22 | Saldo | R$ (auto) | Calculado: Valor total − Sinal |
| 23 | Data pagamento do saldo | Data | |
| 24 | Forma de pagamento do saldo | Lista | Cartão, Depósito, Boleto, PIX, Link de pagamento, Pendente, Dispensado |
| 25 | Observações | Texto longo | |

---

## Notas

- **Número OS, Data de abertura e Saldo** são automáticos: não aparecem no formulário de criação, o sistema preenche.
- **Responsável** fica fora do formulário de abertura. Toda OS nova entra na coluna **Novas OS** do quadro; a Cintia arrasta para o funcionário.
- Produção local segue a `TABELA_PRECOS.md`; terceirizada é valor informado caso a caso.
- VIP (ver `LISTA_VIP.md`): sinal dispensado.
