CREATE TABLE Receipts
(cust_id   CHAR(1) NOT NULL,
 seq   INTEGER NOT NULL,
 price   INTEGER NOT NULL,
     PRIMARY KEY (cust_id, seq));
