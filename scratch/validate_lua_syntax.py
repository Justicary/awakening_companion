import sys
import re

def check_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')
    
    clean_lines = []
    in_block_comment = False
    
    for i, line in enumerate(lines, 1):
        l = line
        if in_block_comment:
            if ']]' in l:
                l = l[l.index(']]') + 2:]
                in_block_comment = False
            else:
                clean_lines.append((i, ''))
                continue
        while '--[[' in l:
            start = l.index('--[[')
            if ']]' in l[start+4:]:
                end = l.index(']]', start+4)
                l = l[:start] + l[end+2:]
            else:
                l = l[:start]
                in_block_comment = True
                break
        if '--' in l and not in_block_comment:
            idx = 0
            in_str = None
            comment_pos = None
            while idx < len(l):
                ch = l[idx]
                if in_str:
                    if ch == '\\':
                        idx += 1
                    elif ch == in_str:
                        in_str = None
                else:
                    if ch in ("'", '"'):
                        in_str = ch
                    elif ch == '-' and idx + 1 < len(l) and l[idx+1] == '-':
                        comment_pos = idx
                        break
                idx += 1
            if comment_pos is not None:
                l = l[:comment_pos]
        clean_lines.append((i, l))

    delimiter_stack = []
    block_stack = [] # ('if', line), ('do', line), ('function', line), ('repeat', line)
    
    # Tokens to match
    token_re = re.compile(r'\b(if|elseif|else|then|do|while|for|function|repeat|until|end)\b')
    
    for line_num, l in clean_lines:
        s = ''
        idx = 0
        in_str = None
        while idx < len(l):
            ch = l[idx]
            if in_str:
                if ch == '\\':
                    idx += 2
                    continue
                elif ch == in_str:
                    in_str = None
            else:
                if ch in ("'", '"'):
                    in_str = ch
                else:
                    s += ch
            idx += 1
            
        for ch in s:
            if ch in '({[':
                delimiter_stack.append((ch, line_num))
            elif ch in ')}]':
                if not delimiter_stack:
                    print(f"Error in {path}:{line_num}: Unexpected closing '{ch}'")
                    return False
                top, top_line = delimiter_stack.pop()
                expected = {'(': ')', '{': '}', '[': ']'}[top]
                if ch != expected:
                    print(f"Error in {path}:{line_num}: Mismatched '{ch}', expected '{expected}' (opened at line {top_line})")
                    return False
                    
        # Tokenize keywords
        tokens = token_re.findall(s)
        for tok in tokens:
            if tok == 'if':
                block_stack.append(('if', line_num))
            elif tok == 'function':
                block_stack.append(('function', line_num))
            elif tok == 'repeat':
                block_stack.append(('repeat', line_num))
            elif tok == 'do':
                # 'do' can be part of 'while ... do' or 'for ... do' or standalone 'do'
                # All of them are closed by 'end', so pushing 'do'
                block_stack.append(('do', line_num))
            elif tok == 'until':
                if not block_stack:
                    print(f"Error in {path}:{line_num}: Unexpected 'until'")
                    return False
                top, top_line = block_stack.pop()
                if top != 'repeat':
                    print(f"Error in {path}:{line_num}: 'until' matched with '{top}' from line {top_line}")
                    return False
            elif tok == 'end':
                if not block_stack:
                    print(f"Error in {path}:{line_num}: Unexpected 'end'")
                    return False
                top, top_line = block_stack.pop()
                if top not in ('if', 'do', 'function'):
                    print(f"Error in {path}:{line_num}: 'end' matched with '{top}' from line {top_line}")
                    return False
                    
    if delimiter_stack:
        top, top_line = delimiter_stack[-1]
        print(f"Error in {path}: Unclosed delimiter '{top}' opened at line {top_line}")
        return False
        
    if block_stack:
        top, top_line = block_stack[-1]
        print(f"Error in {path}: Unclosed block '{top}' opened at line {top_line}")
        return False
        
    print(f"OK: {path} (Fully balanced)")
    return True

files = [
    "Core/Init.lua",
    "Core/Comms.lua",
    "Data/BiSData.lua",
    "Data/SecretsData.lua",
    "Data/FarmingData.lua",
    "Data/CampingData.lua",
    "Modules/GuideHUD.lua",
    "Modules/RaidPrep.lua",
    "Modules/GuildRoster.lua",
    "Modules/MainUI.lua",
    "Modules/MinimapButton.lua",
]

all_ok = True
for f in files:
    if not check_file(f):
        all_ok = False

sys.exit(0 if all_ok else 1)
