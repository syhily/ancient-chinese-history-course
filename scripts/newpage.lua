-- 硬换页标记：独占一行的 `\newpage` 转换为空的二级标题（.unlisted），
-- 借助 pandoc --split-level=2 的文件拆分实现换页——拆出的新 xhtml 文件
-- 在任何阅读器中都从新页开始，不依赖 CSS page-break（部分阅读器不支持）。
-- 标题内容为空，渲染为不可见的 <h2>；.unlisted 使其不进入目录 nav。
-- 注意：`\newpage` 是 LaTeX 命令，markdown 的 raw_tex 扩展将其解析为
-- RawBlock("tex")（EPUB 输出会静默丢弃）；仅当 raw_tex 被禁用、
-- 退化为普通段落时才走 Para 分支，两者都须处理。
local function newpage_header()
  return pandoc.Header(2, {}, pandoc.Attr("", { "unlisted" }))
end

function RawBlock(el)
  if el.format == "tex" and el.text:match("^\\newpage%s*$") then
    return newpage_header()
  end
end

function Para(el)
  if #el.content == 1
    and el.content[1].t == "Str"
    and el.content[1].text == "\\newpage"
  then
    return newpage_header()
  end
end
