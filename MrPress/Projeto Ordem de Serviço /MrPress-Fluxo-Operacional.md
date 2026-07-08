# Fluxo Operacional Mr.Press

**Versão:** 2.0  
**Status:** Validado (documentos de apoio anexados)  
**Data:** Junho 2026

**Documentos de apoio:**
- `TABELA_PRECOS.md` : preços de tabela, prazos e condições comerciais
- `LISTA_VIP.md` : clientes dispensados do sinal de 50%
- `FORNECEDORES.md` : fornecedores externos e ordem de prioridade
- `ENTREGA.md` : modais de entrega e regras de frete
- `POS_VENDA.md` : pós-venda ativo (3 gatilhos)

---

## 1\. Entradas

O atendimento pode originar por quatro canais:

- **WhatsApp** \- mensagens diretas ao número da loja  
- **E-mail** \- pedidos e solicitações via e-mail  
- **Direto** \- Cintia, Marcelo ou contato por telefone  
- **Balcão** \- cliente presencial na loja  
  - Trabalho rápido (boleto, plastificação, bureau de impressão): controle via PDV, sem OS  
  - Trabalho com entrega: segue o fluxo normal com geração de OS

---

## 2\. Triagem

Ao receber a demanda, verifica-se se é necessário orçamento:

- **Não precisa de orçamento:** serviço com preço de tabela (ver `TABELA_PRECOS.md`). Segue direto para criação da OS.  
- **Precisa de orçamento:** encaminha para a Cintia.

---

## 3\. Orçamento (Cintia)

- Cintia elabora e envia o orçamento ao cliente.  
- **Orçamento reprovado:** processo encerrado.  
- **Orçamento aprovado:** solicitar sinal de 50% antes de iniciar o serviço.  
  - Exceção: clientes da lista VIP, sem sinal obrigatório (ver `LISTA_VIP.md`).
  - Formas de pagamento e validade do orçamento: ver `TABELA_PRECOS.md`.

---

## 4\. Ordem de Serviço (OS)

Gerada após aprovação do orçamento e confirmação do sinal.

A OS deve conter:

- Dados do cliente  
- Descrição do serviço  
- Tipo de produção (local ou fornecedor externo)  
- Prazo de entrega  
- Forma de retirada / entrega

---

## 5\. Verificação de Arquivo

Etapa obrigatória antes de qualquer produção.

- **Arquivo correto:** segue para produção.  
- **Ajuste pequeno:**  
  - Mr.Press resolve internamente.  
  - Sem custo adicional.  
  - Não é necessário informar o cliente.  
- **Ajuste grande:**  
  - Cliente é informado.  
  - Define-se se haverá custo adicional ou não.  
  - Aguarda aprovação/reenvio antes de prosseguir.

---

## 6\. Produção

Dois tipos de produção:

### 6.1 Impressão local

- Realizada na própria loja.

### 6.2 Fornecedores externos

Produção terceirizada conforme a especialidade e a ordem de prioridade definidas em `FORNECEDORES.md`. Resumo por tipo de serviço:

| Tipo de serviço | 1ª opção |
| :---- | :---- |
| Adesivos | Imprime Sim |
| Lonas e banners | Grupo Selva |
| Placas e corte laser/router | Grupo Selva |
| Impressos gráficos gerais | Atual Card |
| Offset especial | Carlos |

Ordem completa de 2ª, 3ª e 4ª opções, especialidades, prazo e contato: ver `FORNECEDORES.md`.

---

## 7\. Acabamento

Após a produção, verifica-se a necessidade de acabamento:

- **Necessário:** trabalho vai para o setor de acabamento. Após finalizar, avisa o cliente.  
- **Não necessário:** avisa o cliente diretamente.

---

## 8\. Logística

Detalhes completos dos modais e regras de frete em `ENTREGA.md`. Resumo:

- **Retirada na loja (80%):**  
    
  - Produto armazenado no depósito, organizado de A a Z.  
  - Cliente retira no balcão.


- **Motoboy parceiro (18%):** pega na loja e entrega porta a porta.

- **Transportadora (2%):** envio por Melhor Envio ou Correios.

---

## 9\. Pós-venda

Após o cliente receber o produto, roda o pós-venda ativo (3 gatilhos), detalhado em `POS_VENDA.md`:

1. **Confirmação de recebimento + agradecimento** \- no dia da entrega.  
2. **Pesquisa de satisfação** \- 1 a 2 dias depois, nota de 0 a 10.  
3. **Recompra e indicação** \- avaliação no Google e lembrete por ciclo de produto.

---

## Pendências para próxima revisão

As 5 pendências originais do fluxo foram resolvidas e documentadas nos arquivos de apoio. Restam apenas detalhes operacionais, registrados dentro de cada documento:

- [ ] Prazo e contato dos fornecedores (`FORNECEDORES.md`)
- [ ] Confirmar se o M-Press foi substituído pela Imprime Sim (`FORNECEDORES.md`)
- [ ] Critério objetivo para absorver x cobrar frete (`ENTREGA.md`)
- [ ] Link de avaliação do Google e ciclos de recompra (`POS_VENDA.md`)
- [ ] Automação dos gatilhos de pós-venda no WhatsApp (`POS_VENDA.md`)

