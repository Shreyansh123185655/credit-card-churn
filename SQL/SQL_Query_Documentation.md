# SQL Query Documentation
## Credit Card Customer Churn & Spending Analytics
**Lead Analyst:** [Shreyansh Gupta](https://github.com/Shreyansh123185655)  
**Dataset Size:** 10,127 customers  
**Domain:** Fintech / Credit Card Analytics  
**Execution Runner:** `python3 SQL/run_sql_queries.py`

---

# 1️⃣ Total Customer Base

### Business Question
How many customers exist in the credit card portfolio?

### SQL Query
```sql
SELECT COUNT(*) AS total_customers
FROM bankchurners;
```

### KPI Result
- **Total Customers:** 10,127

### Insight
This represents the total population used for churn and behavioral analysis.

### Business Recommendation
This value serves as the baseline for churn calculations and customer segmentation.

---

# 2️⃣ Overall Customer Churn Rate

### Business Question
What percentage of customers have churned?

### SQL Query
```sql
SELECT 
COUNT(*) AS total_customers,
SUM(CASE WHEN Attrition_Flag='Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
ROUND(
SUM(CASE WHEN Attrition_Flag='Attrited Customer' THEN 1 ELSE 0 END)/COUNT(*)*100,2
) AS churn_rate_percentage
FROM bankchurners;
```

### KPI Result
- **Churn Rate:** 16.07% (1,627 out of 10,127 customers)

### Insight
Approximately **1 out of every 6 customers leaves the service**, representing significant lost lifetime value and transaction revenue.

### Business Recommendation
Financial institutions should monitor engagement metrics such as transaction activity and inactivity periods to detect churn risks early.

---

# 3️⃣ Normalized Churn Distribution by Card Category

### Business Question
Which card category experiences the highest churn rate?

### SQL Query
```sql
SELECT 
    Card_Category AS card_type,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1.0 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG(Credit_Limit), 2) AS avg_credit_limit
FROM bankchurners
GROUP BY card_type
ORDER BY churn_rate_pct DESC;
```

### Insight
While **Blue cards account for the largest raw volume of churn (1,519 customers)** due to making up 93.2% of all cardholders, **Platinum cardholders suffer the highest relative churn rate at 25.0%**, followed by **Gold at 18.1%**, Blue at **16.1%**, and Silver at **14.8%**. Premium cardholders are leaving at higher proportionate rates.

### Business Recommendation
Re-evaluate the value proposition and rewards structure for Premium (Platinum and Gold) tiers to prevent high-value customer attrition, while deploying digital engagement triggers for Blue tier customers.

---

# 4️⃣ Average Transaction Amount by Card Category

### Business Question
Which card category generates the highest transaction volume?

### SQL Query
```sql
SELECT 
Card_Category AS card_type,
ROUND(AVG(Total_Trans_Amt),2) AS avg_transaction_amount
FROM bankchurners
GROUP BY card_type
ORDER BY avg_transaction_amount DESC;
```

### Insight
Premium card categories generally generate **higher average transaction amounts**.

### Business Recommendation
Encourage customers to upgrade to higher-tier cards with enhanced benefits.

---

# 5️⃣ Customer Inactivity vs Churn

### Business Question
Does customer inactivity correlate with churn?

### SQL Query
```sql
SELECT 
Attrition_Flag AS customer_status,
ROUND(AVG(Months_Inactive_12_mon),2) AS avg_inactive_months
FROM bankchurners
GROUP BY customer_status;
```

### Insight
Customers who churn tend to have **higher inactivity levels**, suggesting disengagement before leaving.

### Business Recommendation
Develop **early warning systems** that trigger retention campaigns when inactivity increases.

---

# 6️⃣ Transaction Activity by Customer Status

### Business Question
Do churned customers perform fewer transactions?

### SQL Query
```sql
SELECT 
Attrition_Flag AS customer_status,
ROUND(AVG(Total_Trans_Ct),2) AS avg_transaction_count
FROM bankchurners
GROUP BY customer_status;
```

### Insight
Customers who churn demonstrate **lower transaction frequency**, indicating reduced engagement.

### Business Recommendation
Offer transaction incentives such as cashback or reward points to boost engagement.

---

# 7️⃣ Customers with Above-Average Credit Limits

### Business Question
Which customers have credit limits higher than the portfolio average?

### SQL Query
```sql
SELECT 
CLIENTNUM AS customer_id,
Credit_Limit AS credit_limit
FROM bankchurners
WHERE Credit_Limit > (
SELECT AVG(Credit_Limit)
FROM bankchurners
)
ORDER BY credit_limit DESC;
```

### Insight
High credit limit customers represent **high-value segments with greater spending capacity**.

### Business Recommendation
Prioritize retention strategies for high-value customers.

---

# 8️⃣ Revenue Contribution by Card Category

### Business Question
Which card categories contribute most to overall transaction revenue?

### SQL Query
```sql
WITH card_revenue AS (
SELECT 
Card_Category AS card_type,
SUM(Total_Trans_Amt) AS total_revenue
FROM bankchurners
GROUP BY card_type
)

SELECT 
card_type,
total_revenue,
ROUND(
total_revenue * 100 / SUM(total_revenue) OVER (),
2
) AS revenue_percentage
FROM card_revenue
ORDER BY revenue_percentage DESC;
```

### Insight
Certain card categories contribute a **larger share of total transaction revenue**.

### Business Recommendation
Focus marketing and retention efforts on high-revenue customer segments.

---

# 2️⃣1️⃣ Customer Service Escalation Spiral (Contacts vs Churn)

### Business Question
Does frequent customer contact indicate dissatisfaction and higher churn probability?

### SQL Query
```sql
SELECT 
    Contacts_Count_12_mon AS customer_contacts_count,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_pct
FROM bankchurners
GROUP BY customer_contacts_count
ORDER BY customer_contacts_count ASC;
```

### KPI Result
- 0 Contacts: **1.75%** Churn Rate
- 1-2 Contacts: **7.2% - 12.5%** Churn Rate
- 3 Contacts: **20.15%** Churn Rate
- 4 Contacts: **22.63%** Churn Rate
- 5 Contacts: **33.52%** Churn Rate
- 6 Contacts: **100.0%** Churn Rate (54/54 customers churned)

### Insight
There is a direct **exponential relationship between customer service contacts and churn**. When a customer reaches 4 or more contacts, it signals severe service friction. Every single customer who contacted support 6 times churned.

### Business Recommendation
Establish an automated CRM escalation rule: when any customer reaches **3 contacts within 12 months**, route their case immediately to a Senior Retention Specialist to resolve pain points before they churn.

---

# 2️⃣2️⃣ Transaction Velocity Collapse (Q4 vs Q1)

### Business Question
Can quarter-over-quarter transaction activity drops serve as an early leading indicator?

### SQL Query
```sql
SELECT 
    CASE 
        WHEN Total_Ct_Chng_Q4_Q1 < 0.5 THEN 'Severe Drop (<0.50x)'
        WHEN Total_Ct_Chng_Q4_Q1 < 0.7 THEN 'Moderate Drop (0.50x - 0.69x)'
        WHEN Total_Ct_Chng_Q4_Q1 < 1.0 THEN 'Mild Drop (0.70x - 0.99x)'
        ELSE 'Stable or Growing (>=1.0x)'
    END AS transaction_velocity_band,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_pct
FROM bankchurners
GROUP BY transaction_velocity_band
ORDER BY churn_rate_pct DESC;
```

### KPI Result
- Severe Drop (<0.50x): **50.88% Churn Rate** (697 churned out of 1,370)
- Moderate Drop (0.50x - 0.69x): **14.77% Churn Rate**
- Mild Drop (0.70x - 0.99x): **7.80% Churn Rate**
- Stable or Growing (>=1.0x): **7.07% Churn Rate**

### Insight
A severe decline in transaction velocity (< 50% of Q1 volume) is the single most powerful leading indicator of impending attrition, accounting for over 50% churn probability.

---

# 2️⃣3️⃣ Multi-Product Retention Power (Relationship Count)

### Business Question
Does increasing the number of bank products per customer improve retention?

### SQL Query
```sql
SELECT 
    Total_Relationship_Count AS products_held,
    COUNT(*) AS customer_count,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_count,
    ROUND(
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_pct,
    ROUND(AVG(Total_Revolving_Bal), 2) AS avg_revolving_balance
FROM bankchurners
GROUP BY products_held
ORDER BY products_held ASC;
```

### KPI Result
- 1 Product: **25.60% Churn**
- 2 Products: **27.84% Churn**
- 3 Products: **17.35% Churn**
- 4-6 Products: **10.50% - 12.00% Churn**

### Insight
Customer stickiness increases dramatically when a customer holds **4 or more banking products**, reducing the churn rate by more than **58%**.

---

# Final Conclusion

Key strategic takeaways from the enhanced SQL analytics:

1. **Portfolio Churn Rate**: 16.07% overall attrition.
2. **Escalation Friction Risk**: Contacts count >= 4 is a critical operational trigger; 6 contacts leads to a 100% churn rate.
3. **Leading Indicator**: A quarter-over-quarter transaction count ratio below 0.50x signals a 50.88% churn risk.
4. **Card Tier Reality**: Platinum cardholders have the highest proportionate churn rate at 25.0%, demanding tailored VIP retention efforts.
5. **Cross-Selling Power**: Expanding product relationships to 4+ accounts cuts churn risk from 27.8% down to 10.5%.

All queries can be executed and verified via the automated SQLite runner:
```bash
python3 SQL/run_sql_queries.py
```
