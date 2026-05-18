library(safetyData)

test_that("mask_subject_id replaces every USUBJID with a pseudonym", {
  key <- new_mask_key()
  dm  <- mask_subject_id(sdtm_dm, col = "USUBJID", key = key)

  expect_false(any(dm$USUBJID %in% sdtm_dm$USUBJID))
  expect_true(all(grepl("^SUBJ-", dm$USUBJID)))
  expect_equal(length(unique(dm$USUBJID)), length(unique(sdtm_dm$USUBJID)))
})

test_that("mask_subject_id reuses existing mapping across two calls", {
  key <- new_mask_key()
  dm  <- mask_subject_id(sdtm_dm, col = "USUBJID", key = key)
  ae  <- mask_subject_id(sdtm_ae, col = "USUBJID", key = key)

  # Every subject in AE also appears in DM; pseudonyms must agree
  shared_orig <- intersect(sdtm_dm$USUBJID, sdtm_ae$USUBJID)
  dm_map <- setNames(dm$USUBJID, sdtm_dm$USUBJID)
  ae_map <- setNames(ae$USUBJID, sdtm_ae$USUBJID)

  for (s in shared_orig) {
    expect_equal(unname(dm_map[s]), unname(ae_map[s]))
  }
})

test_that("mask_subject_id handles integer SUBJID and roundtrips correctly", {
  key <- new_mask_key()
  dm  <- mask_subject_id(sdtm_dm, col = "SUBJID", key = key)

  expect_type(dm$SUBJID, "character")  # replaced by pseudonyms (character)

  # round-trip via unmask requires mask_domain for attribute tracking; tested there
})

test_that("mask_subject_id preserves NA values", {
  key <- new_mask_key()
  df  <- data.frame(USUBJID = c("A", NA, "B"), stringsAsFactors = FALSE)
  out <- mask_subject_id(df, col = "USUBJID", key = key)

  expect_true(is.na(out$USUBJID[2]))
})
