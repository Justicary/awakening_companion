import sys

target = sys.argv[1] if len(sys.argv) > 1 else 'Modules/SkillsUI.lua'

with open(target, 'r', encoding='utf-8') as f:
    text = f.read()

stack = []
pairs = {')': '(', ']': '[', '}': '{'}
in_string = False
str_char = None
in_comment = False

lines = text.split('\n')
for line_idx, line in enumerate(lines, 1):
    i = 0
    while i < len(line):
        if in_comment:
            if line[i:i+2] == ']]':
                in_comment = False
                i += 2
                continue
            i += 1
            continue
        if in_string:
            if line[i] == '\\':
                i += 2
                continue
            if line[i] == str_char:
                in_string = False
            i += 1
            continue
        if line[i:i+4] == '--[[':
            in_comment = True
            i += 4
            continue
        if line[i:i+2] == '--':
            break # line comment
        ch = line[i]
        if ch in ('"', "'"):
            in_string = True
            str_char = ch
        elif ch in ('(', '[', '{'):
            stack.append((ch, line_idx, i+1))
        elif ch in (')', ']', '}'):
            if not stack:
                print(f'Unmatched {ch} at line {line_idx}:{i+1}')
                sys.exit(1)
            last, l_idx, c_idx = stack.pop()
            if pairs[ch] != last:
                print(f'Mismatched {last} (line {l_idx}) with {ch} at line {line_idx}:{i+1}')
                sys.exit(1)
        i += 1

if stack:
    print(f'Unclosed {stack[-1]}')
    sys.exit(1)
print(f'VALIDATION SUCCESS: {target} is syntactically valid!')
