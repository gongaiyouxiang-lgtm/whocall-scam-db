#!/usr/bin/env python3
"""Refresh regional JSON + manifest from manual/*.csv.

Inputs (committed):
    manual/<region>.csv     CSV with columns: number, reported_at, category

Outputs (regenerated each run):
    regional/<region>.json  Wire-format consumed by the Android app
    manifest.json           Region index with updated_at_ms + sha256 etags

Run locally:
    python scripts/refresh.py

Run on GitHub Actions:
    .github/workflows/refresh.yml does this weekly + on workflow_dispatch.
"""

from __future__ import annotations

import csv
import hashlib
import json
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANUAL = ROOT / "manual"
MANIFEST = ROOT / "manifest.json"

# source -> (csv basename, regional json path relative to root)
REGION_FILES: dict[str, tuple[str, str]] = {
    "TW_165": ("tw_165.csv", "regional/tw_165.json"),
    "HK_POLICE": ("hk_police.csv", "regional/hk_police.json"),
    "CN_12321": ("cn_12321.csv", "regional/cn_12321.json"),
    "UK_NCSC": ("uk_ncsc.csv", "regional/uk_ncsc.json"),
    "US_FTC": ("us_ftc.csv", "regional/us_ftc.json"),
}


def normalize_number(raw: str) -> str:
    """Strip everything except digits and a leading '+'."""
    raw = raw.strip()
    if not raw:
        return ""
    has_plus = raw.startswith("+")
    digits = "".join(c for c in raw if c.isdigit())
    return ("+" + digits) if has_plus else digits


def parse_date_ms(raw: str) -> int:
    """Convert YYYY-MM-DD into epoch ms; fall back to now()."""
    raw = (raw or "").strip()
    if raw:
        try:
            struct = time.strptime(raw, "%Y-%m-%d")
            return int(time.mktime(struct) * 1000)
        except ValueError:
            pass
    return int(time.time() * 1000)


def read_manual_csv(path: Path) -> list[dict]:
    if not path.exists():
        return []
    rows: list[dict] = []
    seen: set[str] = set()
    with path.open("r", encoding="utf-8") as f:
        for raw_row in csv.DictReader(f):
            number = normalize_number(raw_row.get("number", ""))
            if not number or number in seen:
                continue
            seen.add(number)
            rows.append(
                {
                    "number": number,
                    "reported_at_ms": parse_date_ms(raw_row.get("reported_at", "")),
                    "category": (raw_row.get("category") or "").strip() or None,
                }
            )
    return rows


def dump_json(target: Path, data: dict) -> str:
    text = json.dumps(data, indent=2, ensure_ascii=False) + "\n"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text, encoding="utf-8")
    return text


def main() -> None:
    now_ms = int(time.time() * 1000)
    regions: list[dict] = []
    total = 0
    for source, (csv_name, json_rel) in REGION_FILES.items():
        entries = read_manual_csv(MANUAL / csv_name)
        json_path = ROOT / json_rel
        text = dump_json(
            json_path,
            {
                "source": source,
                "updated_at_ms": now_ms,
                "entries": entries,
            },
        )
        etag = hashlib.sha256(text.encode("utf-8")).hexdigest()[:16]
        regions.append({"source": source, "file": json_rel, "etag": etag})
        total += len(entries)
        print(f"{source}: {len(entries)} entries")
    dump_json(
        MANIFEST,
        {
            "version": 1,
            "updated_at_ms": now_ms,
            "regions": regions,
        },
    )
    print(f"manifest updated: {total} total entries")


if __name__ == "__main__":
    main()
