#!/usr/bin/env python3
"""把精校 TXT 的「行内 [n] + 章末 [n] 注文列表」机械转换为 pandoc 行内脚注 ^[…]。

用法：在仓库根目录执行  python3 scripts/inline-footnotes.py
输入：ocr/ch01.txt … ocr/ch10.txt（精校 TXT 分章稿，由原始 TXT 按章拆分）
输出：ocr/chNN-inline.txt（正文脚注已内联，章末注文列表已剥离）

转换前已验证：每章正文标记 [1]…[N] 各出现一次，与章末注文编号一一对应；
注文列表中 [1][2] 形式表示多个编号共用同一条注文；不以 [n] 开头的
非空行是上一条注文的续行，直接拼接。
"""
import pathlib
import re

OCR = pathlib.Path(__file__).resolve().parent.parent / "ocr"

for ch in range(1, 11):
    lines = (OCR / f"ch{ch:02d}.txt").read_text().split("\n")
    start = next(i for i, l in enumerate(lines) if re.match(r"^\[1[\]\d]", l))
    body = "\n".join(lines[:start]).rstrip() + "\n"

    notes: dict[int, str] = {}
    cur: list[int] = []
    for line in lines[start:]:
        if not line.strip():
            continue
        m = re.match(r"^((?:\[\d+\])+)\s*(.*)$", line)
        if m:
            cur = [int(x) for x in re.findall(r"\d+", m.group(1))]
            for n in cur:
                notes[n] = m.group(2).rstrip()
        else:
            for n in cur:
                notes[n] += line.rstrip()

    assert sorted(notes) == list(range(1, max(notes) + 1)), f"ch{ch:02d} 注文编号不连续"
    for n, t in notes.items():
        assert t.count("[") == t.count("]"), f"ch{ch:02d} 注[{n}] 方括号不平衡"

    new_body, cnt = re.subn(r"\[(\d+)\]", lambda m: "^[" + notes[int(m.group(1))] + "]", body)
    assert cnt == max(notes), f"ch{ch:02d} 替换数 {cnt} != {max(notes)}"
    (OCR / f"ch{ch:02d}-inline.txt").write_text(new_body)
    print(f"ch{ch:02d}: 内联脚注 {cnt} 条 -> ocr/ch{ch:02d}-inline.txt")
