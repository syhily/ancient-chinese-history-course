-- 硬换页标记：独占一行的 `\newpage` 转换为空的一级标题（.unlisted），
-- 借助 pandoc --split-level=1 的文件拆分实现换页——拆出的新 xhtml 文件
-- 在任何阅读器中都从新页开始，不依赖 CSS page-break（部分阅读器不支持）。
-- 标题内容为空，渲染为不可见的 <h1>；.unlisted 使其不进入目录 nav。
-- 本书用 --split-level=1（只按章拆文件，节连续排版，贴近原书页式）；
-- 卷首图版、版权页等需要硬分页处全靠本过滤器产生的空 h1 拆出独立文件。
-- 注意：`\newpage` 是 LaTeX 命令，markdown 的 raw_tex 扩展将其解析为
-- RawBlock("tex")（EPUB 输出会静默丢弃）；仅当 raw_tex 被禁用、
-- 退化为普通段落时才走 Para 分支，两者都须处理。
-- 警告：unlisted 空标题不只是自己不进 nav 目录——pandoc（3.12 实测）会把
-- 它之后、下一个正式章标题之前的所有节/目标题一并从 nav 吞掉。因此章内
-- 禁止使用 \newpage；章前地图等独立页放到排序在该章之前的
-- manuscript/chNN-00-maps.md 里。
local function newpage_header()
  return pandoc.Header(1, {}, pandoc.Attr("", { "unlisted" }))
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
