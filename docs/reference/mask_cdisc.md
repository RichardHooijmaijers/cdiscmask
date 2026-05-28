# Mask multiple CDISC domains consistently

Convenience wrapper that calls
[`mask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_domain.md)
on each element of `domains` using a shared `key`, guaranteeing
cross-domain consistency of subject-ID pseudonyms and date shifts.

## Usage

``` r
mask_cdisc(domains, key = NULL)
```

## Arguments

- domains:

  A named list of data frames, one per CDISC domain (e.g.
  `list(DM = dm_df, AE = ae_df, LB = lb_df)`).

- key:

  A `cdiscmask_key`. If `NULL` a new key is created automatically.

## Value

A list with the same names as `domains`, each element being the masked
data frame. The key used is attached as attribute `"key"`.
