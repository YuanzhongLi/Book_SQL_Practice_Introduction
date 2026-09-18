CREATE TABLE Items
(   item_id     INTEGER  NOT NULL,
       year     INTEGER  NOT NULL,
  item_name     CHAR(32) NOT NULL,
  price_tax_ex  INTEGER  NOT NULL,
  price_tax_in  INTEGER  NOT NULL,
  PRIMARY KEY (item_id, year));
