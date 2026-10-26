-- 将 pandoc 依据标题文字自动生成的中文锚点改写为 ASCII 序号锚点
--（sec-1、sec-2……）。Clearview 等阅读器无法解析目录 nav.xhtml 里的
-- 非 ASCII 片段链接（href="ch005.xhtml#江南春-杜牧"），点击目录无法跳转。
-- auto_identifiers 在解析阶段已分配 id，此处统一覆盖；目录与 toc.ncx
-- 由 pandoc 依据最终 AST 生成，会自动使用新锚点。
local n = 0
function Header(el)
  n = n + 1
  el.identifier = "sec-" .. n
  return el
end
