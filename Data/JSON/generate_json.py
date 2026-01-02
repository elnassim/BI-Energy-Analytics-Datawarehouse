import json
import random
from datetime import datetime, timedelta
from pathlib import Path

# --------- SETTINGS (edit only this part)
OUTPUT_DIR = Path("data/json")
MONTH_START = "2025-01-01 00:00:00"
MONTH_DAYS = 3  # <-- keep small for tests (3 days). Change to 30/31 later.

REGIONS = ["REG01", "REG02", "REG03", "REG04", "REG05"]
# Choose which buildings belong to each region (edit to match your SQL if you want)
BUILDINGS_BY_REGION = {
    "REG01": ["BAT001", "BAT002"],
    "REG02": ["BAT003", "BAT004"],
    "REG03": ["BAT005", "BAT006"],
    "REG04": ["BAT007", "BAT008"],
    "REG05": ["BAT009", "BAT010"],
}

# Simple meter IDs per building (you can change to match your SQL compteurs table)
def meter_id(energy: str, b_index: int) -> str:
    prefix = {"electricite": "ELEC_", "eau": "EAU_", "gaz": "GAZ_"}[energy]
    return f"{prefix}{b_index:03d}"

ENERGIES = [
    ("electricite", "KWh", 20, 200),  # min/max per hour
    ("eau", "m3", 0.2, 5.0),
    ("gaz", "m3", 0.5, 10.0),
]
# ----------------------------------------

def generate_energy_file(energy_type: str, unit: str, vmin: float, vmax: float, month_start: str, month_days: int):
    start_dt = datetime.strptime(month_start, "%Y-%m-%d %H:%M:%S")
    generation_date = (start_dt + timedelta(days=month_days)).strftime("%Y-%m-%d")

    all_regions_docs = []

    for reg in REGIONS:
        batiments = []
        buildings = BUILDINGS_BY_REGION.get(reg, [])
        for i, bat in enumerate(buildings, start=1):
            compteur = meter_id(energy_type, i)
            mesures = []

            # hourly data
            for h in range(month_days * 24):
                dt = start_dt + timedelta(hours=h)
                consommation = round(random.uniform(vmin, vmax), 3)
                mesures.append({
                    "compteur_id": compteur,
                    "date_mesure": dt.strftime("%Y-%m-%d %H:%M:%S"),
                    "consommation": consommation
                })

            batiments.append({
                "id_batiment": bat,
                "type_energie": energy_type,
                "unite": unit,
                "date_generation": generation_date,
                "mesures": mesures
            })

        all_regions_docs.append({
            "id_region": reg,
            "batiments": batiments
        })

    return all_regions_docs

def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for energy_type, unit, vmin, vmax in ENERGIES:
        docs = generate_energy_file(energy_type, unit, vmin, vmax, MONTH_START, MONTH_DAYS)

        filename = {
            "electricite": "Elec_consumption_01_2025.json",
            "eau": "Eau_consumption_01_2025.json",
            "gaz": "Gaz_consumption_01_2025.json",
        }[energy_type]

        out_path = OUTPUT_DIR / filename
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(docs, f, ensure_ascii=False, indent=2)

        print(f"[+] Created: {out_path}  (regions={len(docs)})")

if __name__ == "__main__":
    main()
