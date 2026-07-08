# Validação do Sistema de OS Mr.Press

**Objetivo:** rodar o sistema de ponta a ponta, anotar tudo que estiver errado ou faltando, e corrigir em lote. Sai da descoberta aleatória para uma lista finita.

**Como usar:** siga o roteiro abaixo. Sempre que algo te incomodar, anote na seção "Problemas encontrados". Não filtre, anote tudo, até detalhe pequeno.

---

## Roteiro de teste (faça na ordem)

### No computador
- [ ] Login funciona (testar com Cintia e com um funcionário)
- [ ] Criar OS pelo formulário "Nova OS": campos fazem sentido, na ordem certa
- [ ] Datas aparecem em DD/MM/AAAA
- [ ] Defaults entram sozinhos (Responsável = Novas OS, Status = A fazer)
- [ ] OS nova aparece na coluna "Novas OS" do quadro
- [ ] Atribuir a OS a um funcionário (campo Responsável) e ver o card mudar de coluna
- [ ] Funcionário muda o Status (A fazer → Em produção → Acabamento → Pronta)
- [ ] Registrar o sinal (valor, forma, data) e conferir o Saldo
- [ ] Registrar pagamento do saldo (forma real + data): Saldo zera e, em até 1 min, Status vira Entregue
- [ ] OS Entregue some do quadro e aparece em "Finalizadas"

### No celular (Cintia)
- [ ] Acessar de fora pelo Tailscale
- [ ] Criar uma OS
- [ ] Atribuir pelo campo Responsável (sem arrastar)
- [ ] Mudar o status de uma OS

---

## Problemas encontrados (anote aqui)

| # | O que está errado / faltando | Onde | Prioridade |
| :- | :--- | :--- | :--- |
| 1 | | | |
| 2 | | | |
| 3 | | | |

---

## Pontos já conhecidos a decidir

- [ ] Data de abertura mostra hora junto (fórmula). Manter ou tentar só data?
- [ ] Botão do formulário fica "Submit" (NocoDB não deixa customizar; no máximo "Enviar" em português)
- [ ] Não existe OS em PDF para o cliente (documento com logo). Construir?
- [ ] Card do quadro: definir o que aparece no cartão (cliente, produto, prazo, valor?)
- [ ] Campos obrigatórios: quais não podem ficar em branco na criação?
- [ ] Notificação quando uma OS é atribuída a alguém (usar o ntfy)
- [ ] Funcionário enxerga o financeiro (limite do NocoDB; travar só via n8n)
