# cdiscmask: Anonymize CDISC Clinical Trial Data

Anonymizes CDISC-standard datasets (SDTM, ADaM) while preserving data
types and cross-domain consistency. Subject identifiers are replaced
with pseudonyms, dates are shifted by a per-subject random offset
applied uniformly across all domains, and a reversible key is stored so
that original data can be recovered. Sensitive columns are detected
automatically based on CDISC variable naming conventions.

## See also

Useful links:

- <https://richardhooijmaijers.github.io/cdiscmask>

- <https://github.com/RichardHooijmaijers/cdiscmask>

- Report bugs at
  <https://github.com/RichardHooijmaijers/cdiscmask/issues>

## Author

**Maintainer**: Richard Hooijmaijers <richardhooijmaijers@gmail.com>
\[copyright holder\]

Authors:

- Richard Hooijmaijers <richardhooijmaijers@gmail.com> \[copyright
  holder\]
