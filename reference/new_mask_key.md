# Create an empty masking key

A masking key stores all per-subject mappings produced during masking so
that anonymization can be reversed. Pass the **same** key object when
masking multiple domains to ensure cross-domain consistency of
subject-ID substitutions and date shifts.

## Usage

``` r
new_mask_key()
```

## Value

An object of class `cdiscmask_key`.

## Examples

``` r
key <- new_mask_key()
key
#> <cdiscmask_key>
#>   0 subject ID mapping(s)
#>   0 date offset(s)
#>   0 free-text column(s) stored
```
