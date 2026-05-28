# Detect sensitive columns in a CDISC dataset

Identifies columns that should be anonymized based on CDISC variable
naming conventions and column classes. Returns separate vectors for each
sensitivity category so that callers can apply different masking
strategies per type.

## Usage

``` r
detect_sensitive_cols(df, domain = NULL)
```

## Arguments

- df:

  A data frame representing one CDISC domain.

- domain:

  Optional domain name (e.g. `"DM"`, `"AE"`). Reserved for future
  domain-specific rules; currently unused.

## Value

A named list with elements:

- `subject_id`: row-level subject identifiers (`USUBJID`, `SUBJID`)

- `dates`: character DTC/DTM columns and `Date`-class DT columns

- `dy`: integer study-day columns (suffix `DY`)

- `free_text`: verbatim / narrative / categorical columns that need
  category-preserving masking: verbatim terms (TERM, TRT, NAM, TEXT,
  VERBATIM suffixes), study identifier (STUDYID), and character
  treatment / arm assignment columns (ARM\*, ACTARM\*, character TRT\*
  columns)

- `other`: reserved for future domain-specific flagging
