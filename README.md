# 🔍 SQL Data Exploration & Analysis

## Overview
This project explores a sales database using SQL to uncover business insights across products, customers, time trends, and performance metrics. It includes exploratory analysis, KPI calculations, segmentation, and advanced analytical techniques such as time series and cumulative analysis.

The goal is to transform raw sales data into meaningful business insights.

---

## 📂 Database Exploration
- Inspect database structure using `INFORMATION_SCHEMA`
- Explore table schemas and metadata

---

## 🌍 Dimension Exploration
- Unique customer countries
- Product categories, subcategories, and product names

---

## 📅 Date Range Analysis
- First and last order dates
- Customer age distribution
- Dataset time coverage (lifespan of data)

---

## 📊 Measures (KPIs)
- Total sales
- Total quantity sold
- Total orders
- Average price
- Total customers and active customers
- Business KPI summary report using `UNION ALL`

---

## 📦 Magnitude Analysis
- Sales by category
- Revenue by customer
- Sales distribution by country and gender
- Product and category-level performance insights

---

## 🏆 Ranking Analysis
- Top 5 and bottom 5 products by revenue
- Top customers by total revenue
- Customers with lowest order counts
- Ranking using `TOP` and window functions (`RANK()`)

---

## 📈 Time Series Analysis
- Monthly and yearly sales trends
- Customer and quantity trends over time
- Date transformations using `DATEPART`, `DATETRUNC`, and `FORMAT`

---

## 🔁 Cumulative Analysis
- Running total of sales over time
- Moving averages for price trends
- Long-term performance tracking using window functions

---

## 📉 Performance Analysis (YoY / MoM)
- Year-over-year product performance
- Comparison against average product performance
- Growth and decline analysis using `LAG()`

---

## 🧩 Segmentation Analysis
- Product cost segmentation (price bands)
- Customer segmentation (VIP, Regular, New)
- Behaviour-based grouping using `CASE`

---

## 📊 Part-to-Whole Analysis
- Revenue contribution by category
- Percentage contribution to total sales
- Business share-of-market insights

---

## 📁 Data Sources
- `gold.fact_sales`
- `gold.dim_customers`
- `gold.dim_products`

---

## 🛠️ Tools & Techniques Used
- SQL (CTEs, joins, aggregations)
- Window functions (`SUM() OVER`, `LAG()`, `RANK()`)
- Conditional logic (`CASE`)
- Time-based analysis
- Data segmentation
- Exploratory data analysis (EDA)

---

## 🎯 Outcome
This project transforms raw sales data into structured insights, covering performance, trends, and segmentation. It demonstrates strong SQL analytical skills and the ability to convert data into actionable business intelligence.

---

## 💡 Skills Demonstrated
- Advanced SQL querying  
- Data exploration and profiling  
- KPI development  
- Time series and cumulative analysis  
- Customer and product segmentation  
- Analytical thinking using real-world datasets  
