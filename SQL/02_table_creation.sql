CREATE TABLE bankchurners (
CLIENTNUM BIGINT PRIMARY KEY,
Attrition_Flag VARCHAR(50),
Customer_Age INT,
Gender VARCHAR(10),
Dependent_count INT,
Education_Level VARCHAR(50),
Marital_Status VARCHAR(50),
Income_Category VARCHAR(50),
Card_Category VARCHAR(50),
Months_on_book INT,
Total_Relationship_Count INT,
Months_Inactive_12_mon INT,
Contacts_Count_12_mon INT,
Credit_Limit FLOAT,
Total_Revolving_Bal FLOAT,
Avg_Open_To_Buy FLOAT,
Total_Amt_Chng_Q4_Q1 FLOAT,
Total_Trans_Amt FLOAT,
Total_Trans_Ct INT,
Total_Ct_Chng_Q4_Q1 FLOAT,
Avg_Utilization_Ratio FLOAT
);

-- Backward compatibility view
CREATE VIEW credit_card_customers AS SELECT * FROM bankchurners;
