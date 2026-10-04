export type SlotKey =
  | 'HEAD'
  | 'NECK'
  | 'SHOULDERS'
  | 'BACK'
  | 'CHEST'
  | 'WRISTS'
  | 'HANDS'
  | 'WAIST'
  | 'LEGS'
  | 'FEET'
  | 'FINGER_1'
  | 'FINGER_2'
  | 'TRINKET_1'
  | 'TRINKET_2'
  | 'MAIN_HAND'
  | 'OFF_HAND'
  | 'RANGED';

export interface BiSItem {
  itemId: number;
  name: string;
  source?: string;
  zone?: string;
  dropChance?: string;
}

export interface BiSSpecData {
  phase: number;
  sourceUrl?: string;
  slots: Partial<Record<SlotKey, BiSItem>>;
}

export type BiSClassData = Record<string, BiSSpecData>;

export type BiSLists = Record<string, BiSClassData>;

export interface SpecConfig {
  key: string;
  name: string;
  role: 'dps' | 'tank' | 'healer';
  wowheadUrls: string[];
}

export interface ClassConfig {
  name: string;
  displayName: string;
  specs: SpecConfig[];
}
