# Data Warehouse Catalog

> **Schema:** gold  
> **Last Updated:** 2025-12-18  
> **Version:** 1.0

---

## Table of Contents

- [1. dim_customers - Customer Dimension](#1-dim_customers---customer-dimension)
- [2. dim_products - Product Dimension](#2-dim_products---product-dimension)
- [3. fact_sales - Sales Fact](#3-fact_sales---sales-fact)
- [4. Data Lineage](#4-data-lineage)

---

## 1. dim_customers - Customer Dimension

### Description

Customer dimension table containing detailed customer information, integrated from CRM and ERP systems.

### Primary Key

`customer_key`

### Table Structure

| Column Name     | Data Type    | Description                                                                                                    |
| --------------- | ------------ | -------------------------------------------------------------------------------------------------------------- |
| customer_key    | INT          | Surrogate key uniquely identifying each customer record in the dimension table.                                |
| customer_id     | INT          | Natural key representing the customer identifier from the source CRM system (e.g., 11000).                     |
| customer_number | NVARCHAR(50) | A unique alphanumeric identifier for each customer in business format (e.g., 'AW00011000').                    |
| first_name      | NVARCHAR(50) | The first name of the customer as recorded in the CRM system (e.g., 'Jon').                                    |
| last_name       | NVARCHAR(50) | The last name of the customer as recorded in the CRM system (e.g., 'Yang').                                    |
| country         | NVARCHAR(50) | The country where the customer resides, sourced from ERP location data (e.g., 'Australia').                    |
| marital_status  | NVARCHAR(50) | The marital status of the customer (e.g., 'M' for Married, 'S' for Single).                                    |
| gender          | NVARCHAR(50) | The gender of the customer, with priority from CRM and fallback to ERP if unavailable (e.g., 'M', 'F', 'n/a'). |
| create_date     | DATE         | The date when the customer account was created in the system (e.g., '2025-10-06').                             |
| birthdate       | DATE         | The date of birth of the customer from ERP data (e.g., '1971-10-06').                                          |

### Business Rules

- **Gender Logic:** Prioritize CRM data; if 'n/a', fallback to ERP; default is 'n/a'
- **Data Integration:** Join with ERP based on customer_number (cst_key = cid)
- **Granularity:** One unique customer per row (DISTINCT)

### Source Tables

- **CRM:** cust_info.csv (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
- **ERP:** CUST_AZ12.csv (CID, BDATE, GEN), LOC_A101.csv (CID, CNTRY)

---

## 2. dim_products - Product Dimension

### Description

Product dimension table containing active product information, integrated from CRM and ERP systems.

### Primary Key

`product_key`

### Table Structure

| Column Name    | Data Type    | Description                                                                                                |
| -------------- | ------------ | ---------------------------------------------------------------------------------------------------------- |
| product_key    | INT          | Surrogate key uniquely identifying each product record in the dimension table.                             |
| product_id     | INT          | Natural key representing the product identifier from the source CRM system (e.g., 210).                    |
| product_number | NVARCHAR(50) | A unique alphanumeric identifier for each product in business format (e.g., 'CO-RF-FR-R92B-58').           |
| product_name   | NVARCHAR(50) | The name of the product as recorded in the CRM system (e.g., 'HL Road Frame - Black- 58').                 |
| category_id    | NVARCHAR(50) | The category code linking to product categorization in ERP (e.g., 'AC_BR').                                |
| category       | NVARCHAR(50) | The category name of the product from ERP classification (e.g., 'Accessories').                            |
| subcategory    | NVARCHAR(50) | The subcategory name providing finer classification from ERP (e.g., 'Bike Racks').                         |
| maintenance    | NVARCHAR(50) | Indicates whether the product requires maintenance (e.g., 'Yes', 'No').                                    |
| cost           | INT          | The cost of the product for manufacturing or procurement, in whole currency units (e.g., 12).              |
| product_line   | NVARCHAR(50) | The product line classification indicating the product category group (e.g., 'R' for Road, 'S' for Sport). |
| start_date     | DATETIME     | The date when the product became effective in the catalog (e.g., '2003-07-01').                            |

### Business Rules

- **Active Products Only:** Filter products where `prd_end_dt IS NULL` (currently active)
- **Category Join:** Join with ERP based on category_id (cat_id = id)
- **Ordering:** Sort by start_date, then product_number

### Source Tables

- **CRM:** prd_info.csv (prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
- **ERP:** PX_CAT_G1V2.csv (ID, CAT, SUBCAT, MAINTENANCE)

---

## 3. fact_sales - Sales Fact

### Description

Sales fact table containing transactional sales data, connected to dim_customers and dim_products.

### Foreign Keys

- `product_key` → dim_products.product_key
- `customer_key` → dim_customers.customer_key

### Table Structure

| Column Name   | Data Type    | Description                                                                                 |
| ------------- | ------------ | ------------------------------------------------------------------------------------------- |
| order_number  | NVARCHAR(50) | A unique alphanumeric identifier for each sales order (e.g., 'SO54496').                    |
| product_key   | INT          | Surrogate key linking the order to the product dimension table.                             |
| customer_key  | INT          | Surrogate key linking the order to the customer dimension table.                            |
| order_date    | DATE         | The date when the order was placed.                                                         |
| shipping_date | DATE         | The date when the order was shipped to the customer.                                        |
| due_date      | DATE         | The date when the order payment was due.                                                    |
| sales_amount  | INT          | The total monetary value of the sale for the line item, in whole currency units (e.g., 25). |
| quantity      | INT          | The number of units of the product ordered for the line item (e.g., 1).                     |
| price         | INT          | The price per unit of the product for the line item, in whole currency units (e.g., 25).    |

### 📐 Measures

- **sale_amount:** Total revenue of the order
- **quantity:** Quantity of products
- **price:** Unit selling price

### Business Rules

- **Grain:** Each row represents one order line item
- **Product Join:** Join with dim_products via product_number
- **Customer Join:** Join with dim_customers via customer_id
- **Date Format:** Dates are stored as INT (require conversion when using)

### Common Calculations

```sql
-- Total revenue
SUM(sale_amount)

-- Number of orders
COUNT(DISTINCT order_number)

-- Average order value
AVG(sale_amount)

-- Total products sold
SUM(quantity)
```

### Source Tables

- **CRM:** sales_details.csv (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)

---

## Metadata

| Attribute         | Value                    |
| ----------------- | ------------------------ |
| Schema            | gold                     |
| Database          | [Your Database Name]     |
| Refresh Frequency | [Daily/Hourly/Real-time] |
| Data Retention    | [Retention Policy]       |
| Owner             | Data Engineering Team    |
| Contact           | [Email/Slack Channel]    |

---

## Sample Queries

### Query 1: Top 10 Customers by Revenue

```sql
SELECT TOP 10
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    c.country,
    SUM(f.sale_amount) AS total_sales,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
ORDER BY total_sales DESC;
```

### Query 2: Revenue by Product Category

```sql
SELECT
    p.category,
    p.subcategory,
    SUM(f.sale_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity,
    COUNT(DISTINCT f.order_number) AS order_count
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.category, p.subcategory
ORDER BY total_sales DESC;
```

### Query 3: Customer Analysis by Gender and Country

```sql
SELECT
    c.country,
    c.gender,
    COUNT(DISTINCT c.customer_key) AS customer_count,
    SUM(f.sale_amount) AS total_sales,
    AVG(f.sale_amount) AS avg_order_value
FROM gold.dim_customers c
LEFT JOIN gold.fact_sales f ON c.customer_key = f.customer_key
GROUP BY c.country, c.gender
ORDER BY total_sales DESC;
```

---

## Important Notes

1. **Date Format:** Date columns in fact_sales are in INT format, need conversion to DATE when using
2. **NULL Values:** All columns are nullable, handle accordingly in queries
3. **View Performance:** Gold tables are VIEWs, consider materialized views for better performance
4. **Historical Data:** dim_products contains only active products, no historical tracking

---

**Prepared by:** Data Engineering Team  
**Document Version:** 1.0  
**Last Review Date:** 2025-12-18
