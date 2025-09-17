# Monday Coffee – SQL Sales Analysis 

## Overview
This project analyzes **coffee sales data** across multiple cities using SQL.  
The goal was to answer important **business questions** such as revenue trends, market potential, customer segmentation, and city-wise performance.  

---

## Tools Used
- **PostgreSQL** (queries & schema design)
- **SQL Joins, CTEs, Window Functions**
- **Data Cleaning & Business Analysis**

---

## Database Schema
The project uses four main tables:
- **city** – city details, population, estimated rent, rank  
- **customers** – customer info linked to city  
- **products** – coffee products with price  
- **sales** – transactions with date, product, customer, total amount, rating  

---

## Key Business Questions Answered
1. **Coffee Consumers Count** – Estimate coffee consumers as 25% of city population.  
2. **Total Revenue** – Revenue across all cities (focus on Q4 2023).  
3. **Sales Count by Product** – How many units of each product sold.  
4. **Average Sales per City** – Avg sale per customer in each city.  
5. **Population vs Customers** – Compare potential consumers vs actual customers.  
6. **Top Selling Products per City** – Top 3 products city-wise.  
7. **Customer Segmentation** – Unique customers in each city.  
8. **Average Sale vs Rent** – Compare average customer sale vs estimated rent.  
9. **Monthly Sales Growth** – Calculate month-over-month sales growth % by city.  
10. **Market Potential Analysis** – Identify top 3 cities with highest business opportunity.  

---

## Sample Insights
- **Delhi, Mumbai, Kolkata** have the highest estimated coffee consumers.  
- **Pune, Chennai, Bangalore** generate the highest Q4 2023 revenue.  
- **Top products differ by city**, showing regional preferences.  
- **Pune** stands out with highest revenue and low average rent per customer.  
- **Delhi** has the largest potential market (7.7M estimated consumers).  

---

## Recommendations
- **Pune** – Strong revenue, low rent per customer, high sales per customer.  
- **Delhi** – Largest coffee consumer base and customer count, good revenue potential.  
- **Chennai** – Solid revenue, growing customer base, relatively affordable rent. 
