#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
修复 TWRP 8.1 (Android 8.1) 源码树里的 Python 2 遗留语法。

背景
----
TWRP 8.1 分支的辅助脚本写于 2017~2018 年，是 Python 2 语法。
Ubuntu 22.04 runner 只有 Python 3，直接运行会报：

    SyntaxError: multiple exception types must be parenthesized

最典型的例子（TWRP 编译圈公认的坑）：
    vendor/omni/build/tools/roomservice.py 第 109 / 166 行
        except IOError, ES.ParseError:      # Python 2 写法
    必须改成：
        except (IOError, ES.ParseError):    # Python 3 写法

lunch 阶段会调用 roomservice.py，语法错误会让 lunch 直接崩，
进而导致 mka 编译中止。

用法
----
    cd ~/twrp
    python3 /path/to/fix_python2.py

脚本会递归扫描当前目录下所有 .py（跳过 .repo / out / .git），
把 `except A, B:` 形式的语法批量修成 `except (A, B):`。
"""
import os
import re
import pathlib

# except A, B:  /  except A, B, C:   ->  except (A, B, C):
# 只在行首缩进后出现 except 且逗号分隔多个异常类型时匹配
# ★ 必须加 re.MULTILINE，否则 ^ 只匹配整个文本开头，多行源码里一处都改不到！
PAT = re.compile(
    r'^(\s*)except\s+([A-Za-z_][\w.]*(?:\s*,\s*[A-Za-z_][\w.]*)+)\s*:',
    re.MULTILINE,
)

SKIP_DIRS = {'.repo', 'out', '.git'}
SKIP_FILES = {os.path.abspath(__file__), 'fix_python2.py'}


def fix_all(root='.'):
    fixed = []
    scanned = 0
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            if not fn.endswith('.py'):
                continue
            if fn in SKIP_FILES:          # 跳过脚本自身
                continue
            p = os.path.join(dirpath, fn)
            scanned += 1
            try:
                txt = pathlib.Path(p).read_text(encoding='utf-8', errors='ignore')
            except Exception:
                continue
            new = PAT.sub(lambda m: f"{m.group(1)}except ({m.group(2)}):", txt)
            if new != txt:
                try:
                    pathlib.Path(p).write_text(new, encoding='utf-8')
                    fixed.append(p)
                    print(f"  [修复] {p}")
                except Exception as e:
                    print(f"  [失败] {p}: {e}")
    print(f"===> 扫描 {scanned} 个 .py 文件，修复 {len(fixed)} 个")
    return fixed


if __name__ == '__main__':
    fix_all()
