CREATE TABLE PriceByAge
(product_id VARCHAR(32) NOT NULL,
 low_age    INTEGER NOT NULL,
 high_age   INTEGER NOT NULL,
 price      INTEGER NOT NULL,
 PRIMARY KEY (product_id, low_age),
   CHECK (low_age < high_age));
