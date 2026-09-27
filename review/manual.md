# 手動確認項目
# 書式：- [when: 条件1, 条件2] 確認内容
# 条件：css / markup / image / delete / log / vwo / always
# 組み合わせ：条件を複数書いた場合は「いずれか」を満たせば質問する

- [when: css, markup] SP 幅 320px で表示崩れ（要素のはみ出しなど）がないか
- [when: css, markup] 連続した半角・全角英数字や長い文字列を入れても、スタイルが崩れないか
- [when: css] テキストと背景のコントラストが十分か（WCAG AA：通常テキスト 4.5:1 以上）
- [when: markup] HTML Validator でエラーがないか
- [when: image] デザイン上のサイズと書き出し後のサイズに差がないか（差がある場合、デザイナーに整数値での再書き出しを依頼したか）
- [when: image] 画像の書き出し倍率が正しいか（PC 1 倍 / SP 2 倍。デザイナーの要望がある場合や周囲の画像が 2 倍の場合は PC も 2 倍）
- [when: image, css] スプライト画像がずれていないか
- [when: log] ビーコン・サイカタ・suit コードなどのログが実際に送信されているか
- [when: vwo] VWO 側に記述された JS を確認したか
- [when: vwo] VWO 側に記述された CSS を確認したか
- [when: delete] 削除したファイルが検品環境からも削除されているか
- [when: markup] （git-web）デモのソースを Source パネルから取得したか（DevTools から HTML を取得していないか）
- [always] （FM）AB テスト＋恒久対応を含む案件の場合、リリース後に恒久対応分のみ master にマージできるよう、ブランチを分けているか
- [always] 推奨環境（PC / SP）での確認は済んでいるか（軽微な内容や既存実装の横展開の場合は省略可）
