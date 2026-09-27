---
name: rf_kreisel-form
applyTo: "**/*.{js,scss,svg,png,jpg,jpeg,webp}"
---
## 目的
FM（rf_kreisel-form）固有の反映漏れ・画像格納ミスを防ぐ。

## ルール
- FM-01 dev で修正した内容を prod にも反映している（dev と prod で差分があるので、コピペは控える）。
- FM-02 material の画像を削除した場合、dist の画像も手動で削除している。
- FM-03 scss で使用した SVG 画像を material/svg に格納している。

## 対象外（他の観点で見る）
- webp 実装 → project-lp
