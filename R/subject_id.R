#' Replace subject identifiers with pseudonyms
#'
#' Maps every unique value in `col` to a new opaque identifier and stores the
#' mapping in `key`. If a subject was already mapped by a previous call (e.g.
#' from another domain), the existing pseudonym is reused.
#'
#' @param df A data frame.
#' @param col Name of the subject-ID column (e.g. `"USUBJID"`).
#' @param key A `cdiscmask_key` created by [new_mask_key()].
#' @param prefix String prepended to the zero-padded integer pseudonym
#'   (default `"SUBJ-"`).
#'
#' @return `df` with `col` replaced by pseudonyms. `key` is updated in place.
#' @examples
#' key <- new_mask_key()
#' df  <- data.frame(USUBJID = c("01-001", "01-002", "01-001"),
#'                   stringsAsFactors = FALSE)
#' mask_subject_id(df, col = "USUBJID", key = key)
#' @export
mask_subject_id <- function(df, col = "USUBJID", key, prefix = "SUBJ-") {
  stopifnot(inherits(key, "cdiscmask_key"), col %in% names(df))

  orig <- as.character(df[[col]])
  unique_orig <- unique(orig[!is.na(orig)])
  new_ids <- setdiff(unique_orig, names(key$id_map))

  if (length(new_ids) > 0) {
    start <- length(key$id_map) + 1L
    pseudonyms <- paste0(prefix, sprintf("%04d", seq(start, start + length(new_ids) - 1L)))
    new_map <- setNames(pseudonyms, new_ids)
    key$id_map <- c(key$id_map, new_map)
  }

  df[[col]] <- key$id_map[orig]
  df
}
