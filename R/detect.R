#' Detect sensitive columns in a CDISC dataset
#'
#' Identifies columns that should be anonymized based on CDISC variable naming
#' conventions and column classes. Returns separate vectors for each sensitivity
#' category so that callers can apply different masking strategies per type.
#'
#' @param df A data frame representing one CDISC domain.
#' @param domain Optional domain name (e.g. `"DM"`, `"AE"`). Reserved for
#'   future domain-specific rules; currently unused.
#'
#' @return A named list with elements:
#'   - `subject_id`: row-level subject identifiers (`USUBJID`, `SUBJID`)
#'   - `dates`: character DTC/DTM columns and `Date`-class DT columns
#'   - `dy`: integer study-day columns (suffix `DY`)
#'   - `free_text`: verbatim / narrative / categorical columns that need
#'     category-preserving masking: verbatim terms (TERM, TRT, NAM, TEXT,
#'     VERBATIM suffixes), study identifier (STUDYID), and character treatment /
#'     arm assignment columns (ARM*, ACTARM*, character TRT* columns)
#'   - `other`: reserved for future domain-specific flagging
#'
#' @examples
#' df <- data.frame(
#'   USUBJID = "01-001",
#'   RFSTDTC = "2020-01-15",
#'   AGE     = 45L,
#'   stringsAsFactors = FALSE
#' )
#' detect_sensitive_cols(df)
#' @export
detect_sensitive_cols <- function(df, domain = NULL) {
  nms <- names(df)

  id_cols <- intersect(nms, c("USUBJID", "SUBJID"))

  # Character ISO-8601 date columns (SDTM DTC/DTM) and Date-class columns (ADaM)
  dtc_cols  <- nms[grepl("DTC$|DTM$", nms)]
  dt_cols   <- nms[sapply(df[nms], inherits, "Date")]
  date_cols <- setdiff(union(dtc_cols, dt_cols), id_cols)

  # Study-day integer columns
  dy_cols <- setdiff(nms[grepl("DY$", nms)], c(id_cols, date_cols))

  # Verbatim / narrative free text (suffix-based)
  verbatim_cols <- nms[grepl("TERM$|TRT$|NAM$|TEXT$|VERBATIM$", nms, ignore.case = FALSE)]

  # Study identifier
  study_id_cols <- intersect(nms, "STUDYID")

  # Treatment assignment and arm columns — character only
  # Numeric variants (TRT01PN, TRTAN, TRTDUR) and Date variants (TRTSDT, TRTEDT)
  # are already handled by dy_cols/date_cols or are non-sensitive numerics.
  trt_arm_pattern <- grepl("^TRT|^ARM|^ACTARM", nms)
  trt_arm_cols    <- nms[trt_arm_pattern & sapply(df[nms], is.character)]

  free_text_cols <- Reduce(
    union,
    list(verbatim_cols, study_id_cols, trt_arm_cols)
  )
  free_text_cols <- setdiff(free_text_cols, c(id_cols, date_cols, dy_cols))

  list(
    subject_id = id_cols,
    dates      = date_cols,
    dy         = dy_cols,
    free_text  = free_text_cols,
    other      = character(0)
  )
}
