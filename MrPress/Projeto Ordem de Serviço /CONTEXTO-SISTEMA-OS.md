# Sistema de OS — MrPress (contexto para Claude Chat)

Data: 07/jul/2026

---

## O que é

Sistema interno de Ordem de Serviço da MrPress (gráfica, Barra da Tijuca, RJ). Substitui o MarketUP (que continua rodando em paralelo até jan/2027 para fiscal/comercial).

---

## Infraestrutura — servidor local

- **Servidor:** 192.168.0.109 (IP reservado no roteador)
- **SSH:** `ssh mrpress-server` (chave `~/.ssh/mrpress_key`, usuário `marcelo`)
- **Docker Compose:** `~/mrpress-stack/docker-compose.yml`

### Containers rodando

| Container | Porta | Função |
|---|---|---|
| nocodb | :8080 | Banco de dados (NocoDB) |
| postgres | — | PostgreSQL (NocoDB + Chatwoot) |
| chatwoot-rails | :3100 | Chat unificado |
| chatwoot-sidekiq | — | Workers Chatwoot |
| chatwoot-redis | — | Redis |
| n8n | :5678 | Automações |
| meta-webhook | :3300 | Bridge Meta API → Chatwoot |
| waha-mrpress | :3001 | WAHA (futuro: 2777 e 3982) |
| ntfy | :80 | Notificações push internas |
| whatsapp-search | — | Busca em conversas WA |

### Cloudflare Tunnels

| Domínio | Porta | Serviço |
|---|---|---|
| os.mrpress.com.br | :3003 | Frontend OS (Next.js) |
| chat.mrpress.com.br | :3100 | Chatwoot |
| wa.mrpress.com.br | :3300 | Meta webhook |
| n8n.mrpress.com.br | :5678 | n8n |

---

## NocoDB — banco de dados

- **Base:** MrPress_OS (id: `p7vcubvup967npa`)
- **Token:** `nc_pat_NZ0u5nzMq9MGmWIZQFv84W9z7GGTzzQxcJUT3yRy`
- **Tabela OS:** id `mjao8u7krrcbhg0`
- **Endpoint:** `http://nocodb:8080` (interno Docker) / `http://192.168.0.109:8080` (rede local)

### Campos da tabela OS

| Campo | Tipo | Obs |
|---|---|---|
| Numero OS | Fórmula | Auto |
| Data abertura | Data | Auto |
| Cliente | Texto | `*` Obrigatório |
| Celular / Telefone (WhatsApp) | Texto | |
| E-mail | Texto | |
| Especificações | Texto longo | `*` Obrigatório |
| Quantidade | Número | `*` Obrigatório |
| Categorias | Texto | IA preenche via cron |
| Observações | Texto | |
| Aguardando arquivo | Checkbox | |
| Data de entrega | Data/hora | |
| Entrega | Select | Retirada na loja / Motoboy / Transportadora |
| Endereço entrega | Texto | |
| Valor total | Moeda | |
| Sinal | Moeda | |
| Saldo | Fórmula | Valor total - Sinal |
| Formas pagto sinal | Select | PIX / C_credito / C_debito / Depósito / Link / Boleto / Dispensado |
| Formas pagto saldo | Select | idem |
| Liberado pra produção | Fórmula | Saldo pago OU VIP |
| VIP | Checkbox | Isenta sinal |
| Responsável | Select | Cintia/Entradas / Marcelo / Pedro / Lyncon / Brenda / Bruno |
| Status | Select | A fazer / Em produção / Pronta / Entregue |
| Retrabalhos | Número | |
| Refazer | Checkbox | |
| Faturado | Checkbox | |
| Prioridade | Número | Ordenação dentro da coluna Kanban |

### Crons rodando no servidor

- `os_status_updater.py` (1min) — saldo pago → Entregue; Refazer → volta A fazer
- `os_categorizar.py` (2min) — IA classifica categorias
- `os_vincular_cliente.py` (5min) — vincula OS por telefone

---

## Frontend — os.mrpress.com.br

- **Stack:** Next.js 14 + TypeScript + Tailwind
- **Pasta:** `~/mrpress-os-frontend/`
- **Serviço:** systemd user `mrpress-os.service` (porta 3003)
- **Auth:** JWT via jose, cookie httpOnly 12h
- **Logins:** nome+1234 (marcelo, cintia, pedro, lyncon, brenda, bruno)

### Funcionalidades do Kanban

- 6 colunas por Responsável
- Drag & drop entre colunas (muda Responsável) e dentro da coluna (muda Prioridade)
- Auto-refresh a cada 15 segundos
- Busca por cliente ou número OS
- Badges nos cards: ARQUIVO / HOJE / URGENTE / ATRASADO
- Modal de detalhe com todos os campos editáveis
- Visão Finalizadas: A Refazer / A Faturar / Finalizadas

### Deploy

```bash
cd ~/mrpress-os-frontend && rm -rf .next && npm run build && systemctl --user restart mrpress-os
```

---

## Chatwoot — chat.mrpress.com.br

- **Login admin:** mrq777@gmail.com / $MIckey00
- **API token:** `d6G6UmHJnewBds81ma4rTngE`
- **Inbox 2:** WhatsApp 4383 (Meta API) — exclusivo do robô

### Agentes cadastrados

| Nome | Email | Senha |
|---|---|---|
| Marcelo | mrq777@gmail.com | $Mickey00 |
| Cintia | cintia@mrpress.com.br | Cintia@2026 |
| Pedro | pedro@mrpress.com.br | Pedro@2026 |
| Lyncon | lyncon@mrpress.com.br | Lyncon@2026 |
| Brenda | brenda@mrpress.com.br | Brenda@2026 |

> Bruno não tem conta no Chatwoot (só produz, não atende)

---

## WhatsApp — números e tecnologias

| Número | Tecnologia | Função |
|---|---|---|
| (21)99783-4383 | Meta Cloud API | Robô — notificações internas, avisa Cintia |
| (21)98916-2777 | WAHA (conectar em ~2 semanas) | Atendimento ao cliente |
| (21)3982-2777 | WAHA (conectar em ~2 semanas) | Atendimento ao cliente |

### Meta API (4383)

- App: MrPress_APP_WS (ID: `1792669825033243`)
- Phone Number ID: `1253088944549482`
- WABA ID: `1465549848663563`
- Token permanente: `EAAZAebHge5BsBR7eM4ne...` (ver acessos completos)
- Webhook URL: `https://wa.mrpress.com.br/webhook`
- Bridge: `~/mrpress-stack/meta_webhook.py`

---

## n8n — automações

- **URL:** n8n.mrpress.com.br
- **Login:** marcelo / mrpress2026

### Workflows ativos

| ID | Nome | Função |
|---|---|---|
| xJcq6BokwbKgcxbh | Chatwoot -> OS (MrPress) | **Principal** — cria OS via WhatsApp |
| gmailOsWorkflow01 | Gmail -> OS (Fazer OS) | Cria OS via email (label "Fazer OS") |
| LYZ0kWZBg2cGhUlT | MARCELO OS | OS pessoal do Marcelo |

---

## Fluxo atual de criação de OS (via WhatsApp)

```
Cintia encaminha mensagem do cliente pro 4383
↓
Meta API recebe → meta_webhook.py → cria conversa no Chatwoot (inbox 2)
↓
Chatwoot dispara webhook "conversation_created" → n8n
↓
n8n: Claude Haiku extrai campos da mensagem
↓
NocoDB: cria OS imediatamente (nunca bloqueia criação)
↓
SE campos obrigatórios faltando → 4383 envia nota privada pra Cintia no Chatwoot
SE nenhum pedido identificado → avisa Cintia que nenhuma OS foi criada
```

### Classificação de campos

| Campo | Prioridade |
|---|---|
| Cliente (nome ou celular) | `*` Obrigatório |
| Especificações | `*` Obrigatório |
| Quantidade | `*` Obrigatório |
| Responsável | `**` Opcional Forte (default: Cintia/Entradas) |
| Valor total | `**` Opcional Forte |
| Prazo de entrega | `**` Opcional Forte |
| Forma de pagamento | `**` Opcional Forte |
| E-mail | `**` Opcional Forte |
| Endereço de entrega | `**` Opcional Forte (só se motoboy) |
| Categoria do produto | `***` Opcional Fraco |
| Arquivo (recebido/aguardando) | `***` Opcional Fraco |
| Tipo de entrega | `***` Opcional Fraco |
| Observações | `***` Opcional Fraco |

### Regras de notificação

- Campos `*` faltando → nota privada no Chatwoot pra Cintia
- Campos `**` faltando → alerta visual no card do Kanban pro funcionário
- Campos `***` → sem alerta

---

## Regras de negócio

- Sinal: 50% do valor antes de iniciar produção
- Clientes VIP (Nova Igreja, INVB, INVJ, INVP): dispensados do sinal
- Fornecedores: Adesivos → Imprime Sim → Grupo Selva → Rafael | Cartões/Folders → AtualCard (5 dias úteis) | Banner → M2 → Grupo Selva
- Entrega: 80% retirada, 18% motoboy, 2% transportadora
- Prazo produção local: até 24h (exceto banner) | Terceirizado: varia por fornecedor

---

## Checklists de produto

Arquivo com campos obrigatórios/opcionais por tipo de produto:
`/Volumes/SSD Dados/Claude_arquivos/projetos/MrPress/Projeto Ordem de Serviço /checklist-produtos-classificado.md`

Produtos cobertos: Cartão de visita, Flyers/Folders/Folhetos, Adesivos, Letreiros, Envelopes, Embalagens, Acrílico/PS/PVC, Brindes, Cadernos/Revistas/Apostilas.

---

## Pendências

- [ ] Conectar WAHA nos números 2777 e 3982 (~2 semanas)
- [ ] Publicar app Meta pra receber mensagens de clientes reais (não só admins)
- [ ] Alertas visuais no frontend para campos `**` faltando no card
- [ ] Emails reais da equipe pra criar agentes Chatwoot (Cintia, Pedro, Lyncon, Brenda pendentes)
- [ ] Migrar servidor pro VPS Hostinger (após 1-2 meses rodando local)
- [ ] Atualizar cartão de pagamento na WABA (Visa 4195 expirado)
