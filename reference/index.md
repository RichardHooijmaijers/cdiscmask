# Package index

## Subject identifiers

Mask or pseudonymise USUBJID and other subject-level keys. Mappings can
be persisted for reproducible re-runs.

- [`mask_subject_id()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_subject_id.md)
  : Replace subject identifiers with pseudonyms

## Date shifting

Apply per-subject date offsets so intervals are preserved while absolute
dates are scrambled.

- [`shift_dates()`](https://richardhooijmaijers.github.io/cdiscmask/reference/shift_dates.md)
  : Shift date/datetime columns by a per-subject random offset

## Free-text redaction

Scrub comments, AE verbatim terms, and other free-text fields.

- [`mask_free_text()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_free_text.md)
  : Mask free-text / verbatim / categorical columns

## Pipeline helpers

Convenience wrappers for masking a whole study at once.

- [`mask_cdisc()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_cdisc.md)
  : Mask multiple CDISC domains consistently
- [`mask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/mask_domain.md)
  : Mask a single CDISC domain data frame
- [`unmask_domain()`](https://richardhooijmaijers.github.io/cdiscmask/reference/unmask_domain.md)
  : Reverse anonymization for a single domain
- [`detect_sensitive_cols()`](https://richardhooijmaijers.github.io/cdiscmask/reference/detect_sensitive_cols.md)
  : Detect sensitive columns in a CDISC dataset
- [`new_mask_key()`](https://richardhooijmaijers.github.io/cdiscmask/reference/new_mask_key.md)
  : Create an empty masking key
- [`save_mask_key()`](https://richardhooijmaijers.github.io/cdiscmask/reference/save_mask_key.md)
  : Save a masking key to disk
- [`load_mask_key()`](https://richardhooijmaijers.github.io/cdiscmask/reference/load_mask_key.md)
  : Load a masking key from disk
