# Poem clock for Playdate | 分钟之诗

> Based on the current time, the language model writes one sentence of poetry every minute on Playdate. You can choose Chinese or English poems.

语言模型结合当前时间、为每分钟撰写一句诗歌，显示在 Playdate 上。可选择中文或英文。

V1.1 - 添加了凯文·凯利的人生建议

![screenshot_menu](https://github.com/Antonoko/poem-clock-for-playdate/blob/main/__asset__/showcase.jpg)

## How to use | 如何使用

> Download PoemClock.pdx.zip from [Release](https://github.com/Antonoko/poem-clock-for-playdate/releases) and sideload it to Playdate.

从 Release 下载 [PoemClock.pdx.zip](https://github.com/Antonoko/poem-clock-for-playdate/releases)，sideload 侧载到 Playdate 即可。

![screenshot_menu](https://github.com/Antonoko/poem-clock-for-playdate/blob/main/__asset__/screenshot_game.png)

> You can change the poetry display language (English/Chinese/random language) in the menu. The Chinese poetry supports adjusting the display direction through gravity sensing while holding down the A key. For power saving reasons, the app runs at a refresh rate of 1fps and there may be some delay when opening the menu.

你可以在菜单中更改诗词显示语言（英文/中文/随机语言）。**中文诗词支持在按住 A 键的情况下、通过重力感应调整显示方向。** 出于省电考虑，应用运行刷新率为 1fps，因此在打开菜单时可能会有一些延迟。

![screenshot_menu](https://github.com/Antonoko/poem-clock-for-playdate/blob/main/__asset__/screenshot_menu.png)

> [!NOTE]
>
> 笔者非诗词俳句专家，语言模型书写的诗句可能存在错漏表达，如发现错漏、或有更好的 LLM 生成 prompt，欢迎提出 issue。也请关注版本更新，以获得更高质量的诗句更新。
>
> I am not an expert in poetry or haiku. There may be errors or omissions in the poems written by the language model. If you meet errors or omissions, or there is a better LLM generation prompt, you are welcome to raise an issue. Also stay tuned for version updates to get higher quality poems.


## How to build | 如何构建

> Configure [Playdate SDK](https://play.date/dev/) and global variables, use `pdc source PoemClock` to build.

配置 [Playdate SDK](https://play.date/dev/) 与全局变量，使用 `pdc source PoemClock` 进行构建。


## Thanks
LLM service provider: [Coze: Next-Gen AI Chatbot Developing Platform](https://www.coze.com/)

Playdate 中文支持项目：https://github.com/Antonoko/Chinese-font-for-playdate