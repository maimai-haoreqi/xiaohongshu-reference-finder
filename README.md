# 小红书通用找参考 Skill

为内容创作者按目标用户、具体场景和互动数据寻找小红书参考笔记。先对齐方向，再给一小批候选供你选择，最后核验详情并交付参考清单。

适合已有大致赛道或主题、希望建立选题池或为一条内容找参考的人。支持任意赛道，实际搜索结果取决于平台可见内容和你的筛选要求。

## 能做什么

| 需求 | 工作方式 |
| --- | --- |
| 核验一条笔记 | 检查你提供的链接是否符合筛选标准 |
| 复查漏掉的参考 | 查明漏检原因，沿标题、标签、人群和场景补搜 |
| 围绕主题找参考 | 先给 5–8 条候选，与你校准方向后扩搜 |
| 建立参考库 | 按指定范围搜索、去重、核验，报告覆盖缺口 |

默认筛选：近半年发布、点赞达到 1000，或者近一周发布、点赞达到 100。可以在每次任务中覆盖这些条件。

## 使用条件

- 当前流程面向具备内置浏览器操作能力的 Codex 环境，需要在该浏览器中登录小红书。
- Skill 是工作流程指令，不会自行提供浏览器工具、平台账号或 AI 服务。安装后若环境没有浏览器操作能力，无法完成站内搜索。
- 仅在检索已有 JSON 参考库时需要 Ruby；附带脚本使用标准库，无需额外 gem。
- 归档到外部表格需要你明确指定目标，并具备对应工具和访问权限。
- 尚未验证其他 Agent 产品的兼容性。本次发布准备检查覆盖文件结构和本地脚本，未进行全新账号的端到端搜索验收。

## 安装

仓库中的 Skill 位于 `skills/mm-xiaohongshu-reference-finder/`，请安装整个文件夹，保留 `references/`、`scripts/` 和 `agents/`。

### 交给 Codex 安装

发布后，复制本仓库 GitHub 地址，在具备 skill-installer 的 Codex 中发送：

> 请使用 skill-installer，从这个 GitHub 仓库安装 skills/mm-xiaohongshu-reference-finder：这里粘贴仓库地址。

### 手动安装

1. 在 GitHub 点击 **Code → Download ZIP**，解压仓库。
2. 将 `skills/mm-xiaohongshu-reference-finder` 整个文件夹放入 `$CODEX_HOME/skills/`。未自定义 CODEX_HOME 时，默认位置为 `~/.codex/skills/`。
3. 若同名文件夹已存在，先备份，再自行决定是否替换。
4. 在下一轮对话中尝试调用；若未识别，重新打开 Codex 后重试。

## 第一次使用

当前版本保留手动调用设置，请在消息中明确带上 `$mm-xiaohongshu-reference-finder`。

复制下面的示例，并按你的赛道修改：

```text
使用 $mm-xiaohongshu-reference-finder 帮我找小红书参考。

赛道：小户型装修。
目标用户：第一次装修、预算有限的业主。
主题：装修预算分配和超支避坑。
内容目的：输出实用方法，建立信任。
形式：图文和 1–3 分钟视频。
筛选：使用默认的时间和点赞门槛。
交付：先给我 5–8 条候选，校准后最终保留 5 条，附链接、日期、点赞数和入选原因。
```

第一批候选出来后，明确告诉它编号和接近点，例如：

> 第 3 条最接近，我想借鉴它按装修阶段拆预算的方法；第 1 条偏豪宅，不符合目标用户。请按第 3 条的方向继续找。

最终清单会按要求给出标题链接、发布日期、互动数据和入选原因；无法核实的信息会注明。需要保存到表格或沉淀账号偏好时，再明确提出。

更多输入示例见 [examples/usage.md](examples/usage.md)。

## 已有参考库：可选的本地检索

没有历史数据也可以使用站内搜索。以下脚本只读取本地 JSON 并输出匹配结果，不请求网络、不修改源数据，也不解析短链接跳转。

从仓库根目录运行：

```bash
ruby skills/mm-xiaohongshu-reference-finder/scripts/search-records.rb examples/records.example.json '预算 装修' 5
ruby skills/mm-xiaohongshu-reference-finder/scripts/dedupe-records.rb examples/records.example.json '小户型装修预算怎么分'
```

示例数据全部虚构，链接使用 example.com，不代表真实笔记或效果。

支持 JSON 数组，或包含 `records` / `data` 数组的对象。每条记录须为对象。常用字段包括 `id`、`title`、`url`、`tags`、`body`、`comments`、`published_at`、`likes`。正文和评论用于关键词匹配；脚本返回少量摘要。

去重按笔记 ID、去除查询参数及末尾斜杠后的 URL，或忽略大小写的完整标题匹配。它不会判断语义相似，也不会验证链接可访问性。

账号偏好可参考 [Profile 模板](skills/mm-xiaohongshu-reference-finder/references/profile-format.md)，存放在自己的项目中，使用时明确提供路径。私人参考库、搜索日志和账号资料不需要上传本仓库。

## 文件说明

- [SKILL.md](skills/mm-xiaohongshu-reference-finder/SKILL.md)：主要工作流程。
- `references/`：需求访谈、搜索核验、交付、账号偏好和反馈沉淀规范。
- `scripts/`：历史参考库检索与去重工具。
- `agents/openai.yaml`：Codex 中的显示名称和调用设置。
- `examples/`：可复制的任务输入及虚构 JSON 数据。

## 反馈

欢迎通过仓库 Issues 提交问题，写明你的运行环境、任务输入、预期结果和实际结果。示例中请去除登录信息和私人资料。

## 许可

由麦麦创作，采用 [MIT License](LICENSE)。允许使用、修改、分发和商用，须保留版权及许可声明。Skill 本身免费；运行所需的 AI 产品或服务可能收费。第三方平台上的笔记和图片不属于本项目的许可范围。
