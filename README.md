# Online Marketplace Query Optimization & Concurrency Control

A follow-up MySQL project developed for CSE 535: Database Systems, building on the [Online Marketplace Database System](https://github.com/Rupa-18/online-marketplace-database-system) (Project 1). This project focuses on query optimization, indexing strategy, transaction management, and concurrency control on the same 1.43M+ row marketplace database.

## Project Overview

Using the normalized marketplace schema and dataset from Project 1, this project investigates how indexing and query restructuring affect analytical query performance, and how transaction isolation levels affect data consistency under concurrent access.

The work was designed to:

- Restructure baseline analytical queries into optimized versions (subqueries, CTEs, pre-aggregation) and compare execution plans
- Design and apply B-tree, composite, and generated-column (partial) indexes
- Statistically evaluate whether optimizations produced a significant runtime improvement, before and after indexing
- Simulate and prevent dirty reads, non-repeatable reads, and phantom reads using MySQL transaction isolation levels
- Demonstrate transaction commit/rollback behavior in a single session

## Features

- Query restructuring: correlated aggregations rewritten as derived tables / CTEs for 7 core analytical queries
- `EXPLAIN FORMAT=JSON` execution plan comparison between baseline and optimized queries
- B-tree single-column and composite indexes, plus a generated-column partial index (`is_low_stock`)
- Benchmarking of each query (20 runs each, before and after indexing)
- Paired t-test and 95% confidence interval analysis on baseline vs. optimized runtimes
- Two-session concurrency simulation (Session A / Session B) covering dirty reads, non-repeatable reads, and phantom reads across `READ UNCOMMITTED`, `READ COMMITTED`, `REPEATABLE READ`, and `SERIALIZABLE` isolation levels
- Single-session transaction demo with `COMMIT` / `ROLLBACK`

## Technologies Used

- MySQL
- Python
- pandas, NumPy
- SciPy (paired t-test, confidence intervals)
- Jupyter Notebook

## Indexing Strategy

Implemented in [`sql/indexing.sql`](sql/indexing.sql):

- **Single-column B-tree indexes:** `Order.order_date`, `OrderItem.quantity`, `Product.stock`, `Product.price`, `Payment.amount`
- **Composite indexes:** `Order(customer_id, order_date)`, `OrderItem(product_id, quantity)`, `Payment(order_id, amount)`, `Review(product_id, rating)`
- **Partial/generated-column index:** a stored generated column `is_low_stock` (`stock < 50`) on `Product`, indexed to speed up low-stock filtering

## Query Optimization

Implemented in [`sql/optimized_queries_explain.sql`](sql/optimized_queries_explain.sql). Seven baseline analytical queries were rewritten and compared via `EXPLAIN FORMAT=JSON`:

- Most frequent customers
- Most popular / most sold products
- Highest spending customers
- Customers with the most orders in the last 6 months
- Most frequently bought product pairs
- Total sales per category
- Total payment per customer

Most baseline queries used correlated joins with `GROUP BY` directly against large fact tables; the optimized versions pre-aggregate in a derived table or CTE before joining, reducing the row count involved in the final join.

## Transaction Management & Concurrency Control

- [`sql/transaction_single_session.sql`](sql/transaction_single_session.sql): demonstrates a single-session transaction with `START TRANSACTION` / `COMMIT` (and `ROLLBACK` alternative), verifying the update is durable after commit.
- [`sql/concurrency_session_a.sql`](sql/concurrency_session_a.sql) and [`sql/concurrency_session_b.sql`](sql/concurrency_session_b.sql): two concurrent sessions used to simulate and then prevent:
  - **Dirty reads** (`READ UNCOMMITTED` vs. `READ COMMITTED`)
  - **Non-repeatable reads** (`READ COMMITTED` vs. `REPEATABLE READ`)
  - **Phantom reads** (`READ COMMITTED`/`REPEATABLE READ` vs. `SERIALIZABLE`)

## Benchmarking & Statistical Analysis

Each of the 7 queries was run 20 times (baseline and optimized), both before and after indexing:

- [`benchmarking/benchmarking-project2.ipynb`](benchmarking/benchmarking-project2.ipynb) collects average runtime and standard deviation per query.
- [`benchmarking/statistical_analysis-project2.ipynb`](benchmarking/statistical_analysis-project2.ipynb) runs a paired t-test and computes the 95% confidence interval for the mean runtime difference (baseline − optimized).

**Before indexing** (`benchmarking/project2_stats_results.csv`), 6 of 7 queries showed a statistically significant improvement (p < 0.05) from query restructuring alone — most notably "most frequent customers" (mean diff ≈ 0.67s) and "total sales per category" (mean diff ≈ 1.83s).

**After indexing** (`benchmarking/after_indexing_project2_stats_results.csv`), overall runtimes dropped further, and the picture became more mixed: some queries (e.g. "most frequent customers", "total sales per category") retained large, significant gains, while others (e.g. "highest spending customers", "most frequently bought product pair") showed little or no significant difference — or even a small regression — once indexes did most of the optimization work for both query forms.

## Repository Structure

```
online-marketplace-query-optimization/
│
├── README.md
│
├── sql/
│   ├── indexing.sql
│   ├── optimized_queries_explain.sql
│   ├── transaction_single_session.sql
│   ├── concurrency_session_a.sql
│   └── concurrency_session_b.sql
│
├── benchmarking/
│   ├── benchmarking-project2.ipynb
│   ├── statistical_analysis-project2.ipynb
│   ├── project2_benchmark_results.csv
│   ├── after_indexing_project2_benchmark_results.csv
│   ├── project2_stats_results.csv
│   └── after_indexing_project2_stats_results.csv
│
└── report/
    └── Ghosh_Rupa_2nd_Project_Report.pdf   (add manually — see note below)
```

## How to Run

1. **Set up the database** using the schema and data from [Project 1](https://github.com/Rupa-18/online-marketplace-database-system).

2. **Run baseline benchmarking** (before indexing):

   Open and run `benchmarking/benchmarking-project2.ipynb` and `benchmarking/statistical_analysis-project2.ipynb`.

3. **Apply indexes:**

   ```sql
   SOURCE sql/indexing.sql;
   ```

4. **Re-run benchmarking** to generate the "after indexing" results.

5. **Review execution plans:**

   ```sql
   SOURCE sql/optimized_queries_explain.sql;
   ```

6. **Explore transactions & concurrency control:**

   Run `sql/transaction_single_session.sql` for the single-session demo, or run `sql/concurrency_session_a.sql` and `sql/concurrency_session_b.sql` in two separate MySQL sessions to reproduce the isolation-level experiments.

> **Note:** The notebooks read the MySQL password from the `MYSQL_PASSWORD` environment variable rather than a hardcoded value. Set it before running, e.g. `export MYSQL_PASSWORD=your_password`.

> **Report:** The full write-up (`Ghosh_Rupa_2nd_Project_Report.pdf`) is not yet uploaded to this repo — add it to a `report/` folder via GitHub's "Add file" button.
