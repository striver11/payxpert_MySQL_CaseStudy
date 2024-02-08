CREATE DATABASE PAYXPERT;
USE PAYXPERT2;

CREATE TABLE EMPLOYEE(
EmployeeID INT PRIMARY KEY auto_increment,
FirstName VARCHAR(60) NOT NULL,
LastName VARCHAR(50) NOT NULL,
DateOfBirth DATE NOT NULL,
Gender VARCHAR(20) NOT NULL,
Email VARCHAR(60) UNIQUE NOT NULL,
PhoneNumber VARCHAR(20) UNIQUE NOT NULL,
ADDRESS  VARCHAR(100) NOT NULL,
Position VARCHAR(30) NOT NULL,
JoiningDate DATE NOT NULL,
TerminationDate DATE default null
 );


 
 CREATE TABLE Payroll(
 PayrollID INT PRIMARY KEY AUTO_INCREMENT,
 EmployeeID INT,
 PayPeriodStartDate DATE NOT NULL,
 PayPeriodEndDate DATE NOT NULL,
 BasicSalary DECIMAL(10,2) NOT NULL DEFAULT 0,
 OvertimePay DECIMAL(10,2) NOT NULL DEFAULT 0,
 otherpay DECIMAL(10,2) default NULL DEFAULT 0,
 Deductions DECIMAL(10,2) NOT NULL DEFAULT 0,	
 GrossSalary DECIMAL(10,2) NOT NULL DEFAULT 0,
 TaxAmount decimal(10,2) not null default 0,
 NetSalary DECIMAL(10,2) not null DEFAULT 0,
 FOREIGN KEY (EmployeeID) REFERENCES EMPLOYEE(EmployeeID)
 );
 





 CREATE TABLE Tax(
 TaxID INT PRIMARY KEY AUTO_INCREMENT,
 EmployeeID INT,
TaxYear  INT NOT NULL,
 TaxableIncome DECIMAL(10,2) NOT NULL DEFAULT 0,
 TaxAmount DECIMAL(10,2) NOT NULL DEFAULT 0,
 FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
 );
 

DELIMITER //

CREATE TRIGGER combinedPayrollTriggers
BEFORE INSERT ON Payroll
FOR EACH ROW
BEGIN
    DECLARE tax_amount DECIMAL(10, 2);

-- here in this trigger i am calculating the GrossSalary by adding BasicSalary,BasicSalary,OtherPay and subracting Deductions
    SET NEW.GrossSalary = NEW.BasicSalary + NEW.OvertimePay + NEW.OtherPay - NEW.Deductions;
    
    
-- trigger 2: here in this trigger i am calculating the Monthly Tax and Updating Net Salary
    IF NEW.GrossSalary <= 20833 THEN
        SET tax_amount = 0;
    ELSEIF NEW.GrossSalary <= 41667 THEN
        SET tax_amount = (NEW.GrossSalary - 20833) * 0.05;
    ELSEIF NEW.GrossSalary <= 62500 THEN
        SET tax_amount = (NEW.GrossSalary - 41667) * 0.10 + 1042;
    ELSEIF NEW.GrossSalary <= 83333 THEN
        SET tax_amount = (NEW.GrossSalary - 62500) * 0.15 + 3125;
    ELSEIF NEW.GrossSalary <= 104167 THEN
        SET tax_amount = (NEW.GrossSalary - 83333) * 0.20 + 6250;
    ELSEIF NEW.GrossSalary <= 125000 THEN
        SET tax_amount = (NEW.GrossSalary - 104167) * 0.25 + 10417;
    ELSE
        SET tax_amount = (NEW.GrossSalary - 125000) * 0.30 + 15625;
    END IF;

-- here i am setting the TaxAmount in payroll table explicityly
    SET NEW.TaxAmount = tax_amount; 

    SET NEW.NetSalary = NEW.GrossSalary - tax_amount;

    INSERT INTO Tax (EmployeeID, TaxYear, TaxableIncome, TaxAmount)
    VALUES (NEW.EmployeeID, YEAR(CURDATE()), NEW.GrossSalary, tax_amount);

    --  here in this trigger i am Updating Financial Records
    INSERT INTO FinancialRecord (EmployeeID, RecordDate, Descriptions, Amount, RecordType)
    VALUES (NEW.EmployeeID, NEW.PayPeriodEndDate, 'Base Salary Payment credited', NEW.BasicSalary, 'BasicSalary'),
           (NEW.EmployeeID, NEW.PayPeriodEndDate, 'Overtime Payment credited', NEW.OvertimePay, 'OvertimePay'),
           (NEW.EmployeeID, NEW.PayPeriodEndDate, 'Incentive/reimbursement/bonus credited', NEW.OtherPay, 'OtherPay'),
           (NEW.EmployeeID, NEW.PayPeriodEndDate, 'Loan or PF or Insurance Premium debited', NEW.Deductions, 'Deductions'),
           (NEW.EmployeeID, NEW.PayPeriodEndDate, 'Gross Salary credited', NEW.GrossSalary, 'GrossSalary'),
           (NEW.EmployeeID, NEW.PayPeriodEndDate, 'Tax Amount debited', tax_amount, 'TaxAmount'),
           (NEW.EmployeeID, NEW.PayPeriodEndDate, 'Net Salary credited', NEW.NetSalary, 'NetSalary');
END;
//

DELIMITER ;


 
 CREATE TABLE FinancialRecord(
 RecordID INT PRIMARY KEY AUTO_INCREMENT,
 EmployeeID INT,
 RecordDate DATE not null,
 Descriptions VARCHAR(300) NOT NULL,
 Amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
 RecordType VARCHAR(150) NOT NULL,
 FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
 );
 

 INSERT INTO EMPLOYEE (FirstName, LastName, DateOfBirth, Gender, Email, PhoneNumber, ADDRESS, Position, JoiningDate, TerminationDate)
VALUES
('Rahul', 'Sharma', '1990-05-15','Male', 'rahulsharma@email.com', '123-456-7890', '123-6-7 ,Ramnagar Street,Ananthapur -515001,Andhra Pradesh, India', 'Manager', '2020-01-10', NULL),
('Priya', 'Patel', '1985-08-22','FeMale', 'priyapatel@email.com', '987-654-3210', '456-54-88, Oak Street,Kasaragod -671121,Kerala , India', 'Developer', '2019-07-03', NULL),
('Suresh', 'Singh', '1978-12-10','Male', 'sureshsingh@email.com', '555-123-4567', '789-9-77 ,Kamala Nagar,Ananthapur -515001,Andhra Pradesh, India', 'Analyst', '2021-02-28', NULL),
('Ananya', 'Desai', '1995-03-03', 'FeMale','ananyadesai@email.com', '111-222-3333', '101-55-87,Church Street,Bengaluru -560070 ,Karnataka, India', 'Designer', '2020-09-15', NULL),
('Arjun', 'Mehta', '1980-07-18','Male', 'arjunmehta@email.com', '999-888-7777', '202-6-5, BEML Street, Bengaluru -560066,Karnataka , India', 'Engineer', '2018-04-20', NULL),
('Nisha', 'Kapoor', '1992-09-28','FeMale', 'nishakapoor@email.com', '777-666-5555', '454-9-45, Bazaar Lane Street, Mylapore,Chennai  - 600 004.,Tamil Nadu, India', 'Coordinator', '2019-11-12', NULL),
('Rajesh', 'Verma', '1983-04-12','Male', 'rajeshverma@email.com', '444-333-2222', '21-5-64, Sabari Street, Chennai - 600 078.,Tamil Nadu, India', 'Supervisor', '2021-05-03', NULL),
('Pooja', 'Joshi', '1998-11-05','FeMale', 'poojajoshi@email.com', '666-777-8888', '505-5-54, Walnut Street,Kollam -601021,Kerala, India', 'Manager', '2018-12-07', NULL),
('Sanjay', 'Khanna', '1975-06-20','Male', 'sanjaykhanna@email.com', '222-555-9999', '606-6-54, Srinivas Nagar Street,Ananthapur -515001,Andhra Pradesh, India', 'Developer', '2017-06-25', NULL),
('Deepa', 'Reddy', '1987-02-14','Male', 'deepareddy@email.com', '888-444-1111', '707-7-57, oldtown St, Ananthapur -515001,Andhra Pradesh, India', 'Analyst', '2022-03-18', NULL);


INSERT INTO Payroll (EmployeeID, PayPeriodStartDate, PayPeriodEndDate, BasicSalary, OvertimePay, OtherPay, Deductions, GrossSalary, NetSalary)
VALUES
(1, '2023-01-01', '2023-01-31', 50000.00, 3000.00, 2300.00, 2000, 53300.00, 0.00),
(2, '2023-01-01', '2023-01-31', 45000.00, 2500.00, 1800.00, 1500, 47700.00, 0.00),
(3, '2023-01-01', '2023-01-31', 55000.00, 3200.00, 2500.00, 1800, 59700.00, 0.00),
(4, '2023-01-01', '2023-01-31', 48000.00, 2800.00, 2000.00, 1200, 51800.00, 0.00),
(5, '2023-01-01', '2023-01-31', 60000.00, 3500.00, 2800.00, 2500, 64200.00, 0.00),
(6, '2023-01-01', '2023-01-31', 52000.00, 3000.00, 2300.00, 2000, 55300.00, 0.00),
(7, '2023-01-01', '2023-01-31', 47000.00, 2400.00, 1700.00, 1200, 49300.00, 0.00),
(8, '2023-01-01', '2023-01-31', 58000.00, 3100.00, 2400.00, 1800, 60700.00, 0.00),
(9, '2023-01-01', '2023-01-31', 51000.00, 2800.00, 2100.00, 1500, 54400.00, 0.00),
(10, '2023-01-01', '2023-01-31', 49000.00, 2600.00, 1900.00, 1300, 52600.00, 0.00);


INSERT INTO FinancialRecord ( EmployeeID, RecordDate, Descriptions, Amount, RecordType)
VALUES
(1, '2023-01-01', 'January BasicSalary', 50000.00, 'BasicSalary'),
(1, '2023-01-01', 'January OvertimePay', 3000.00, 'OvertimePay'),
(1, '2023-01-01', 'January Incentive', 2300.00, 'OtherPay'),
(1, '2023-01-01', 'January Insurance Premium Deduction', 1700.00, 'Deductions'),
(1, '2023-01-01', 'January Leave Deduction', 300.00, 'Deductions'),
(1, '2023-01-01', 'January GrossSalary', 53300.00, 'GrossSalary'),
(1, '2023-01-01', 'January NetSalary', 51094.70, 'NetSalary'),
(2, '2023-01-01', 'January BasicSalary', 45000.00, 'BasicSalary'),
(2, '2023-01-01', 'January OvertimePay', 2500.00, 'OvertimePay'),
(2, '2023-01-01', 'January Incentive', 1800.00, 'OtherPay'),
( 2, '2023-01-01', 'January Insurance Premium Deduction', 1500.00, 'Deductions'),
( 2, '2023-01-01', 'January GrossSalary', 47700.00, 'GrossSalary'),
( 2, '2023-01-01', 'January NetSalary', 46294.70, 'NetSalary'),
( 3, '2023-01-01', 'January BasicSalary', 55000.00, 'BasicSalary'),
( 3, '2023-01-01', 'January OvertimePay', 3200.00, 'OvertimePay'),
( 3, '2023-01-01', 'January Incentive', 2500.00, 'OtherPay'),
( 3, '2023-01-01', 'January Insurance Premium Deduction', 1800.00, 'Deductions'),
( 3, '2023-01-01', 'January GrossSalary', 59700.00, 'GrossSalary'),
( 3, '2023-01-01', 'January NetSalary', 57694.70, 'NetSalary'),
( 4, '2023-01-01', 'January BasicSalary', 48000.00, 'BasicSalary'),
( 4, '2023-01-01', 'January OvertimePay', 2800.00, 'OvertimePay'),
( 4, '2023-01-01', 'January Incentive', 2000.00, 'OtherPay'),
( 4, '2023-01-01', 'January  Insurance Premium Deduction', 1200.00, 'Deductions'),
( 4, '2023-01-01', 'January GrossSalary', 51800.00, 'GrossSalary'),
( 4, '2023-01-01', 'January NetSalary', 50694.70, 'NetSalary'),
( 5, '2023-01-01', 'January BasicSalary', 60000.00, 'BasicSalary'),
( 5, '2023-01-01', 'January OvertimePay', 3500.00, 'OvertimePay'),
( 5, '2023-01-01', 'January Incentive', 2800.00, 'OtherPay'),
( 5, '2023-01-01', 'January Insurance Premium Deduction', 1900.00, 'Deductions'),
( 5, '2023-01-01', 'January Leave Deduction', 600.00, 'Deductions'),
( 5, '2023-01-01', 'January GrossSalary', 64200.00, 'GrossSalary'),
( 5, '2023-01-01', 'January NetSalary', 61700.00, 'NetSalary'),
( 6, '2023-01-01', 'January BasicSalary', 52000.00, 'BasicSalary'),
( 6, '2023-01-01', 'January OvertimePay', 3000.00, 'OvertimePay'),
( 6, '2023-01-01', 'January Incentive', 2300.00, 'OtherPay'),
( 6, '2023-01-01', 'January Insurance Premium Deduction', 2000.00, 'Deductions'),
( 6, '2023-01-01', 'January GrossSalary', 55300.00, 'GrossSalary'),
( 6, '2023-01-01', 'January NetSalary', 53394.70, 'NetSalary'),
( 7, '2023-01-01', 'January BasicSalary', 47000.00, 'BasicSalary'),
( 7, '2023-01-01', 'January OvertimePay', 2400.00, 'OvertimePay'),
( 7, '2023-01-01', 'January Incentive', 1700.00, 'OtherPay'),
( 7, '2023-01-01', 'January Insurance Premium Deduction', 1200.00, 'Deductions'),
( 7, '2023-01-01', 'January GrossSalary', 49300.00, 'GrossSalary'),
( 7, '2023-01-01', 'January NetSalary', 48194.70, 'NetSalary'),
( 8, '2023-01-01', 'January BasicSalary', 58000.00, 'BasicSalary'),
( 8, '2023-01-01', 'January OvertimePay', 3100.00, 'OvertimePay'),
( 8, '2023-01-01', 'January Incentive', 2400.00, 'OtherPay'),
( 8, '2023-01-01', 'January Insurance Premium Deduction', 1800.00, 'Deductions'),
( 8, '2023-01-01', 'January GrossSalary', 60700.00, 'GrossSalary'),
( 8, '2023-01-01', 'January NetSalary', 58994.70, 'NetSalary'),
( 9, '2023-01-01', 'January BasicSalary', 51000.00, 'BasicSalary'),
( 9, '2023-01-01', 'January OvertimePay', 2800.00, 'OvertimePay'),
( 9, '2023-01-01', 'January Incentive', 2100.00, 'OtherPay'),
( 9, '2023-01-01', 'January Insurance Premium Deduction', 1500.00, 'Deductions'),
( 9, '2023-01-01', 'January GrossSalary', 54400.00, 'GrossSalary'),
( 9, '2023-01-01', 'January NetSalary', 52994.70, 'NetSalary'),
( 10, '2023-01-01', 'January BasicSalary', 49000.00, 'BasicSalary'),
( 10, '2023-01-01', 'January OvertimePay', 2600.00, 'OvertimePay'),
( 10, '2023-01-01', 'January Incentive', 1900.00, 'OtherPay'),
( 10, '2023-01-01', 'January Insurance Premium Deduction', 1300.00, 'Deductions'),
( 10, '2023-01-01', 'January GrossSalary', 52600.00, 'GrossSalary'),
( 10, '2023-01-01', 'January NetSalary', 51394.70, 'NetSalary');	

select * from employee;
select * from payroll;
select * from tax;
select * from FinancialRecord;



drop table payroll;
drop table tax;
drop table FinancialRecord;