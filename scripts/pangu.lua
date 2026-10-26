-- 盘古之白：在中文字符与西文/数字相邻处插入窄空格（U+2009）。
-- 阅读器对 text-autospace 等 CSS 属性支持极差，插入真实字符是唯一可靠方案。
-- 两个层面：
--   Str 过滤器 —— 修复字符串内部的相邻边界（如「中文ABC」）；
--   Para/Plain/Header/LineBlock 过滤器 —— 修复跨内联元素的边界
--   （如「中文 **EN**」「使用 `start` 属性」），只看两端的首尾字符，
--   已有空格/标点隔开的不动。
local THINSP = utf8.char(0x2009)

local function cp_class(cp)
  if (cp >= 0x4E00 and cp <= 0x9FFF) or (cp >= 0x3400 and cp <= 0x4DBF)
    or (cp >= 0xF900 and cp <= 0xFAFF) or cp == 0x3007 then
    return "cjk"
  end
  if (cp >= 48 and cp <= 57) or (cp >= 65 and cp <= 90) or (cp >= 97 and cp <= 122) then
    return "latin"
  end
  return nil
end

local function fix_text(s)
  local out = {}
  local prev = nil
  for _, cp in utf8.codes(s) do
    if prev then
      local a, b = cp_class(prev), cp_class(cp)
      if (a == "cjk" and b == "latin") or (a == "latin" and b == "cjk") then
        table.insert(out, THINSP)
      end
    end
    table.insert(out, utf8.char(cp))
    prev = cp
  end
  return table.concat(out)
end

local function edge_char(el, side)
  local t = el.t
  if t == "Str" or t == "Code" or t == "Math" then
    local s = el.text
    if s == "" then return nil end
    local cps = {}
    for _, cp in utf8.codes(s) do
      cps[#cps + 1] = cp
    end
    return side == "first" and cps[1] or cps[#cps]
  elseif t == "Note" then
    -- 脚注标记渲染为数字，按拉丁/数字类处理，使「中文^[注]」两侧加窄空格
    return 48 -- '0'
  elseif t == "Emph" or t == "Strong" or t == "Underline" or t == "Strikeout"
    or t == "Superscript" or t == "Subscript" or t == "SmallCaps"
    or t == "Span" or t == "Link" or t == "Cite" or t == "Quoted" then
    local content = el.content
    if not content or #content == 0 then return nil end
    return edge_char(side == "first" and content[1] or content[#content], side)
  end
  return nil
end

local function fix_boundaries(inlines)
  local out = {}
  for _, el in ipairs(inlines) do
    local prev = out[#out]
    if prev then
      local a = edge_char(prev, "last")
      local b = edge_char(el, "first")
      if a and b then
        local ca, cb = cp_class(a), cp_class(b)
        if (ca == "cjk" and cb == "latin") or (ca == "latin" and cb == "cjk") then
          table.insert(out, pandoc.Str(THINSP))
        end
      end
    end
    table.insert(out, el)
  end
  return out
end

function Str(el)
  local fixed = fix_text(el.text)
  if fixed ~= el.text then
    return pandoc.Str(fixed)
  end
end

function Para(el)
  el.content = fix_boundaries(el.content)
  return el
end

function Plain(el)
  el.content = fix_boundaries(el.content)
  return el
end

function Header(el)
  el.content = fix_boundaries(el.content)
  return el
end

function LineBlock(el)
  for i, line in ipairs(el.content) do
    el.content[i] = fix_boundaries(line)
  end
  return el
end
