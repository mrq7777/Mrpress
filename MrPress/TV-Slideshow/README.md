# Slideshow TV da Loja — Mr.Press

Slideshow de 10 slides (1920x1080, formato Full HD) para rodar na Smart TV
da loja via pendrive, usando o app de fotos/slideshow nativo da TV (sem
computador conectado).

## Conteúdo dos slides

1. `01_abertura.png` — Logo + tagline "Merece impacto"
2. `02_institucional.png` — 40+ anos, 5000+ clientes, nota 4.9 no Google
3. `03_impressao_laser.png` — Serviço: Impressão a Laser
4. `04_adesivos.png` — Serviço: Adesivos Personalizados
5. `05_grandes_formatos.png` — Serviço: Grandes Formatos
6. `06_sinalizacao.png` — Serviço: Sinalização e Banners
7. `07_brindes.png` — Serviço: Brindes Corporativos
8. `08_precos.png` — Preços "a partir de" (cartão, flyer, adesivo, plastificação)
9. `09_depoimento.png` — Depoimento de cliente (avaliação Google)
10. `10_contato.png` — Endereço, telefone, horário, CTA WhatsApp

## Como colocar no pendrive e rodar na TV

1. Formate o pendrive em **FAT32** (a maioria das Smart TVs só lê FAT32/exFAT).
2. Copie todos os arquivos da pasta `slides/` para a raiz do pendrive
   (ou dentro de uma pasta, ex: `MrPress/`).
3. Conecte o pendrive na entrada USB da TV.
4. Abra o app **Fotos / Galeria / Media Player** da TV (no menu de fontes/entradas).
5. Selecione a pasta com os slides e escolha a opção **Slideshow / Apresentação de slides**.
6. Configure na própria TV:
   - **Intervalo:** 8–10 segundos por slide (recomendado)
   - **Repetir / Loop:** ativado
   - **Ordem:** por nome do arquivo (os arquivos já estão numerados 01 a 10 para manter a ordem certa)
   - **Transição:** a que preferir (fade costuma ficar mais profissional)

> Cada marca de Smart TV (Samsung, LG, TCL, Philips etc.) tem seu app de
> mídia com nome e opções ligeiramente diferentes, mas todas seguem esse
> fluxo: Fontes → USB → Fotos → Slideshow.

## Como editar o conteúdo (preços, textos, novos slides)

O conteúdo é gerado a partir de `slideshow.html` (um único arquivo com os
10 slides, no estilo visual do site da Mr.Press). Para atualizar:

1. Edite o texto/preços direto em `slideshow.html`.
2. Rode `node generate_slides.js` (requer Node + Playwright) para gerar
   novos PNGs em `slides/`.
3. Copie os PNGs atualizados para o pendrive.

Os preços do slide 8 vieram de `../Projeto Ordem de Serviço /TABELA_PRECOS.md`
(status "em validação" em jun/2026) — confirme se ainda estão corretos antes
de usar.
