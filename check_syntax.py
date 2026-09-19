import os

files = [
    'Functions/Helicopter/fn_heliManager.sqf',
    'Functions/Helicopter/fn_addResupplyAction.sqf',
    'description.ext'
]

pairs = {')': '(', ']': '[', '}': '{'}

for path in files:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    stack = []
    in_str = False
    str_char = ''
    line = 1
    err = False
    i = 0
    while i < len(content):
        c = content[i]
        if c == '\n':
            line += 1
        elif not in_str and c == '/' and i + 1 < len(content) and content[i+1] == '/':
            while i < len(content) and content[i] != '\n':
                i += 1
            line += 1
        elif not in_str and c == '/' and i + 1 < len(content) and content[i+1] == '*':
            i += 2
            while i + 1 < len(content) and not (content[i] == '*' and content[i+1] == '/'):
                if content[i] == '\n': line += 1
                i += 1
            i += 1
        elif c in '"\'':
            if not in_str:
                in_str = True
                str_char = c
            elif str_char == c:
                # check escaped quote in arma: ""
                if i + 1 < len(content) and content[i+1] == c:
                    i += 1
                else:
                    in_str = False
        elif not in_str:
            if c in '([{':
                stack.append((c, line))
            elif c in ')]}':
                if not stack:
                    print(f'{path}: Unexpected {c} at line {line}')
                    err = True
                    break
                top, top_l = stack.pop()
                if pairs[c] != top:
                    print(f'{path}: Mismatched {c} at line {line}, expected {top} from line {top_l}')
                    err = True
                    break
        i += 1
    if stack and not err:
        print(f'{path}: Unclosed {stack[-1][0]} from line {stack[-1][1]}')
    elif not err:
        print(f'{path}: Syntax OK')
