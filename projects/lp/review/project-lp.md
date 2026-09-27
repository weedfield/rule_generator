---
name: project-lp
applyTo: "**/*.{html,htm,scss,css,webp,png,jpg,jpeg,svg}"
---
## 目的
LP 固有の画像実装規約からの逸脱を防ぐ。

## ルール
- LP-01 SVG 以外の画像は基本 webp 形式で実装している。
- LP-02 webp が読み込まれない際に png または jpg を読み込むようにしている。
- LP-03 material の画像を削除した場合、dist の画像も手動で削除している。

## 対象外（他の観点で見る）
- 書き出し倍率・スプライト → image
