import os
import re

CLASSES = ["Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior"]
CLASS_TOKENS = {
    "Druid": "DRUID",
    "Hunter": "HUNTER",
    "Mage": "MAGE",
    "Paladin": "PALADIN",
    "Priest": "PRIEST",
    "Rogue": "ROGUE",
    "Shaman": "SHAMAN",
    "Warlock": "WARLOCK",
    "Warrior": "WARRIOR",
}

def parse_class_file(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Find the overridden spells call
    # wt:AddOverriddenSpells(...)
    overridden_match = re.search(r"wt:AddOverriddenSpells\s*\((.*?)\)", content, re.DOTALL)
    overridden_vars = []
    if overridden_match:
        vars_str = overridden_match.group(1)
        # extract variable names
        overridden_vars = [v.strip() for v in re.split(r"[,\s\n\r]+", vars_str) if v.strip()]

    # Extract variable definitions before wt:AddOverriddenSpells
    # e.g. local battleShout = {6673, 5242, 6192, 11549, 11550, 11551}
    var_definitions = {}
    for var_name in overridden_vars:
        pattern = rf"local\s+{var_name}\s*=\s*\{{([^}}]+)\}}"
        m = re.search(pattern, content)
        if m:
            ids_str = m.group(1)
            ids = [int(x.strip()) for x in ids_str.split(",") if x.strip().isdigit()]
            var_definitions[var_name] = ids

    # Extract wt.SpellsByLevel = ...
    # It might be `wt.SpellsByLevel = { ... }` or `wt.SpellsByLevel = wt.FactionFilter({ ... })`
    # Let's find the table inside
    spells_match = re.search(r"wt\.SpellsByLevel\s*=\s*(?:wt\.(?:FactionFilter|RaceFilter)\s*\()?\s*(\{.*)", content, re.DOTALL)
    if not spells_match:
        print(f"Could not find SpellsByLevel in {file_path}")
        return var_definitions, ""

    table_content = spells_match.group(1)
    # If it ends with `)\n` or `\n)` remove trailing parenthesis
    # Let's cleanly balance braces for the outer table `{ ... }`
    brace_depth = 0
    end_idx = 0
    for idx, ch in enumerate(table_content):
        if ch == '{':
            brace_depth += 1
        elif ch == '}':
            brace_depth -= 1
            if brace_depth == 0:
                end_idx = idx + 1
                break

    clean_table = table_content[:end_idx]
    return var_definitions, clean_table

def main():
    base_dir = "scratch_camelot"
    out_lines = []
    out_lines.append("-- Data/SkillsData.lua")
    out_lines.append("-- Extraído canónicamente y optimizado desde WhatsTraining Forever (Camelot 1.16+)")
    out_lines.append("local ADDON, ns = ...")
    out_lines.append("ns.Data = ns.Data or {}")
    out_lines.append("")
    out_lines.append("ns.Data.ClassSkills = {}")
    out_lines.append("")

    for cls_name in CLASSES:
        token = CLASS_TOKENS[cls_name]
        path = os.path.join(base_dir, f"{cls_name}.lua")
        if not os.path.exists(path):
            print(f"Missing {path}")
            continue

        var_defs, table_code = parse_class_file(path)
        out_lines.append(f"-- =========================================================================")
        out_lines.append(f"-- HABILIDADES: {token}")
        out_lines.append(f"-- =========================================================================")
        out_lines.append(f"ns.Data.ClassSkills[\"{token}\"] = {{")
        out_lines.append("    overriddenSpells = {")
        for vname, id_list in var_defs.items():
            out_lines.append(f"        {{{', '.join(str(x) for x in id_list)}}}, -- {vname}")
        out_lines.append("    },")
        out_lines.append(f"    spellsByLevel = {table_code}")
        out_lines.append("}")
        out_lines.append("")

    with open("scratch/generated_skills.lua", "w", encoding="utf-8") as f:
        f.write("\n".join(out_lines))
    print("Done! Wrote scratch/generated_skills.lua")

if __name__ == "__main__":
    main()
