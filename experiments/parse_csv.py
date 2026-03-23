from pathlib import Path

csv_path = Path(__file__).resolve().parents[1] / "results" / "raw" / "baseline.csv"

if not csv_path.exists():
    raise FileNotFoundError(f"Missing CSV file: {csv_path}")

try:
    import pandas as pd
except ImportError as exc:
    raise SystemExit("Missing dependency: install pandas to parse baseline.csv") from exc

df = pd.read_csv(csv_path)
print(df.head())
