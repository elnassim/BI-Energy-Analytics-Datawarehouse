# Data Quality Issues Summary - Energy Analytics Data Warehouse

## Overview
This document summarizes all intentionally injected data quality issues across the three data sources (SQL, JSON, CSV) for ETL testing and validation.

---

## Total Issues: 330+

### By Data Source:
- **SQL Database**: ~8-10 types of issues (manual count needed)
- **JSON Files**: 300 issues (100 per file × 3 files)
- **CSV File**: 30 issues

---

## 1. SQL DATABASE ISSUES

### Regions Table
- **Missing values**: `nom_region` = NULL (1 row: REG06)

### Batiments Table
- **Invalid surface**: `surface_m2` = 0 or 1 (too small for buildings)
- **Invalid surface**: `surface_m2` = very large values (e.g., 999998, 882218)
- **Extra whitespace**: `batiment_id` with trailing spaces (e.g., 'BAT009 ', 'BAT016 ', 'BAT026 ')
- **Unknown type**: `type_batiment` = 'unknown'

### Clients Table
- **Invalid email**: Missing '@' (e.g., name@gmailcom instead of name@gmail.com)
- **Missing phone**: `telephone` = NULL

### Contrats Table
- **Missing date**: `date_fin` = NULL
- **Invalid dates**: `date_fin` < `date_debut` (end before start)

### Compteurs Table
- **Wrong unit**: Incorrect measurement units

### Factures Table
- **Invalid amounts**: `cout_energie` + `autres_couts` > `montant_ttc`

### Paiements Table
- **Invalid status**: `statut` = 'paid' (should be 'paye')

---

## 2. JSON ENERGY CONSUMPTION FILES

### Files:
1. `Elec_consumption_01_2025.json`
2. `Eau_consumption_01_2025.json`
3. `Gaz_consumption_01_2025.json`

### Total: 300 issues (100 per file)

### Issue Breakdown (per file):

| Issue Type | Count | Description |
|------------|-------|-------------|
| **DUPLICATE** | 25 | Same timestamp appears twice consecutively |
| **MISSING** | 25 | `consommation` = null |
| **NEGATIVE** | 20 | `consommation` < 0 (range: -10 to -0.5) |
| **IMPOSSIBLE** | 20 | Extremely high values:<br>- Electricity: 50,000-99,999 KWh<br>- Water/Gas: 5,000-9,999 m³ |
| **WRONG_UNIT** | 5 | Incorrect units:<br>- Electricity: m³ instead of KWh<br>- Water: KWh instead of m³<br>- Gas: L instead of m³ |
| **ZERO** | 5 | `consommation` = 0.0 (suspicious for active buildings) |
| **TOTAL** | **100** | Per file |

### Distribution:
- Issues spread across all 5 regions (REG01-REG05)
- Issues distributed across 10 buildings (BAT001-BAT010)
- **Log file**: `Data/JSON/data/json/injected_issues_log.json`

---

## 3. CSV ENVIRONMENTAL REPORTS

### File: `env_reports_01_2025.csv`

### Total: 30 issues

### Issue Breakdown:

| Issue Type | Count | Description | Examples |
|------------|-------|-------------|----------|
| **MISSING_EMISSION** | 10 | Empty `emission_CO2_kg` field | Row 552, 511, 520, 691, etc. |
| **MISSING_TAUX** | 10 | Empty `taux_recyclage` field | Row 68, 277, 407, 281, etc. |
| **INVALID_TAUX** | 5 | `taux_recyclage` > 1 | 1.28, 1.66, 1.64, 1.51, 1.47 |
| **WRONG_DATE** | 5 | Wrong date format | '2025/01/13', '01/14/2025', 'Jan 13, 2025' |
| **TOTAL** | **30** | |

### Date Format Issues:
- **Correct format**: YYYY-MM-DD (e.g., 2025-01-15)
- **Wrong formats found**:
  - YYYY/MM/DD (e.g., 2025/01/13)
  - MM/DD/YYYY (e.g., 01/14/2025)
  - DD-MM-YYYY
  - DD.MM.YYYY
  - Month Name (e.g., Jan 13, 2025)

### Sample Issue Rows:
- **Row 68**: Missing taux_recyclage
- **Row 123**: Invalid taux_recyclage = 1.66
- **Row 240**: Wrong date format '2025/01/13'
- **Row 277**: Missing taux_recyclage
- **Row 552**: Missing emission_CO2_kg

### Distribution:
- Issues spread across all regions and buildings
- **Log file**: `Data/CSV/csv_injected_issues_log.txt`

---

## ETL Validation Checklist

### Data Cleaning Rules to Implement:

#### SQL Issues:
- [ ] Handle NULL values (imputation or filtering)
- [ ] Validate surface ranges (min/max thresholds)
- [ ] Trim whitespace from IDs
- [ ] Standardize type values
- [ ] Validate email format
- [ ] Handle missing phone numbers
- [ ] Validate date ranges (start < end)
- [ ] Validate financial calculations
- [ ] Standardize status values

#### JSON Issues:
- [ ] Remove duplicate timestamps
- [ ] Handle NULL consumption values
- [ ] Filter/flag negative values
- [ ] Detect outliers (statistical thresholds)
- [ ] Standardize units (conversion)
- [ ] Handle zero consumption (flag or filter)

#### CSV Issues:
- [ ] Handle missing numeric values
- [ ] Validate recycling rate range (0-1)
- [ ] Standardize date format to YYYY-MM-DD
- [ ] Validate CO2 emission ranges

---

## Log Files

1. **JSON Issues**: `Data/JSON/data/json/injected_issues_log.json`
2. **CSV Issues**: `Data/CSV/csv_injected_issues_log.txt`
3. **Overall Summary**: `Missed_data.txt`

---

## Notes

- All issues are **intentionally injected** for ETL testing
- Issues simulate real-world data quality problems
- Each issue type represents common data problems in BI systems
- Use log files to verify ETL cleaning effectiveness

---

*Generated: 2025-01-02*
*Project: Energy Analytics Data Warehouse*
