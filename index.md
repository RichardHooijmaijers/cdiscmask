# cdiscmask

`cdiscmask` is an R package for anonymizing CDISC clinical trial data
(SDTM and ADaM). It replaces subject identifiers with pseudonyms, shifts
dates by a per-subject random offset, and redacts verbatim/categorical
text — while leaving non-sensitive columns (AGE, SEX, lab units, normal
ranges) completely unchanged.

Key properties:

- **Cross-domain consistency** — the same subject ID and date shift are
  applied identically across all domains when a shared masking key is
  used.
- **Reversible** — every transformation is recorded in a masking key so
  original data can be recovered exactly.
- **Type-preserving** — numeric columns stay numeric; character columns
  stay character; `Date`-class columns stay `Date`.
- **Auto-detection** — sensitive columns are identified from CDISC
  naming conventions (no manual column lists required).

## Installation

The package is not yet on CRAN. Install from GitHub:

``` r

# install.packages("remotes")
remotes::install_github("RichardHooijmaijers/cdiscmask")
```

## Quick start

``` r

library(cdiscmask)
library(safetyData)  # provides sdtm_dm, sdtm_ae, sdtm_lb, adam_adsl, ...

# Mask multiple domains with a single call — one shared key guarantees consistency
masked <- mask_cdisc(list(
  DM = sdtm_dm,
  AE = sdtm_ae,
  LB = sdtm_lb
))

# Inspect: AGE/SEX untouched, USUBJID pseudonymised, dates shifted
masked$DM[1:3, c("USUBJID", "RFSTDTC", "AGE", "SEX", "ARM")]

# Recover original data using the attached key
key <- attr(masked, "key")
dm_original <- unmask_domain(masked$DM, key)

# Persist the key so you can unmask in a later session
save_mask_key(key, "masking_key.rds")
key <- load_mask_key("masking_key.rds")
```

## How it works

All masking state lives in a `cdiscmask_key` object. Pass the same key
to every
[`mask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_domain.md)
call and the package guarantees:

- A subject pseudonymised as `SUBJ-0042` in DM will be `SUBJ-0042` in
  every other domain.
- Dates for that subject are shifted by exactly the same number of days
  everywhere.

``` r

key <- new_mask_key()

dm_masked <- mask_domain(sdtm_dm, key, domain = "DM")
ae_masked <- mask_domain(sdtm_ae, key, domain = "AE")  # reuses mappings from above
```

### What gets masked

| Column type | Detection rule | Transformation |
|----|----|----|
| Subject ID | `USUBJID`, `SUBJID` | Replaced with opaque pseudonym (`SUBJ-0001`, …) |
| Date / datetime | `DTC`/`DTM` suffix (SDTM) or `Date` class (ADaM) | Shifted by per-subject random day offset |
| Study day | `DY` suffix | Shifted by the same integer offset |
| Verbatim / categorical | `TERM`, `TRT`, `NAM`, `TEXT`, `VERBATIM` suffix; `STUDYID`; character `ARM*`/`TRT*` columns | Replaced with category-preserving label (`AETERM-0001`, …) |
| Everything else | — | Unchanged |

Partial ISO-8601 dates (`"2020-03"`, `"2020"`) and CDISC `"--"`
placeholders are left untouched.

## Vignette

A full walkthrough with cross-domain verification and ADaM examples:

``` r

vignette("cdiscmask-intro", package = "cdiscmask")
```
