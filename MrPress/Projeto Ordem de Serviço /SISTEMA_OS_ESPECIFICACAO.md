# Sistema de Ordem de Serviço Mr.Press

**Versão:** 1.0 (especificação)
**Status:** Em definição
**Data:** Junho 2026
**Tipo:** Sistema próprio sob medida, web, hospedado no servidor Ubuntu existente (mrpress-server, Docker).

---

## Problema que resolve

Hoje o controle é por grupo de WhatsApp. A Cintia (gerente) avisa o trabalho ou o número da OS no grupo e precisa ficar perguntando o andamento, porque o grupo não guarda o status atual de cada OS e ela nem sempre está na loja.

O sistema dá a cada OS um **responsável** e um **status visível e atualizado**, e à gerente uma **visão geral acessível de qualquer lugar**, sem precisar cobrar.

---

## Papéis e permissões

| Ação | Gerente (Cintia/Marcelo) | Funcionário (4 a 6) |
| :--- | :---: | :---: |
| Criar OS | Sim | Não |
| Atribuir responsável | Sim | Não |
| Ver todas as OS | Sim | Não (só as suas) |
| Atualizar status da OS | Sim | Sim (nas suas) |
| Registrar observações | Sim | Sim (nas suas) |
| Ver / lançar financeiro | Sim | Não (ou só leitura) |

---

## Modelo de dados

**Usuário:** id, nome, papel (gerente/funcionário), login, senha.

**Cliente:** id, nome, contato (WhatsApp), VIP (sim/não).

**OS:**
- Número sequencial, data de abertura
- Cliente
- Responsável (funcionário)
- Produto, quantidade, especificações
- Arquivo: recebido / aguardando
- Produção: local / terceirizada
- Fornecedor (se terceirizada)
- Prazo: tipo (normal/urgente) + data de entrega
- Entrega: retirada / motoboy / transportadora
- Status (ver workflow)
- Criado por
- Observações

**Financeiro (por OS):**
- Valor total
- Origem do preço: tabela (local) / informado (terceirizado)
- Sinal: valor, pago/dispensado (VIP)
- Saldo
- Forma de pagamento
- Lançamentos de pagamento (data, valor)

**Histórico de status:** quem mudou, de qual status para qual, quando. (É o que substitui a cobrança no WhatsApp.)

---

## Quadro kanban: agrupado por funcionário

Decisão de junho/2026: o quadro principal NÃO é agrupado por status, e sim por **responsável**. As colunas são os funcionários.

- Colunas = funcionários (Marcelo, Pedro, Lyncon, Brenda, Bruno).
- Coluna **"Não atribuídas"** (responsável vazio) = OS abertas esperando dono. Para o Marcelo, "não atribuída" e "aberta" são a mesma coisa.
- Atribuir ou repassar: pelo campo **Responsável** (dropdown) dentro da OS, que funciona em celular e PC. No computador também dá pra arrastar o card entre colunas (atalho extra). No celular o arrastar não funciona, por isso o campo é o método oficial. "Novas OS" é o valor padrão (toda OS nasce nessa coluna).
- Equipe pode "puxar" OS de quem está sobrecarregado; Cintia acompanha tudo pelo quadro (quadro compartilhado, todos veem tudo, de propósito).
- OS com Status "Entregue" ou "Finalizada" somem do quadro (filtro) e vão para a visão **Finalizadas**.

**Status** é um campo (etiqueta) dentro do card, não é coluna. Opções: A fazer, Em produção, Com fornecedor, Acabamento, Pronta, Entregue, Finalizada.

**Aguardando arquivo** é um checkbox (default desmarcado), porque ~95% das OS abrem com o arquivo pronto. Substituiu o antigo campo "Arquivo".

### Regra de atribuição
Só Cintia ou Marcelo podem atribuir OS à coluna do Marcelo. Os demais funcionários podem puxar OS entre si, mas não podem empurrar trabalho para o Marcelo. O NocoDB não trava isso nativamente. Por enquanto vale como combinado de equipe; o travamento real fica para a guarda no n8n (Fase 3), usando o campo "quem alterou" (LastModifiedBy): se um não autorizado mover OS para a coluna do Marcelo, o n8n desfaz e avisa.

### Visões
- **Quadro de OS**: kanban por funcionário, esconde Entregue/Finalizada.
- **Finalizadas**: grade com Status Entregue ou Finalizada (histórico).
- **Ordens de Serviço**: grade completa (consulta/edição).
- **Minhas OS** (por funcionário): grade filtrada pelo nome (a criar).

---

## Regras de negócio (reaproveitar documentos existentes)

- Preço: produção local segue `TABELA_PRECOS.md`; terceirizada é valor informado.
- Sinal: 50% antes de iniciar, exceto clientes da `LISTA_VIP.md` (dispensados).
- Fornecedor: ordem de prioridade da `FORNECEDORES.md`, sempre da 1ª opção, escalando por prazo.
- Entrega: modais e frete da `ENTREGA.md`.
- Pós-venda: gatilhos da `POS_VENDA.md`, disparados ao status "Entregue".

---

## Telas

1. **Login**
2. **Dashboard da gerente:** kanban de todas as OS, filtros por funcionário/status/prazo, alertas de OS atrasada e de OS aguardando arquivo.
3. **Minhas OS (funcionário):** só as atribuídas a ele, com botão pra mudar status.
4. **Nova OS (gerente):** formulário com os campos do `OS_MODELO.md` e cálculo automático do preço quando a produção é local.
5. **Detalhe da OS:** todos os dados, histórico de status e financeiro.

---

## Fases de construção

### Fase 1 — MVP (mata a dor imediata)
Login, papéis, cadastro de OS, atribuição de responsável, workflow de status (kanban), tela "Minhas OS", dashboard da gerente. Sem financeiro completo, sem integrações. Já elimina a cobrança no WhatsApp.

### Fase 2 — Financeiro e cadastros
Valor total, sinal/saldo, formas de pagamento, cálculo automático pela tabela, cadastro de clientes com VIP.

### Fase 3 — Integrações
- Áudio para OS (transcrição via Replicate)
- Notificação no WhatsApp ao funcionário quando recebe uma OS
- Escalonamento automático de fornecedor (WAHA + n8n)
- Gatilhos de pós-venda no status "Entregue"

---

## Arquitetura no servidor existente

O sistema roda no mesmo servidor do agente de WhatsApp (mrpress-server), como novos containers no stack Docker em `~/mrpress-stack/`:

- **App do sistema de OS** (interface kanban + financeiro) com banco de dados próprio.
- **n8n** (já existe) vira o cérebro de integração: cria OS via API quando a IA do WhatsApp resolve um pedido, dispara notificações e o escalonamento de fornecedor.
- **WAHA** (já existe) é a entrada/saída de WhatsApp.

Fluxo da visão final: cliente pede no WhatsApp → IA (Claude via n8n) resolve → n8n cria a OS via API → OS entra como "Aguardando validação" → Cintia valida e atribui o responsável → segue o workflow normal.

### Ponto crítico: acesso remoto

O servidor é local (192.168.0.101). Os funcionários acessam pela rede da loja, mas a Cintia precisa acessar de fora. Solução recomendada: **Cloudflare Tunnel** (gratuito, seguro, sem abrir portas no roteador). Alternativa: Tailscale.

---

## Stack definido: NocoDB (low-code self-hosted)

Decidido em junho/2026. O app de OS será o **NocoDB**, rodando como container no stack Docker do mrpress-server.

Motivo: a lógica inteligente (IA resolver pedido, criar OS, escalar fornecedor, cálculo de preço) vive no n8n. O app de OS é banco de dados + interface. NocoDB entrega pronto: kanban, logins, papéis e API REST. n8n tem nó nativo de NocoDB.

- Kanban, grades e formulários: nativos do NocoDB.
- Papéis (gerente x funcionário): controle de acesso do NocoDB por base/tabela.
- Cálculos financeiros mais elaborados: rodam no n8n e gravam o resultado no NocoDB.

---

## Progresso

### Feito (junho/2026)
- NocoDB rodando como container no stack Docker do mrpress-server (porta 8080).
- Acesso por chave SSH configurado (`ssh mrpress-server`, chave `~/.ssh/mrpress_server`).
- Base "MrPress OS" (id `p7vcubvup967npa`), tabela "Ordens de Serviço" (id `mjao8u7krrcbhg0`).
- Campos completos (OS + financeiro com sinal/saldo, situação, forma de pagamento e datas).
- Quadro kanban "Quadro de OS" agrupado por funcionário, escondendo Entregue/Finalizada.
- Visão "Finalizadas" (histórico) e visões "Minhas OS - [Nome]" por funcionário.
- Logins criados: Marcelo (owner), Cintia (creator/gerente), Pedro/Lyncon/Brenda/Bruno (editor). Senha inicial = primeiro nome + 1234.
- Token de API NocoDB ativo (usado também pelo n8n na Fase 3).
- Acesso local (loja/casa): http://192.168.0.101:8080.
- Acesso remoto via Tailscale (servidor na conta mrq777@): http://mrpress-server.tailbc82f5.ts.net:8080 ou http://100.94.69.106:8080. Cada usuário externo precisa do app Tailscale logado (convidar pelo painel para uso real).
- Formulário "Nova OS" criado para cadastro manual guiado (logo no form é recurso pago do NocoDB; fica para a OS em PDF).

### Limitações conhecidas (NocoDB community)
- Funcionário (editor) enxerga os campos financeiros; não dá pra esconder campo por papel. Restrição real só na camada n8n.
- Visão "Minhas OS" não é barreira de segurança; editor pode ver as OS dos outros (o que aqui é desejado, para puxar trabalho).
- Texto do botão Submit do formulário não é customizável (segue o idioma da interface).
- No celular não dá pra arrastar card no kanban; atribuição é pelo campo Responsável (dropdown).
- Datas exibidas em DD/MM/AAAA via formato do campo. "Data de abertura" é fórmula e pode exibir com hora.

### Regras automáticas
- "Saldo pago" = Forma de pagamento do saldo é um método real (Cartão, Depósito, Boleto, PIX, Link) E Data do pagamento do saldo preenchida. "Pendente" não conta como pago.
- Saldo = 0 quando o saldo está pago; senão Valor total − Sinal (fórmula nativa).
- Status → "Entregue" quando o saldo é pago (na MrPress, pagar o saldo = retirada/entrega). Implementado por um script automatizador: `~/mrpress-stack/os_status_updater.py`, rodando via cron a cada minuto (log em `os_updater.log`). Pode migrar pro n8n quando consolidar a automação.

## Pendências

- [x] Acesso remoto seguro: resolvido via Tailscale (validação). No VPS de produção será por domínio/HTTPS público.
- [ ] Convidar a Cintia (e quem mais usar de fora) no Tailscale para login próprio.
- [ ] SEGURANÇA: desligar o cadastro aberto (signup) antes de expor no VPS, senão qualquer um cria conta.
- [ ] Fase 2: cálculo de preço automático no n8n gravando no NocoDB.
- [ ] Fase 3: integração WhatsApp → cria OS automática "Aguardando validação".
- [ ] Fase 3: guarda no n8n para a regra de atribuição (só Cintia/Marcelo atribuem ao Marcelo).
- [ ] Migrar o stack pro VPS Hostinger quando validado.
- [ ] (2ª fase) Frontend bonito sob medida com a marca MrPress, por cima do NocoDB via API (o banco e as automações de hoje continuam). Adiado de propósito: visual depois da operação validada.
- [ ] Configurar acesso remoto seguro (Cloudflare Tunnel).
- [ ] Confirmar recursos do servidor (RAM/CPU) pra rodar mais um app + banco.
- [ ] Confirmar nomes/logins dos 4 a 6 funcionários.
- [ ] Confirmar se funcionário vê o financeiro (leitura) ou não vê.
