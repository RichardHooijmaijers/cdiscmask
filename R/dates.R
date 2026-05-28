#' Shift date/datetime columns by a per-subject random offset
#'
#' Each subject receives a random integer offset (in days) drawn once and
#' stored in `key`. The same offset is reused across domains, preserving
#' within-subject temporal relationships.
#'
#' Three column types are handled:
#' - **Character DTC/DTM** (SDTM): ISO-8601 strings. Full dates (`YYYY-MM-DD`,
#'   optionally followed by a time component) are shifted; partial dates
#'   (`YYYY-MM`, `YYYY`) and the CDISC `"--"` placeholder are left untouched.
#' - **`Date` objects** (ADaM): shifted by adding the offset.
#' - **Integer/numeric DY** (study days): shifted arithmetically without date
#'   parsing.
#'
#' @param df A data frame.
#' @param cols Character vector of column names to shift.
#' @param subject_col Name of the subject-ID column used to look up or create
#'   per-subject offsets in `key` (default `"USUBJID"`).
#' @param key A `cdiscmask_key` created by [new_mask_key()].
#' @param range Integer vector of length 2 giving the inclusive range (days)
#'   from which offsets are sampled (default `c(-365L, 365L)`).
#'
#' @return `df` with `cols` shifted. `key` is updated in place.
#' @examples
#' key <- new_mask_key()
#' df  <- data.frame(
#'   USUBJID = c("01-001", "01-001", "01-002"),
#'   RFSTDTC = c("2020-01-15", "2020-06-01", "2019-11-20"),
#'   stringsAsFactors = FALSE
#' )
#' shift_dates(df, cols = "RFSTDTC", key = key)
#' @export
shift_dates <- function(df, cols, subject_col = "USUBJID", key,
                        range = c(-365L, 365L)) {
  stopifnot(inherits(key, "cdiscmask_key"), subject_col %in% names(df))

  subjects <- df[[subject_col]]
  unique_subjects <- unique(subjects[!is.na(subjects)])
  new_subjects <- setdiff(unique_subjects, names(key$date_offsets))

  if (length(new_subjects) > 0) {
    new_offsets <- setNames(
      sample(seq(range[1], range[2]), length(new_subjects), replace = TRUE),
      new_subjects
    )
    key$date_offsets <- c(key$date_offsets, new_offsets)
  }

  row_offsets <- key$date_offsets[subjects]

  for (col in intersect(cols, names(df))) {
    vals <- df[[col]]
    if (inherits(vals, "Date")) {
      df[[col]] <- vals + row_offsets
    } else if (is.numeric(vals) || is.integer(vals)) {
      df[[col]] <- vals + row_offsets
    } else if (is.character(vals)) {
      df[[col]] <- .shift_dtc(vals, row_offsets)
    }
  }
  df
}

# Shift a character vector of ISO-8601 date strings by a per-element integer offset.
# Only full-precision dates (YYYY-MM-DD, optionally with time) are shifted.
.shift_dtc <- function(vals, offsets) {
  result <- vals
  is_full <- !is.na(vals) & grepl("^\\d{4}-\\d{2}-\\d{2}", vals)
  if (!any(is_full)) return(result)

  date_strs  <- substr(vals[is_full], 1L, 10L)
  time_parts <- sub("^\\d{4}-\\d{2}-\\d{2}", "", vals[is_full])
  shifted    <- as.Date(date_strs) + offsets[is_full]
  result[is_full] <- paste0(format(shifted, "%Y-%m-%d"), time_parts)
  result
}
