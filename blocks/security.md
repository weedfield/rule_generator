## セキュリティ

- API キー・トークンなどの秘匿情報がハードコード / コミットされていないか。
- ユーザー入力や外部データを、サニタイズせずに innerHTML / html() などへ渡していないか(XSS)。
- target="_blank" の外部リンクに rel="noopener"(必要に応じて noreferrer)が付いているか。
- eval / new Function など危険な動的実行を使っていないか。
