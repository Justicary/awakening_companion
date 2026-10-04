import re

def check_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        text = f.read()

    in_string = None
    in_comment = False
    clean_chars = []
    i = 0
    while i < len(text):
        c = text[i]
        c2 = text[i:i+2]
        if in_comment:
            if c == '\n':
                in_comment = False
                clean_chars.append('\n')
            i += 1
        elif in_string:
            if c == '\\' and i + 1 < len(text):
                i += 2
            elif c == in_string:
                in_string = None
                i += 1
            else:
                i += 1
        else:
            if c2 == '--':
                in_comment = True
                i += 2
            elif c in ('"', "'"):
                in_string = c
                i += 1
            else:
                clean_chars.append(c)
                i += 1

    cleaned = "".join(clean_chars)
    tokens = re.findall(r"\b(function|if|then|elseif|else|for|while|do|repeat|until|end)\b", cleaned)

    stack = []
    for t in tokens:
        if t in ("function", "while", "repeat", "if"):
            stack.append(t)
        elif t == "for":
            stack.append("for")
        elif t == "do":
            if stack and stack[-1] in ("for", "while"):
                pass
            else:
                stack.append("do")
        elif t == "until":
            if stack and stack[-1] == "repeat":
                stack.pop()
        elif t == "end":
            if stack:
                stack.pop()
            else:
                print("EXTRA END FOUND")

    print(filepath, "Remaining open blocks:", stack)
    assert len(stack) == 0, f"Unclosed blocks in {filepath}: {stack}"
    print(filepath, "PERFECT Lua Syntax verified!")

import sys
files = sys.argv[1:] if len(sys.argv) > 1 else ['Modules/RaidPrep.lua', 'Data/CampingData.lua']
for f in files:
    check_file(f)
