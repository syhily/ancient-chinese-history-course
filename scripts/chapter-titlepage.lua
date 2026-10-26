-- 章扉页：为「第X章」一级标题加 .zhang 类，并把标题拆成
-- 小字「第X章」（.juanshu）+ 大字章题两个 span，供 CSS 分层排版。
-- --split-level=1 时章标题独立成页、页面上只有章题，CSS 将其排为
-- 居中横排宋体（最大兼容方案，详见 epub.css 的 h1.zhang 注释）。
-- 其他一级标题（修订前言、自序、电子版说明）不标记，保持居中黑体横排。
-- 目录条目由标题纯文本生成，拆 span 不影响目录文字。
function Header(el)
  if el.level ~= 1 then
    return nil
  end
  local juan, title = pandoc.utils.stringify(el.content):match("^(第[一二三四五六七八九十]+章)%s*(.+)$")
  if not juan then
    return nil
  end
  el.classes:insert("zhang")
  el.content = {
    pandoc.Span(juan, { class = "juanshu" }),
    pandoc.Space(),
    pandoc.Span(title),
  }
  return el
end
