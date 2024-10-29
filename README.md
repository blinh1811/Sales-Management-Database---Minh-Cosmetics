# Sales Management Database - Minh Cosmetics
## Project Overview
This project provides a comprehensive database management solution for **Minh Cosmetics**, a retail cosmetics chain. Minh Cosmetics specializes in distributing genuine cosmetics from multiple countries, focusing on high-quality products and personalized customer care. The database system is designed to streamline operations across multiple locations in central Vietnam, allowing for efficient tracking of inventory, sales, customer data, promotions, and employee management.

## Project Structure

### 1. Introduction to Minh Cosmetics
An overview of Minh Cosmetics, including:
- **Mission**: Provide quality cosmetics to enhance customer confidence.
- **Products**: A diverse selection of makeup, skincare, and body care products.
- **Expansion**: Stores located in Quảng Trị, Huế, Đà Nẵng, and Quảng Nam.

### 2. Database Design and Development
The database includes the following entities:
- **Products**: Stores product details (ID, name, origin, price, brand).
- **Suppliers**: Contains supplier information for inventory management.
- **Locations**: Stores branch codes and addresses.
- **Employees**: Employee details, including work shifts and management roles.
- **Customers**: Customer details for membership and loyalty programs.
- **Transactions**: Records each sale transaction through invoices, linking customers and promotions.
- **Membership and Promotions**: Manages loyalty cards and promotional events.

### 3. Entity-Relationship Diagram (ERD)
The ERD illustrates the relationships between entities, ensuring data is normalized and optimizing query performance.

### 4. SQL Server Implementation
Includes:
- **Views**: Four views (e.g., `View_MatHang`, `KH_USE`) for simplified data access.
- **Stored Procedures**: Functions like `ADD_KH` and `UPDATE_KH` to manage customer data.
- **Functions**: Includes `Max_Luong` to retrieve specific data points (e.g., employee with the highest wage).
- **Triggers**: Automatic triggers, such as `InsertTriGia`, calculate invoice values.
- **Constraints**: Data integrity is enforced through constraints for fields like `SDT` (phone number).

### 5. MySQL Implementation
A parallel MySQL implementation includes equivalent views, stored procedures, and triggers, providing cross-database compatibility.

## Usage
1. **Import** the SQL schema into either SQL Server or MySQL.
2. **Execute** the stored procedures to manage customer and product data.
3. Use the **Python scripts** for analyzing sales data and generating visual insights.

## Conclusion
This project provides Minh Cosmetics with a scalable and robust solution for efficient store management, encompassing inventory, customer data, and sales performance.

## Author
Developed by **Trương Ngọc Bảo Linh**.
