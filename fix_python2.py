#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
兜底修复 TWRP 8.1 / AOSP 8.1 源码树里的 Python 2 遗留语法。

背景
----
TWRP 8.1 分支的脚本写于 2017~2018 年，是 Python 2 语法。
主方案是在 workflow 里装 **Python 2.7**（deadsnakes PPA）并把 `python`
指向它，让 AOSP 8.1 用它本该用的解释器。

本脚本是**兜底**：把 `except A, B:` 这种「带逗号但不带括号」的旧式写法
统一修成 `except (A, B):`。

为什么这样改是安全的：
    `except (A, B):` 这种「带括号」的写法 **Python 2.6+ 和 Python 3 都支持**，
    所以无论 `python` 指向 2.7 还是 3，都不会破坏。

（★ 不要在这里用 2to3 做全量转换——那会产出纯 Python 3 代码，
  与「python → python2.7」的主方案冲突。）

⚠️ 只用正则，不做 AST 级改写，风险最小。

用法
----
    cd ~/twrp
    python3 /path/to/fix_python2.py
"""
import os
import re
import sys

# ---------- 正则：except A, B:  ->  except (A, B): ----------
# ★★★ 必须加 re.MULTILINE！
# 否则 ^ 只匹配整个文本的开头，多行源码里一处都改不到
# （血泪教训：漏了它 → "扫描 2602 个文件，修复 0 个"）
PAT_EXCEPT = re.compile(
    r'^(\s*)except\s+([A-Za-z_][\w.]*(?:\s*,\s*[A-Za-z_][\w.]*)+)\s*:',
    re.MULTILINE,
)

# 扫描报告用的 Python 2 语法探针
PY2_PATTERNS = [
    ('except_list', PAT_EXCEPT),
    ('print_stmt ', re.compile(r'^(\s*)print\s+(?!\()\S', re.MULTILINE)),
    ('has_key    ', re.compile(r'\.has_key\s*\(')),
    ('execfile   ', re.compile(r'\bexecfile\s*\(')),
]

SKIP_DIRS = {'.repo', 'out', '.git', 'prebuilts', 'external'}
SKIP_FILES = {os.path.basename(__file__), 'fix_python2.py'}


def log(s):
    print(s, flush=True)


def scan(root='.'):
    log(">>> 扫描 Python 2 语法（仅报告，不修改）")
    hits = {}
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            if not fn.endswith('.py') or fn in SKIP_FILES:
                continue
            p = os.path.join(dirpath, fn)
            try:
                txt = open(p, encoding='utf-8', errors='ignore').read()
            except Exception:
                continue
            kinds = [name.strip() for name, pat in PY2_PATTERNS if pat.search(txt)]
            if kinds:
                hits[p] = kinds
    if not hits:
        log("  未发现 Python 2 语法")
    else:
        log(f"  发现 {len(hits)} 个含 Python 2 语法的文件（前 30 个）:")
        for p in sorted(hits)[:30]:
            log(f"     [{','.join(hits[p])}] {p}")
    return hits


def fix_except(root='.'):
    fixed, scanned = [], 0
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            if not fn.endswith('.py') or fn in SKIP_FILES:
                continue
            p = os.path.join(dirpath, fn)
            scanned += 1
            try:
                txt = open(p, encoding='utf-8', errors='ignore').read()
            except Exception:
                continue
            new = PAT_EXCEPT.sub(
                lambda m: f"{m.group(1)}except ({m.group(2)}):", txt)
            if new != txt:
                open(p, 'w', encoding='utf-8', newline='\n').write(new)
                fixed.append(p)
    log(f"  扫描 {scanned} 个 .py，修复 {len(fixed)} 个")
    for f in fixed[:20]:
        log(f"     {f}")
    return fixed


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else '.'
    log("=" * 64)
    log("兜底修复 Python 2 遗留语法（TWRP 8.1 / AOSP 8.1）")
    log("=" * 64)
    scan(root)
    log(">>> 修复 except A, B:（Python 2/3 双兼容写法）")
    fix_except(root)
    log("=" * 64)
    log("完成")


if __name__ == '__main__':
    main()
