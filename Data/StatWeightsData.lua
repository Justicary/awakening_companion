-- =========================================================================
-- Awakening Companion - Data/StatWeightsData.lua
-- Motor de Puntuación de Estadísticas (Stat Weights / Equivalency Points)
-- Basado en metodología de Sixty Upgrades & Classic BiS Weights
-- =========================================================================
local addonName, ns = ...
ns = ns or {}
ns.Data = ns.Data or {}

AwakeningData = AwakeningData or {}

-- -------------------------------------------------------------------------
-- PONDERACIONES DE ESTADÍSTICAS (STAT WEIGHTS / EP) POR CLASE Y SPEC
-- -------------------------------------------------------------------------
AwakeningData.StatWeights = {
    ["WARRIOR"] = {
        ["fury"] = {
            name = "Furia (DPS Dual/2H)",
            weights = {
                STR = 2.0, AGI = 1.4, AP = 1.0, CRIT = 14.0, HIT = 18.0,
                STA = 0.2, ARMOR = 0.05, WEAPON_DPS = 10.0,
            }
        },
        ["arms"] = {
            name = "Armas (PvE / PvP)",
            weights = {
                STR = 2.0, AGI = 1.3, AP = 1.0, CRIT = 15.0, HIT = 18.0,
                STA = 0.35, ARMOR = 0.05, WEAPON_DPS = 12.0,
            }
        },
        ["prot"] = {
            name = "Protección (Tanque)",
            weights = {
                DEFENSE = 2.5, STA = 2.0, ARMOR = 0.3, AGI = 1.0, STR = 0.8,
                BLOCK_VALUE = 0.6, BLOCK = 1.2, PARRY = 1.8, DODGE = 1.8, HIT = 8.0,
            }
        },
    },
    ["PALADIN"] = {
        ["retribution"] = {
            name = "Retribución (DPS)",
            weights = {
                STR = 2.0, AGI = 1.2, AP = 1.0, SPELL_DMG = 0.5, CRIT = 13.0, HIT = 16.0,
                STA = 0.3, INT = 0.4, WEAPON_DPS = 10.0,
            }
        },
        ["holy"] = {
            name = "Sagrado (Sanador)",
            weights = {
                HEAL = 1.0, SPELL_POWER = 1.0, INT = 0.7, MP5 = 3.5, SPIRIT = 0.4,
                SPELL_CRIT = 8.0, STA = 0.2,
            }
        },
        ["protection"] = {
            name = "Protección (Tanque)",
            weights = {
                STA = 2.0, ARMOR = 0.3, DEFENSE = 2.2, SPELL_DMG = 0.8,
                BLOCK_VALUE = 0.8, BLOCK = 1.5, DODGE = 1.6, PARRY = 1.6, STR = 0.6, INT = 0.4,
            }
        },
    },
    ["HUNTER"] = {
        ["marksman"] = {
            name = "Puntería (DPS)",
            weights = {
                AGI = 2.5, RAP = 1.0, AP = 0.5, CRIT = 14.0, HIT = 16.0,
                STA = 0.3, INT = 0.4, WEAPON_DPS = 14.0,
            }
        },
        ["bm"] = {
            name = "Dominio de Bestias (DPS)",
            weights = {
                AGI = 2.2, RAP = 1.0, AP = 0.6, CRIT = 12.0, HIT = 15.0,
                STA = 0.4, INT = 0.3, WEAPON_DPS = 12.0,
            }
        },
        ["surv"] = {
            name = "Supervivencia (DPS)",
            weights = {
                AGI = 2.7, RAP = 1.0, AP = 0.5, CRIT = 15.0, HIT = 16.0,
                STA = 0.4, INT = 0.3, WEAPON_DPS = 14.0,
            }
        },
    },
    ["ROGUE"] = {
        ["sword"] = {
            name = "Combate Espadas (DPS)",
            weights = {
                AGI = 2.0, STR = 1.1, AP = 1.0, CRIT = 13.0, HIT = 20.0,
                STA = 0.2, WEAPON_DPS = 11.0,
            }
        },
        ["dagger"] = {
            name = "Asesinato / Dagas (DPS)",
            weights = {
                AGI = 2.1, STR = 1.1, AP = 1.0, CRIT = 15.0, HIT = 18.0,
                STA = 0.2, WEAPON_DPS = 12.0,
            }
        },
        ["subtlety"] = {
            name = "Sutileza (PvP / DPS)",
            weights = {
                AGI = 2.2, AP = 1.0, STR = 1.0, CRIT = 14.0, HIT = 17.0,
                STA = 0.4, WEAPON_DPS = 11.0,
            }
        },
    },
    ["PRIEST"] = {
        ["holy"] = {
            name = "Sagrado (Sanador)",
            weights = {
                HEAL = 1.0, SPELL_POWER = 1.0, INT = 0.65, MP5 = 3.8, SPIRIT = 0.7,
                SPELL_CRIT = 6.0, STA = 0.2,
            }
        },
        ["shadow"] = {
            name = "Sombras (DPS)",
            weights = {
                SPELL_SHADOW = 1.0, SPELL_DMG = 1.0, SPELL_HIT = 14.0, SPELL_CRIT = 7.0,
                INT = 0.35, SPIRIT = 0.1, STA = 0.25, MP5 = 1.5,
            }
        },
        ["discipline"] = {
            name = "Disciplina (Soporte)",
            weights = {
                HEAL = 1.0, SPELL_POWER = 1.0, INT = 0.75, MP5 = 3.5, SPIRIT = 0.6,
                SPELL_CRIT = 7.0, STA = 0.3,
            }
        },
    },
    ["SHAMAN"] = {
        ["resto"] = {
            name = "Restauración (Sanador)",
            weights = {
                HEAL = 1.0, SPELL_POWER = 1.0, INT = 0.65, MP5 = 3.5, SPIRIT = 0.2,
                SPELL_CRIT = 7.5, STA = 0.2,
            }
        },
        ["elemental"] = {
            name = "Elemental (Cáster DPS)",
            weights = {
                SPELL_NATURE = 1.0, SPELL_DMG = 1.0, SPELL_HIT = 13.0, SPELL_CRIT = 9.0,
                INT = 0.5, MP5 = 2.0, STA = 0.25,
            }
        },
        ["enhancement"] = {
            name = "Mejora (DPS Melee)",
            weights = {
                STR = 2.0, AGI = 1.7, AP = 1.0, CRIT = 14.0, HIT = 16.0,
                SPELL_DMG = 0.4, INT = 0.4, STA = 0.3, WEAPON_DPS = 10.0,
            }
        },
    },
    ["MAGE"] = {
        ["frost"] = {
            name = "Escarcha (DPS Control)",
            weights = {
                SPELL_FROST = 1.0, SPELL_DMG = 1.0, SPELL_HIT = 12.0, SPELL_CRIT = 8.0,
                INT = 0.4, MP5 = 0.8, STA = 0.2,
            }
        },
        ["fire"] = {
            name = "Fuego (DPS Ráfaga)",
            weights = {
                SPELL_FIRE = 1.0, SPELL_DMG = 1.0, SPELL_HIT = 14.0, SPELL_CRIT = 10.0,
                INT = 0.4, MP5 = 0.8, STA = 0.2,
            }
        },
        ["arcane"] = {
            name = "Arcano (DPS / Utilidad)",
            weights = {
                SPELL_ARCANE = 1.0, SPELL_DMG = 1.0, SPELL_HIT = 11.0, SPELL_CRIT = 8.5,
                INT = 0.5, MP5 = 1.2, STA = 0.2,
            }
        },
    },
    ["WARLOCK"] = {
        ["affliction"] = {
            name = "Aflicción (DoTs / DPS)",
            weights = {
                SPELL_SHADOW = 1.0, SPELL_DMG = 1.0, SPELL_HIT = 14.0, SPELL_CRIT = 6.5,
                INT = 0.35, STA = 0.5, SPIRIT = 0.1, MP5 = 0.5,
            }
        },
        ["destruction"] = {
            name = "Destrucción (DPS Fuego)",
            weights = {
                SPELL_FIRE = 1.0, SPELL_SHADOW = 0.8, SPELL_DMG = 1.0, SPELL_HIT = 14.0, SPELL_CRIT = 9.0,
                INT = 0.4, STA = 0.4,
            }
        },
        ["demonology"] = {
            name = "Demonología (DPS)",
            weights = {
                SPELL_DMG = 1.0, STA = 0.7, INT = 0.4, SPELL_HIT = 12.0, SPELL_CRIT = 7.0,
            }
        },
    },
    ["DRUID"] = {
        ["feral_cat"] = {
            name = "Feral Felino (DPS)",
            weights = {
                AGI = 2.4, STR = 2.4, AP = 1.0, CRIT = 15.0, HIT = 18.0,
                STA = 0.3,
            }
        },
        ["feral_bear"] = {
            name = "Feral Oso (Tanque)",
            weights = {
                STA = 2.5, ARMOR = 0.6, AGI = 1.5, STR = 1.0, DODGE = 2.0,
                DEFENSE = 1.5, HIT = 8.0,
            }
        },
        ["resto"] = {
            name = "Restauración (Sanador)",
            weights = {
                HEAL = 1.0, SPELL_POWER = 1.0, INT = 0.6, MP5 = 3.5, SPIRIT = 0.6,
                SPELL_CRIT = 5.0, STA = 0.2,
            }
        },
        ["balance"] = {
            name = "Equilibrio (Pollo DPS)",
            weights = {
                SPELL_NATURE = 1.0, SPELL_ARCANE = 1.0, SPELL_DMG = 1.0, SPELL_HIT = 13.0,
                SPELL_CRIT = 8.5, INT = 0.5, MP5 = 1.5, STA = 0.25,
            }
        },
    },
}

-- Aliases para retrocompatibilidad
ns.Data.StatWeights = AwakeningData.StatWeights

-- -------------------------------------------------------------------------
-- MAPEO DE ATRIBUTOS DE LA API DE WOW A CLAVES INTERNAS
-- -------------------------------------------------------------------------
local STAT_KEY_MAP = {
    ["ITEM_MOD_STRENGTH_SHORT"] = "STR",
    ["ITEM_MOD_AGILITY_SHORT"] = "AGI",
    ["ITEM_MOD_STAMINA_SHORT"] = "STA",
    ["ITEM_MOD_INTELLECT_SHORT"] = "INT",
    ["ITEM_MOD_SPIRIT_SHORT"] = "SPIRIT",
    ["ITEM_MOD_ARMOR_SHORT"] = "ARMOR",
    ["ITEM_MOD_ATTACK_POWER_SHORT"] = "AP",
    ["ITEM_MOD_RANGED_ATTACK_POWER_SHORT"] = "RAP",
    ["ITEM_MOD_CRIT_RATING_SHORT"] = "CRIT",
    ["ITEM_MOD_CRIT_MELEE_RATING_SHORT"] = "CRIT",
    ["ITEM_MOD_CRIT_RANGED_RATING_SHORT"] = "CRIT",
    ["ITEM_MOD_CRIT_SPELL_RATING_SHORT"] = "SPELL_CRIT",
    ["ITEM_MOD_HIT_RATING_SHORT"] = "HIT",
    ["ITEM_MOD_HIT_MELEE_RATING_SHORT"] = "HIT",
    ["ITEM_MOD_HIT_RANGED_RATING_SHORT"] = "HIT",
    ["ITEM_MOD_HIT_SPELL_RATING_SHORT"] = "SPELL_HIT",
    ["ITEM_MOD_SPELL_POWER_SHORT"] = "SPELL_POWER",
    ["ITEM_MOD_SPELL_DAMAGE_DONE_SHORT"] = "SPELL_DMG",
    ["ITEM_MOD_SPELL_HEALING_DONE_SHORT"] = "HEAL",
    ["ITEM_MOD_DEFENSE_SKILL_RATING_SHORT"] = "DEFENSE",
    ["ITEM_MOD_DODGE_RATING_SHORT"] = "DODGE",
    ["ITEM_MOD_PARRY_RATING_SHORT"] = "PARRY",
    ["ITEM_MOD_BLOCK_RATING_SHORT"] = "BLOCK",
    ["ITEM_MOD_BLOCK_VALUE_SHORT"] = "BLOCK_VALUE",
    ["ITEM_MOD_MANA_REGENERATION_SHORT"] = "MP5",
}

-- -------------------------------------------------------------------------
-- NORMALIZACIÓN DE ESPECIALIZACIONES
-- -------------------------------------------------------------------------
local function NormalizeSpecKey(specKey)
    if not specKey then return nil end
    local s = tostring(specKey):lower():gsub("[_%s%-]", "")
    if s:find("holy") or s:find("sagrado") then return "holy" end
    if s:find("shadow") or s:find("sombra") then return "shadow" end
    if s:find("disc") then return "discipline" end
    if s:find("fury") or s:find("furia") then return "fury" end
    if s:find("arms") or s:find("armas") then return "arms" end
    if s:find("prot") or s:find("def") then return "prot" end
    if s:find("frost") or s:find("escarcha") then return "frost" end
    if s:find("fire") or s:find("fuego") then return "fire" end
    if s:find("arcane") or s:find("arcano") then return "arcane" end
    if s:find("afflict") or s:find("aflic") then return "affliction" end
    if s:find("destro") then return "destruction" end
    if s:find("demo") then return "demonology" end
    if s:find("ret") then return "retribution" end
    if s:find("resto") or s:find("restaur") then return "resto" end
    if s:find("ele") then return "elemental" end
    if s:find("enh") or s:find("mejora") then return "enhancement" end
    if s:find("bear") or s:find("oso") then return "feral_bear" end
    if s:find("feral") or s:find("cat") or s:find("gato") then return "feral_cat" end
    if s:find("balance") or s:find("equilibrio") or s:find("pollo") then return "balance" end
    if s:find("sword") or s:find("espada") or s:find("combat") then return "sword" end
    if s:find("dagger") or s:find("daga") or s:find("assassin") or s:find("asesin") then return "dagger" end
    if s:find("sub") or s:find("sutil") then return "subtlety" end
    if s:find("mark") or s:find("punter") then return "marksman" end
    if s:find("bm") or s:find("beast") or s:find("bestia") then return "bm" end
    if s:find("surv") or s:find("superv") then return "surv" end
    return s
end

-- -------------------------------------------------------------------------
-- PRIORIDADES DE ESTADÍSTICAS Y CAPS (LÍMITES) DE CLASE Y ESPECIALIZACIÓN
-- -------------------------------------------------------------------------
AwakeningData.SpecPrioritiesAndCaps = {
    ["PRIEST"] = {
        ["holy"] = {
            name = "Sagrado (Sanador)",
            priority = "Intelecto > Espíritu > Aguante",
            combatPriority = "Sanación > Intelecto > Espíritu > MP5 > Crítico",
            caps = "Sin Cap (Soft Cap: Regeneración / Regla 5s)",
            capsShort = "Sin Cap (Soft: Regen)",
            details = {
                "Sin Cap de Golpe: Las habilidades sanadoras nunca fallan sobre objetivos aliados.",
                "Regla de los 5 Segundos (FSR): El Espíritu otorga regeneración masiva de maná tras 5s sin lanzar hechizos.",
                "Intelecto: Amplía la reserva total de maná y probabilidad de golpe crítico sagrado.",
            }
        },
        ["shadow"] = {
            name = "Sombras (DPS)",
            priority = "Daño Sombras > Golpe > Crítico",
            combatPriority = "Daño Sombras > Golpe Hechizos > Crítico > Intelecto > Aguante",
            caps = "Cap Golpe Hechizos: 16% (6% con talentos)",
            capsShort = "Cap Golpe: 16% (6% talentos)",
            details = {
                "Cap de Golpe con Hechizos: 16% contra jefes Nv. 63 (1% siempre falla de forma innata).",
                "Talento 'Enfoque de las Sombras' (5/5): Reduce la necesidad de golpe en equipo a solo 6%.",
                "Poder con Sombras: Escala directamente el daño sostenido de DoTs (Palabra de las Sombras: Dolor).",
            }
        },
        ["discipline"] = {
            name = "Disciplina (Soporte)",
            priority = "Intelecto > Espíritu > Aguante",
            combatPriority = "Sanación > Intelecto > Espíritu > MP5 > Aguante",
            caps = "Sin Cap (Soft Cap: Regeneración)",
            capsShort = "Sin Cap (Soft: Regen)",
            details = {
                "Sin Cap de Golpe: Los escudos protectores y curaciones no pueden ser resistidos.",
                "Espíritu Divino: Otorga bonificaciones cruciales de regeneración para toda la banda.",
            }
        },
    },
    ["WARRIOR"] = {
        ["fury"] = {
            name = "Furia (DPS Dual)",
            priority = "Fuerza > Agilidad > Aguante",
            combatPriority = "Golpe > Crítico > Fuerza > AP > Agilidad",
            caps = "Cap Golpe: 9% (Amarillo) / 28% (Blanco)",
            capsShort = "Cap Golpe: 9% Esp / 28% Blanco",
            details = {
                "Cap Golpe Amarillo (Habilidades): 9% contra jefes Nv. 63 (8% con 305 en habilidad de armas).",
                "Cap Golpe Blanco (Dual Wield): 28% para eliminar fallos de autoataques que generan ira.",
                "Crítico: Activa Ráfaga (Flurry) otorgando +30% velocidad de ataque.",
            }
        },
        ["arms"] = {
            name = "Armas (DPS 2M)",
            priority = "Fuerza > Agilidad > Aguante",
            combatPriority = "Golpe > Crítico > Fuerza > AP > Aguante",
            caps = "Cap Golpe: 9% (Arma 2M)",
            capsShort = "Cap Golpe: 9%",
            details = {
                "Cap Golpe: 9% contra jefes Nv. 63 con armas de dos manos (8% con 305 en habilidad).",
                "Fuerza: Otorga 2 Poder de Ataque (AP) por punto.",
            }
        },
        ["prot"] = {
            name = "Protección (Tanque)",
            priority = "Aguante > Armadura > Defensa",
            combatPriority = "Defensa > Aguante > Armadura > Bloqueo > Golpe",
            caps = "Cap Defensa: 440 (Anticrítico) · Cap Golpe: 9%",
            capsShort = "Cap Defensa: 440 · Golpe: 9%",
            details = {
                "Cap de Defensa: 440 (140 en equipo) para inmunidad total a golpes críticos de jefes Nv. 63.",
                "Cap de Golpe: 9% para asegurar que Provocar (Taunt) y Venganza no fallen.",
                "Cobertura de Tabla (Crush Cap): 102.4% combinando Bloqueo con Escudo + Esquiva + Parada + Fallo.",
            }
        },
    },
    ["PALADIN"] = {
        ["holy"] = {
            name = "Sagrado (Sanador)",
            priority = "Intelecto > Espíritu > Aguante",
            combatPriority = "Sanación > Intelecto > Crítico Hechizos > MP5",
            caps = "Sin Cap (Soft Cap: Crítico para Iluminación)",
            capsShort = "Sin Cap (Soft: Crítico)",
            details = {
                "Sin Cap de Golpe: Las curaciones nunca fallan.",
                "Talento 'Iluminación': Los golpes críticos sanadores devuelven el 100% del coste de maná.",
            }
        },
        ["retribution"] = {
            name = "Retribución (DPS)",
            priority = "Fuerza > Agilidad > Intelecto > Aguante",
            combatPriority = "Golpe > Fuerza > Crítico > AP > Intelecto",
            caps = "Cap Golpe: 9% (Arma 2M)",
            capsShort = "Cap Golpe: 9%",
            details = {
                "Cap de Golpe: 9% contra jefes de banda Nv. 63 con armas de dos manos.",
                "Fuerza: Otorga 2 AP por punto.",
            }
        },
        ["protection"] = {
            name = "Protección (Tanque)",
            priority = "Aguante > Armadura > Defensa",
            combatPriority = "Defensa > Aguante > Armadura > Bloqueo > Poder Hechizos",
            caps = "Cap Defensa: 440 (Anticrítico) · Cap Golpe: 9%",
            capsShort = "Cap Defensa: 440 · Golpe: 9%",
            details = {
                "Cap de Defensa: 440 para evitar golpes críticos de jefes Nv. 63.",
                "Poder con Hechizos: Esencial para la generación de amenaza mediante Consagración y Furia Recta.",
            }
        },
    },
    ["ROGUE"] = {
        ["sword"] = {
            name = "Combate Espadas (DPS)",
            priority = "Agilidad > Fuerza > Aguante",
            combatPriority = "Golpe > Agilidad > Crítico > Fuerza > AP",
            caps = "Cap Golpe: 9% Especiales / 28% Dual Wield",
            capsShort = "Cap Golpe: 9% Esp / 28% Blanco",
            details = {
                "Cap Golpe Amarillo: 9% contra jefes Nv. 63 (con 5/5 Precisión solo requieres 4% en equipo).",
                "Cap Golpe Blanco: 28% para eliminar fallos de autoataques.",
                "Habilidad en Espadas: 305 reduce severamente la penalización de golpes de refilón (glancing blows).",
            }
        },
        ["dagger"] = {
            name = "Asesinato / Dagas (DPS)",
            priority = "Agilidad > Fuerza > Aguante",
            combatPriority = "Golpe > Agilidad > Crítico > Fuerza > AP",
            caps = "Cap Golpe: 9% Especiales / 28% Dual Wield",
            capsShort = "Cap Golpe: 9% Esp / 28% Blanco",
            details = {
                "Cap Golpe Amarillo: 9% contra jefes Nv. 63 (4% con talentos de combate).",
                "Crítico: Máxima prioridad tras el cap de golpe para Puñalada (Backstab).",
            }
        },
        ["subtlety"] = {
            name = "Sutileza (PvP / DPS)",
            priority = "Agilidad > AP > Aguante > Fuerza",
            combatPriority = "Golpe (5% PvP / 9% PvE) > Agilidad > AP > Crítico",
            caps = "Cap Golpe: 5% (PvP) / 9% (PvE)",
            capsShort = "Cap Golpe: 5% PvP / 9% PvE",
            details = {
                "PvP Hit Cap: 5% contra objetivos Nv. 60.",
                "Agilidad: Otorga armadura, crítico, esquiva y poder de ataque.",
            }
        },
    },
    ["MAGE"] = {
        ["frost"] = {
            name = "Escarcha (DPS)",
            priority = "Intelecto > Aguante > Espíritu",
            combatPriority = "Poder Escarcha > Golpe Hechizos > Crítico > Intelecto",
            caps = "Cap Golpe Hechizos: 16% (10% con Precisión Elemental)",
            capsShort = "Cap Golpe: 16% (10% con talentos)",
            details = {
                "Cap Golpe Hechizos: 16% contra jefes Nv. 63.",
                "Talento 'Precisión Elemental' (3/3): Otorga +6% de golpe con Escarcha/Fuego, reduciendo el cap a 10% en equipo.",
            }
        },
        ["fire"] = {
            name = "Fuego (DPS)",
            priority = "Intelecto > Aguante > Espíritu",
            combatPriority = "Poder Fuego > Golpe Hechizos > Crítico > Intelecto",
            caps = "Cap Golpe Hechizos: 16% (10% con Precisión Elemental)",
            capsShort = "Cap Golpe: 16% (10% con talentos)",
            details = {
                "Cap Golpe Hechizos: 16% contra jefes Nv. 63 (10% con talentos).",
                "Crítico con Fuego: Desencadena Ignición (Ignite) acumulable entre magos del grupo.",
            }
        },
        ["arcane"] = {
            name = "Arcano (DPS)",
            priority = "Intelecto > Aguante > Espíritu",
            combatPriority = "Poder Hechizos > Intelecto > Golpe Hechizos > Crítico",
            caps = "Cap Golpe Hechizos: 16%",
            capsShort = "Cap Golpe: 16%",
            details = {
                "Cap Golpe Hechizos: 16% contra jefes Nv. 63.",
                "Intelecto: Requerido para sostener el enorme gasto de maná de Poder Arcano y Misiles.",
            }
        },
    },
    ["WARLOCK"] = {
        ["affliction"] = {
            name = "Aflicción (DPS)",
            priority = "Intelecto > Aguante > Espíritu",
            combatPriority = "Daño Sombras > Golpe Hechizos > Aguante > Intelecto",
            caps = "Cap Golpe Hechizos: 16%",
            capsShort = "Cap Golpe: 16%",
            details = {
                "Cap Golpe Hechizos: 16% contra jefes Nv. 63.",
                "Aguante: Recurso de conversión directa a maná mediante Transfusión de Vida (Life Tap).",
            }
        },
        ["destruction"] = {
            name = "Destrucción (DPS)",
            priority = "Intelecto > Aguante > Espíritu",
            combatPriority = "Daño Sombras/Fuego > Golpe Hechizos > Crítico > Intelecto",
            caps = "Cap Golpe Hechizos: 16%",
            capsShort = "Cap Golpe: 16%",
            details = {
                "Cap Golpe Hechizos: 16% contra jefes Nv. 63.",
                "Crítico: Activa Ruina para un 100% de daño adicional en golpes críticos.",
            }
        },
        ["demonology"] = {
            name = "Demonología (DPS)",
            priority = "Aguante > Intelecto > Espíritu",
            combatPriority = "Poder Hechizos > Aguante > Intelecto > Golpe Hechizos",
            caps = "Cap Golpe Hechizos: 16%",
            capsShort = "Cap Golpe: 16%",
            details = {
                "Cap Golpe Hechizos: 16% contra jefes Nv. 63.",
                "Aguante: Mitigación masiva y transferencia de daño mediante Enlace de Alma (Soul Link).",
            }
        },
    },
    ["HUNTER"] = {
        ["marksman"] = {
            name = "Puntería (DPS)",
            priority = "Agilidad > Intelecto > Aguante",
            combatPriority = "Golpe > Agilidad > RAP > Crítico > Intelecto",
            caps = "Cap Golpe: 9% (6% con Puntería Certera)",
            capsShort = "Cap Golpe: 9% (6% con talentos)",
            details = {
                "Cap de Golpe a Distancia: 9% contra jefes Nv. 63.",
                "Talento 'Puntería Certera' (3/3): Otorga +3% de golpe, reduciendo el cap de equipo a 6%.",
            }
        },
        ["bm"] = {
            name = "Bestias (DPS)",
            priority = "Agilidad > Aguante > Intelecto",
            combatPriority = "Golpe > Agilidad > RAP > AP > Aguante",
            caps = "Cap Golpe: 9% (6% con talentos)",
            capsShort = "Cap Golpe: 9% (6% con talentos)",
            details = {
                "Cap de Golpe: 9% contra jefes Nv. 63 (6% con Puntería Certera).",
            }
        },
        ["surv"] = {
            name = "Supervivencia (DPS)",
            priority = "Agilidad > Aguante > Intelecto",
            combatPriority = "Golpe > Agilidad > RAP > Crítico",
            caps = "Cap Golpe: 9% (6% con talentos)",
            capsShort = "Cap Golpe: 9% (6% con talentos)",
            details = {
                "Cap de Golpe: 9% contra jefes Nv. 63.",
                "Agilidad: Otorga probabilidad de crítico a distancia y armadura.",
            }
        },
    },
    ["DRUID"] = {
        ["resto"] = {
            name = "Restauración (Sanador)",
            priority = "Intelecto > Espíritu > Aguante",
            combatPriority = "Sanación > Intelecto > Espíritu > MP5",
            caps = "Sin Cap (Soft Cap: Espíritu / Regla 5s)",
            capsShort = "Sin Cap (Soft: Regen)",
            details = {
                "Sin Cap de Golpe: Las curaciones nunca fallan.",
                "Espíritu: Máximo rendimiento bajo el talento de Intensidad (regeneración durante el lanzamiento).",
            }
        },
        ["feral_cat"] = {
            name = "Feral Felino (DPS)",
            priority = "Fuerza > Agilidad > Aguante",
            combatPriority = "Golpe > Fuerza > Agilidad > Crítico > AP",
            caps = "Cap Golpe: 9%",
            capsShort = "Cap Golpe: 9%",
            details = {
                "Cap de Golpe: 9% contra jefes Nv. 63.",
                "Fuerza: Otorga 2 AP por punto en forma felina.",
            }
        },
        ["feral_bear"] = {
            name = "Feral Oso (Tanque)",
            priority = "Aguante > Armadura > Defensa",
            combatPriority = "Armadura > Aguante > Defensa > Esquiva > Golpe",
            caps = "Cap Defensa: 440 · Cap Armadura: 75%",
            capsShort = "Cap Defensa: 440 · Armadura: 75%",
            details = {
                "Cap de Armadura: 75% reducción física (17,265 armadura contra jefes Nv. 63).",
                "Cap de Defensa: 440 para evitar golpes críticos de jefes de banda.",
            }
        },
        ["balance"] = {
            name = "Equilibrio (DPS)",
            priority = "Intelecto > Aguante > Espíritu",
            combatPriority = "Poder Hechizos > Golpe Hechizos > Crítico > Intelecto",
            caps = "Cap Golpe Hechizos: 16%",
            capsShort = "Cap Golpe: 16%",
            details = {
                "Cap Golpe Hechizos: 16% contra jefes Nv. 63.",
                "Intelecto: Requerido para sostener el alto coste de Fuego Estelar y Cólera.",
            }
        },
    },
    ["SHAMAN"] = {
        ["resto"] = {
            name = "Restauración (Sanador)",
            priority = "Intelecto > Espíritu > Aguante",
            combatPriority = "Sanación > MP5 > Intelecto > Crítico Hechizos",
            caps = "Sin Cap (Soft Cap: MP5)",
            capsShort = "Sin Cap (Soft: MP5)",
            details = {
                "Sin Cap de Golpe: Las sanaciones nunca fallan.",
                "MP5: El maná pasivo cada 5 segundos es superior al espíritu debido a los constantes lanzamientos de Sanación en Cadena.",
            }
        },
        ["elemental"] = {
            name = "Elemental (DPS)",
            priority = "Intelecto > Aguante > Espíritu",
            combatPriority = "Poder Naturaleza > Golpe Hechizos > Crítico > Intelecto",
            caps = "Cap Golpe Hechizos: 16%",
            capsShort = "Cap Golpe: 16%",
            details = {
                "Cap Golpe Hechizos: 16% contra jefes Nv. 63.",
                "Crítico con Naturaleza: Sinergia con Maestría Elemental.",
            }
        },
        ["enhancement"] = {
            name = "Mejora (DPS Melee)",
            priority = "Fuerza > Agilidad > Aguante",
            combatPriority = "Golpe > Fuerza > Agilidad > Crítico > AP",
            caps = "Cap Golpe: 9% (Arma 2M)",
            capsShort = "Cap Golpe: 9%",
            details = {
                "Cap de Golpe: 9% con armas de dos manos contra jefes Nv. 63.",
                "Fuerza y Agilidad: Escalado principal de Viento Furioso (Windfury).",
            }
        },
    },
}

-- -------------------------------------------------------------------------
-- FUNCIONES DEL MOTOR DE PUNTUACIÓN (STAT WEIGHTS ENGINE)
-- -------------------------------------------------------------------------

--- Obtiene la información de prioridad de estadísticas y caps para una clase y especialización
-- @param classKey string (opcional)
-- @param specKey string (opcional)
-- @return table info ({ priority, combatPriority, caps, capsShort, details, name })
function ns.GetSpecPriorityAndCaps(classKey, specKey)
    local _, playerClass = UnitClass("player")
    classKey = (classKey or playerClass or "WARRIOR"):upper()

    local classCaps = AwakeningData.SpecPrioritiesAndCaps[classKey] or AwakeningData.SpecPrioritiesAndCaps["WARRIOR"]
    if not classCaps then return nil end

    local normSpec = NormalizeSpecKey(specKey)
    if normSpec and classCaps[normSpec] then
        return classCaps[normSpec]
    end

    if normSpec == "prot" and classCaps["protection"] then
        return classCaps["protection"]
    elseif normSpec == "protection" and classCaps["prot"] then
        return classCaps["prot"]
    end

    if specKey and classCaps[specKey] then
        return classCaps[specKey]
    end

    -- Buscar la spec predeterminada de la clase si no se especificó o no se encontró
    local defSpec = ns.GetClassDefaultEnchantSpec and ns.GetClassDefaultEnchantSpec(classKey)
    local normDef = NormalizeSpecKey(defSpec)
    if normDef and classCaps[normDef] then
        return classCaps[normDef]
    end

    -- Fallback a la primera spec disponible de la clase
    for _, sData in pairs(classCaps) do
        return sData
    end
    return nil
end

--- Genera el texto formateado para el subtítulo dinámico del marco principal
-- @param classKey string (opcional)
-- @param specKey string (opcional)
-- @return string subtitleText
function ns.GetSpecSubtitle(classKey, specKey)
    local info = ns.GetSpecPriorityAndCaps(classKey, specKey)
    if not info then
        return "WoW Classic Forever · Servidor Activo"
    end
    local pStr = info.priority or "Atributos Primarios"
    local cStr = info.capsShort or info.caps or "Sin Cap"
    return string.format("|cFF00FFCC%s|r  ·  |cFFFFAA00%s|r", pStr, cStr)
end

--- Muestra el tooltip detallado de Stat Weights y Caps al pasar el ratón sobre el subtítulo
-- @param anchorFrame Frame
-- @param classKey string (opcional)
-- @param specKey string (opcional)
function ns.ShowStatWeightsTooltip(anchorFrame, classKey, specKey)
    if not anchorFrame then return end
    local info = ns.GetSpecPriorityAndCaps(classKey, specKey)
    if not info then return end

    local _, playerClass = UnitClass("player")
    classKey = (classKey or playerClass or "WARRIOR"):upper()

    GameTooltip:SetOwner(anchorFrame, "ANCHOR_BOTTOMLEFT", 0, -4)
    GameTooltip:ClearLines()

    local title = string.format("%s · %s", classKey, info.name or "Especialización")
    GameTooltip:AddLine("|cFFFFD100" .. title .. "|r", 1, 1, 1)
    GameTooltip:AddLine(" ")

    GameTooltip:AddDoubleLine(
        "|cFF00FFCCPrioridad Primaria:|r",
        string.format("|cFFFFFFFF%s|r", info.priority or "N/D")
    )
    if info.combatPriority then
        GameTooltip:AddDoubleLine(
            "|cFF00FFCCPrioridad Combate:|r",
            string.format("|cFFFFFFFF%s|r", info.combatPriority)
        )
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cFFFFAA00Límites (Caps) en WoW Classic:|r", 1, 0.82, 0)
    if info.details then
        for _, line in ipairs(info.details) do
            GameTooltip:AddLine("• |cFFFFFFFF" .. line .. "|r", 0.9, 0.9, 0.9, true)
        end
    end

    -- Ponderaciones numéricas de estadísticas (Stat Weights / EP)
    local weights = ns.GetStatWeights(classKey, specKey)
    if weights then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFF88DDFFPonderaciones Numéricas (Stat Weights / EP):|r", 0.5, 0.85, 1)
        local sorted = {}
        for k, v in pairs(weights) do
            table.insert(sorted, { key = k, val = v })
        end
        table.sort(sorted, function(a, b) return a.val > b.val end)

        local count = 0
        for _, entry in ipairs(sorted) do
            if count < 6 and entry.val > 0 then
                count = count + 1
                local statName = entry.key
                if entry.key == "HEAL" then statName = "+Sanación"
                elseif entry.key == "SPELL_POWER" or entry.key == "SPELL_DMG" then statName = "Poder con Hechizos"
                elseif entry.key == "SPELL_SHADOW" then statName = "Daño Sombras"
                elseif entry.key == "SPELL_FIRE" then statName = "Daño Fuego"
                elseif entry.key == "SPELL_FROST" then statName = "Daño Escarcha"
                elseif entry.key == "SPELL_NATURE" then statName = "Daño Naturaleza"
                elseif entry.key == "SPELL_ARCANE" then statName = "Daño Arcano"
                elseif entry.key == "SPELL_HIT" then statName = "% Golpe Hechizos"
                elseif entry.key == "SPELL_CRIT" then statName = "% Crítico Hechizos"
                elseif entry.key == "HIT" then statName = "% Golpe Físico"
                elseif entry.key == "CRIT" then statName = "% Crítico Físico"
                elseif entry.key == "STR" then statName = "Fuerza"
                elseif entry.key == "AGI" then statName = "Agilidad"
                elseif entry.key == "STA" then statName = "Aguante"
                elseif entry.key == "INT" then statName = "Intelecto"
                elseif entry.key == "SPIRIT" then statName = "Espíritu"
                elseif entry.key == "MP5" then statName = "Maná / 5 seg (MP5)"
                elseif entry.key == "DEFENSE" then statName = "Defensa"
                elseif entry.key == "ARMOR" then statName = "Armadura"
                elseif entry.key == "AP" or entry.key == "RAP" then statName = "Poder de Ataque"
                end
                GameTooltip:AddDoubleLine(
                    "  1 " .. statName,
                    string.format("|cFFFFD100%.2f EP|r", entry.val)
                )
            end
        end
    end

    -- Fuente de la Verdad activa
    if ns.Provider and ns.Provider.GetSourceOfTruth then
        local _, sotName = ns.Provider:GetSourceOfTruth()
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("|cFF888888Fuente de la Verdad BiS (SOT):|r", "|cFF00FF00" .. (sotName or "Local") .. "|r")
    end

    GameTooltip:Show()
end

--- Obtiene la tabla de pesos para una clase y especialización
function ns.GetStatWeights(classKeyOrSpec, maybeSpecKey)
    local classKey, specKey
    local _, playerClass = UnitClass("player")
    playerClass = (playerClass or "WARRIOR"):upper()

    if maybeSpecKey then
        classKey = (classKeyOrSpec or playerClass):upper()
        specKey = maybeSpecKey
    elseif classKeyOrSpec and AwakeningData.StatWeights[classKeyOrSpec:upper()] then
        classKey = classKeyOrSpec:upper()
        specKey = nil
    else
        classKey = playerClass
        specKey = classKeyOrSpec
    end

    local classTable = AwakeningData.StatWeights[classKey] or AwakeningData.StatWeights["WARRIOR"]
    if not classTable then return nil end

    local normSpec = NormalizeSpecKey(specKey)
    if normSpec and classTable[normSpec] then
        return classTable[normSpec].weights, classTable[normSpec].name
    end
    if normSpec == "prot" and classTable["protection"] then
        return classTable["protection"].weights, classTable["protection"].name
    elseif normSpec == "protection" and classTable["prot"] then
        return classTable["prot"].weights, classTable["prot"].name
    end

    if specKey and classTable[specKey] then
        return classTable[specKey].weights, classTable[specKey].name
    end

    -- Tomar la primera spec disponible
    for sKey, sData in pairs(classTable) do
        return sData.weights, sData.name
    end
    return nil, nil
end

--- Calcula la puntuación numérica (Item Score / EP) de un objeto
-- @param itemLinkOrID string|number
-- @param classKeyOrSpec string (opcional)
-- @param maybeSpecKey string (opcional)
-- @return number Score total del objeto
function ns.GetItemScore(itemLinkOrID, classKeyOrSpec, maybeSpecKey)
    if not itemLinkOrID or itemLinkOrID == 0 then return 0 end

    local weights = ns.GetStatWeights(classKeyOrSpec, maybeSpecKey)
    if not weights then return 0 end

    local score = 0

    -- Convertir identificador a itemLink o formato "item:ID" que GetItemStats reconoce nativamente
    local itemQuery = itemLinkOrID
    local itemLevel, itemQuality, itemEquipLoc
    if GetItemInfo then
        local _, link, q, lvl, _, _, _, _, eqLoc = GetItemInfo(itemLinkOrID)
        if link then
            itemQuery = link
        end
        itemLevel = lvl
        itemQuality = q
        itemEquipLoc = eqLoc
    end

    if type(itemQuery) == "number" or (type(itemQuery) == "string" and tonumber(itemQuery)) then
        itemQuery = "item:" .. itemQuery
    end

    -- 1. Intentar obtener atributos a través de GetItemStats nativo
    local stats = GetItemStats and GetItemStats(itemQuery)
    if stats then
        for statConst, val in pairs(stats) do
            local mappedKey = STAT_KEY_MAP[statConst]
            if mappedKey and weights[mappedKey] then
                score = score + (val * weights[mappedKey])
            end
        end
    end

    -- 2. Si el objeto no tiene stats explícitos y es equipo blanco/gris (calidad <= 1),
    -- su valor radica en su nivel de objeto (iLvl) básico para tramos iniciales 1-10.
    -- NUNCA inflar objetos mágicos (verde/azul/épico) que tienen estadísticas inapropiadas para la especialización.
    if score == 0 and itemLevel and itemLevel > 0 and (not itemQuality or itemQuality <= 1) then
        score = itemLevel * 0.5
    end

    return math.floor(score * 10) / 10
end

--- Mapea nombres de ranuras de interfaz a ranuras de inventario de WoW
local SLOT_TO_INVENTORY_ID = {
    ["Head"]          = 1,
    ["Neck"]          = 2,
    ["Shoulder"]      = 3,
    ["Back"]          = 15,
    ["Chest"]         = 5,
    ["Wrists"]        = 9,
    ["Hands"]         = 10,
    ["Waist"]         = 6,
    ["Legs"]          = 7,
    ["Feet"]          = 8,
    ["Finger"]        = 11,
    ["RFinger"]       = 12,
    ["Trinket"]       = 13,
    ["RTrinket"]      = 14,
    ["MainHand"]      = 16,
    ["SecondaryHand"] = 17,
    ["Relic"]         = 18,
}

--- Mapea tipo de ranura de GetItemInfo a ranura de Awakening
local EQUIPLOC_TO_SLOT = {
    ["INVTYPE_HEAD"]           = "Head",
    ["INVTYPE_NECK"]           = "Neck",
    ["INVTYPE_SHOULDER"]       = "Shoulder",
    ["INVTYPE_CLOAK"]          = "Back",
    ["INVTYPE_CHEST"]          = "Chest",
    ["INVTYPE_ROBE"]           = "Chest",
    ["INVTYPE_WRIST"]          = "Wrists",
    ["INVTYPE_HAND"]           = "Hands",
    ["INVTYPE_WAIST"]          = "Waist",
    ["INVTYPE_LEGS"]           = "Legs",
    ["INVTYPE_FEET"]           = "Feet",
    ["INVTYPE_FINGER"]         = "Finger",
    ["INVTYPE_TRINKET"]        = "Trinket",
    ["INVTYPE_WEAPON"]         = "MainHand",
    ["INVTYPE_SHIELD"]         = "SecondaryHand",
    ["INVTYPE_2HWEAPON"]       = "MainHand",
    ["INVTYPE_WEAPONMAINHAND"] = "MainHand",
    ["INVTYPE_WEAPONOFFHAND"]  = "SecondaryHand",
    ["INVTYPE_HOLDABLE"]       = "SecondaryHand",
    ["INVTYPE_RANGED"]         = "Relic",
    ["INVTYPE_THROWN"]         = "Relic",
    ["INVTYPE_RANGEDRIGHT"]    = "Relic",
    ["INVTYPE_RELIC"]          = "Relic",
}

--- Compara un objeto candidato con el objeto actualmente equipado en esa ranura
-- @param slotName string Ranura (ej: "Head", "Chest", "MainHand")
-- @param candidateItemID number|string ID o enlace del objeto a evaluar
-- @param classKeyOrSpec string (opcional)
-- @param maybeSpecKey string (opcional)
-- @return number upgradePct Porcentaje de mejora (+25.4%)
-- @return number diff Diferencia en puntos de score
-- @return number candidateScore Score del nuevo objeto
-- @return number equippedScore Score del objeto equipado
function ns.GetSlotUpgrade(slotName, candidateItemID, classKeyOrSpec, maybeSpecKey)
    if not candidateItemID or candidateItemID == 0 then return 0, 0, 0, 0 end

    local invSlotID = SLOT_TO_INVENTORY_ID[slotName] or 0
    local equippedItemID = 0

    if invSlotID > 0 and GetInventoryItemID then
        local ok, id = pcall(GetInventoryItemID, "player", invSlotID)
        if ok and id then
            equippedItemID = id
        end
    end

    local candidateScore = ns.GetItemScore(candidateItemID, classKeyOrSpec, maybeSpecKey)
    local equippedScore = equippedItemID > 0 and ns.GetItemScore(equippedItemID, classKeyOrSpec, maybeSpecKey) or 0

    local diff = candidateScore - equippedScore
    local upgradePct = 0

    if equippedScore > 0 then
        upgradePct = (diff / equippedScore) * 100
    elseif candidateScore > 0 then
        upgradePct = 100 -- Ranura vacía = 100% de mejora directa
    end

    upgradePct = math.floor(upgradePct * 10) / 10
    return upgradePct, diff, candidateScore, equippedScore
end

--- Formatea el texto de mejora con código de colores para la UI
function ns.FormatUpgradeText(upgradePct)
    if upgradePct > 0 then
        return string.format("|cFF00FF00+%.1f%% Mejora|r", upgradePct)
    elseif upgradePct == 0 then
        return "|cFF888888Equivalente|r"
    else
        return string.format("|cFFFF4040%.1f%% Inferior|r", upgradePct)
    end
end

--- Abre o busca un objeto en AtlasLoot Classic si está instalado
function ns.OpenInAtlasLoot(itemName, itemID)
    if not _G.AtlasLoot then return false end

    -- Limpiar texto enriquecido de WoW para la búsqueda
    local cleanName = itemName or ""
    if type(cleanName) == "string" then
        cleanName = cleanName:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("%[", ""):gsub("%]", ""):gsub("^%s*(.-)%s*$", "%1")
    end

    if _G.AtlasLoot.SlashCommands and cleanName ~= "" then
        pcall(function()
            _G.AtlasLoot.SlashCommands:Run("search " .. cleanName)
        end)
        return true
    end

    if _G.AtlasLoot.GUI and _G.AtlasLoot.GUI.Toggle then
        pcall(function() _G.AtlasLoot.GUI:Toggle() end)
        return true
    end

    return false
end

-- -------------------------------------------------------------------------
-- INTEGRACIÓN CON TOOLTIPS (Soporte Universal para WoW Forever & Classic)
-- -------------------------------------------------------------------------
local function ProcessTooltipItem(selfTooltip, itemLinkOrID)
    if not selfTooltip then return end
    if not itemLinkOrID and selfTooltip.GetItem then
        local _, link = selfTooltip:GetItem()
        itemLinkOrID = link
    end
    if not itemLinkOrID then return end

    local playerClass = select(2, UnitClass("player")) or "WARRIOR"
    local specKey = ns.GetClassDefaultEnchantSpec and ns.GetClassDefaultEnchantSpec(playerClass)
    local weights, specDisplayName = ns.GetStatWeights(playerClass, specKey)

    -- Extraer ranura equipable
    local itemEquipLoc
    if GetItemInfo then
        local _, _, _, _, _, _, _, _, eqLoc = GetItemInfo(itemLinkOrID)
        itemEquipLoc = eqLoc
    end
    if not itemEquipLoc or itemEquipLoc == "" or itemEquipLoc == "INVTYPE_NON_EQUIP" then
        return
    end

    local score = ns.GetItemScore(itemLinkOrID, playerClass, specKey)
    if score and score > 0 then
        selfTooltip:AddLine(" ")
        selfTooltip:AddDoubleLine(
            "|cFF00FFCCAwakening Score:|r",
            string.format("|cFFFFD100%.1f pts|r |cFF888888(%s)|r", score, specDisplayName or "General")
        )

        local slotName = EQUIPLOC_TO_SLOT[itemEquipLoc]
        if slotName and ns.GetSlotUpgrade then
            local pctUpgrade, _, _, eqScore = ns.GetSlotUpgrade(slotName, itemLinkOrID, playerClass, specKey)
            if pctUpgrade and pctUpgrade > 0 then
                selfTooltip:AddDoubleLine(
                    "|cFF00FF00->Mejora estimada:|r",
                    string.format("|cFF00FF00+%.1f%%|r |cFF888888(vs actual %.1f)|r", pctUpgrade, eqScore or 0)
                )
            end
        end

        if _G.AtlasLoot then
            selfTooltip:AddLine("|cFF00FFCCAlt+Clic:|r Buscar en AtlasLoot Classic", 0.5, 0.8, 1)
        end

        selfTooltip:Show()
    end
end

pcall(function()
    -- 1. WoW Forever / Classic 1.15+ (TooltipDataProcessor oficial de Blizzard)
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tt, data)
            if tt and data then
                local item = data.hyperlink or data.id
                ProcessTooltipItem(tt, item)
            end
        end)
        return
    end

    -- 2. WoW Classic Legacy (HookScript seguro comprobando HasScript primero)
    if GameTooltip and GameTooltip.HasScript and GameTooltip:HasScript("OnTooltipSetItem") and GameTooltip.HookScript then
        GameTooltip:HookScript("OnTooltipSetItem", function(selfTooltip)
            ProcessTooltipItem(selfTooltip, nil)
        end)
    end
end)
