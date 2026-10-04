import path from 'path';
import { fileURLToPath } from 'url';
import { CLASSES_CONFIG, SLOT_ORDER } from './config.js';
import { BASELINE_BIS } from './baseline.js';
import { WowheadScraper } from './scraper.js';
import { LuaExporter } from './exporter.js';
import { BiSLists, BiSSpecData, SlotKey } from './types.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
  console.log('=================================================================');
  console.log('⚔️  Awakening Companion - Wowhead BiS Scraper & Lua Exporter');
  console.log('=================================================================\n');

  const scraper = new WowheadScraper();
  const exporter = new LuaExporter();
  const bisLists: BiSLists = {};

  let totalClasses = 0;
  let totalSpecs = 0;
  let totalItems = 0;
  let liveScrapedSpecs = 0;

  for (const [classKey, classConfig] of Object.entries(CLASSES_CONFIG)) {
    console.log(`\n🔍 Procesando Clase: [${classKey}] (${classConfig.displayName})`);
    bisLists[classKey] = {};
    totalClasses++;

    for (const spec of classConfig.specs) {
      totalSpecs++;
      console.log(`  ├─ Especialización: [${spec.key}] (${spec.role.toUpperCase()})`);

      const baselineSpec = BASELINE_BIS[classKey]?.[spec.key];
      const specSlots: Partial<Record<SlotKey, any>> = {};

      // Initialize with baseline if available
      if (baselineSpec?.slots) {
        for (const [slot, item] of Object.entries(baselineSpec.slots)) {
          specSlots[slot as SlotKey] = { ...item };
        }
      }

      let scraped = false;
      // Attempt live scraping across candidate URLs
      for (const url of spec.wowheadUrls) {
        try {
          process.stdout.write(`  │   Intento Wowhead: ${url} ... `);
          const html = await scraper.fetchPage(url);
          if (html) {
            const parsedSlots = scraper.parseGuideHtml(html);
            const foundCount = Object.keys(parsedSlots).length;
            if (foundCount > 0) {
              console.log(`✅ OK (${foundCount} objetos encontrados)`);
              for (const [slot, item] of Object.entries(parsedSlots)) {
                if (item && item.itemId > 0) {
                  specSlots[slot as SlotKey] = item;
                }
              }
              scraped = true;
              liveScrapedSpecs++;
              break;
            } else {
              console.log('⚠️ Sin tabla de objetos BiS');
            }
          } else {
            console.log('❌ No disponible (404/403/Timeout)');
          }
        } catch (err: any) {
          console.log(`❌ Error: ${err.message}`);
        }
      }

      if (!scraped) {
        console.log(`  │   ↳ Usando datos base verificados (Pre-Raid / Fase 1)`);
      }

      const itemCount = Object.keys(specSlots).length;
      totalItems += itemCount;

      const specData: BiSSpecData = {
        phase: 1,
        slots: specSlots,
      };

      bisLists[classKey][spec.key] = specData;
    }
  }

  // Generate Lua file
  const targetLuaPath = path.resolve(__dirname, '../../../Data/BiSData.lua');
  console.log('\n📄 Generando archivo Lua...');
  const luaCode = exporter.generateLua(bisLists);

  console.log(`💾 Guardando en: ${targetLuaPath}`);
  exporter.writeToFile(targetLuaPath, luaCode);

  console.log('\n=================================================================');
  console.log('✨ RESUMEN DE EXPORTACIÓN BiS:');
  console.log(`   - Clases procesadas:        ${totalClasses}`);
  console.log(`   - Especializaciones:        ${totalSpecs}`);
  console.log(`   - Specs con datos en vivo:  ${liveScrapedSpecs}`);
  console.log(`   - Total de objetos BiS:     ${totalItems}`);
  console.log(`   - Archivo destino:          Data/BiSData.lua`);
  console.log('   - Estado:                   COMPLETADO CON ÉXITO (Exit code 0)');
  console.log('=================================================================\n');

  process.exit(0);
}

main().catch((err) => {
  console.error('Fatal error during BiS generation:', err);
  process.exit(1);
});
