import { ClassConfig, SlotKey } from './types.js';

export const CLASSES_CONFIG: Record<string, ClassConfig> = {
  WARRIOR: {
    name: 'WARRIOR',
    displayName: 'Guerrero',
    specs: [
      {
        key: 'Fury',
        name: 'Furia (DPS Dual/2H)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/warrior/fury/level-20-dps-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-fury-warrior-dps-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/warrior/fury/overview-pve-dps',
        ],
      },
      {
        key: 'Protection',
        name: 'Protección (Tanque)',
        role: 'tank',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/warrior/protection/level-20-tank-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-warrior-tank-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/warrior/protection/overview-pve-tank',
        ],
      },
      {
        key: 'Arms',
        name: 'Armas (PvE / PvP)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/warrior/arms/level-20-dps-overview',
          'https://www.wowhead.com/forever/guide/classes/warrior/arms/overview-pve-dps',
        ],
      },
    ],
  },
  PALADIN: {
    name: 'PALADIN',
    displayName: 'Paladín',
    specs: [
      {
        key: 'Retribution',
        name: 'Reprensión (DPS)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/paladin/retribution/level-20-dps-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-paladin-dps-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/paladin/retribution/overview-pve-dps',
        ],
      },
      {
        key: 'Holy',
        name: 'Sagrado (Sanador)',
        role: 'healer',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/paladin/holy/level-20-healer-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-paladin-healing-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/paladin/holy/overview-pve-healer',
        ],
      },
      {
        key: 'Protection',
        name: 'Protección (Tanque)',
        role: 'tank',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/paladin/protection/level-20-tank-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-paladin-tank-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/paladin/protection/overview-pve-tank',
        ],
      },
    ],
  },
  HUNTER: {
    name: 'HUNTER',
    displayName: 'Cazador',
    specs: [
      {
        key: 'Beast Mastery',
        name: 'Dominio de Bestias (DPS)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/hunter/beast-mastery/level-20-dps-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-hunter-dps-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/hunter/beast-mastery/overview-pve-dps',
        ],
      },
      {
        key: 'Marksmanship',
        name: 'Puntería (DPS)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/hunter/marksmanship/level-20-dps-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-hunter-dps-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/hunter/marksmanship/overview-pve-dps',
        ],
      },
      {
        key: 'Survival',
        name: 'Supervivencia (DPS)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/hunter/survival/level-20-dps-overview',
          'https://www.wowhead.com/forever/guide/classes/hunter/survival/overview-pve-dps',
        ],
      },
    ],
  },
  ROGUE: {
    name: 'ROGUE',
    displayName: 'Pícaro',
    specs: [
      {
        key: 'Combat Swords',
        name: 'Combate Espadas / Dagas',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/rogue/combat/level-20-dps-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-rogue-dps-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/rogue/combat/overview-pve-dps',
        ],
      },
      {
        key: 'Assassination',
        name: 'Asesinato (DPS)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/rogue/assassination/level-20-dps-overview',
          'https://www.wowhead.com/forever/guide/classes/rogue/assassination/overview-pve-dps',
        ],
      },
      {
        key: 'Subtlety',
        name: 'Sutileza (PvP / DPS)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/rogue/subtlety/level-20-dps-overview',
          'https://www.wowhead.com/forever/guide/classes/rogue/subtlety/overview-pve-dps',
        ],
      },
    ],
  },
  PRIEST: {
    name: 'PRIEST',
    displayName: 'Sacerdote',
    specs: [
      {
        key: 'Holy',
        name: 'Sagrado (Sanador)',
        role: 'healer',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/priest/holy/level-20-healer-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-priest-healing-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/priest/holy/overview-pve-healer',
        ],
      },
      {
        key: 'Shadow',
        name: 'Sombras (DPS)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/priest/shadow/level-20-dps-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-shadow-priest-dps-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/priest/shadow/overview-pve-dps',
        ],
      },
      {
        key: 'Discipline',
        name: 'Disciplina (Soporte/Sanación)',
        role: 'healer',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/priest/discipline/level-20-healer-overview',
          'https://www.wowhead.com/forever/guide/classes/priest/discipline/overview-pve-healer',
        ],
      },
    ],
  },
  SHAMAN: {
    name: 'SHAMAN',
    displayName: 'Chamán',
    specs: [
      {
        key: 'Restoration',
        name: 'Restauración (Sanador)',
        role: 'healer',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/shaman/restoration/level-20-healer-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-shaman-healing-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/shaman/restoration/overview-pve-healer',
        ],
      },
      {
        key: 'Elemental',
        name: 'Elemental (Cáster DPS)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/shaman/elemental/level-20-dps-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-elemental-shaman-dps-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/shaman/elemental/overview-pve-dps',
        ],
      },
      {
        key: 'Enhancement',
        name: 'Mejora (DPS Melee)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/shaman/enhancement/level-20-dps-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-enhancement-shaman-dps-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/shaman/enhancement/overview-pve-dps',
        ],
      },
    ],
  },
  MAGE: {
    name: 'MAGE',
    displayName: 'Mago',
    specs: [
      {
        key: 'Frost',
        name: 'Escarcha (DPS Control)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/mage/frost/level-20-dps-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-mage-dps-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/mage/frost/overview-pve-dps',
        ],
      },
      {
        key: 'Fire',
        name: 'Fuego (DPS Ráfaga)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/mage/fire/level-20-dps-overview',
          'https://www.wowhead.com/forever/guide/classes/mage/fire/overview-pve-dps',
        ],
      },
      {
        key: 'Arcane',
        name: 'Arcano (DPS / Utilidad)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/mage/arcane/level-20-dps-overview',
          'https://www.wowhead.com/forever/guide/classes/mage/arcane/overview-pve-dps',
        ],
      },
    ],
  },
  WARLOCK: {
    name: 'WARLOCK',
    displayName: 'Brujo',
    specs: [
      {
        key: 'Destruction',
        name: 'Destrucción (DPS)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/warlock/destruction/level-20-dps-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-warlock-dps-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/warlock/destruction/overview-pve-dps',
        ],
      },
      {
        key: 'Affliction',
        name: 'Aflicción (DoTs / DPS)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/warlock/affliction/level-20-dps-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-warlock-dps-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/warlock/affliction/overview-pve-dps',
        ],
      },
      {
        key: 'Demonology',
        name: 'Demonología (DPS)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/warlock/demonology/level-20-dps-overview',
          'https://www.wowhead.com/forever/guide/classes/warlock/demonology/overview-pve-dps',
        ],
      },
    ],
  },
  DRUID: {
    name: 'DRUID',
    displayName: 'Druida',
    specs: [
      {
        key: 'Feral DPS',
        name: 'Feral Felino (DPS)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/druid/feral/level-20-dps-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-feral-druid-dps-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/druid/feral/overview-pve-dps',
        ],
      },
      {
        key: 'Feral Tank',
        name: 'Feral Oso (Tanque)',
        role: 'tank',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/druid/feral/level-20-tank-overview',
          'https://www.wowhead.com/classic/guide/wow-classic-feral-druid-tank-molten-core-best-in-slot-gear',
          'https://www.wowhead.com/forever/guide/classes/druid/feral/tank-abilities',
        ],
      },
      {
        key: 'Restoration',
        name: 'Restauración (Sanador)',
        role: 'healer',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/druid/restoration/level-20-healer-overview',
          'https://www.wowhead.com/forever/guide/classes/druid/restoration/overview-pve-healer',
        ],
      },
      {
        key: 'Balance',
        name: 'Equilibrio (Cáster DPS)',
        role: 'dps',
        wowheadUrls: [
          'https://www.wowhead.com/forever/guide/classes/druid/balance/level-20-dps-overview',
          'https://www.wowhead.com/forever/guide/classes/druid/balance/overview-pve-dps',
        ],
      },
    ],
  },
};

export const SLOT_ORDER: SlotKey[] = [
  'HEAD',
  'NECK',
  'SHOULDERS',
  'BACK',
  'CHEST',
  'WRISTS',
  'HANDS',
  'WAIST',
  'LEGS',
  'FEET',
  'FINGER_1',
  'FINGER_2',
  'TRINKET_1',
  'TRINKET_2',
  'MAIN_HAND',
  'OFF_HAND',
  'RANGED',
];

export const SLOTBAK_MAP: Record<number, SlotKey | 'FINGER' | 'TRINKET'> = {
  1: 'HEAD',
  2: 'NECK',
  3: 'SHOULDERS',
  16: 'BACK',
  5: 'CHEST',
  20: 'CHEST',
  9: 'WRISTS',
  10: 'HANDS',
  6: 'WAIST',
  7: 'LEGS',
  8: 'FEET',
  11: 'FINGER',
  12: 'TRINKET',
  13: 'MAIN_HAND',
  17: 'MAIN_HAND',
  21: 'MAIN_HAND',
  14: 'OFF_HAND',
  22: 'OFF_HAND',
  23: 'OFF_HAND',
  15: 'RANGED',
  25: 'RANGED',
  26: 'RANGED',
  28: 'RANGED',
};
