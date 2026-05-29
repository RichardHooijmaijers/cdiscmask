# Save a masking key to disk

Save a masking key to disk

## Usage

``` r
save_mask_key(key, path)
```

## Arguments

- key:

  A `cdiscmask_key` object.

- path:

  File path for the `.rds` file.

## Examples

``` r
key <- new_mask_key()
tmp <- tempfile(fileext = ".rds")
save_mask_key(key, tmp)
```
