# cdiscmask: Anonymize CDISC Clinical Trial Data

Anonymizes CDISC-standard datasets (SDTM, ADaM) while preserving data
types and cross-domain consistency. Subject identifiers are replaced
with pseudonyms, dates are shifted by a per-subject random offset
applied uniformly across all domains, and a reversible key is stored so
that original data can be recovered. Sensitive columns are detected
automatically based on CDISC variable naming conventions.

## Author

**Maintainer**: First Last <first.last@example.com>

Authors:

- First Last <first.last@example.com>
