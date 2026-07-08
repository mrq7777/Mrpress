# Projeto: WhatsApp → OS (modo aprendizado paralelo)

**Status:** Planejado
**Data:** Junho 2026
**Meta de implementação:** Janeiro 2027
**Estratégia:** rodar em paralelo (modo observador) por ~6 meses, aprendendo com erros, sem mexer na operação atual.

---

## Visão geral: a OS como cérebro operacional

A base de OS é a fonte da verdade. Como a MrPress não tem e-commerce e nada é produto pronto (tudo vira produto por um processo de serviço), a OS é o único lugar que sabe o estado de cada trabalho. Ela alimenta duas pontas:

```
                  [ BASE DE OS ]  (fonte da verdade)
                  /            \
   ENTRADA (interno)            SAÍDA (cliente)
   Grupo da Cintia →            Cliente no WhatsApp →
   IA cria a OS                 IA consulta a OS e responde
   (sem formulário)             status, pronto, arquivo errado
```

## Fluxo 1 — Entrada (grupo interno → OS)

A Cintia já manda os trabalhos para os funcionários num grupo de WhatsApp da empresa. O sistema deve:
1. Observar as mensagens do grupo.
2. Identificar quais são trabalhos a executar (e ignorar conversa comum).
3. Transformar a mensagem em uma OS rascunho, completando as informações que faltam.
4. Deixar a OS como rascunho não validado, para Cintia/Marcelo revisarem.

Esse fluxo entrega duas coisas de uma vez: alimenta o sistema (sem formulário) e se autoavalia (rascunho vs. correção). Roda em paralelo; ninguém depende da IA até janeiro/2027.

## Fluxo 2 — Saída (atendimento ao cliente)

Mesmo motor do agente da ChooseLove (WAHA + n8n + Claude), mas consultando a OS em vez de catálogo de produtos:
- Cliente pergunta o status → IA acha a OS dele (pelo número de WhatsApp, campo Celular/Telefone) → responde.
- OS muda para "Pronta" → IA avisa o cliente automaticamente.
- Arquivo errado → IA avisa e pede reenvio.
- Vai crescendo conforme necessidades e oportunidades aparecem.

Sequência: Fluxo 1 primeiro (popula os dados), Fluxo 2 depois (consome os dados). Ambos dentro do runway até jan/2027.

---

## Como o "aprendizado" funciona (expectativa correta)

A IA não se re-treina sozinha. O sistema melhora deliberadamente:
- **Observando:** o bot lê todas as mensagens do grupo (membro silencioso).
- **Perguntando:** quando falta info, marca "a confirmar" na OS rascunho.
- **Memorizando:** a base de conhecimento ("cérebro MrPress") cresce com produtos, gírias, abreviações, regras.
- **Errando:** rascunhos errados são corrigidos por humanos; as correções viram regras/exemplos no cérebro e nas instruções da IA (revisão semanal).

Em 6 meses de correções, a extração fica afiada.

---

## Arquitetura (modo sombra)

```
Grupo WhatsApp da empresa (Cintia posta os trabalhos)
   ↓  número-bot é membro silencioso do grupo
 WAHA → n8n → Claude classifica a mensagem
   ↓ é trabalho?
   sim → cria OS RASCUNHO (Origem: WhatsApp, Validada=não, marca faltantes)
   não → ignora
   ↓
 Cintia/Marcelo revisam e validam
   ↓
 correções alimentam o cérebro MrPress
```

Peças (todas já existem no servidor): WAHA, n8n, Claude API, NocoDB + token.

---

## Pré-requisito que trava o início

- Um número de WhatsApp **membro do grupo da empresa**, rodando no WAHA (o número da ChooseLove provavelmente não está no grupo). Decidir: chip novo dedicado ou usar o número atual do WAHA no grupo.

---

## Mudanças na OS para suportar rascunhos da IA

- Campo **Origem**: Balcão / WhatsApp / Telefone / E-mail / Direto.
- Campo **Mensagem original**: guarda o texto do WhatsApp que gerou a OS.
- Campo **Validada** (checkbox, default não): OS da IA nasce como não validada.

---

## Milestones (jun/2026 → jan/2027)

1. **Preparar OS para rascunhos** (campos Origem, Mensagem original, Validada). *(pode já)*
2. **Criar o cérebro MrPress** (produtos, regras, jeitos de escrever, abreviações). *(pode já)*
3. **Número-bot no grupo + sessão WAHA.** *(depende do Marcelo)*
4. **Fluxo n8n:** mensagem do grupo → Claude classifica e extrai → cria OS rascunho.
5. **Rodar em paralelo + revisão semanal** dos acertos/erros, alimentando o cérebro.
6. **Janeiro/2027:** virar a chave, OS passa a nascer pela IA com validação da Cintia.

---

## Riscos e cuidados

- Falso positivo (criar OS de mensagem que não é trabalho) e falso negativo (perder trabalho). O modo paralelo existe justamente para calibrar isso sem prejuízo.
- O bot é observador: não responde no grupo, para não atrapalhar a operação.
- Privacidade: o grupo é da empresa, do Marcelo. Sem leitura de conversas externas.
