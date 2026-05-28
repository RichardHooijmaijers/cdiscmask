#' Create an empty masking key
#'
#' A masking key stores all per-subject mappings produced during masking so
#' that anonymization can be reversed. Pass the **same** key object when
#' masking multiple domains to ensure cross-domain consistency of subject-ID
#' substitutions and date shifts.
#'
#' @return An object of class `cdiscmask_key`.
#' @examples
#' key <- new_mask_key()
#' key
#' @export
new_mask_key <- function() {
  key <- new.env(parent = emptyenv())
  # named character: names = original IDs, values = pseudonyms
  key$id_map        <- character(0)
  # named integer:   names = original IDs, values = day offsets to add
  key$date_offsets  <- integer(0)
  # list per masked free-text column: original value vector (same order as masked df)
  key$free_text     <- list()
  class(key) <- "cdiscmask_key"
  key
}

#' @export
print.cdiscmask_key <- function(x, ...) {
  cat("<cdiscmask_key>\n")
  cat(" ", length(x$id_map), "subject ID mapping(s)\n")
  cat(" ", length(x$date_offsets), "date offset(s)\n")
  cat(" ", length(x$free_text), "free-text column(s) stored\n")
  invisible(x)
}

#' Save a masking key to disk
#'
#' @param key A `cdiscmask_key` object.
#' @param path File path for the `.rds` file.
#' @examples
#' key <- new_mask_key()
#' tmp <- tempfile(fileext = ".rds")
#' save_mask_key(key, tmp)
#' @export
save_mask_key <- function(key, path) {
  stopifnot(inherits(key, "cdiscmask_key"))
  snapshot <- list(
    id_map       = key$id_map,
    date_offsets = key$date_offsets,
    free_text    = key$free_text
  )
  saveRDS(snapshot, path)
  invisible(path)
}

#' Load a masking key from disk
#'
#' @param path Path to an `.rds` file previously written by [save_mask_key()].
#' @return A `cdiscmask_key` object.
#' @examples
#' key <- new_mask_key()
#' tmp <- tempfile(fileext = ".rds")
#' save_mask_key(key, tmp)
#' key2 <- load_mask_key(tmp)
#' identical(key$id_map, key2$id_map)
#' @export
load_mask_key <- function(path) {
  snapshot <- readRDS(path)
  key <- new_mask_key()
  key$id_map       <- snapshot$id_map
  key$date_offsets <- snapshot$date_offsets
  key$free_text    <- snapshot$free_text
  key
}
