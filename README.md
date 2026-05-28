# whocall-scam-db

Static JSON data feed for the [Who Call](https://github.com/gongaiyouxiang-lgtm/whocall)
Android app. The app fetches `manifest.json` weekly over WiFi and pulls the
listed regional files.

Hosted via GitHub Pages at https://gongaiyouxiang-lgtm.github.io/whocall-scam-db/

## Layout

```
manifest.json            # index of regional files + their ETag/last-updated
regional/
  tw_165.json            # Taiwan 165 anti-fraud line
  hk_police.json         # Hong Kong Police CADRC
  cn_12321.json          # China 12321 spam reporting
  uk_ncsc.json           # UK National Cyber Security Centre
  us_ftc.json            # US Federal Trade Commission
```

## Wire format

`manifest.json`:

```json
{
  "version": 1,
  "updated_at_ms": 1748390400000,
  "regions": [
    { "source": "TW_165", "file": "regional/tw_165.json", "etag": "<sha256>" }
  ]
}
```

Each regional file:

```json
{
  "source": "TW_165",
  "updated_at_ms": 1748390400000,
  "entries": [
    {
      "number": "0212345678",
      "reported_at_ms": 1744000000000,
      "category": "investment_fraud"
    }
  ]
}
```

`source` must be one of `TW_165`, `HK_POLICE`, `CN_12321`, `UK_NCSC`, `US_FTC`,
`MANUAL` — matching `com.ppinter.whocall.data.db.ScamSource`.

## Updating

Phase 2 will add a GitHub Actions workflow that periodically scrapes the
upstream public sources, normalises the numbers, and pushes a refreshed
manifest. Until then the regional files here are placeholders.
