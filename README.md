# 📚 Online Bookstore SQL Analysis

## 🔹 Project Overview
I built this project to practice how SQL can be used to answer real business questions.  
I created a bookstore database (Books, Customers, Orders), added sample data, and wrote SQL queries to analyze sales, customers, and inventory.

The main idea: **show how raw data can be turned into insights that help managers make decisions.**

---

## 🔹 Dataset
- **Books** → book details (title, author, genre, price, stock)  
- **Customers** → customer info (name, city, country)  
- **Orders** → transaction history (customer, book, date, total amount)  

---

## 🔹 What I Analyzed
Here are the business questions I solved with SQL:

1. Which books are the **top sellers**?  
2. Who are the **highest-spending customers**?  
3. Which books are **low on stock**?  
4. Which genres bring in the **most revenue**?  
5. What do **monthly sales trends** look like?  
6. Which **cities or countries** have the most customers?  

---

## 🔹 Key Findings
- 📈 Fiction and Fantasy generated the highest revenue  
- 🛒 Medium-priced books sold more consistently than high-end ones  
- 👥 Top 5 customers contributed about 30% of total sales  
- ⚠️ Some bestsellers had stock under 10 units (need restocking)  
- 🌍 Customers in large cities had higher average spending  

---

## 🔹 Tools I Used
- **PostgreSQL** for database and queries  
- **Excel / Power BI** for basic charts and visual summaries  

---

## 🔹 Visuals (Ideas)
- 📊 Top 10 best-selling books  
- 📉 Monthly revenue trends  
- 🛒 Sales share by genre  
- ⚠️ Low stock alert table  

---

## 🔹 Why This Project Matters
I wanted to go beyond just writing queries.  
This project shows how SQL connects to real business needs:  
- **Track performance** (sales, revenue, customers)  
- **Identify risks** (low stock, declining genres)  
- **Spot opportunities** (loyal customers, trending books)  



## 🔹 How to Run It
1. Create a database called `OnlineBooks` in PostgreSQL  
2. Run the `create_tables.sql` file to set up tables  
3. Import the CSVs into the tables  
4. Run queries from the `queries.sql` file to get results  

---

## 🔹 Next Steps
- Build a **Power BI dashboard** with KPIs and trends  
- Add **predictive analysis** (future sales trends with Python)  
- Automate **inventory alerts** for low-stock books  

---
