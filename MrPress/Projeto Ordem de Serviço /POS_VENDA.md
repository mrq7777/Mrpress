# Pós-venda Ativo Mr.Press

**Versão:** 1.0
**Status:** Em validação
**Data:** Junho 2026
**Uso:** Etapa 9 do Fluxo Operacional. Roda após o cliente receber o produto.
**Princípio:** Marcelo trabalha sozinho. O pós-venda precisa ser simples e quase automático (idealmente via WhatsApp, no mesmo modelo do agente da ChooseLove).

---

## Os 3 gatilhos

### Gatilho 1: Confirmação de recebimento + agradecimento

- **Quando:** no dia da retirada/entrega, algumas horas depois.
- **Objetivo:** confirmar que chegou tudo certo e agradecer.
- **Canal:** WhatsApp.
- **Modelo de mensagem:**
  > Oi [nome], aqui é da Mr.Press. Seu pedido foi entregue, deu tudo certo? Qualquer ajuste é só me chamar. Obrigado pela preferência!

### Gatilho 2: Pesquisa rápida de satisfação

- **Quando:** 1 a 2 dias após a confirmação.
- **Objetivo:** medir satisfação e captar quem está feliz (para indicação) e quem não está (para resolver antes de virar reclamação).
- **Canal:** WhatsApp.
- **Modelo de mensagem:**
  > [nome], numa nota de 0 a 10, o quanto você indicaria a Mr.Press para um amigo? Sua resposta ajuda muito a melhorar nosso trabalho.
- **Tratamento da nota:**
  - **9 ou 10:** seguir para o Gatilho 3 (indicação/avaliação).
  - **7 ou 8:** agradecer e perguntar o que faltou para ser 10.
  - **0 a 6:** acionar Marcelo na hora para contato direto e resolver.

### Gatilho 3: Recompra e indicação

- **Quando:** clientes nota 9-10, logo após a pesquisa. Recompra: conforme o ciclo do produto.
- **Objetivo:** gerar nova venda e indicações.
- **Canal:** WhatsApp.
- **Duas ações:**
  - **Indicação / avaliação:**
    > Que bom que gostou, [nome]! Se puder deixar uma avaliação no Google leva 1 minuto e ajuda demais: [link]. E se indicar alguém, é só mandar pra cá.
  - **Recompra (lembrete por ciclo):** identificar produtos recorrentes (flyer, cartão de visita, receituário) e lembrar o cliente antes de acabar o estoque dele.
    > Oi [nome], faz [X] que você fez seus [produto]. Quer que eu já adiante um novo lote pra não te deixar na mão?

---

## Ciclos de recompra sugeridos

| Produto | Ciclo aproximado |
| :--- | :--- |
| Cartão de visita | *(a definir)* |
| Flyer / panfleto | *(a definir, ligado a campanha do cliente)* |
| Receituário / bloco | *(a definir)* |

---

## Pendências para próxima revisão

- [ ] Link de avaliação do Google da Mr.Press.
- [ ] Definir ciclos de recompra por produto recorrente.
- [ ] Automatizar os gatilhos no WhatsApp (avaliar reaproveitar a infra WAHA + n8n da ChooseLove).
- [ ] Definir quem dispara enquanto não houver automação (Marcelo ou Cintia).
