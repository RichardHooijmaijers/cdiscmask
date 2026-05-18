# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`cdiscmask` is a planned R package for anonymizing CDISC clinical trial data. It is currently in the ideation stage with no source code yet.

## Goals

- Anonymize CDISC-standard datasets (SDTM, ADaM) while preserving data types (e.g., AGE stays numeric, not bucketed)
- Handle cross-domain consistency: date shifts for a subject ID must be identical across all datasets
- Support reversible anonymization — track transformations so original data can be recovered
- Auto-detect sensitive fields (subject IDs, dates, etc.) and leave non-sensitive fields (units, normal ranges, labs) unchanged
- Intended end-use: feed anonymized CDISC data to agentic workflows without exposing PII

## Relevant Prior Art to Be Aware Of

- `deident` R package — general de-identification
- `privacyR` R package — `anonymize_dataframe()` is a useful reference, but lacks numeric preservation and cross-dataset consistency

## Development Commands

```r
devtools::load_all()                                  # load package interactively
devtools::test()                                      # run all tests
devtools::check()                                     # full R CMD check
devtools::document()                                  # regenerate NAMESPACE + man/ from roxygen
testthat::test_file("tests/testthat/test-mask.R")    # run a single test file
```

## Architecture

All public functions funnel through a shared `cdiscmask_key` object (created by `new_mask_key()`) that stores every per-subject mapping. Passing the same key to multiple `mask_domain()` calls is what guarantees cross-domain consistency — it is the central design invariant.

```
mask_cdisc(domains, key)          # multi-domain entry point
  └─ mask_domain(df, key)         # per-domain orchestrator
       ├─ detect_sensitive_cols() # classify columns by type
       ├─ mask_subject_id()       # pseudonymize IDs, write to key
       ├─ shift_dates()           # shift dates, write offsets to key
       └─ mask_free_text()        # redact verbatim text, write originals to key

unmask_domain(df, key)            # reverse using stored mappings
save_mask_key() / load_mask_key() # persist key to .rds
```

### Source files

| File | Contents |
|------|----------|
| `R/mask.R` | `mask_domain()`, `mask_cdisc()`, `unmask_domain()` |
| `R/detect.R` | `detect_sensitive_cols()` |
| `R/subject_id.R` | `mask_subject_id()` |
| `R/dates.R` | `shift_dates()` |
| `R/free_text.R` | `mask_free_text()` |
| `R/key.R` | `new_mask_key()`, `save_mask_key()`, `load_mask_key()` |

## Key Design Decisions

- **Numeric types are preserved** — AGE and similar numeric variables are never converted to categories. Only subject IDs (character) and dates are transformed.
- **Partial ISO-8601 dates** (`"2020-03"`, `"2020"`) and CDISC `"--"` unknown-date placeholders must be handled in `shift_dates()` without coercing to a full date object.
- **Day-offset columns** (CDISC suffix `DY`, e.g. `AEDY`) are plain integers representing study-day; they should be shifted by the same per-subject offset as dates, with no date parsing.
- **Free text is destructive** — verbatim/narrative columns cannot be shifted or pseudonymized reliably, so they are replaced with a placeholder and the originals are stored in the key.
