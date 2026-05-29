# Load a masking key from disk

Load a masking key from disk

## Usage

``` r
load_mask_key(path)
```

## Arguments

- path:

  Path to an `.rds` file previously written by
  [`save_mask_key()`](https://richardhooijmaijers.github.io/cdiscmask/reference/save_mask_key.md).

## Value

A `cdiscmask_key` object.

## Examples

``` r
key <- new_mask_key()
tmp <- tempfile(fileext = ".rds")
save_mask_key(key, tmp)
key2 <- load_mask_key(tmp)
identical(key$id_map, key2$id_map)
#> [1] TRUE
```
