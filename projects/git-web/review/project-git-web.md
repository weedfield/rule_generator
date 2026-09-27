---
name: project-git-web
applyTo: "**/*.{html,htm,jsp}"
---
## 目的
git-web / git-web-edit 固有のマークアップ・差込ファイル規約からの逸脱を防ぐ。

## ルール
- GITWEB-01 開発接続用のコメントが入っている。
  - 既存画面: 変更箇所を FACE-XXX で囲む
    ```
    <!-- ↓↓↓ FACE-XXX backlog案件名 ↓↓↓ -->
    <!-- ↑↑↑ FACE-XXX backlogの案件名 ↑↑↑ -->
    ```
  - 新規画面: 変更箇所を MEMO でコメントする（参考）
    ```
    <!-- MEMO:id追加/class追加/カセット1つめ、など -->
    ```
- GITWEB-02 img, input, br などの空要素の最後に / を付けている（✕ `<img>` ／ ○ `<img />`。JSP コーディングルール）。
- GITWEB-03 デモにパターンを網羅している（カセット要件が複数ある場合や、電話番号あり / なし など）。
- GITWEB-04 ログ関連の suumo.jp 本番パスを検品パスに修正している。
  - `//suumo.jp/front/tag/stmt/stmt_sp.js`
  - `//suumo.jp/sp/js/s_code_prd.js`
  - `//suumo.jp/sp/js/catalyst.js`
- GITWEB-05 差し込みファイル内だけで完結するモジュール設計になっている（可能な範囲で）。
- GITWEB-06 改行コードが CRLF になっている（既存に合わせる）。
- GITWEB-07 インデントがタブになっている（既存に合わせる）。
- GITWEB-08 命名規則に則った差し込みファイル名になっている / 事前に決めている。
- GITWEB-09 差し込みファイルのコメントが規定どおり書かれている（3 行はインデントなし。= は長さが足りなければ他の差し込みファイルに合わせる）。
    ```
    <!-- ↓============================================↓ -->
    <!-- ↓/detail/KR_100_000_CF_kaisha_seoparts.html↓ -->
    <div class="l-section_h2"> </div>
    <!-- ↑/detail/KR_100_000_CF_kaisha_seoparts.html↑ -->
    <!-- ↑============================================↑ -->
    ```
- GITWEB-10 他モジュール・他画面に影響のある修正を行っていない。

## 対象外（他の観点で見る）
- 汎用マークアップ（Validator、width/height 等） → markup
