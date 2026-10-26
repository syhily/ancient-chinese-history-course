# 中国古代史教程（A Course of Ancient Chinese History）

朱绍侯 主编 · 龚留柱 执行主编 · 河南大学出版社 · 2010 年 8 月第 1 版（全二册，ISBN 978-7-5649-0200-1）

本项目将扫描版《中国古代史教程》（上下册）排版为 EPUB 3 电子书。正文文字采用人工精校的 OCR 文稿；原书的页底圈码脚注（①②③，每页重新编号）经脚本内联化后，再以 [MinerU](https://github.com/opendatalab/MinerU) 双模式（pipeline / vlm）识别结果交叉比对圈码位置、对照扫描原页抽核注文，转为随文弹注；章末的王朝世系表与简表逐格对照原书还原；卷首 17 幅文物图版改用维基共享资源、博物馆官网等来源的高清照片并附来源说明。中间稿为 Markdown，由 pandoc 构建。

全书十章：远古时代／夏商周／春秋战国／秦汉／三国两晋南北朝／隋唐五代／宋辽西夏金／元／明／清（至 1840 年），共约 96 万字、1270 条脚注。

## 文件结构

| 文件 | 说明 |
| --- | --- |
| `manuscript/00-frontmatter.md` | 前置部分（电子版说明、书名页、版权信息） |
| `manuscript/01-preface.md` | 前言（含编写分工名单） |
| `manuscript/02-inserts.md` | 卷首图版（17 幅文物高清照片，图注与来源见 `assets/insert-NN.txt`） |
| `manuscript/chNN.md` | 十章正文（**所有修改都在对应文件里进行**），构建时按文件名序合并 |
| `metadata.yaml` | pandoc 元数据（书名、编者、出版社、ISBN） |
| `assets/epub.css` | EPUB 样式（正文用阅读器默认字体；标题黑体 / 引文楷体 / 扉页仿宋；另有本书专用的表格、表题、链式世系表样式） |
| `assets/cover.jpg` | 封面图 |
| `scripts/inline-footnotes.py` | 把精校 TXT 的「行内 [n] + 章末注文列表」机械转换为 pandoc 行内脚注（1270 条，程序校验一一对应） |
| `scripts/build.sh` | pandoc 构建脚本（`--split-level=2` 按节拆分文件即硬分页；CSS 剥注释后打包，兼容 Clearview） |
| `scripts/newpage.lua` | pandoc Lua 过滤器：`\newpage` 转硬分页 |
| `scripts/ascii-heading-ids.lua` | pandoc Lua 过滤器：标题锚点改写为 ASCII 序号（sec-N），否则中文锚点在部分阅读器中目录无法跳转 |
| `scripts/chapter-titlepage.lua` | pandoc Lua 过滤器：「第X章」标题拆分为小字章次 + 大字章题，章扉页居中宋体 |
| `scripts/pangu.lua` | pandoc Lua 过滤器：中西文之间加间距 |
| `Makefile` | `make build` 构建，`make clean` 清理 |
| `docs/workflow.md` | 转换约定与校对流程的完整说明（页码换算、标题层级、脚注核对、表格写法、自查命令） |
| `中国古代史教程.epub` | 构建产物（不入库，见 Releases） |

原始 PDF 与 OCR 中间结果（`source/`、`ocr/`）不入库，请自行准备。

## 下载

每次打 tag 都会由 GitHub Actions 自动构建 EPUB 并发布到 Releases：

- [下载最新版 EPUB](https://github.com/syhily/ancient-chinese-history-course/releases/latest/download/ancient-chinese-history-course.epub)（直链，始终指向最新 Release）

## 版权说明

本书著作权归原作者及河南大学出版社所有。本电子版仅供个人学习与研究使用，不进行任何商业用途。内容请以纸质原书为准。若涉及侵权，请联系仓库所有者，核实后将立即删除。
