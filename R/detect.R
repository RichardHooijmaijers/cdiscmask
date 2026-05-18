#' Detect sensitive columns in a CDISC dataset
#'
#' Identifies columns that should be anonymized based on CDISC variable naming
#' conventions. Returns separate vectors for each sensitivity category so that
#' callers can apply different masking strategies per type.
#'
#' @param df A data frame representing one CDISC domain.
#' @param domain Optional domain name (e.g. `"DM"`, `"AE"`). Reserved for
#'   future domain-specific rules; currently unused.
#'
#' @return A named list with elements:
#'   - `subject_id`: columns that hold subject identifiers (`USUBJID`, `SUBJID`)
#'   - `dates`: character DTC/DTM columns and `Date`-class DT columns
#'   - `dy`: integer study-day columns (suffix `DY`)
#'   - `free_text`: verbatim / narrative columns (suffix `TERM`, `TRT`, `NAM`,
#'     `TEXT`, or `VERBATIM`)
#'   - `other`: reserved for future domain-specific flagging
#'
#' @export
detect_sensitive_cols <- function(df, domain = NULL) {
  nms <- names(df)

  id_cols <- intersect(nms, c("USUBJID", "SUBJID"))

  # Character ISO-8601 date columns (SDTM DTC/DTM) and Date-class columns (ADaM DT)
  dtc_cols <- nms[grepl("DTC$|DTM$", nms)]
  dt_cols  <- nms[sapply(df[nms], inherits, "Date")]
  date_cols <- union(dtc_cols, dt_cols)
  date_cols <- setdiff(date_cols, id_cols)

  # Study-day integer columns
  dy_cols <- setdiff(nms[grepl("DY$", nms)], c(id_cols, date_cols))

  # Verbatim / narrative free text
  free_text_cols <- setdiff(
    nms[grepl("TERM$|TRT$|NAM$|TEXT$|VERBATIM$", nms, ignore.case = FALSE)],
    c(id_cols, date_cols, dy_cols)
  )

  list(
    subject_id = id_cols,
    dates      = date_cols,
    dy         = dy_cols,
    free_text  = free_text_cols,
    other      = character(0)
  )
}
