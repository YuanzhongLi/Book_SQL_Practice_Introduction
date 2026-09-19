CREATE TABLE Sales
(company CHAR(1) NOT NULL,
 year    INTEGER NOT NULL ,
 sale    INTEGER NOT NULL ,
   CONSTRAINT pk_sales PRIMARY KEY (company, year));
