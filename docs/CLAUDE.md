# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Project Overview

`cdiscmask` is an R package for anonymizing CDISC clinical trial data
(SDTM and ADaM). It is fully implemented with source, tests, and a
vignette.

## Goals

- Anonymize CDISC-standard datasets (SDTM, ADaM) while preserving data
  types (e.g., AGE stays numeric, not bucketed)
- Handle cross-domain consistency: date shifts for a subject ID must be
  identical across all datasets
- Support reversible anonymization — track transformations so original
  data can be recovered
- Auto-detect sensitive fields (subject IDs, dates, etc.) and leave
  non-sensitive fields (units, normal ranges, labs) unchanged
- Intended end-use: feed anonymized CDISC data to agentic workflows
  without exposing PII

## Development Commands

``` r

devtools::load_all()                                  # load package interactively
devtools::test()                                      # run all tests
devtools::check()                                     # full R CMD check
devtools::check(args = "--no-manual")                 # skip PDF manual (if pdflatex unavailable)
devtools::document()                                  # regenerate NAMESPACE + man/ from roxygen
testthat::test_file("tests/testthat/test-mask.R")    # run a single test file
```

The project `.Rprofile` calls
[`tinytex::use_tinytex()`](https://rdrr.io/pkg/tinytex/man/copy_tinytex.html)
to put pdflatex on PATH for `R CMD check`. If the PDF manual build still
fails, use `devtools::check(args = "--no-manual")`.

Tests use [`library(safetyData)`](https://rdrr.io/r/base/library.html)
for real CDISC datasets (`sdtm_dm`, `sdtm_ae`, `sdtm_lb`, `adam_adsl`).

## Architecture

All public functions funnel through a shared `cdiscmask_key` object
(created by
[`new_mask_key()`](https://richardhooijmaijers.github.io/cdiscmask/reference/new_mask_key.md))
that stores every per-subject mapping. Passing the same key to multiple
[`mask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_domain.md)
calls is what guarantees cross-domain consistency — it is the central
design invariant.

    mask_cdisc(domains, key)          # multi-domain entry point
      └─ mask_domain(df, key)         # per-domain orchestrator
           ├─ detect_sensitive_cols() # classify columns by type
           ├─ shift_dates()           # shift dates while original IDs are still in the df
           ├─ mask_subject_id()       # pseudonymize IDs, write to key
           └─ mask_free_text()        # redact verbatim text, write originals to key

    unmask_domain(df, key)            # reverse in opposite order: free_text → IDs → dates
    save_mask_key() / load_mask_key() # persist key to .rds

**The masking order in
[`mask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_domain.md)
is load-bearing**: dates are shifted first (keyed by the original
subject ID), then subject IDs are replaced, then free text.
[`unmask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/unmask_domain.md)
reverses in the opposite order.

### Source files

| File | Contents |
|----|----|
| `R/mask.R` | [`mask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_domain.md), [`mask_cdisc()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_cdisc.md), [`unmask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/unmask_domain.md) |
| `R/detect.R` | [`detect_sensitive_cols()`](https://richardhooijmaijers.github.io/cdiscmask/reference/detect_sensitive_cols.md) |
| `R/subject_id.R` | [`mask_subject_id()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_subject_id.md) |
| `R/dates.R` | [`shift_dates()`](https://richardhooijmaijers.github.io/cdiscmask/reference/shift_dates.md), internal `.shift_dtc()` |
| `R/free_text.R` | [`mask_free_text()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_free_text.md) |
| `R/key.R` | [`new_mask_key()`](https://richardhooijmaijers.github.io/cdiscmask/reference/new_mask_key.md), [`save_mask_key()`](https://richardhooijmaijers.github.io/cdiscmask/reference/save_mask_key.md), [`load_mask_key()`](https://richardhooijmaijers.github.io/cdiscmask/reference/load_mask_key.md) |

## Key Design Decisions

- **`cdiscmask_key` is an environment**, not a list — this means all
  `mask_*` functions mutate it in place rather than returning a new
  copy. Callers share state by reference.

- **`"cdiscmask_cols"` attribute** —
  [`mask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_domain.md)
  stores the column classification as `attr(df, "cdiscmask_cols")` on
  the returned data frame.
  [`unmask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/unmask_domain.md)
  requires this attribute; it errors if absent.

- **Numeric types are preserved** — AGE and similar numeric variables
  are never converted to categories. Only subject IDs (character) and
  dates are transformed.

- **Partial ISO-8601 dates** (`"2020-03"`, `"2020"`) and CDISC `"--"`
  unknown-date placeholders are left untouched by `.shift_dtc()` — only
  full-precision `YYYY-MM-DD` strings (with optional time component) are
  shifted.

- **Day-offset columns** (CDISC suffix `DY`, e.g. `AEDY`) are plain
  integers shifted arithmetically by the same per-subject day offset —
  no date parsing.

- **Free text is category-preserving** — verbatim/narrative columns and
  categorical columns (ARM, TRT, STUDYID) get opaque labels like
  `AETERM-0001` that preserve category structure. The original → label
  map is stored in `key$free_text[[col]]`.

- **Column detection rules** in
  [`detect_sensitive_cols()`](https://richardhooijmaijers.github.io/cdiscmask/reference/detect_sensitive_cols.md):

  - `subject_id`: exact names `USUBJID`, `SUBJID`
  - `dates`: columns matching `DTC$|DTM$` (SDTM) or `Date`-class columns
    (ADaM)
  - `dy`: columns matching `DY$`, excluding any already classified as
    dates
  - `free_text`: suffix match `TERM$|TRT$|NAM$|TEXT$|VERBATIM$`;
    `STUDYID`; character columns matching `^TRT|^ARM|^ACTARM`
    (numeric/date variants excluded)
