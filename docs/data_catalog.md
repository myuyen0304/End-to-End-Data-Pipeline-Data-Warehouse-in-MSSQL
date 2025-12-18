# 📊 Data Warehouse Catalog

> **Schema:** gold  
> **Last Updated:** 2025-12-18  
> **Version:** 1.0

---

## 📑 Mục Lục

- [1. dim_customers - Dimension Khách Hàng](#1-dim_customers---dimension-khách-hàng)
- [2. dim_products - Dimension Sản Phẩm](#2-dim_products---dimension-sản-phẩm)
- [3. fact_sales - Fact Bán Hàng](#3-fact_sales---fact-bán-hàng)
- [4. Data Lineage](#4-data-lineage)

---

## 1. dim_customers - Dimension Khách Hàng

### 📝 Mô Tả

Bảng dimension chứa thông tin chi tiết về khách hàng, được tích hợp từ hệ thống CRM và ERP.

### 🔑 Primary Key

`customer_key`

### 📊 Cấu Trúc Bảng

| #   | Tên Cột          | Kiểu Dữ Liệu | Nullable | Mô Tả                                               | Nguồn               |
| --- | ---------------- | ------------ | -------- | --------------------------------------------------- | ------------------- |
| 1   | **customer_key** | INT          | No       | Khóa chính surrogate, tự động tăng theo customer_id | Generated           |
| 2   | customer_id      | INT          | Yes      | ID khách hàng từ hệ thống CRM                       | CRM                 |
| 3   | customer_number  | NVARCHAR(50) | Yes      | Mã số khách hàng duy nhất                           | CRM                 |
| 4   | first_name       | NVARCHAR(50) | Yes      | Tên của khách hàng                                  | CRM                 |
| 5   | last_name        | NVARCHAR(50) | Yes      | Họ của khách hàng                                   | CRM                 |
| 6   | country          | NVARCHAR(50) | Yes      | Quốc gia của khách hàng                             | ERP (erp_loc_a101)  |
| 7   | marital_status   | NVARCHAR(50) | Yes      | Tình trạng hôn nhân                                 | CRM                 |
| 8   | gender           | NVARCHAR(50) | Yes      | Giới tính (CRM master, fallback ERP)                | CRM/ERP             |
| 9   | create_date      | DATE         | Yes      | Ngày tạo tài khoản khách hàng                       | CRM                 |
| 10  | birthdate        | DATE         | Yes      | Ngày sinh của khách hàng                            | ERP (erp_cust_az12) |

### 🔗 Business Rules

- **Gender Logic:** Ưu tiên dữ liệu từ CRM, nếu là 'n/a' thì lấy từ ERP, default là 'n/a'
- **Data Integration:** Join với ERP dựa trên customer_number (cst_key = cid)
- **Granularity:** Một khách hàng duy nhất mỗi dòng (DISTINCT)

### 📈 Số Lượng Dòng (Ước Tính)

Tùy thuộc vào số lượng khách hàng duy nhất trong hệ thống

---

## 2. dim_products - Dimension Sản Phẩm

### 📝 Mô Tả

Bảng dimension chứa thông tin về sản phẩm hiện tại (active), tích hợp dữ liệu từ CRM và ERP.

### 🔑 Primary Key

`product_key`

### 📊 Cấu Trúc Bảng

| #   | Tên Cột         | Kiểu Dữ Liệu | Nullable | Mô Tả                                                                | Nguồn                 |
| --- | --------------- | ------------ | -------- | -------------------------------------------------------------------- | --------------------- |
| 1   | **product_key** | INT          | No       | Khóa chính surrogate, tự động tăng theo start_date và product_number | Generated             |
| 2   | product_id      | INT          | Yes      | ID sản phẩm từ hệ thống CRM                                          | CRM                   |
| 3   | product_number  | NVARCHAR(50) | Yes      | Mã số sản phẩm duy nhất                                              | CRM                   |
| 4   | product_name    | NVARCHAR(50) | Yes      | Tên sản phẩm                                                         | CRM                   |
| 5   | category_id     | NVARCHAR(50) | Yes      | Mã danh mục sản phẩm                                                 | CRM (cat_id)          |
| 6   | category        | NVARCHAR(50) | Yes      | Tên danh mục sản phẩm                                                | ERP (erp_px_cat_g1v2) |
| 7   | subcategory     | NVARCHAR(50) | Yes      | Tên danh mục phụ                                                     | ERP (erp_px_cat_g1v2) |
| 8   | maintenance     | NVARCHAR(50) | Yes      | Thông tin bảo trì                                                    | ERP (erp_px_cat_g1v2) |
| 9   | cost            | INT          | Yes      | Chi phí sản xuất/nhập                                                | CRM                   |
| 10  | product_line    | NVARCHAR(50) | Yes      | Dòng sản phẩm                                                        | CRM                   |
| 11  | start_date      | DATETIME     | Yes      | Ngày bắt đầu hiệu lực                                                | CRM                   |

### 🔗 Business Rules

- **Active Products Only:** Chỉ lấy sản phẩm có `prd_end_dt IS NULL` (đang hoạt động)
- **Category Join:** Join với ERP dựa trên category_id (cat_id = id)
- **Ordering:** Sắp xếp theo start_date, sau đó product_number

### 📈 Số Lượng Dòng (Ước Tính)

Chỉ sản phẩm đang active (không bao gồm lịch sử)

---

## 3. fact_sales - Fact Bán Hàng

### 📝 Mô Tả

Bảng fact chứa dữ liệu giao dịch bán hàng, kết nối với dim_customers và dim_products.

### 🔑 Foreign Keys

- `product_key` → dim_products.product_key
- `customer_key` → dim_customers.customer_key

### 📊 Cấu Trúc Bảng

| #   | Tên Cột          | Kiểu Dữ Liệu | Nullable | Mô Tả                        | Loại        | Nguồn     |
| --- | ---------------- | ------------ | -------- | ---------------------------- | ----------- | --------- |
| 1   | order_number     | NVARCHAR(50) | Yes      | Mã số đơn hàng               | Dimension   | CRM       |
| 2   | **product_key**  | INT          | Yes      | Khóa ngoại đến dim_products  | Foreign Key | Generated |
| 3   | **customer_key** | INT          | Yes      | Khóa ngoại đến dim_customers | Foreign Key | Generated |
| 4   | order_date       | INT          | Yes      | Ngày đặt hàng (format INT)   | Dimension   | CRM       |
| 5   | shipping_date    | INT          | Yes      | Ngày giao hàng (format INT)  | Dimension   | CRM       |
| 6   | due_date         | INT          | Yes      | Ngày đến hạn (format INT)    | Dimension   | CRM       |
| 7   | sale_amount      | INT          | Yes      | Doanh thu bán hàng           | **Measure** | CRM       |
| 8   | quantity         | INT          | Yes      | Số lượng sản phẩm bán        | **Measure** | CRM       |
| 9   | price            | INT          | Yes      | Đơn giá                      | **Measure** | CRM       |

### 📐 Measures (Các Chỉ Số)

- **sale_amount:** Tổng doanh thu của đơn hàng
- **quantity:** Số lượng sản phẩm
- **price:** Đơn giá bán

### 🔗 Business Rules

- **Grain:** Mỗi dòng đại diện cho một chi tiết đơn hàng (order line item)
- **Product Join:** Join với dim_products qua product_number
- **Customer Join:** Join với dim_customers qua customer_id
- **Date Format:** Các ngày được lưu dạng INT (cần convert khi sử dụng)

### 💡 Các Phép Tính Thường Dùng

```sql
-- Tổng doanh thu
SUM(sale_amount)

-- Số lượng đơn hàng
COUNT(DISTINCT order_number)

-- Giá trị trung bình đơn hàng
AVG(sale_amount)

-- Tổng số sản phẩm bán ra
SUM(quantity)
```

---

## 4. Data Lineage

### 📊 Sơ Đồ Luồng Dữ Liệu

```
┌─────────────────────────────────────────────────────────────┐
│                     BRONZE LAYER                            │
├─────────────────────────────────────────────────────────────┤
│  • bronze.crm_cust_info                                     │
│  • bronze.crm_prd_info                                      │
│  • bronze.crm_sales_details                                 │
│  • bronze.erp_cust_az12                                     │
│  • bronze.erp_loc_a101                                      │
│  • bronze.erp_px_cat_g1v2                                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                     SILVER LAYER                            │
├─────────────────────────────────────────────────────────────┤
│  • silver.crm_cust_info         (cleaned & standardized)   │
│  • silver.crm_prd_info          (cleaned & standardized)   │
│  • silver.crm_sales_details     (cleaned & standardized)   │
│  • silver.erp_cust_az12         (cleaned & standardized)   │
│  • silver.erp_loc_a101          (cleaned & standardized)   │
│  • silver.erp_px_cat_g1v2       (cleaned & standardized)   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                      GOLD LAYER                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐      ┌──────────────────┐           │
│  │ dim_customers    │      │  dim_products    │           │
│  │ (VIEW)           │      │  (VIEW)          │           │
│  └────────┬─────────┘      └────────┬─────────┘           │
│           │                         │                      │
│           └────────┬────────────────┘                      │
│                    │                                       │
│           ┌────────▼─────────┐                            │
│           │   fact_sales     │                            │
│           │   (VIEW)         │                            │
│           └──────────────────┘                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 🔄 Data Flow Chi Tiết

#### dim_customers

```
silver.crm_cust_info (master)
    ↓
LEFT JOIN silver.erp_cust_az12 (birthdate, gender)
    ↓
LEFT JOIN silver.erp_loc_a101 (country)
    ↓
gold.dim_customers
```

#### dim_products

```
silver.crm_prd_info (master)
    ↓
LEFT JOIN silver.erp_px_cat_g1v2 (category info)
    ↓
WHERE prd_end_dt IS NULL (active only)
    ↓
gold.dim_products
```

#### fact_sales

```
silver.crm_sales_details (master)
    ↓
LEFT JOIN gold.dim_products
    ↓
LEFT JOIN gold.dim_customers
    ↓
gold.fact_sales
```

---

## 📋 Metadata

| Thuộc Tính        | Giá Trị                  |
| ----------------- | ------------------------ |
| Schema            | gold                     |
| Database          | [Your Database Name]     |
| Refresh Frequency | [Daily/Hourly/Real-time] |
| Data Retention    | [Retention Policy]       |
| Owner             | Data Engineering Team    |
| Contact           | [Email/Slack Channel]    |

---

## 🔍 Queries Mẫu

### Query 1: Top 10 Khách Hàng Theo Doanh Thu

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

### Query 2: Doanh Thu Theo Danh Mục Sản Phẩm

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

### Query 3: Phân Tích Khách Hàng Theo Giới Tính và Quốc Gia

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

## ⚠️ Lưu Ý Quan Trọng

1. **Date Format:** Các cột ngày trong fact_sales đang ở định dạng INT, cần convert sang DATE khi sử dụng
2. **NULL Values:** Tất cả các cột đều có thể NULL, cần xử lý trong queries
3. **View Performance:** Các bảng gold là VIEW, có thể cần materialized view cho performance
4. **Historical Data:** dim_products chỉ chứa active products, không có lịch sử thay đổi

---

**Prepared by:** Data Engineering Team  
**Document Version:** 1.0  
**Last Review Date:** 2025-12-18
