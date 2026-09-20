CREATE TABLE Employees
(emp_id CHAR(8),
 emp_name VARCHAR(32),
 dept_id CHAR(2),
     CONSTRAINT pk_emp PRIMARY KEY(emp_id));

CREATE INDEX idx_dept_id ON Employees(dept_id);
