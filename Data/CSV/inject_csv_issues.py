import csv
import random
from pathlib import Path

# --------- SETTINGS
INPUT_FILE = Path("env_reports_01_2025.csv")
OUTPUT_FILE = Path("env_reports_01_2025.csv")
ISSUES_LOG_FILE = Path("csv_injected_issues_log.txt")

# Issues to inject - Total 30
ISSUES_CONFIG = {
    "missing_emission": 10,     # Missing CO2 emission value
    "missing_taux": 10,          # Missing recycling rate
    "invalid_taux": 5,           # Recycling rate > 1 (impossible)
    "wrong_date": 5,             # Wrong date format
}

# Wrong date formats to use
WRONG_DATE_FORMATS = [
    "01/15/2025",      # MM/DD/YYYY instead of YYYY-MM-DD
    "15-01-2025",      # DD-MM-YYYY
    "2025/01/15",      # YYYY/MM/DD with slashes
    "15.01.2025",      # DD.MM.YYYY
    "Jan 15, 2025",    # Text format
]

def inject_csv_issues(input_path, output_path):
    """Inject data quality issues into the CSV file"""
    issues_log = []

    # Read all rows
    with open(input_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        rows = list(reader)

    if len(rows) < 30:
        print("[!] Not enough rows to inject 30 issues")
        return rows, issues_log

    # Get random row indices (avoid duplicates)
    available_indices = list(range(len(rows)))
    random.shuffle(available_indices)

    issue_row_indices = available_indices[:30]  # Select 30 random rows

    # Track which issue to inject for each row
    issue_types = []
    for issue_type, count in ISSUES_CONFIG.items():
        issue_types.extend([issue_type] * count)
    random.shuffle(issue_types)

    # Inject issues
    for idx, issue_type in zip(issue_row_indices, issue_types):
        row = rows[idx]
        row_num = idx + 2  # +2 because CSV starts at row 1 (header) and we're 0-indexed

        if issue_type == "missing_emission":
            original_value = row['emission_CO2_kg']
            row['emission_CO2_kg'] = ''
            issues_log.append({
                "type": "MISSING_EMISSION",
                "row": row_num,
                "region": row['id_region'],
                "batiment": row['id_batiment'],
                "date": row['date_rapport'],
                "original_value": original_value,
                "description": "Missing CO2 emission value (empty)"
            })

        elif issue_type == "missing_taux":
            original_value = row['taux_recyclage']
            row['taux_recyclage'] = ''
            issues_log.append({
                "type": "MISSING_TAUX",
                "row": row_num,
                "region": row['id_region'],
                "batiment": row['id_batiment'],
                "date": row['date_rapport'],
                "original_value": original_value,
                "description": "Missing recycling rate value (empty)"
            })

        elif issue_type == "invalid_taux":
            original_value = row['taux_recyclage']
            # Generate invalid rate > 1
            invalid_rate = round(random.uniform(1.1, 2.5), 2)
            row['taux_recyclage'] = str(invalid_rate)
            issues_log.append({
                "type": "INVALID_TAUX",
                "row": row_num,
                "region": row['id_region'],
                "batiment": row['id_batiment'],
                "date": row['date_rapport'],
                "original_value": original_value,
                "invalid_value": invalid_rate,
                "description": f"Invalid recycling rate {invalid_rate} (should be 0-1)"
            })

        elif issue_type == "wrong_date":
            original_date = row['date_rapport']
            # Parse original date and convert to wrong format
            try:
                year, month, day = original_date.split('-')
                wrong_format = random.choice(WRONG_DATE_FORMATS)

                # Apply the wrong format
                if wrong_format == "01/15/2025":
                    new_date = f"{month}/{day}/{year}"
                elif wrong_format == "15-01-2025":
                    new_date = f"{day}-{month}-{year}"
                elif wrong_format == "2025/01/15":
                    new_date = f"{year}/{month}/{day}"
                elif wrong_format == "15.01.2025":
                    new_date = f"{day}.{month}.{year}"
                else:  # "Jan 15, 2025"
                    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                             "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                    month_name = months[int(month) - 1]
                    new_date = f"{month_name} {day}, {year}"

                row['date_rapport'] = new_date
                issues_log.append({
                    "type": "WRONG_DATE",
                    "row": row_num,
                    "region": row['id_region'],
                    "batiment": row['id_batiment'],
                    "original_date": original_date,
                    "wrong_date": new_date,
                    "description": f"Wrong date format: '{new_date}' (should be YYYY-MM-DD)"
                })
            except:
                pass

    # Write modified CSV
    with open(output_path, 'w', encoding='utf-8', newline='') as f:
        fieldnames = ['id_region', 'id_batiment', 'date_rapport', 'emission_CO2_kg', 'taux_recyclage']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    return rows, issues_log

def main():
    print("\n[*] Processing env_reports_01_2025.csv...")

    rows, issues_log = inject_csv_issues(INPUT_FILE, OUTPUT_FILE)

    print(f"[+] Injected {len(issues_log)} issues into CSV file")

    # Print summary
    print("\n" + "="*60)
    print("ISSUES INJECTED:")
    print("="*60)

    type_counts = {}
    for issue in issues_log:
        issue_type = issue['type']
        type_counts[issue_type] = type_counts.get(issue_type, 0) + 1
        print(f"Row {issue['row']:4d} - {issue['type']}: {issue['description']}")

    print("\n" + "="*60)
    print("SUMMARY:")
    print("="*60)
    for issue_type, count in sorted(type_counts.items()):
        print(f"{issue_type}: {count} issues")
    print(f"\nTOTAL: {len(issues_log)} issues")

    # Save log file
    with open(ISSUES_LOG_FILE, 'w', encoding='utf-8') as f:
        f.write("CSV DATA QUALITY ISSUES LOG\n")
        f.write("="*60 + "\n\n")
        f.write(f"File: {INPUT_FILE}\n")
        f.write(f"Total Issues: {len(issues_log)}\n\n")

        for issue_type, count in sorted(type_counts.items()):
            f.write(f"{issue_type}: {count}\n")

        f.write("\n" + "="*60 + "\n")
        f.write("DETAILED ISSUE LIST:\n")
        f.write("="*60 + "\n\n")

        for issue in issues_log:
            f.write(f"Row {issue['row']}:\n")
            f.write(f"  Type: {issue['type']}\n")
            f.write(f"  Region: {issue.get('region', 'N/A')}\n")
            f.write(f"  Building: {issue.get('batiment', 'N/A')}\n")
            f.write(f"  Description: {issue['description']}\n")
            if 'original_value' in issue:
                f.write(f"  Original value: {issue['original_value']}\n")
            if 'invalid_value' in issue:
                f.write(f"  Invalid value: {issue['invalid_value']}\n")
            if 'original_date' in issue:
                f.write(f"  Original date: {issue['original_date']}\n")
            if 'wrong_date' in issue:
                f.write(f"  Wrong date: {issue['wrong_date']}\n")
            f.write("\n")

    print(f"\n[*] Issues log saved to: {ISSUES_LOG_FILE}")

if __name__ == "__main__":
    main()
