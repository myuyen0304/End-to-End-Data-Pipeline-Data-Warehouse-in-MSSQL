# End-to-End Data Pipeline & Data Warehouse in MSSQL

This project demonstrates a complete end-to-end data pipeline and data warehouse solution using Microsoft SQL Server (MSSQL). It covers the process from raw data ingestion to the creation of a robust data warehouse, following the Bronze-Silver-Gold architecture pattern.

## Project Overview

- **Data Sources:** Includes CRM and ERP datasets in CSV format.
- **ETL Scripts:** SQL scripts for each layer (Bronze, Silver, Gold) to transform and load data.
- **Data Warehouse:** Dimensional modeling with fact and dimension tables for analytics.
- **Quality Checks:** Automated SQL scripts to validate data integrity and relationships.
- **Documentation:** Data catalog and architecture diagram for easy reference.

## Architecture

The solution follows the modern data warehouse architecture with three layers:

- **Bronze Layer:** Raw data ingestion and initial staging.
- **Silver Layer:** Data cleansing, transformation, and integration.
- **Gold Layer:** Data modeling for analytics and business intelligence.

![Data Warehouse Architecture](docs/Dwh-Architecture.svg)

## Folder Structure

- `datasets/` - Source data files (CRM, ERP)
- `scripts/` - SQL scripts for each layer (bronze, silver, gold)
- `docs/` - Documentation, data catalog, and architecture diagram
- `tests/` - Data quality check scripts

## Documentation

- [Dataset Folder](datasets/): Browse the source data files (CRM, ERP)
- [Data Catalog](docs/data_catalog.md): Detailed description of tables, columns, and business logic.

## Getting Started

1. Clone the repository.
2. Review the datasets in `datasets/`.
3. Execute the SQL scripts in `scripts/` in order: bronze → silver → gold.
4. Run quality checks in `tests/`.
5. Refer to the documentation in `docs/` for details.

## License

This project is licensed under the MIT License.
