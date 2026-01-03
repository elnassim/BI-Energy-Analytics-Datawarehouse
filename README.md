# Energy Analytics Data Warehouse - BI Project

A complete Business Intelligence data warehouse project for energy analytics with intentionally injected data quality issues for ETL testing.

## Project Scope

- **6 Regions**: Casablanca, Rabat, Marrakech, Tanger, Berkane, Laayoune
- **3 Months**: January - March 2025 (Q1)
- **3 Energy Types**: Electricity, Water, Gas
- **87 Buildings**: Distributed across regions
- **1,080+ Data Quality Issues**: For ETL validation

## Data Sources

### 1. SQL Operational Database (8 tables)
Location: `Data/SQL/`

- `regions.sql` - 6 regions
- `batiments.sql` - 40+ buildings
- `clients.sql` - Customer data
- `contrats.sql` - Contracts
- `compteurs.sql` - Energy meters
- `factures.sql` - Invoices
- `paiements.sql` - Payments

### 2. JSON Energy Consumption (9 files)
Location: `Data/JSON/data/json/`

**Structure**: Hourly measurements by region → building → meter

| Month | Electricity | Water | Gas |
|-------|------------|-------|-----|
| January | Elec_consumption_01_2025.json | Eau_consumption_01_2025.json | Gaz_consumption_01_2025.json |
| February | Elec_consumption_02_2025.json | Eau_consumption_02_2025.json | Gaz_consumption_02_2025.json |
| March | Elec_consumption_03_2025.json | Eau_consumption_03_2025.json | Gaz_consumption_03_2025.json |

**Total**: 78,696 hourly measurements

### 3. CSV Environmental Reports (6 files)
Location: `Data/CSV/`

One file per region with CO₂ emissions and recycling rates:

- `env_reports_REG01_Q1_2025.csv` (Casablanca)
- `env_reports_REG02_Q1_2025.csv` (Rabat)
- `env_reports_REG03_Q1_2025.csv` (Marrakech)
- `env_reports_REG04_Q1_2025.csv` (Tanger)
- `env_reports_REG05_Q1_2025.csv` (Berkane)
- `env_reports_REG06_Q1_2025.csv` (Laayoune)

**Total**: 1,200 environmental reports

## Data Quality Issues

### Total: 1,080+ intentional issues

#### JSON (900 issues)
- 225 Duplicate timestamps
- 225 Missing values (null)
- 180 Negative consumption
- 180 Impossible outliers
- 45 Wrong units
- 45 Zero consumption

#### CSV (180 issues)
- 60 Missing CO₂ emissions
- 60 Missing recycling rates
- 30 Invalid rates (>1)
- 30 Wrong date formats

#### SQL (~20 issues)
- NULL values
- Invalid ranges
- Whitespace errors
- Wrong enumerations

## Scripts

### Data Generation

```bash
# Generate 9 JSON files (3 months × 3 energy types)
cd Data/JSON
python generate_json_3months.py

# Generate 6 CSV files (1 per region)
cd Data/CSV
python generate_csv_regional.py
```

### Issue Injection

```bash
# Inject 100 issues per JSON file
cd Data/JSON
python inject_issues_all_json.py

# Inject 30 issues per CSV file
cd Data/CSV
python inject_issues_all_csv.py
```

## Documentation

- **[Missed_data.txt](Missed_data.txt)** - Master data quality issues list
- **[PROJECT_DATA_SUMMARY.md](Data/PROJECT_DATA_SUMMARY.md)** - Complete documentation
- **JSON Issues Log** - `Data/JSON/data/json/json_injected_issues_log.json`
- **CSV Issues Log** - `Data/CSV/csv_injected_issues_all_log.txt`

## ETL Requirements

### Data Cleaning Checklist

- [ ] **JSON**: Remove 225 duplicates, handle 225 nulls, filter 180 negatives
- [ ] **JSON**: Detect 180 outliers, convert 45 wrong units, investigate 45 zeros
- [ ] **CSV**: Handle 120 missing values, fix 30 invalid rates, standardize 30 dates
- [ ] **SQL**: Clean nulls, validate ranges, trim whitespace, standardize enums

### Data Warehouse Design

Create 3 data marts:

1. **Energy Data Mart** - Consumption analysis
2. **Financial Data Mart** - Revenue and costs
3. **Environmental Data Mart** - CO₂ and recycling

Each with:
- Fact tables (measurements/transactions)
- Dimension tables (time, region, building, client, energy type)

## Quick Stats

| Metric | Value |
|--------|-------|
| Total Data Files | 23 (9 JSON + 6 CSV + 8 SQL) |
| Regions | 6 |
| Buildings | 87 unique |
| Time Period | Q1 2025 (3 months) |
| JSON Measurements | 78,696 |
| CSV Reports | 1,200 |
| Data Quality Issues | 1,080+ |

## Project Structure

```
Energy_Analytics_Datawarehouse/
├── README.md
├── Missed_data.txt
├── Data/
│   ├── PROJECT_DATA_SUMMARY.md
│   ├── JSON/
│   │   ├── data/json/              (9 consumption files + log)
│   │   ├── generate_json_3months.py
│   │   └── inject_issues_all_json.py
│   ├── CSV/
│   │   ├── env_reports_REG*.csv    (6 regional files)
│   │   ├── generate_csv_regional.py
│   │   └── inject_issues_all_csv.py
│   └── SQL/
│       ├── create_tables.sql
│       └── *.sql                    (8 table files)
```

## Next Steps

1. **ETL Development** - Use Pentaho/Talend to clean data
2. **Data Warehouse** - Design star schemas for 3 data marts
3. **KPI Definition** - Define business metrics
4. **Dashboards** - Create visualizations in Power BI/Tableau

## Team

- **Person 1**: ETL development, data warehouse design, automation
- **Person 2**: Data generation, data quality simulation, KPI definition, reporting

---

*Last Updated: 2025-01-02*
*Project Type: Business Intelligence Mini-Project*
*Purpose: Energy Analytics with ETL Testing*
