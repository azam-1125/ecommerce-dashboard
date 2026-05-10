# E-commerce Sales Performance & Customer Intelligence Dashboard

## 📌 Project Overview
End-to-end data analytics project analyzing 100,000+ orders from a 
Brazilian e-commerce platform (Olist). Built an interactive Power BI 
dashboard covering revenue trends, customer segmentation, product 
performance, and delivery analytics.

## 🎯 Business Questions Answered
- Which product categories drive the most revenue?
- How are customers segmented by purchasing behavior?
- Which states have the worst delivery performance?
- What payment methods do customers prefer?
- How has revenue trended over time?

## 🛠️ Tools & Technologies
- **SQL (MySQL)** — data extraction, joins, window functions, RFM queries
- **Python** — EDA, data cleaning, feature engineering, visualizations
- **Power BI** — 4-page interactive dashboard
- **Libraries** — Pandas, NumPy, Matplotlib, Seaborn, Scikit-learn

## 📊 Dashboard Pages
1. **Executive Summary** — KPI cards, revenue trend, top categories, payment breakdown
2. **Sales Analysis** — category performance, combo chart, treemap, slicers
3. **Customer Segments** — RFM analysis, scatter plot, segment revenue, location map
4. **Delivery Performance** — late delivery rates, avg delivery days, state-level map

## 🔍 Key Insights
- Top 3 categories (bed/bath/table, health/beauty, sports/leisure) account for 
  X% of total revenue
- Champions segment (X% of customers) drives X% of total revenue
- States in the North/Northeast region have X% higher late delivery rates 
  than the national average
- Credit card is the dominant payment method at 75.89% of all orders

## 📁 Project Structure
├── data/

│   ├── raw/           # Original Kaggle dataset

│   └── processed/     # Cleaned data + SQL exports

├── notebooks/

│   └── eda.ipynb      # Python EDA notebook

├── dashboard/

│   └── ecommerce-dashboard.pbix

├── sql/

│   └── queries.sql    # All SQL queries used

└── README.md

