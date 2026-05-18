#' Mask free-text / verbatim columns
#'
#' Replaces narrative or verbatim fields with a generic placeholder and stores
#' the original values in `key` so they can be restored by [unmask_domain()].
#' Free text cannot be shifted or pseudonymized reliably because it often
#' contains names, locations, and other PII.
#'
#' @param df A data frame.
#' @param cols Character vector of free-text column names.
#' @param key A `cdiscmask_key` created by [new_mask_key()].
#' @param placeholder Replacement string (default `"[REDACTED]"`).
#'
#' @return `df` with `cols` replaced by `placeholder`. `key` is updated in
#'   place with the original column vectors (keyed by column name).
#' @export
mask_free_text <- function(df, cols, key, placeholder = "[REDACTED]") {
  stopifnot(inherits(key, "cdiscmask_key"))

  for (col in intersect(cols, names(df))) {
    key$free_text[[col]] <- df[[col]]
    df[[col]] <- placeholder
  }
  df
}
