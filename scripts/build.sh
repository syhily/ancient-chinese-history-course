#!/usr/bin/env bash
# pandoc 构建 EPUB
set -euo pipefail
cd "$(dirname "$0")/.."

mkdir -p build

mapfile -t chapters < <(ls manuscript/*.md | sort)
if [ ${#chapters[@]} -eq 0 ]; then
  echo "manuscript/ 下没有 Markdown 文件，先完成 OCR 校对。" >&2
  exit 1
fi

cover_opt=()
for c in assets/cover.jpg assets/cover.png; do
  if [ -f "$c" ]; then
    cover_opt=(--epub-cover-image="$c")
    break
  fi
done

# Clearview 等阅读器的 CSS 预处理器会被注释中的字符（如 |）中断并吞掉后续规则，
# 构建时剥离注释后再交给 pandoc；assets/epub.css 保留完整注释供维护
stripped_css="build/epub.stripped.css"
perl -0777 -pe 's{/\*.*?\*/}{}gs' assets/epub.css > "$stripped_css"

pandoc metadata.yaml "${chapters[@]}" \
  --from markdown+footnotes+inline_notes+fenced_divs+smart \
  --to epub3 \
  --split-level=1 \
  --lua-filter=scripts/newpage.lua \
  --lua-filter=scripts/ascii-heading-ids.lua \
  --lua-filter=scripts/chapter-titlepage.lua \
  --lua-filter=scripts/pangu.lua \
  --css "$stripped_css" \
  "${cover_opt[@]}" \
  -o "build/中国古代史教程.epub"

echo "已生成 build/中国古代史教程.epub"
