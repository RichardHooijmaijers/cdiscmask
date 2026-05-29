# Reverse anonymization for a single domain

Uses the mappings stored in `key` to restore the original values in
columns that were masked by
[`mask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_domain.md)
or
[`mask_cdisc()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_cdisc.md).
The data frame must carry the `"cdiscmask_cols"` attribute set during
masking, and its row order must be unchanged.

## Usage

``` r
unmask_domain(df, key)
```

## Arguments

- df:

  A masked data frame produced by
  [`mask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_domain.md)
  or
  [`mask_cdisc()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_cdisc.md).

- key:

  The `cdiscmask_key` used when masking.

## Value

The original (unmasked) data frame.

## Examples

``` r
if (requireNamespace("safetyData", quietly = TRUE)) {
  key       <- new_mask_key()
  dm_masked <- mask_domain(safetyData::sdtm_dm, key)
  dm_back   <- unmask_domain(dm_masked, key)
  identical(dm_back$USUBJID, safetyData::sdtm_dm$USUBJID)
}
#> [1] TRUE
```
