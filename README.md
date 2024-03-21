# Poem clock for Playdate | 分钟之诗

> Based on the current time, the language model writes one sentence of poetry every minute on Playdate. You can choose Chinese or English poems.


结合当前时间，语言模型为每分钟写一句诗歌，书写在 Playdate 上。可选择中文或英文。

![screenshot_menu](https://github.com/Antonoko/poem-clock-for-playdate/blob/main/__asset__/showcase.jpg)

## How to use | 如何使用

> Download PoemClock.pdx.zip from Release and sideload it to Playdate.

从 Release 下载 [PoemClock.pdx.zip]()，sideload 侧载到 Playdate 即可。

![screenshot_menu](https://github.com/Antonoko/poem-clock-for-playdate/blob/main/__asset__/screenshot_game.png)

> You can change the poetry display language (English/Chinese/random language) in the menu. Among them, Chinese poetry supports adjusting the display direction through gravity sensing while holding down the A key. For power saving reasons, the app runs at a refresh rate of 1fps and there may be some delay when opening the menu.

你可以在菜单中更改诗词显示语言（英文/中文/随机语言）。其中中文诗词支持在按住 A 键的情况下、通过重力感应调整显示方向。出于省电考虑，应用运行刷新率为 1fps，在打开菜单时可能会有一些延迟。

![screenshot_menu](https://github.com/Antonoko/poem-clock-for-playdate/blob/main/__asset__/screenshot_menu.png)


## How to build | 如何构建

配置 [Playdate SDK](https://play.date/dev/) 与全局变量，使用 `pdc source PoemClock` 进行构建。



## Thanks
LLM service provider: [Coze: Next-Gen AI Chatbot Developing Platform](https://www.coze.com/)