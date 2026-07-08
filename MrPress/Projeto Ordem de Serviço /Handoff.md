# MrPress OS Frontend - Handoff

**Data:** 22/06/2026
**Status:** v1 no ar, em teste pelo Marcelo

---

## O que foi feito

### Etapa 1: Cloudflare Tunnel
- Conta Cloudflare criada (mrq777@gmail.com)
- Dominio `mrpress.com.br` adicionado ao Cloudflare (plano Free)
- Nameservers atualizados no Registro.br: `coen.ns.cloudflare.com` / `demi.ns.cloudflare.com`
- `cloudflared` instalado em `~/.local/bin/cloudflared` (sem sudo, binario direto)
- Tunnel `mrpress-os` criado (ID: `f3c8b33c-7181-4be8-8916-5e6e0a151f4b`)
- CNAME `os.mrpress.com.br` → tunnel (criado automaticamente)
- Servico systemd user `cloudflared.service` (enable + linger)

### Etapa 2: Next.js Kanban
- Projeto em `~/mrpress-os-frontend/` (Next.js 14, TypeScript, Tailwind)
- Porta 3003, servico systemd user `mrpress-os.service`
- URL publica: **https://os.mrpress.com.br**

---

## Arquitetura

```
Browser → Cloudflare Tunnel → localhost:3003 (Next.js) → localhost:8080 (NocoDB API)
```

## Arquivos do projeto

```
~/mrpress-os-frontend/
├── .env.local                  # NOCODB_API_URL, TOKEN, TABLE_ID, AUTH_SECRET
├── src/
│   ├── middleware.ts            # Auth guard (JWT via jose)
│   ├── lib/
│   │   ├── auth.ts             # Usuarios e senhas
│   │   └── nocodb.ts           # Client NocoDB API + tipos
│   ├── app/
│   │   ├── page.tsx            # Pagina principal (renderiza KanbanBoard)
│   │   ├── login/page.tsx      # Tela de login
│   │   └── api/
│   │       ├── auth/route.ts   # POST login → JWT cookie
│   │       └── os/route.ts     # GET/PATCH/POST ordens de servico
│   └── components/
│       ├── KanbanBoard.tsx     # Board com 6 colunas + drag & drop
│       ├── OSCard.tsx          # Card resumido da OS
│       ├── OSDetail.tsx        # Modal com todos os campos editaveis
│       └── NewOSForm.tsx       # Formulario de nova OS
```

## Servicos systemd (user)

```bash
systemctl --user status cloudflared    # Tunnel
systemctl --user status mrpress-os     # Next.js
systemctl --user restart mrpress-os    # Apos rebuild
```

## Deploy de alteracoes

```bash
cd ~/mrpress-os-frontend
# editar arquivos
npm run build
systemctl --user restart mrpress-os
```

## Logins

| Usuario | Senha | Papel |
|---|---|---|
| marcelo | marcelo1234 | Owner |
| cintia | cintia1234 | Gerente |
| pedro | pedro1234 | Editor |
| lyncon | lyncon1234 | Editor |
| brenda | brenda1234 | Editor |
| bruno | bruno1234 | Editor |

Senhas definidas em `src/lib/auth.ts` (mesmo padrao do NocoDB).

## Funcionalidades

- Login com JWT (cookie httpOnly, 12h)
- Kanban 6 colunas: Novas OS, Marcelo, Pedro, Lyncon, Brenda, Bruno
- Card: Numero OS, Cliente, Celular, Status (dropdown), Data entrega, Saldo, badge VIP, badge "Aguardando arquivo", borda vermelha se entrega < 24h
- Drag & drop entre colunas (muda Responsavel)
- Clique no card → modal com campos editaveis (status, responsavel, entrega, financeiro, observacoes)
- Botao Nova OS
- Auto-refresh 15s
- Filtra OS Finalizadas (nao aparecem no kanban)

## Pendencias / proximos ajustes

- [ ] Ajustes visuais apos teste do Marcelo
- [ ] Campos legado (Quantidade, Produto, Producao, Fornecedor) nao aparecem no frontend (correto)
- [ ] Campos de controle (Retrabalhos, Liberado pra producao) aparecem so no detalhe (correto)
- [ ] Futuramente: visao "Finalizadas" separada
- [ ] Futuramente: notificacoes (ntfy ja roda na porta 8090)
