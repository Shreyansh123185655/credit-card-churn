#!/usr/bin/env python3
"""
SQL Analytics Engine for Credit Card Churn Portfolio
Author: Shreyansh Gupta (GitHub: Shreyansh123185655)

Loads Dataset/BankChurners.csv into an in-memory SQLite database,
executes high-impact business and behavioral queries, and prints
clear analytical summaries.
"""

import sqlite3
import csv
import os
import sys

def get_data_path():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    csv_path = os.path.join(base_dir, "..", "Dataset", "BankChurners.csv")
    if not os.path.exists(csv_path):
        csv_path = os.path.join(os.getcwd(), "Dataset", "BankChurners.csv")
    if not os.path.exists(csv_path):
        raise FileNotFoundError(f"Cannot find BankChurners.csv at {csv_path}")
    return os.path.abspath(csv_path)

def setup_database(conn, csv_path):
    cursor = conn.cursor()
    
    # Read header and sample row to create schema
    with open(csv_path, mode='r', encoding='utf-8') as f:
        reader = csv.reader(f)
        headers = [h.strip().replace('"', '') for h in next(reader)]
        
        # We only keep the 21 primary columns (drop the 2 synthetic Naive Bayes columns)
        valid_cols = headers[:21]
        
        col_defs = []
        for col in valid_cols:
            if col in ['CLIENTNUM', 'Customer_Age', 'Dependent_count', 'Months_on_book',
                        'Total_Relationship_Count', 'Months_Inactive_12_mon', 
                        'Contacts_Count_12_mon', 'Total_Trans_Ct']:
                col_defs.append(f'"{col}" INTEGER')
            elif col in ['Credit_Limit', 'Total_Revolving_Bal', 'Avg_Open_To_Buy', 
                         'Total_Amt_Chng_Q4_Q1', 'Total_Trans_Amt', 'Total_Ct_Chng_Q4_Q1', 
                         'Avg_Utilization_Ratio']:
                col_defs.append(f'"{col}" REAL')
            else:
                col_defs.append(f'"{col}" TEXT')
                
        cursor.execute(f"CREATE TABLE bankchurners ({', '.join(col_defs)})")
        cursor.execute("CREATE VIEW credit_card_customers AS SELECT * FROM bankchurners")
        
        placeholders = ', '.join(['?'] * len(valid_cols))
        insert_sql = f"INSERT INTO bankchurners ({', '.join(['\"'+c+'\"' for c in valid_cols])}) VALUES ({placeholders})"
        
        rows = []
        for row in reader:
            clean_row = []
            for i, val in enumerate(row[:21]):
                val = val.strip().replace('"', '')
                col_name = valid_cols[i]
                if col_name in ['CLIENTNUM', 'Customer_Age', 'Dependent_count', 'Months_on_book',
                                'Total_Relationship_Count', 'Months_Inactive_12_mon', 
                                'Contacts_Count_12_mon', 'Total_Trans_Ct']:
                    clean_row.append(int(val) if val != '' else None)
                elif col_name in ['Credit_Limit', 'Total_Revolving_Bal', 'Avg_Open_To_Buy', 
                                 'Total_Amt_Chng_Q4_Q1', 'Total_Trans_Amt', 'Total_Ct_Chng_Q4_Q1', 
                                 'Avg_Utilization_Ratio']:
                    clean_row.append(float(val) if val != '' else None)
                else:
                    clean_row.append(val)
            rows.append(clean_row)
            
        cursor.executemany(insert_sql, rows)
        conn.commit()
        print(f"Loaded {len(rows):,} customer records into in-memory SQLite database successfully.\n")

def print_table(title, columns, rows):
    print("=" * 78)
    print(f" {title.upper()}")
    print("=" * 78)
    if not rows:
        print("No records returned.")
        print()
        return

    # Calculate column widths
    widths = [len(str(c)) for c in columns]
    for row in rows:
        for i, val in enumerate(row):
            val_str = str(val) if val is not None else "NULL"
            widths[i] = max(widths[i], len(val_str))
            
    header_line = " | ".join(f"{str(columns[i]):<{widths[i]}}" for i in range(len(columns)))
    separator = "-+-".join("-" * widths[i] for i in range(len(widths)))
    print(header_line)
    print(separator)
    for row in rows:
        row_line = " | ".join(f"{str(row[i]) if row[i] is not None else 'NULL':<{widths[i]}}" for i in range(len(row)))
        print(row_line)
    print()

def run_analytics(conn):
    cursor = conn.cursor()
    
    # 1. High-level Churn KPI
    q1 = """
    SELECT 
        COUNT(*) AS total_customers,
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
        ROUND(SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1.0 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
        ROUND(AVG(Credit_Limit), 2) AS avg_credit_limit,
        ROUND(AVG(Total_Trans_Amt), 2) AS avg_trans_amt
    FROM bankchurners;
    """
    cursor.execute(q1)
    print_table("1. Executive Portfolio Churn Summary", [d[0] for d in cursor.description], cursor.fetchall())
    
    # 2. Normalized Churn by Card Category
    q2 = """
    SELECT 
        Card_Category,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
        ROUND(SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1.0 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
        ROUND(AVG(Credit_Limit), 2) AS avg_credit_limit,
        ROUND(AVG(Avg_Utilization_Ratio) * 100, 1) AS avg_utilization_pct
    FROM bankchurners
    GROUP BY Card_Category
    ORDER BY churn_rate_pct DESC;
    """
    cursor.execute(q2)
    print_table("2. Normalized Churn Rate by Card Category", [d[0] for d in cursor.description], cursor.fetchall())
    
    # 3. Customer Service Escalation Spiral (Contacts vs Churn)
    q3 = """
    SELECT 
        Contacts_Count_12_mon AS contacts_with_bank,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
        ROUND(SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1.0 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
    FROM bankchurners
    GROUP BY contacts_with_bank
    ORDER BY contacts_with_bank ASC;
    """
    cursor.execute(q3)
    print_table("3. Customer Service Escalation Spiral (Contacts vs Churn Rate)", [d[0] for d in cursor.description], cursor.fetchall())
    
    # 4. Inactivity Cliff
    q4 = """
    SELECT 
        Months_Inactive_12_mon AS inactive_months,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
        ROUND(SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1.0 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
    FROM bankchurners
    GROUP BY inactive_months
    ORDER BY inactive_months ASC;
    """
    cursor.execute(q4)
    print_table("4. Customer Inactivity Thresholds", [d[0] for d in cursor.description], cursor.fetchall())

    # 5. Product Holdings vs Churn Rate
    q5 = """
    SELECT 
        Total_Relationship_Count AS products_held,
        COUNT(*) AS customer_count,
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_count,
        ROUND(SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1.0 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
        ROUND(AVG(Total_Revolving_Bal), 2) AS avg_revolving_bal
    FROM bankchurners
    GROUP BY products_held
    ORDER BY products_held ASC;
    """
    cursor.execute(q5)
    print_table("5. Multi-Product Retention Power (Relationship Count)", [d[0] for d in cursor.description], cursor.fetchall())

    # 6. Transaction Count Velocity Decline (Q4 vs Q1)
    q6 = """
    SELECT 
        CASE 
            WHEN Total_Ct_Chng_Q4_Q1 < 0.5 THEN 'Severe Drop (<0.50x)'
            WHEN Total_Ct_Chng_Q4_Q1 < 0.7 THEN 'Moderate Drop (0.50x - 0.69x)'
            WHEN Total_Ct_Chng_Q4_Q1 < 1.0 THEN 'Mild Drop (0.70x - 0.99x)'
            ELSE 'Stable or Growing (>=1.0x)'
        END AS velocity_change_band,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
        ROUND(SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1.0 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
    FROM bankchurners
    GROUP BY velocity_change_band
    ORDER BY churn_rate_pct DESC;
    """
    cursor.execute(q6)
    print_table("6. Transaction Velocity Drop (Leading Indicator)", [d[0] for d in cursor.description], cursor.fetchall())

    # 7. Top 10 High-Value At-Risk Customers
    q7 = """
    SELECT 
        CLIENTNUM AS customer_id,
        Card_Category AS card_type,
        Credit_Limit AS credit_limit,
        Total_Trans_Amt AS annual_spend,
        Total_Trans_Ct AS trans_count,
        Months_Inactive_12_mon AS inactive_months,
        Contacts_Count_12_mon AS contacts,
        Total_Ct_Chng_Q4_Q1 AS q4_q1_ratio
    FROM bankchurners
    WHERE Attrition_Flag = 'Existing Customer'
      AND (Total_Trans_Amt >= 10000 OR Credit_Limit >= 20000)
      AND (Months_Inactive_12_mon >= 2 OR Contacts_Count_12_mon >= 3 OR Total_Ct_Chng_Q4_Q1 < 0.6)
    ORDER BY annual_spend DESC
    LIMIT 10;
    """
    cursor.execute(q7)
    print_table("7. Top 10 High-Value At-Risk Customers (Immediate Retention Target)", [d[0] for d in cursor.description], cursor.fetchall())

def main():
    print("=" * 78)
    print(" CREDIT CARD CHURN SQL ANALYTICS ENGINE")
    print(" Lead Analyst: Shreyansh Gupta (GitHub: Shreyansh123185655)")
    print("=" * 78)
    try:
        csv_path = get_data_path()
        conn = sqlite3.connect(":memory:")
        setup_database(conn, csv_path)
        run_analytics(conn)
        conn.close()
        print("SQL Analytics Execution Completed Successfully.")
    except Exception as e:
        print(f"Error executing SQL analytics: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
