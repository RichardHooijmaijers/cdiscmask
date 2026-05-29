# Replace subject identifiers with pseudonyms

Maps every unique value in `col` to a new opaque identifier and stores
the mapping in `key`. If a subject was already mapped by a previous call
(e.g. from another domain), the existing pseudonym is reused.

## Usage

``` r
mask_subject_id(df, col = "USUBJID", key, prefix = "SUBJ-")
```

## Arguments

- df:

  A data frame.

- col:

  Name of the subject-ID column (e.g. `"USUBJID"`).

- key:

  A `cdiscmask_key` created by
  [`new_mask_key()`](https://richardhooijmaijers.github.io/cdiscmask/reference/new_mask_key.md).

- prefix:

  String prepended to the zero-padded integer pseudonym (default
  `"SUBJ-"`).

## Value

`df` with `col` replaced by pseudonyms. `key` is updated in place.

## Examples

``` r
key <- new_mask_key()
df  <- data.frame(USUBJID = c("01-001", "01-002", "01-001"),
                  stringsAsFactors = FALSE)
mask_subject_id(df, col = "USUBJID", key = key)
#>     USUBJID
#> 1 SUBJ-0001
#> 2 SUBJ-0002
#> 3 SUBJ-0001
```
