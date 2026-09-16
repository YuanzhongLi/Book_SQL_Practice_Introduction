CREATE TABLE Shops (
 shop_id    CHAR(5) NOT NULL,
 shop_name  VARCHAR(64),
 rating     INTEGER,
 area       VARCHAR(64),
   CONSTRAINT pk_shops PRIMARY KEY (shop_id));
