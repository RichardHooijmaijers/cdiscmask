# Getting started with cdiscmask

`cdiscmask` anonymizes CDISC-standard datasets (SDTM, ADaM) while
preserving data types and keeping cross-domain transformations
consistent. Every change is recorded in a **masking key** so the
original data can be recovered.

We use the [`safetyData`](https://cran.r-project.org/package=safetyData)
package throughout — it ships complete SDTM and ADaM datasets from a
fictional clinical trial.

``` r

library(cdiscmask)
library(safetyData)
```

## The masking key

All state lives in a single `cdiscmask_key` object. Creating one is the
first step in every workflow.

``` r

key <- new_mask_key()
key
#> <cdiscmask_key>
#>   0 subject ID mapping(s)
#>   0 date offset(s)
#>   0 free-text column(s) stored
```

Passing the **same key** to every masking call is what guarantees that a
subject mapped to `SUBJ-0001` in DM is also `SUBJ-0001` in AE and LB,
and that all their dates are shifted by exactly the same number of days.

## Masking a single domain

[`mask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_domain.md)
detects sensitive columns automatically and applies the right strategy
for each type:

| Column type | Detection rule | Strategy |
|----|----|----|
| Subject ID | `USUBJID`, `SUBJID` | Replaced with opaque pseudonym |
| Date / datetime | DTC/DTM suffix (SDTM) or `Date` class (ADaM) | Shifted by per-subject random offset |
| Study day | DY suffix | Shifted by the same offset (integer arithmetic) |
| Verbatim / term | TERM, TRT, NAM, TEXT suffix | Replaced with `[REDACTED]` |
| Everything else | — | Unchanged |

``` r

dm_masked <- mask_domain(sdtm_dm, key, domain = "DM")

dm_masked[1:4, c("USUBJID", "SUBJID", "RFSTDTC", "RFENDTC", "AGE", "SEX", "RACE")]
#>     USUBJID    SUBJID    RFSTDTC    RFENDTC AGE SEX  RACE
#> 1 SUBJ-0001 SUBJ-0307 2014-07-16 2015-01-13  63   F WHITE
#> 2 SUBJ-0002 SUBJ-0308 2012-06-21 2012-07-19  64   M WHITE
#> 3 SUBJ-0003 SUBJ-0309 2012-12-18 2013-06-15  71   M WHITE
#> 4 SUBJ-0004 SUBJ-0310 2013-05-30 2013-06-26  74   M WHITE
```

Notice that `AGE`, `SEX`, and `RACE` are untouched — only identifiable
information is transformed. Dates shift by a random number of days while
preserving the date format, and both `USUBJID` and `SUBJID` receive
pseudonyms.

## Masking multiple domains with a shared key

The key point of the cross-domain design: calling
[`mask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_domain.md)
with the **same key** on additional domains reuses all existing
pseudonyms and date offsets.

``` r

ae_masked <- mask_domain(sdtm_ae, key, domain = "AE")
lb_masked <- mask_domain(sdtm_lb, key, domain = "LB")
```

We can verify that the same subject has the same pseudonym in all three
domains:

``` r

orig_subj <- "01-701-1015"
pseudonym <- key$id_map[orig_subj]

cat("Pseudonym assigned:", pseudonym, "\n")
#> Pseudonym assigned: SUBJ-0001
cat("Present in DM:", pseudonym %in% dm_masked$USUBJID, "\n")
#> Present in DM: TRUE
cat("Present in AE:", pseudonym %in% ae_masked$USUBJID, "\n")
#> Present in AE: TRUE
cat("Present in LB:", pseudonym %in% lb_masked$USUBJID, "\n")
#> Present in LB: TRUE
```

Date consistency can be confirmed by checking that the offset is
identical across domains:

``` r

# The date shift for this subject (in days)
offset <- key$date_offsets[orig_subj]
cat("Date offset for", orig_subj, ":", offset, "days\n\n")
#> Date offset for 01-701-1015 : 195 days

# Original vs masked reference start date in DM
cat("DM RFSTDTC original:", sdtm_dm$RFSTDTC[sdtm_dm$USUBJID == orig_subj][1], "\n")
#> DM RFSTDTC original: 2014-01-02
cat("DM RFSTDTC masked:  ", dm_masked$RFSTDTC[dm_masked$USUBJID == pseudonym][1], "\n\n")
#> DM RFSTDTC masked:   2014-07-16

# Original vs masked AE date — shifted by the same offset
ae_orig <- sdtm_ae[sdtm_ae$USUBJID == orig_subj, ]
ae_mask <- ae_masked[ae_masked$USUBJID == pseudonym, ]
cat("AE AESTDTC original:", ae_orig$AESTDTC[1], "\n")
#> AE AESTDTC original: 2014-01-03
cat("AE AESTDTC masked:  ", ae_mask$AESTDTC[1], "\n")
#> AE AESTDTC masked:   2014-07-17
```

## The `mask_cdisc()` convenience wrapper

When you have a named list of domains,
[`mask_cdisc()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_cdisc.md)
handles key creation and loops over all domains in one call.

``` r

masked <- mask_cdisc(list(
  DM = sdtm_dm,
  AE = sdtm_ae,
  LB = sdtm_lb,
  VS = sdtm_vs
))

# The key is attached as an attribute
key2 <- attr(masked, "key")
key2
#> <cdiscmask_key>
#>   612 subject ID mapping(s)
#>   306 date offset(s)
#>   6 free-text column(s) stored
```

``` r

# AE adverse event term is redacted; other columns are preserved
masked$AE[1:3, c("USUBJID", "AETERM", "AESTDTC", "AESTDY", "AESEV", "AESER")]
#>     USUBJID      AETERM    AESTDTC AESTDY AESEV AESER
#> 1 SUBJ-0001 AETERM-0001 2013-03-16   -291  MILD     N
#> 2 SUBJ-0001 AETERM-0002 2013-03-16   -291  MILD     N
#> 3 SUBJ-0001 AETERM-0003 2013-03-22   -285  MILD     N
```

## ADaM datasets

[`mask_cdisc()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_cdisc.md)
works identically for ADaM. `Date`-class columns (e.g. `TRTSDT`) are
detected automatically.

``` r

adam_masked <- mask_cdisc(list(
  ADSL = adam_adsl,
  ADAE = adam_adae
))

adam_masked$ADSL[1:3, c("USUBJID", "TRTSDT", "TRTEDT", "AGE", "SEX", "ARM")]
#>     USUBJID     TRTSDT     TRTEDT AGE SEX      ARM
#> 1 SUBJ-0001 2013-02-27 2013-08-27  63   F ARM-0001
#> 2 SUBJ-0002 2013-07-30 2013-08-26  64   M ARM-0001
#> 3 SUBJ-0003 2013-03-07 2013-09-02  71   M ARM-0002
```

## Reversing anonymization

[`unmask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/unmask_domain.md)
restores the original data exactly. The `cdiscmask_cols` attribute that
[`mask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_domain.md)
attaches to each masked data frame tells
[`unmask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/unmask_domain.md)
which columns to restore and how.

``` r

dm_back <- unmask_domain(masked$DM, attr(masked, "key"))

# Every column is identical to the original
identical(dm_back$USUBJID,  sdtm_dm$USUBJID)
#> [1] TRUE
identical(dm_back$RFSTDTC,  sdtm_dm$RFSTDTC)
#> [1] TRUE
identical(dm_back$AGE,      sdtm_dm$AGE)
#> [1] TRUE
```

``` r

ae_back <- unmask_domain(masked$AE, attr(masked, "key"))

identical(ae_back$AETERM,   sdtm_ae$AETERM)
#> [1] TRUE
identical(ae_back$AESTDTC,  sdtm_ae$AESTDTC)
#> [1] TRUE
identical(ae_back$AESTDY,   sdtm_ae$AESTDY)
#> [1] TRUE
```

## Persisting the key

To share masked datasets with a collaborator and later restore the
originals, save the key separately from the data.

``` r

save_mask_key(key2, "masking_key.rds")

# Later, or in a different session:
key_loaded <- load_mask_key("masking_key.rds")
dm_restored <- unmask_domain(masked$DM, key_loaded)
```

The key must be stored and transmitted securely — it is the only
artefact that links pseudonyms back to real subject identifiers.

## Overriding column detection

If the automatic detection misses a column or picks up one it shouldn’t,
pass a custom `cols` list to
[`mask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_domain.md):

``` r

my_cols <- detect_sensitive_cols(sdtm_ae)
my_cols$free_text <- c(my_cols$free_text, "AEOUT")  # also redact outcome text

ae_custom <- mask_domain(sdtm_ae, key, cols = my_cols)
```

## Summary

The core workflow in three steps:

``` r

# 1. Create (or load) a key
key <- new_mask_key()

# 2. Mask — reuse the same key for every domain
masked <- mask_cdisc(list(DM = sdtm_dm, AE = sdtm_ae, LB = sdtm_lb), key = key)

# 3. Save the key securely so you can unmask later
save_mask_key(key, "masking_key.rds")
```
