---
name: seisho-section-notes
description: Clean up a chapter's practice notes at sections/NN/README.md in this SQL book repo (Book_SQL_Practice_Introduction) — remove polite/keigo phrasing, cut redundancy without losing information, verify every SQL/technical claim for correctness and fix errors, and match the established style of sections/01 and sections/02. Use when the user asks to "清書して" / "clean up" / tidy up a section's README notes, or after a long back-and-forth Q&A has accumulated raw pasted answers in a section README that need consolidating.
---

# セクションノート清書 (seisho-section-notes)

`sections/NN/README.md` は本の各章に対する自分用の学習メモ。対話の中で得た解説をそのまま貼り付けていくため、丁寧語・重複・生の会話ログ的な体裁が溜まっていく。このスキルは、それを`sections/01/README.md`・`sections/02/README.md`と同じ文体・構成の「清書済みノート」に整形する。

## 事前確認

1. 対象ファイル `sections/NN/README.md` を全部読む（`wc -l`で行数確認の上、必要なら`offset`をずらして読み切ること。取りこぼすと情報を落とす）
2. スタイルの基準として `sections/01/README.md` と `sections/02/README.md` を読み、見出し構成・トーン・図の使い方を確認する
3. 同じディレクトリの `*.sql` ファイル（テーブル定義・INSERT文）があれば読み、README中のSQL例やEXPLAIN結果が実際のスキーマ・データと整合するか照合する

## 清書の方針

- **情報量を落とさない**: 既存の説明・SQL例・EXPLAIN結果・数値は原則すべて残す。会話ログとして生で貼られた説明文は、内容を保ったまま正式な文章に書き直して該当セクションに統合する（重複する説明は1箇所にまとめる）
- **丁寧語を除去**: です・ます調を一切使わず、常体（だ・である調、体言止め）に統一する
- **冗長性を削る**: 同じ内容を別の言い回しで繰り返している箇所は1つにまとめる。ただし意味が変わる情報を安易に間引かない
- **見出しの穴埋め**: `### `のようにタイトルが空の見出しは、その節の内容から適切なタイトルを付ける
- **コードブロックの整形**: SQLとその実行結果（EXPLAIN出力など）は```sql フェンスで統一する。psqlからのコピペで紛れ込んだ余計な引用符（例: `"  Filter: ..."`のような行頭行末の`"`）は取り除く。`null`/`NULL`などの表記ゆれは統一する
- **章末に軽い図解を足す**: 章全体の要点を1枚で振り返れる図（mermaidのflowchart、または簡潔な比較表）を追加する。新しい事実を作り出すのではなく、章内で既に説明した内容を可視化するだけに留める

## 技術的な正しさの検証（必須）

清書はスタイル修正だけでなく、内容の技術的検証も兼ねる。

1. README中のSQLが、実在するテーブル定義（同ディレクトリの`*_create_*.sql`）のカラム名・型と矛盾していないか確認する
2. `COUNT`/`SUM`/`CASE`/`NULL`比較/三値論理などSQLの意味論に関する説明は、標準的なSQL・PostgreSQLの挙動と照らして正確か検証する。あいまいな場合は`docker-compose`経由でローカルDBに接続し実際にクエリを実行して確認する（このリポジトリには`Makefile`と`docker-compose.yaml`がある）
3. サンプルデータを使った計算例（人口の合計、ランキングの順位など）は、実際のデータで手計算し、README記載の結果と一致するか検算する
4. 誤りや矛盾（説明文とSQLが食い違っている、計算結果が合わない、等）を見つけたら、SQL側とテキスト側のどちらが正であるべきかを判断し、必ず修正する。ユーザーから正とすべき側の指示がある場合はそれに従う
5. 見つけた誤りは、清書後にユーザーへの報告で簡潔に列挙する（何を・なぜ直したか）

## 実行手順

1. 対象の`sections/NN/README.md`を全文読む
2. 内容を精査し、誤り・矛盾・冗長箇所・空見出しを洗い出す
3. `sections/01`・`sections/02`のトーンに合わせて全文を書き直す（Writeツールで丸ごと置き換える。差分が大きいため部分編集より書き直しが確実）
4. 章末にmermaid図または比較表を追加する
5. ユーザーに、直した誤りとその理由を簡潔に報告する（清書した旨だけでなく、正誤の修正点を明示する）

## 注意

- 対象はあくまで学習者本人のメモであり、本の原文そのものではない。原文の解釈や補足として書かれた自分の言葉による説明は尊重しつつ、技術的な誤りは遠慮なく正す
- 大きな書き直しになるため、Editではなく`Read`で全文を確認した上で`Write`で全体を置き換える
- git管理下のファイルなので、清書後に`git diff`で意図しない情報欠落が無いか一度確認するとよい
