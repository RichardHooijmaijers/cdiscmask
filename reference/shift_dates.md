# Shift date/datetime columns by a per-subject random offset

Each subject receives a random integer offset (in days) drawn once and
stored in `key`. The same offset is reused across domains, preserving
within-subject temporal relationships.

## Usage

``` r
shift_dates(df, cols, subject_col = "USUBJID", key, range = c(-365L, 365L))
```

## Arguments

- df:

  A data frame.

- cols:

  Character vector of column names to shift.

- subject_col:

  Name of the subject-ID column used to look up or create per-subject
  offsets in `key` (default `"USUBJID"`).

- key:

  A `cdiscmask_key` created by
  [`new_mask_key()`](https://richardhooijmaijers.github.io/cdiscmask/reference/new_mask_key.md).

- range:

  Integer vector of length 2 giving the inclusive range (days) from
  which offsets are sampled (default `c(-365L, 365L)`).

## Value

`df` with `cols` shifted. `key` is updated in place.

## Details

Three column types are handled:

- **Character DTC/DTM** (SDTM): ISO-8601 strings. Full dates
  (`YYYY-MM-DD`, optionally followed by a time component) are shifted;
  partial dates (`YYYY-MM`, `YYYY`) and the CDISC `"--"` placeholder are
  left untouched.

- **`Date` objects** (ADaM): shifted by adding the offset.

- **Integer/numeric DY** (study days): shifted arithmetically without
  date parsing.

## Examples

``` r
key <- new_mask_key()
df  <- data.frame(
  USUBJID = c("01-001", "01-001", "01-002"),
  RFSTDTC = c("2020-01-15", "2020-06-01", "2019-11-20"),
  stringsAsFactors = FALSE
)
shift_dates(df, cols = "RFSTDTC", key = key)
#>   USUBJID    RFSTDTC
#> 1  01-001 2019-08-14
#> 2  01-001 2019-12-30
#> 3  01-002 2019-07-19
```
