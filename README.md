# whocall-scam-db

Static JSON data feed for the [Who Call](https://github.com/gongaiyouxiang-lgtm/whocall)
Android app. The app fetches `manifest.json` weekly over WiFi and pulls the
listed regional files.

Hosted via GitHub Pages at https://gongaiyouxiang-lgtm.github.io/whocall-scam-db/

## Layout

```
manifest.json               # index of regional files + sha256-tail etags
regional/<source>.json      # one file per source, consumed by the app
manual/<source>.csv         # human-curated input (this is the source of truth)
scripts/refresh.py          # rebuilds regional/ + manifest.json from manual/
.github/workflows/refresh.yml  # weekly + manual GitHub Actions run
```

## How updates work

1. Edit any `manual/<source>.csv` and open a PR (or push directly).
2. The Actions workflow runs `scripts/refresh.py` weekly (Mondays 00:00 UTC)
   and on `workflow_dispatch`.
3. The script normalises numbers, regenerates `regional/<source>.json`, and
   updates `manifest.json` with new `updated_at_ms` + etag.
4. If anything changed, Actions commits + pushes back to `main`. GitHub
   Pages redeploys automatically (~30 seconds).
5. The Who Call app's `ScamDbUpdateWorker` pulls the fresh manifest on its
   weekly schedule or whenever the user taps "立即更新" in Settings.

## CSV format

```
number,reported_at,category
0229991111,2025-09-01,investment_fraud
+85299990001,2025-08-12,phishing
```

- `number` — accepted in any common shape (with dashes, spaces, country
  code, etc.). The script strips everything except digits and a leading `+`.
- `reported_at` — `YYYY-MM-DD`; falls back to "now" if blank.
- `category` — free-form short tag. Convention: `snake_case`.

## Sources covered

| `source` enum | Originating reporter |
|---|---|
| `TW_165` | Taiwan 165 anti-fraud line |
| `HK_POLICE` | Hong Kong Police CADRC |
| `CN_12321` | PRC 12321 anti-spam reporting |
| `UK_NCSC` | UK National Cyber Security Centre |
| `US_FTC` | US Federal Trade Commission |

These match `com.ppinter.whocall.data.db.ScamSource` on the Android side.

## Local development

```bash
python scripts/refresh.py
```

Outputs are deterministic given the same `manual/*.csv` + clock tick, so the
diff after running locally previews exactly what Actions will commit.

## Caveats

The numbers currently in `manual/*.csv` are **synthetic placeholders** chosen
from reserved-for-fiction ranges (Taiwan 02-2999-xxxx, HK +852-9999-xxxx, UK
Ofcom +447700-900xxx drama range, US +1-202-555-01xx). Replace with real
reported scams as you collect them. Never commit a number that might belong
to a real subscriber without a public-source citation.
