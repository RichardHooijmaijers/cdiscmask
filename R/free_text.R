#' Mask free-text / verbatim / categorical columns
#'
#' Replaces each unique value with an opaque label that preserves category
#' structure (e.g. all rows with `"DIARRHOEA"` get the same label, so counts
#' and within-subject comparisons remain valid). Labels are formed as
#' `<prefix>-XXXX` where `prefix` defaults to the column name.
#'
#' If a column is masked again in a later call (e.g. a second domain containing
#' the same column), existing mappings are reused so that the same original
#' value always receives the same label.
#'
#' The mapping (original → label) is stored in `key$free_text[[col]]` so that
#' [unmask_domain()] can reverse it.
#'
#' @param df A data frame.
#' @param cols Character vector of column names to mask.
#' @param key A `cdiscmask_key` created by [new_mask_key()].
#' @param prefix Named character vector mapping column names to label prefixes,
#'   or a single string used for every column. Defaults to the column name,
#'   giving labels like `AETERM-0001`, `ARM-0001`, `STUDYID-0001`.
#'
#' @return `df` with `cols` replaced by opaque labels. `key` is updated in
#'   place with the original-to-label mapping for each column.
#' @export
mask_free_text <- function(df, cols, key, prefix = NULL) {
  stopifnot(inherits(key, "cdiscmask_key"))

  for (col in intersect(cols, names(df))) {
    col_prefix <- if (is.null(prefix)) {
      col
    } else if (length(prefix) > 1L) {
      prefix[[col]]
    } else {
      prefix
    }

    orig         <- as.character(df[[col]])
    existing_map <- key$free_text[[col]]
    unique_vals  <- unique(orig[!is.na(orig)])
    new_vals     <- setdiff(unique_vals, names(existing_map))

    if (length(new_vals) > 0L) {
      start  <- length(existing_map) + 1L
      labels <- paste0(col_prefix, "-", sprintf("%04d", seq(start, start + length(new_vals) - 1L)))
      key$free_text[[col]] <- c(existing_map, setNames(labels, new_vals))
    }

    col_map         <- key$free_text[[col]]
    result          <- col_map[orig]
    result[is.na(orig)] <- NA
    df[[col]]       <- unname(result)
  }
  df
}
