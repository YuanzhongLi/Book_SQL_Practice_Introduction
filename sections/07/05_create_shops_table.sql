CREATE TABLE Shops
(co_cd      CHAR(3) NOT NULL,
 shop_id    CHAR(3) NOT NULL,
 emp_nbr    INTEGER NOT NULL,
 main_flg   CHAR(1) NOT NULL,
     PRIMARY KEY (co_cd, shop_id));
