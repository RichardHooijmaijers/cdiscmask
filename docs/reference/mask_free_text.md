# Mask free-text / verbatim / categorical columns

Replaces each unique value with an opaque label that preserves category
structure (e.g. all rows with `"DIARRHOEA"` get the same label, so
counts and within-subject comparisons remain valid). Labels are formed
as `<prefix>-XXXX` where `prefix` defaults to the column name.

## Usage

``` r
mask_free_text(df, cols, key, prefix = NULL)
```

## Arguments

- df:

  A data frame.

- cols:

  Character vector of column names to mask.

- key:

  A `cdiscmask_key` created by
  [`new_mask_key()`](https://richardhooijmaijers.github.io/cdiscmask/reference/new_mask_key.md).

- prefix:

  Named character vector mapping column names to label prefixes, or a
  single string used for every column. Defaults to the column name,
  giving labels like `AETERM-0001`, `ARM-0001`, `STUDYID-0001`.

## Value

`df` with `cols` replaced by opaque labels. `key` is updated in place
with the original-to-label mapping for each column.

## Details

If a column is masked again in a later call (e.g. a second domain
containing the same column), existing mappings are reused so that the
same original value always receives the same label.

The mapping (original → label) is stored in `key$free_text[[col]]` so
that
[`unmask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/unmask_domain.md)
can reverse it.
