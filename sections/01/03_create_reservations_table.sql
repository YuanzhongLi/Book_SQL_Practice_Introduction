CREATE TABLE Reservations (
 reserve_id    INTEGER  NOT NULL,
 shop_id       CHAR(5),
 reserve_name  VARCHAR(64),
   CONSTRAINT pk_reservations PRIMARY KEY (reserve_id));
