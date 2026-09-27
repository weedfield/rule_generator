---
name: css
applyTo: "**/*.{css,scss}"
---
## 目的
崩れやすい実装、不要な記述、記述規則の違反を防ぐ

## ルール
- CSS-IMPL-01 要素の高さを height で固定していない（理由がある場合を除く）
- CSS-IMPL-02 button タグに cursor と font-family を指定している
- CSS-IMPL-03 不要な CSS がない（デフォルト値の再指定、不要な font-size 指定、使われなくなったルールの残存など）
  - 例：block 要素への display: block / inline 要素への display: inline / block 要素への width: 100%
- CSS-IMPL-04 長い英数字や長い文字列が入りうる箇所に、折り返しの対策（word-wrap: break-word など）がある
- CSS-IMPL-05 余白の値に小数を使っていない [linter候補]
- CSS-IMPL-06 小数を指定する場合は小数第 1 位までにしている [linter候補]
- CSS-IMPL-07 擬似要素に :: を使っている [linter候補]
- CSS-IMPL-08 font-size を px で指定している [linter候補]
- CSS-IMPL-09 モジュールごとに 1 行空けている [linter候補]
- CSS-IMPL-10 子要素の margin が親要素を突き抜けていない
  - 判定条件：子が親の最初（最後）の要素で、前（後ろ）にテキストや他の要素がない。
    かつ子に margin-top（margin-bottom）があり、親に padding / border がない。
    かつ親が flex / grid / flow-root / inline-block / overflow: hidden などでなく、float・absolute でもない。
    margin-bottom の場合は、親に height / min-height の指定もない。これらをすべて満たす場合に指摘する
  - 判断材料が差分の中で揃わない場合（親のスタイルが差分外にある、JSP の条件分岐がある、clearfix がある可能性など）は、内容の末尾に「（要確認：差分外のスタイルに依存）」と付ける
  - 重要度は 🟡 とする
- CSS-IMPL-11 クリック可能な要素は、要素全体で cursor: pointer になっている
  - button / [role="button"] / js- クラスのクリック要素 / href のない a に cursor: pointer がなければ指摘する（a[href] はブラウザの既定で pointer になるため対象外）
  - クリック要素が inline のまま、親要素（カード・リスト項目）の一部しか覆っていなければ指摘する
  - 子要素での cursor の上書きや、pointer-events: none の誤用も指摘する
  - 重要度は 🟡 とする
- CSS-IMPL-12 推奨環境で使用できないスタイルを使っていない [linter候補]
  - 推奨環境：（TBD：対応ブラウザの一覧を後日記載）
