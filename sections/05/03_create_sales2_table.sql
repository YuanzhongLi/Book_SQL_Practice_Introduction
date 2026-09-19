CREATE TABLE Sales2
(company CHAR(1) NOT NULL,
 year    INTEGER NOT NULL ,
 sale    INTEGER NOT NULL ,
 var     CHAR(1) ,
   CONSTRAINT pk_sales2 PRIMARY KEY (company, year));
