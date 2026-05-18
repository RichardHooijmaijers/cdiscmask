#' Mask a single CDISC domain data frame
#'
#' Applies anonymization while preserving column types and recording every
#' transformation in `key` so that [unmask_domain()] can reverse it. When the
#' same `key` is reused across multiple domains, subject-ID pseudonyms and date
#' shifts are guaranteed to be consistent.
#'
#' The masking order is:
#' 1. Date columns are shifted (keyed by the original subject ID).
#' 2. Subject-ID columns are replaced with pseudonyms.
#' 3. Free-text columns are redacted.
#'
#' The original column classification is stored as the `"cdiscmask_cols"`
#' attribute on the returned data frame so that [unmask_domain()] knows what to
#' restore.
#'
#' @param df A data frame for one CDISC domain.
#' @param key A `cdiscmask_key` created by [new_mask_key()].
#' @param domain Optional domain name passed to [detect_sensitive_cols()].
#' @param cols An optional named list overriding automatic detection; same
#'   structure as the return value of [detect_sensitive_cols()].
#'
#' @return A data frame with sensitive values replaced. The attribute
#'   `"cdiscmask_cols"` records which columns were masked.
#' @export
mask_domain <- function(df, key, domain = NULL, cols = NULL) {
  stopifnot(inherits(key, "cdiscmask_key"), is.data.frame(df))

  if (is.null(cols)) cols <- detect_sensitive_cols(df, domain)

  # Capture original column classes before any replacement
  cols$orig_classes <- setNames(
    lapply(cols$subject_id, function(col) class(df[[col]])),
    cols$subject_id
  )

  subject_col <- if (length(cols$subject_id) > 0L) cols$subject_id[1L] else NULL

  # 1. Shift dates while subject IDs are still original
  all_date_cols <- c(cols$dates, cols$dy)
  present_date_cols <- intersect(all_date_cols, names(df))
  if (length(present_date_cols) > 0L && !is.null(subject_col)) {
    df <- shift_dates(df, present_date_cols, subject_col = subject_col, key = key)
  }

  # 2. Replace subject IDs
  for (id_col in cols$subject_id) {
    df <- mask_subject_id(df, col = id_col, key = key)
  }

  # 3. Redact free text
  present_ft_cols <- intersect(cols$free_text, names(df))
  if (length(present_ft_cols) > 0L) {
    df <- mask_free_text(df, present_ft_cols, key = key)
  }

  attr(df, "cdiscmask_cols") <- cols
  df
}

#' Mask multiple CDISC domains consistently
#'
#' Convenience wrapper that calls [mask_domain()] on each element of `domains`
#' using a shared `key`, guaranteeing cross-domain consistency of subject-ID
#' pseudonyms and date shifts.
#'
#' @param domains A named list of data frames, one per CDISC domain
#'   (e.g. `list(DM = dm_df, AE = ae_df, LB = lb_df)`).
#' @param key A `cdiscmask_key`. If `NULL` a new key is created automatically.
#'
#' @return A list with the same names as `domains`, each element being the
#'   masked data frame. The key used is attached as attribute `"key"`.
#' @export
mask_cdisc <- function(domains, key = NULL) {
  stopifnot(is.list(domains), !is.null(names(domains)))

  if (is.null(key)) key <- new_mask_key()

  masked <- mapply(
    function(df, nm) mask_domain(df, key = key, domain = nm),
    domains, names(domains),
    SIMPLIFY = FALSE
  )

  attr(masked, "key") <- key
  masked
}

#' Reverse anonymization for a single domain
#'
#' Uses the mappings stored in `key` to restore the original values in columns
#' that were masked by [mask_domain()] or [mask_cdisc()]. The data frame must
#' carry the `"cdiscmask_cols"` attribute set during masking, and its row order
#' must be unchanged.
#'
#' @param df A masked data frame produced by [mask_domain()] or [mask_cdisc()].
#' @param key The `cdiscmask_key` used when masking.
#'
#' @return The original (unmasked) data frame.
#' @export
unmask_domain <- function(df, key) {
  stopifnot(inherits(key, "cdiscmask_key"), is.data.frame(df))

  cols <- attr(df, "cdiscmask_cols")
  if (is.null(cols)) stop("df has no 'cdiscmask_cols' attribute; was it masked with mask_domain()?")

  inv_map <- setNames(names(key$id_map), key$id_map)  # pseudonym → original

  # 1. Restore free text (stored in original column order)
  for (col in intersect(cols$free_text, names(df))) {
    if (!is.null(key$free_text[[col]])) df[[col]] <- key$free_text[[col]]
  }

  # 2. Restore subject IDs (needed to look up date offsets)
  for (id_col in cols$subject_id) {
    restored <- unname(inv_map[df[[id_col]]])
    orig_class <- cols$orig_classes[[id_col]]
    df[[id_col]] <- if (!is.null(orig_class) && orig_class != "character") {
      methods::as(restored, orig_class)
    } else {
      restored
    }
  }

  # 3. Un-shift dates using the now-restored original subject IDs
  subject_col <- if (length(cols$subject_id) > 0L) cols$subject_id[1L] else NULL
  all_date_cols <- c(cols$dates, cols$dy)
  present_date_cols <- intersect(all_date_cols, names(df))

  if (length(present_date_cols) > 0L && !is.null(subject_col)) {
    neg_offsets <- -key$date_offsets  # subtract the same offset that was added
    row_neg_offsets <- neg_offsets[df[[subject_col]]]

    for (col in present_date_cols) {
      vals <- df[[col]]
      if (inherits(vals, "Date")) {
        df[[col]] <- vals + row_neg_offsets
      } else if (is.numeric(vals) || is.integer(vals)) {
        df[[col]] <- vals + row_neg_offsets
      } else if (is.character(vals)) {
        df[[col]] <- .shift_dtc(vals, row_neg_offsets)
      }
    }
  }

  attr(df, "cdiscmask_cols") <- NULL
  df
}
