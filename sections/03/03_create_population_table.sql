CREATE TABLE Population
(prefecture VARCHAR(32),
 sex        CHAR(1),
 pop        INTEGER,
     CONSTRAINT pk_pop PRIMARY KEY(prefecture, sex));
