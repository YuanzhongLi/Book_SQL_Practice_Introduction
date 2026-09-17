# 第2章 SQLの基礎 母国語を話すがごとく

## 1. OR条件とIN条件

OR条件を複数指定する場合:
```sql
SELECT name, address
  FROM Address
 WHERE address = '東京都'
    OR address = '福島県'
    OR address = '千葉県';
```

同じ条件をINでまとめて書ける:
```sql
SELECT name, address
  FROM Address
 WHERE address IN ('東京都', '福島県', '千葉県');
```

## 2. NULLの扱い方

NULLは「値が不明」を表すため`=`では比較できず、常にUNKNOWN（真でも偽でもない）になる。そのため次のクエリは意図通りに動かない。
```sql
SELECT name, address
  FROM Address
 WHERE phone_nbr = NULL;  -- 常にUNKNOWNになり1行も返らない
```

NULL判定には`IS NULL` / `IS NOT NULL`を使う。
```sql
SELECT name, phone_nbr
  FROM Address
 WHERE phone_nbr IS NULL;

SELECT name, phone_nbr
  FROM Address
 WHERE phone_nbr IS NOT NULL;
```

## 3. GROUP BY句

テーブルをグループごとに分けて集計する句。

住所別に人数を数える例:
```sql
SELECT address, COUNT(*)
  FROM Address
 GROUP BY address;
```

テーブル全体を1グループとして数える例:
```sql
SELECT COUNT(*)
  FROM Address
 GROUP BY ( );  -- 空のグループ化＝全体を1グループとして扱う

SELECT COUNT(*)
  FROM Address;  -- 集約関数のみでGROUP BY句を省略しても同じ意味になる（一般的にはこちらを使う）
```

## 4. HAVING句

GROUP BY句でグループ化した後、集計結果に対して条件で絞り込む句。

人数がちょうど1人の住所を抽出する例:
```sql
SELECT address, COUNT(*)
  FROM Address
 GROUP BY address
HAVING COUNT(*) = 1;
```

## 5. ORDER BY句

SELECT文の結果を特定の列の値で並べ替える句。

年齢が高い順に並べる例:
```sql
SELECT name, phone_nbr, address, sex, age
  FROM Address
 ORDER BY age DESC;
```

## 6. VIEW

SELECT文を保存して再利用する仕組み。ビューはデータを実際に保持しているわけではなく、あくまでSELECT文そのものを保存したものであり、実行時にはそのSELECT文に展開される。

住所ごとの人数をまとめたビューを作成する場合:
```sql
CREATE VIEW CountAddress (v_address, cnt)
AS
SELECT address, COUNT(*)
  FROM Address
 GROUP BY address;
```

作成したビューの利用と、実行時に展開される実体:
```sql
-- ビューからデータを選択する
SELECT v_address, cnt
  FROM CountAddress;

-- ビューは実行時にはSELECT文に展開される
SELECT v_address, cnt
  FROM (SELECT address AS v_address, COUNT(*) AS cnt
          FROM Address
         GROUP BY address) AS CountAddress;
```

**ポイント**: SELECT文の閉包性とは、SELECT文はtableを受け取りtableを返すという性質のこと。この性質により、ビュー（SELECT文の結果）もまたtableとして扱うことができる。

## 7. サブクエリ

SELECT文の中に含まれる別のSELECT文。サブクエリを使うことで、より柔軟な条件指定や集計が可能になる。

Address2テーブルに存在する名前をAddressテーブルから抽出する例:
```sql
SELECT name
  FROM Address
 WHERE name IN (SELECT name  -- INの中にサブクエリ
                  FROM Address2);
```

## 8. CASE式

条件に応じて異なる値を返す式。SELECT句だけでなく、WHERE, ORDER BY, GROUP BY, HAVING句など式が使える場所ならどこでも利用できる。

住所に応じて地方を分類する例:
```sql
SELECT name, address,
       CASE WHEN address = '東京都' THEN '関東'
            WHEN address = '千葉県' THEN '関東'
            WHEN address = '福島県' THEN '東北'
            WHEN address = '三重県' THEN '中部'
            WHEN address = '和歌山県' THEN '関西'
            ELSE NULL END AS district
  FROM Address;
```

### 集約関数との組み合わせ（条件付き集計）

CASE式とCOUNTを組み合わせると、条件ごとの集計ができる。住所ごとの男女別人数を数える例:
```sql
SELECT address,
       COUNT(CASE WHEN sex = '男' THEN 1 END) AS male_count,
       COUNT(CASE WHEN sex = '女' THEN 1 END) AS female_count
  FROM Address
 GROUP BY address;
```

`COUNT`はNULLをカウントしないため、`THEN 1`（条件を満たす場合のみ1、それ以外は暗黙の`ELSE NULL`）と組み合わせることで、条件を満たす行だけがカウントされる。`1`の部分は任意の値でよく、重要なのは「条件を満たす場合にNULLでない値を返す」こと。次のクエリも同じ結果になる。
```sql
SELECT address,
       COUNT(CASE WHEN sex = '男' THEN sex ELSE NULL END) AS male_count,
       COUNT(CASE WHEN sex = '女' THEN sex ELSE NULL END) AS female_count
  FROM Address
 GROUP BY address;
```

**注意: `sex IS NULL`の行の扱い**

SQLの比較演算はTRUE/FALSE/UNKNOWNの3値を取り、`sex`がNULLなら`sex = '男'`も`sex = '女'`もUNKNOWNになる。`CASE WHEN`はTRUEの場合しかマッチしないため、UNKNOWNではどちらのWHENにも該当せず暗黙の`ELSE NULL`になり、`COUNT`はそれを数えない。結果として`sex IS NULL`の行は**二重カウントされるのではなく、male/female両方から抜け落ちる**。そのため`male_count + female_count`は`COUNT(*)`と一致しなくなる場合がある（例: 総数5人中1人がNULLなら`male_count + female_count = 4`）。NULLも明示的に集計したいなら第3のバケツを用意する。
```sql
SELECT address,
       COUNT(CASE WHEN sex = '男' THEN 1 END) AS male_count,
       COUNT(CASE WHEN sex = '女' THEN 1 END) AS female_count,
       COUNT(CASE WHEN sex IS NULL THEN 1 END) AS unknown_count
  FROM Address
 GROUP BY address;
```

### COUNT(*) / COUNT(カラム名) / COUNT(1)の違い

- `COUNT(*)`: 行の存在そのものを数える。特定のカラムを参照しないため、どのカラムがNULLかに関係なく全行が対象になる
- `COUNT(カラム名)`: そのカラムがNOT NULLの行だけが対象になる
- `COUNT(1)`: `1`という定数を数える。`1`はどの行でも常に評価されNULLになることが絶対にないため、結局は全行が対象になり`COUNT(*)`と完全に同じ結果になる

## 9. 集合演算

- `UNION`: 結果セットを結合し、重複行を排除する
- `UNION ALL`: 結果セットを結合し、重複行も含める
- `INTERSECT`: 両方の結果セットに共通する行だけを返す
- `EXCEPT`: 最初の結果セットに存在し、2番目の結果セットに存在しない行を返す

## 10. ウィンドウ関数

集計関数のようにグループ化して行を集約することなく、結果セットの各行に対して計算を行う関数。

住所別人数を調べる例:
```sql
SELECT address,
       COUNT(*) OVER(PARTITION BY address)
  FROM Address;
```

ランキングを付ける例:
```sql
SELECT name,
       age,
       RANK() OVER(ORDER BY age DESC) AS rnk
  FROM Address;
```

ランキング（同順位でも欠番を作らない場合）:
```sql
SELECT name,
       age,
       DENSE_RANK() OVER(ORDER BY age DESC) AS dense_rnk
  FROM Address;
```

性別ごとにランキングを付ける例（`PARTITION BY`でグループごとに順位をリセットする）:
```sql
SELECT name,
       age,
       sex,
       RANK() OVER(PARTITION BY sex ORDER BY age DESC) AS rnk
  FROM Address;

name    age  sex  rnk
井上    55   女   1
佐藤    25   女   2
前田    21   女   3
松本    20   女   4
佐々木  19   女   5
森      45   男   1
鈴木    32   男   2
林      32   男   2
小川    30   男   4
```

`ORDER BY age DESC`を外側に付けても、`rnk`はパーティション内で計算された値のまま変わらない（表示順序が変わるだけ）。
```sql
SELECT name,
       age,
       sex,
       RANK() OVER(PARTITION BY sex ORDER BY age DESC) AS rnk
  FROM Address
 ORDER BY age DESC;

name    age  sex  rnk
井上    55   女   1
森      45   男   1
林      32   男   2
鈴木    32   男   2
小川    30   男   4
佐藤    25   女   2
前田    21   女   3
松本    20   女   4
佐々木  19   女   5
```

集約結果（GROUP BY）に対して、さらにウィンドウ関数で全体集計を重ねることもできる。住所ごとの男性人数と、全体の男性人数を同時に取得する例:
```sql
SELECT address,
       COUNT(CASE WHEN sex = '男' THEN 1 END) AS male_count,
       SUM(COUNT(CASE WHEN sex = '男' THEN 1 END)) OVER () AS total_male_count
  FROM Address
 GROUP BY address;

address   male_count  total_male_count
千葉県    0           4
福島県    1           4
東京都    2           4
和歌山県  1           4
三重県    0           4
```

`OVER ()`はウィンドウ（集計対象範囲）を指定する部分で、空の場合は結果セット全体が1つのウィンドウになる。ウィンドウ関数はGROUP BYによる集約の後に評価されるため、集約関数の結果（`COUNT(...)`）をさらにウィンドウ関数（`SUM(...) OVER ()`）で集計できる。

## 11. INSERT, UPDATE, DELETE

### INSERT

複数行を1つの文でまとめて追加する:
```sql
INSERT INTO Address (name, phone_nbr, address, sex, age)
              VALUES('小川', '080-3333-XXXX', '東京都', '男', 30),
                    ('前田', '090-0000-XXXX', '東京都', '女', 21),
                    ('森', '090-2984-XXXX', '東京都', '男', 45),
                    ('林', '080-3333-XXXX', '福島県', '男', 32),
                    ('井上', NULL, '福島県', '女', 55),
                    ('佐々木', '080-5848-XXXX', '千葉県', '女', 19),
                    ('松本', NULL, '千葉県', '女', 20),
                    ('佐藤', '090-1922-XXXX', '三重県', '女', 25),
                    ('鈴木', '090-0001-XXXX', '和歌山県', '男', 32);
```

### DELETE

全件削除:
```sql
DELETE FROM Address;
```

条件付きで一部だけ削除する。DELETEは列を指定しない。行単位で削除する文だから。
```sql
DELETE FROM Address
 WHERE address = '千葉県';
```

### UPDATE

1件だけ更新する例（佐々木さんの電話番号を更新）:
```sql
UPDATE Address
   SET phone_nbr = '080-5849-XXXX'
 WHERE name = '佐々木';
```

複数列を1つのUPDATE文でまとめて更新する2通りの書き方:
```sql
-- 1. 列をカンマ区切りで並べる
UPDATE Address
   SET phone_nbr = '080-5848-XXXX',
       age = 20
 WHERE name = '佐々木';

-- 2. 列を括弧で囲むリスト表現
UPDATE Address
   SET (phone_nbr, age) = ('080-5848-XXXX', 20)
 WHERE name = '佐々木';
```

## まとめ: SQLの論理的な実行順序

本章で登場した句は、書く順序と実際に評価される順序が異なる。

```mermaid
flowchart LR
    A["FROM
    テーブルを決定"] --> B["WHERE
    行を絞り込む"]
    B --> C["GROUP BY
    グループ化"]
    C --> D["HAVING
    グループを絞り込む"]
    D --> E["SELECT
    列・CASE式・ウィンドウ関数を評価"]
    E --> F["ORDER BY
    並べ替え"]
```

`WHERE`は集約前の行に対する条件、`HAVING`は集約後のグループに対する条件、という違いを意識して使い分ける。ウィンドウ関数はGROUP BYの後・SELECTの評価時に計算されるため、集約関数の結果をさらにウィンドウ関数で集計できる（例: 10章の`SUM(COUNT(...)) OVER ()`）。
