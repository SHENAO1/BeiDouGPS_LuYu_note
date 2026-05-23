# Project Requirements

## 笔记同步要求

- 凡是整理、补充、修改章节笔记或专题笔记，必须同时更新 Markdown 源笔记和对应的 HTML 发布页。
- Markdown 源笔记通常位于 `chapters/**/笔记/*.md`。
- HTML 发布页通常位于 `site/**/index.html`。
- 如果只发现其中一种格式，需主动补齐另一种格式，或在最终回复中明确说明无法补齐的原因。
- 修改 HTML 笔记时，应优先从 Markdown 源笔记重新生成 HTML，避免两份内容漂移。

## GitHub Pages 发布规则

- 对外发布的默认入口统一使用根站仓库 `E:\Code\SHENAO1.github.io`，公开地址统一为 `https://shenao1.github.io/`。
- 当前仓库 `site/` 下的页面属于源站内容；凡是修改了笔记相关的 Markdown / HTML，若任务涉及“发布、上线、同步到 GitHub Pages”，必须继续把更新同步到根站仓库后再发布。
- 根站仓库与当前仓库的同步，优先使用 `E:\Code\SHENAO1.github.io\scripts\sync-from-source.ps1`，将当前仓库的 `site/` 副本同步到根站仓库的发布目录。
- `https://shenao1.github.io/BeiDouGPS_LuYu_note/` 这类项目站地址只作为预览或仓库级页面存在，不作为默认对外入口；除非用户明确要求，否则最终交付应以根站地址为准。

## 输出要求

- 每次完成笔记相关任务后，最终回复必须列出本次需要检查的 Markdown 文件和 HTML 文件。
- 文件路径需使用可点击的绝对路径链接。
- 如果涉及多个笔记页面，应分别列出每一组 Markdown / HTML 对应关系。
