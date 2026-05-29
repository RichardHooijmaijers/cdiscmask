# Mask a single CDISC domain data frame

Applies anonymization while preserving column types and recording every
transformation in `key` so that
[`unmask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/unmask_domain.md)
can reverse it. When the same `key` is reused across multiple domains,
subject-ID pseudonyms and date shifts are guaranteed to be consistent.

## Usage

``` r
mask_domain(df, key, domain = NULL, cols = NULL)
```

## Arguments

- df:

  A data frame for one CDISC domain.

- key:

  A `cdiscmask_key` created by
  [`new_mask_key()`](https://richardhooijmaijers.github.io/cdiscmask/reference/new_mask_key.md).

- domain:

  Optional domain name passed to
  [`detect_sensitive_cols()`](https://richardhooijmaijers.github.io/cdiscmask/reference/detect_sensitive_cols.md).

- cols:

  An optional named list overriding automatic detection; same structure
  as the return value of
  [`detect_sensitive_cols()`](https://richardhooijmaijers.github.io/cdiscmask/reference/detect_sensitive_cols.md).

## Value

A data frame with sensitive values replaced. The attribute
`"cdiscmask_cols"` records which columns were masked.

## Details

The masking order is:

1.  Date columns are shifted (keyed by the original subject ID).

2.  Subject-ID columns are replaced with pseudonyms.

3.  Free-text columns are redacted.

The original column classification is stored as the `"cdiscmask_cols"`
attribute on the returned data frame so that
[`unmask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/unmask_domain.md)
knows what to restore.

## Examples

``` r
if (requireNamespace("safetyData", quietly = TRUE)) {
  key       <- new_mask_key()
  dm_masked <- mask_domain(safetyData::sdtm_dm, key, domain = "DM")
  dm_masked[1:3, c("USUBJID", "RFSTDTC", "AGE", "SEX")]
}
#>     USUBJID    RFSTDTC AGE SEX
#> 1 SUBJ-0001 2013-11-13  63   F
#> 2 SUBJ-0002 2011-09-01  64   M
#> 3 SUBJ-0003 2013-01-04  71   M
```
