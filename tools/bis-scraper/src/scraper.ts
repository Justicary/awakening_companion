import dns from 'dns';
import vm from 'vm';
import axios, { AxiosInstance } from 'axios';
import * as cheerio from 'cheerio';
import { BiSItem, SlotKey } from './types.js';
import { SLOTBAK_MAP } from './config.js';

// Ensure IPv4 first in environments like WSL2
dns.setDefaultResultOrder('ipv4first');

export class WowheadScraper {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      timeout: 12000,
      headers: {
        'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) Gecko/20100101 Firefox/124.0',
        Accept:
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
      },
    });
  }

  /**
   * Fetches HTML content with error handling
   */
  async fetchPage(url: string): Promise<string | null> {
    try {
      const response = await this.client.get(url);
      if (response.status === 200 && typeof response.data === 'string') {
        return response.data;
      }
      return null;
    } catch (err: any) {
      // 404, 403 or network errors are handled gracefully
      return null;
    }
  }

  /**
   * Parses items from Wowhead HTML using Gatherer data and Markup tables
   */
  parseGuideHtml(html: string): Partial<Record<SlotKey, BiSItem>> {
    const slots: Partial<Record<SlotKey, BiSItem>> = {};

    // 1. Extract WH.Gatherer item metadata (id, name, slotbak)
    const gathererItems = this.extractGathererItems(html);
    const gathererNpcs = this.extractGathererNpcs(html);

    // 2. Extract markup tables from WH.markup.printHtml
    const markupText = this.extractMarkupText(html);

    if (markupText) {
      this.parseMarkupSections(markupText, gathererItems, gathererNpcs, slots);
    }

    // 3. Fallback: Parse Cheerio DOM <table> and <a href="...item=XXXX...">
    if (Object.keys(slots).length === 0) {
      this.parseDomTables(html, gathererItems, slots);
    }

    // 4. Fallback: If markup tables were partial, use Gatherer slotbak directly
    for (const [idStr, itemInfo] of Object.entries(gathererItems)) {
      const id = parseInt(idStr, 10);
      if (!id || !itemInfo.name) continue;

      const rawSlot = itemInfo.slotbak ? SLOTBAK_MAP[itemInfo.slotbak] : undefined;
      if (!rawSlot) continue;

      let targetSlot: SlotKey | null = null;
      if (rawSlot === 'FINGER') {
        if (!slots.FINGER_1) targetSlot = 'FINGER_1';
        else if (!slots.FINGER_2 && slots.FINGER_1.itemId !== id) targetSlot = 'FINGER_2';
      } else if (rawSlot === 'TRINKET') {
        if (!slots.TRINKET_1) targetSlot = 'TRINKET_1';
        else if (!slots.TRINKET_2 && slots.TRINKET_1.itemId !== id) targetSlot = 'TRINKET_2';
      } else {
        targetSlot = rawSlot as SlotKey;
      }

      if (targetSlot && !slots[targetSlot]) {
        slots[targetSlot] = {
          itemId: id,
          name: itemInfo.name,
          source: itemInfo.source || 'Classic Drop',
        };
      }
    }

    return slots;
  }

  /**
   * Extracts items from WH.Gatherer.addData(3, ...)
   */
  private extractGathererItems(
    html: string
  ): Record<number, { name: string; slotbak?: number; source?: string }> {
    const items: Record<number, { name: string; slotbak?: number; source?: string }> = {};
    const search = 'WH.Gatherer.addData(3,';
    let idx = 0;

    while ((idx = html.indexOf(search, idx)) !== -1) {
      const bracePos = html.indexOf('{', idx);
      if (bracePos === -1) break;

      let depth = 0;
      let inStr = false;
      let escape = false;
      let endPos = -1;

      for (let i = bracePos; i < html.length; i++) {
        const ch = html[i];
        if (escape) {
          escape = false;
          continue;
        }
        if (ch === '\\') {
          escape = true;
          continue;
        }
        if (ch === '"') {
          inStr = !inStr;
          continue;
        }
        if (!inStr) {
          if (ch === '{') depth++;
          else if (ch === '}') {
            depth--;
            if (depth === 0) {
              endPos = i + 1;
              break;
            }
          }
        }
      }

      if (endPos !== -1) {
        try {
          const parsed = JSON.parse(html.substring(bracePos, endPos));
          for (const [idStr, data] of Object.entries(parsed as Record<string, any>)) {
            const id = parseInt(idStr, 10);
            if (id && data.name_enus) {
              items[id] = {
                name: data.name_enus,
                slotbak: data.jsonequip?.slotbak,
              };
            }
          }
        } catch {
          // ignore malformed chunk
        }
      }
      idx += search.length;
    }

    return items;
  }

  /**
   * Extracts NPC names from WH.Gatherer.addData(1, ...)
   */
  private extractGathererNpcs(html: string): Record<number, string> {
    const npcs: Record<number, string> = {};
    const search = 'WH.Gatherer.addData(1,';
    let idx = 0;

    while ((idx = html.indexOf(search, idx)) !== -1) {
      const bracePos = html.indexOf('{', idx);
      if (bracePos === -1) break;

      let depth = 0;
      let inStr = false;
      let escape = false;
      let endPos = -1;

      for (let i = bracePos; i < html.length; i++) {
        const ch = html[i];
        if (escape) {
          escape = false;
          continue;
        }
        if (ch === '\\') {
          escape = true;
          continue;
        }
        if (ch === '"') {
          inStr = !inStr;
          continue;
        }
        if (!inStr) {
          if (ch === '{') depth++;
          else if (ch === '}') {
            depth--;
            if (depth === 0) {
              endPos = i + 1;
              break;
            }
          }
        }
      }

      if (endPos !== -1) {
        try {
          const parsed = JSON.parse(html.substring(bracePos, endPos));
          for (const [idStr, data] of Object.entries(parsed as Record<string, any>)) {
            const id = parseInt(idStr, 10);
            if (id && data.name_enus) {
              npcs[id] = data.name_enus;
            }
          }
        } catch {
          // ignore malformed chunk
        }
      }
      idx += search.length;
    }

    return npcs;
  }

  /**
   * Extracts markup text from WH.markup.printHtml call for the body
   */
  private extractMarkupText(html: string): string | null {
    const marker = '"guide-body"';
    let markerPos = html.indexOf(marker);
    if (markerPos === -1) return null;

    // Look for printHtml call that ends with "guide-body"
    const callPos = html.lastIndexOf('WH.markup.printHtml(', markerPos);
    if (callPos === -1) return null;

    // Find the end of call
    const endCall = html.indexOf(');', markerPos);
    if (endCall === -1) return null;

    const callSnippet = html.substring(callPos, endCall + 2);
    let extracted: string | null = null;

    const sandbox = {
      WH: {
        markup: {
          printHtml: function (text: string) {
            extracted = text;
          },
        },
      },
    };

    try {
      vm.runInNewContext(callSnippet, sandbox);
      return extracted;
    } catch {
      return null;
    }
  }

  /**
   * Parses BBCode markup tables from Wowhead guides
   */
  private parseMarkupSections(
    markup: string,
    gathererItems: Record<number, { name: string; slotbak?: number; source?: string }>,
    gathererNpcs: Record<number, string>,
    slots: Partial<Record<SlotKey, BiSItem>>
  ) {
    // Splits sections by heading: [h3 toc="Head"] or [h2 toc="..."]
    const sectionRegex = /\[h[23][^\]]*toc="([^"]+)"[^\]]*\]([\s\S]*?)(?=\[h[23]|$)/gi;
    let match;

    while ((match = sectionRegex.exec(markup)) !== null) {
      const heading = match[1].toLowerCase();
      const content = match[2];

      const slotKey = this.normalizeSlotName(heading);
      if (!slotKey) continue;

      // Extract item from table rows
      const rowRegex = /\[tr\]([\s\S]*?)\[\/tr\]/gi;
      let rowMatch;
      let isFirstRow = true;

      while ((rowMatch = rowRegex.exec(content)) !== null) {
        const rowContent = rowMatch[1];
        if (rowContent.includes('[b]Item[/b]') || rowContent.includes('[b]Rank[/b]')) {
          continue; // header row
        }

        const itemMatch = rowContent.match(/\[item=(\d+)\]/i);
        if (!itemMatch) continue;

        const itemId = parseInt(itemMatch[1], 10);
        if (!itemId) continue;

        // Extract source
        let source = 'Wowhead Guide';
        const tdMatches = Array.from(rowContent.matchAll(/\[td[^\]]*\]([\s\S]*?)\[\/td\]/gi));
        if (tdMatches.length >= 3) {
          const rawSource = tdMatches[2][1]
            .replace(/\[npc=(\d+)\]/g, (_, id) => gathererNpcs[parseInt(id, 10)] || `NPC #${id}`)
            .replace(/\[zone=(\d+)\]/g, 'Zone')
            .replace(/\[color=[^\]]+\]/g, '')
            .replace(/\[\/color\]/g, '')
            .replace(/\[url=[^\]]+\]/g, '')
            .replace(/\[\/url\]/g, '')
            .replace(/<[^>]+>/g, '')
            .replace(/\s+/g, ' ')
            .trim();
          if (rawSource) source = rawSource;
        }

        const itemName = gathererItems[itemId]?.name || `Item #${itemId}`;

        let assignedSlot: SlotKey | null = null;
        if (slotKey === 'FINGER') {
          if (!slots.FINGER_1) assignedSlot = 'FINGER_1';
          else if (!slots.FINGER_2 && slots.FINGER_1.itemId !== itemId) assignedSlot = 'FINGER_2';
        } else if (slotKey === 'TRINKET') {
          if (!slots.TRINKET_1) assignedSlot = 'TRINKET_1';
          else if (!slots.TRINKET_2 && slots.TRINKET_1.itemId !== itemId) assignedSlot = 'TRINKET_2';
        } else {
          assignedSlot = slotKey as SlotKey;
        }

        if (assignedSlot && (!slots[assignedSlot] || isFirstRow)) {
          slots[assignedSlot] = {
            itemId,
            name: itemName,
            source,
          };
          if (assignedSlot !== 'FINGER_1' && assignedSlot !== 'TRINKET_1') {
            break; // take first (best) item for standard slots
          }
        }
        isFirstRow = false;
      }
    }
  }

  /**
   * DOM fallback parsing using Cheerio
   */
  private parseDomTables(
    html: string,
    gathererItems: Record<number, { name: string; slotbak?: number; source?: string }>,
    slots: Partial<Record<SlotKey, BiSItem>>
  ) {
    const $ = cheerio.load(html);

    $('table').each((_, table) => {
      // Look for heading immediately preceding this table
      const headingText =
        $(table).prevAll('h2, h3').first().text().toLowerCase() ||
        $(table).closest('section').find('h2, h3').first().text().toLowerCase();

      const slotKey = this.normalizeSlotName(headingText);

      $(table)
        .find('tr')
        .each((_, tr) => {
          const itemLink = $(tr).find('a[href*="/item="]').first();
          if (!itemLink.length) return;

          const href = itemLink.attr('href') || '';
          const match = href.match(/item=(\d+)/);
          if (!match) return;

          const itemId = parseInt(match[1], 10);
          const itemName =
            itemLink.text().trim() || gathererItems[itemId]?.name || `Item #${itemId}`;

          const rawSource = $(tr).find('td').last().text().trim();
          const source = rawSource || 'Dungeon / Raid';

          let targetSlot: SlotKey | null = null;
          if (slotKey) {
            if (slotKey === 'FINGER') {
              if (!slots.FINGER_1) targetSlot = 'FINGER_1';
              else if (!slots.FINGER_2 && slots.FINGER_1.itemId !== itemId) targetSlot = 'FINGER_2';
            } else if (slotKey === 'TRINKET') {
              if (!slots.TRINKET_1) targetSlot = 'TRINKET_1';
              else if (!slots.TRINKET_2 && slots.TRINKET_1.itemId !== itemId) targetSlot = 'TRINKET_2';
            } else {
              targetSlot = slotKey as SlotKey;
            }
          }

          if (targetSlot && !slots[targetSlot]) {
            slots[targetSlot] = { itemId, name: itemName, source };
          }
        });
    });
  }

  /**
   * Maps slot strings to SlotKey
   */
  private normalizeSlotName(name: string): SlotKey | 'FINGER' | 'TRINKET' | null {
    const s = name.toLowerCase();
    if (s.includes('head') || s.includes('helm') || s.includes('casco')) return 'HEAD';
    if (s.includes('neck') || s.includes('cuello') || s.includes('pendant')) return 'NECK';
    if (s.includes('shoulder') || s.includes('hombreras')) return 'SHOULDERS';
    if (s.includes('back') || s.includes('cloak') || s.includes('capa')) return 'BACK';
    if (s.includes('chest') || s.includes('robe') || s.includes('pechera')) return 'CHEST';
    if (s.includes('wrist') || s.includes('bracer') || s.includes('brazales')) return 'WRISTS';
    if (s.includes('hand') || s.includes('glove') || s.includes('guantes')) return 'HANDS';
    if (s.includes('waist') || s.includes('belt') || s.includes('cinturón')) return 'WAIST';
    if (s.includes('leg') || s.includes('pant') || s.includes('pantalones')) return 'LEGS';
    if (s.includes('feet') || s.includes('boot') || s.includes('botas')) return 'FEET';
    if (s.includes('ring') || s.includes('finger') || s.includes('anillo')) return 'FINGER';
    if (s.includes('trinket') || s.includes('abalorio')) return 'TRINKET';
    if (s.includes('main-hand') || s.includes('main hand') || s.includes('two-hand') || s.includes('weapon'))
      return 'MAIN_HAND';
    if (s.includes('off-hand') || s.includes('off hand') || s.includes('shield') || s.includes('secundaria'))
      return 'OFF_HAND';
    if (s.includes('ranged') || s.includes('relic') || s.includes('bow') || s.includes('gun') || s.includes('wand'))
      return 'RANGED';

    return null;
  }
}
