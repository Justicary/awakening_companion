import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { CLASSES_CONFIG } from './config.js';
import { BASELINE_BIS } from './baseline.js';
import { WowheadScraper } from './scraper.js';
import { LuaExporter } from './exporter.js';
import { BiSLists, BiSSpecData, SlotKey, BiSItem } from './types.js';

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
      const specSlots: Partial<Record<SlotKey, BiSItem>> = {};

      // Initialize with baseline if available
      if (baselineSpec?.slots) {
        for (const [slot, item] of Object.entries(baselineSpec.slots)) {
          specSlots[slot as SlotKey] = { ...item };
        }
      }

      const enableLiveScraping = process.env.SCRAPE_LIVE === 'true';
      let scraped = false;

      if (enableLiveScraping) {
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
                if (!scraped) {
                  scraped = true;
                  liveScrapedSpecs++;
                }
                if (foundCount >= 14) {
                  break;
                }
              } else {
                console.log('⚠️ Sin tabla de objetos BiS');
              }
            } else {
              console.log('❌ No disponible (404/403/Timeout)');
            }
          } catch (err: unknown) {
            const errMsg = err instanceof Error ? err.message : String(err);
            console.log(`❌ Error: ${errMsg}`);
          }
        }
      }

      if (!scraped) {
        console.log(`  │   ↳ Usando datos verificados AtlasLoot Classic (Raid Fase 1 / MC & Onyxia)`);
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

  // Resolve target output path (allows custom CLI parameter or defaults to Data/BiSData.lua)
  const customOutputPath = process.argv[2];
  let targetLuaPath: string;

  if (customOutputPath) {
    targetLuaPath = path.resolve(process.cwd(), customOutputPath);
  } else {
    // Search relative to workspace root or __dirname
    const candidatePaths = [
      path.resolve(__dirname, '../../../Data/BiSData.lua'),
      path.resolve(process.cwd(), 'Data/BiSData.lua'),
      path.resolve(process.cwd(), '../../Data/BiSData.lua'),
    ];
    targetLuaPath = candidatePaths[0];
    for (const cp of candidatePaths) {
      if (fs.existsSync(path.dirname(cp))) {
        targetLuaPath = cp;
        break;
      }
    }
  }

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
  console.log(`   - Archivo destino:          ${path.relative(process.cwd(), targetLuaPath) || targetLuaPath}`);
  console.log('   - Estado:                   COMPLETADO CON ÉXITO (Exit code 0)');
  console.log('=================================================================\n');

  process.exit(0);
}

main().catch((err: unknown) => {
  const errMsg = err instanceof Error ? err.stack || err.message : String(err);
  console.error('Fatal error during BiS generation:\n', errMsg);
  process.exit(1);
});
