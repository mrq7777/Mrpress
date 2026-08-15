const path = require('path');
const { chromium } = require('/opt/node22/lib/node_modules/playwright');

const BASE = __dirname;
const NAMES = {
  s1: '01_abertura', s2: '02_institucional', s3: '03_impressao_laser',
  s4: '04_adesivos', s5: '05_grandes_formatos', s6: '06_sinalizacao',
  s7: '07_brindes', s8: '08_precos', s9: '09_depoimento', s10: '10_contato',
};

(async () => {
  const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
  const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
  await page.goto(`file://${path.join(BASE, 'slideshow.html')}`);
  await page.waitForTimeout(500);
  const fs = require('fs');
  const outDir = path.join(BASE, 'slides');
  fs.mkdirSync(outDir, { recursive: true });
  for (const [sid, name] of Object.entries(NAMES)) {
    const el = await page.$(`#${sid}`);
    await el.screenshot({ path: path.join(outDir, `${name}.png`) });
    console.log(`saved ${name}.png`);
  }
  await browser.close();
})();
