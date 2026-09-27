---
name: requirements
agent: review-requirements
---
## 目的
要件（Confluence）との齟齬を防ぐ

## ルール
- REQ-01 要件定義書の内容と齟齬がない
- REQ-02 ビーコン・サイカタ・suit コードなどのログが、要件どおりに実装されている
- REQ-03 VWO の各 Variation に、要件どおりのログ計測用 JS が仕込まれている
- REQ-04 画像が動的に変わる場合、要件にある画像パターンをすべて考慮している

## 対象外
- ログが実際に送信されているか → 手動確認（manual.md）
