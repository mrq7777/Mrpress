# SESSAO_TEMPLATE.md

## PROMPT DE FIM DE SESSAO

Cole este prompt no Claude Code ao encerrar qualquer sessao de trabalho:

---

Gera um resumo desta sessao no seguinte formato:

## RESUMO DE SESSAO
**Data:** [data de hoje]
**Projeto:** [nome do projeto, ex: ChooseLove, SWCleaning, Natal Imperial]
**Duracao estimada:** [tempo]

### O que foi feito
- [lista das acoes executadas, com resultado de cada uma]

### Arquivos criados ou modificados
- [caminho completo] : [o que mudou]

### Decisoes tomadas
- [decisao] : [motivo]

### Pendencias e aprovacoes
- [o que depende do cliente ou de uma decisao do Marcelo antes de seguir]

### Problemas encontrados
- [erros, bloqueios, coisas que nao funcionaram como esperado]

### Estado atual
[descricao em 2-3 linhas de onde o projeto esta agora]

### Proximos passos sugeridos
1. [acao 1]
2. [acao 2]
3. [acao 3]

### Contexto para o Chat e Cowork
[paragrafo curto explicando o que o Claude.ai (Chat) e o Cowork precisam saber para continuar a estrategia deste projeto, sem precisar reabrir esta sessao]

---

## COMO USAR

1. Cole o prompt acima no Code ao final da sessao de trabalho
2. Copie o resumo gerado pelo Code
3. Salve o resumo como um arquivo `.md` na pasta do projeto (ex: `/Volumes/SSD Dados/Projeto Choose Love/`), com data no nome (ex: `Sessao - 12Jun2026.md`), para manter um historico
4. Abra o Claude.ai Chat e cole o resumo com a mensagem: "Atualiza sua memoria com isso:"
5. Abra o Cowork e cole o mesmo resumo no projeto correspondente, com a mensagem: "Contexto atualizado, continue a partir daqui:"
6. Chat, Cowork e Code ficam alinhados sobre o que foi feito e o que falta, sem repetir trabalho ou perder contexto

## LOCALIZACAO RECOMENDADA

Este template fica em `/Users/marceloqueiroz/SESSAO_TEMPLATE.md`, na mesma pasta do CLAUDE.md principal.

Os resumos gerados a partir dele (passo 3) ficam dentro da pasta de cada projeto, em `/Volumes/SSD Dados/Projeto [Nome]/`, formando um historico que o Chat e o Cowork podem consultar quando precisar de contexto antigo.
