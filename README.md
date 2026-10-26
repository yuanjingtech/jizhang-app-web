# 远景记账 · 落地页（jizhang-app-web）

介绍远景记账 App 功能的官方落地页。**纯静态站，零构建依赖**——`index.html` 双击就能在浏览器打开，也可以直接丢给任意静态托管（GitHub Pages / OSS / nginx）。

## 目录

```
jizhang-app-web/
├── index.html          # 单页结构，全部文案在此
├── assets/
│   ├── styles.css      # 设计 token + 全部样式
│   ├── app.js          # 移动端菜单、页脚年份、滚动入场（渐进增强）
│   ├── favicon.svg
│   └── qr-code.png     # 【待补】体验版小程序码，见下文
└── scripts/
    └── check.sh        # 上线前自检
```

## 本地预览

```bash
cd jizhang-app-web
python3 -m http.server 8765
# 打开 http://127.0.0.1:8765/
```

## 上线前必做：补二维码

`index.html` 的「开始使用」区块现在是一个**二维码占位**，不是能扫的码。
`jizhang/docs/` 里那张「远景记账体验版」二维码标注 **3 月 5 日前有效**，已经过期，所以没有放进页面。

补法：把新的小程序码保存为 `assets/qr-code.png`，然后把占位块换成一个 `img`：

```html
<div class="qr-card">
  <img class="qr-img" src="assets/qr-code.png" alt="远景记账体验版小程序码" width="152" height="152">
  <p class="qr-title">微信扫一扫</p>
  <p class="qr-note">体验版 · 无需安装</p>
</div>
```

同时补 `assets/styles.css` 里的 `.qr-img`：

```css
.qr-img { display: block; margin: 0 auto 14px; width: 152px; height: 152px; border-radius: var(--radius-control); }
```

> 公众号文章发出去之后，二维码就固化在读者手里了——过期前务必换成长期有效的码。

## 文案与功能来源

页面上的每一条功能描述都来自 `jizhang-app-kuikly` 客户端源码，不是营销层面的推测：

| 页面说法 | 源码依据 |
|---|---|
| 五标签（首页 / 收入 / 支出 / 资产 / 负债） | `app/MainTabScreen.kt` 的 `MainTab` 枚举 |
| 应收应付 / 收入支出双折线、日周月季年切换 | `components/AccountGraph.kt`、`IncomeOutcomeGraph.kt`、`TimeRangeSelector.kt` |
| 未来财富预测（线性拟合 + 不同时间粒度不同预测长度 + 置信区间） | `utils/ForecastPlan.kt`、`charts/` 的 `linearForecast` / `forecastConfidence` |
| 点数不足 / 预测值超出量级时不画预测 | `ForecastPlan.buildForecastPlan` 的 `worthShowing` 与「少于 4 点放弃」 |
| 自然语言智能记账（「出行10元」） | `pages/SmartPage.kt` 与服务端 `smart` 接口 |
| 资产 / 负债按期数管理（年 / 月 / 周 / 日） | `pages/AddEquityPage.kt` 的 `PERIOD_OPTIONS`、`AssetsPage.kt`、`DebtPage.kt` |
| 金额显示取两位小数、入库保留原精度 | `base/AmountFormat.kt` 的 `formatAmount` 与相关注释 |
| 液态玻璃材质、深色玻璃标签栏、只在浮层开模糊 | `components/GlassTheme.kt`、`GlassBlur.kt` |
| 选择器切换不留残影 | `components/TimeRangeSelector.kt`（背景声明恒在） |

配色也取自同一套 token（`GlassTheme.kt` 的壁纸三段渐变、`PageWidgets.kt` 的语义色、`MainTabScreen.kt` 的标签栏颜色）。

## 改文案要注意

- **不要写「保证不超时」「数据永不丢」这类绝对承诺**。客户端有 20 秒兜底超时，超时会明确提示，这是已经验证过的行为；但线上 Mongo 偶发抖动仍在，页面文案按「会明确提示」写，别写成「不会发生」。
- **预测不是投资建议**，页面上已经在「常见问题」里写明，改动时保留这句。
- 页面里的手机样机是 **CSS/SVG 手绘示意图**，不是真实截图。若换成真机截图，请同时更新 `<img>` 的 `alt` 与 `figcaption`，别让示意图的说明停留在截图版本。

## 自检

```bash
./scripts/check.sh
```

检查项：HTML/CSS/JS/SVG 资源是否齐全、页内锚点是否都有对应元素、是否有未使用的 `href="#"` 空链接、是否误把过期二维码塞进页面。

浏览器侧的验收（本项目已跑过一遍，结论记在这里供复查）：

- 桌面 1440×1000 与移动 390×844 下**均无横向溢出**（`scrollWidth == clientWidth`）
- 资源全部 200、控制台 0 error / 0 warning
- 页内锚点 `#main` `#top` `#features` `#screens` `#forecast` `#faq` `#download` 全部可解析
- 移动端菜单：点开 → 点导航项自动收起；`aria-expanded` 同步
- 三台样机等高（448px），首页样机的悬浮按钮不遮挡金额
