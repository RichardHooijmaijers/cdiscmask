library(safetyData)

test_that("mask_domain returns same column names and types for non-sensitive cols", {
  key <- new_mask_key()
  out <- mask_domain(sdtm_dm, key, domain = "DM")

  safe_cols <- c("AGE", "SEX", "RACE", "ARM", "COUNTRY", "STUDYID", "DOMAIN")
  for (col in safe_cols) {
    expect_identical(out[[col]], sdtm_dm[[col]], label = paste("column", col))
  }
})

test_that("mask_cdisc applies identical subject-ID pseudonyms across all domains", {
  masked <- mask_cdisc(list(DM = sdtm_dm, AE = sdtm_ae, LB = sdtm_lb))

  dm_ids <- unique(masked$DM$USUBJID)
  ae_ids <- unique(masked$AE$USUBJID)
  lb_ids <- unique(masked$LB$USUBJID)

  # Every AE and LB subject must appear in DM (subset)
  expect_true(all(ae_ids %in% dm_ids))
  expect_true(all(lb_ids %in% dm_ids))

  # Cross-check one subject: same pseudonym in DM, AE, LB
  orig_subj <- sdtm_dm$USUBJID[1]
  key  <- attr(masked, "key")
  pseu <- key$id_map[orig_subj]
  expect_true(pseu %in% masked$DM$USUBJID)
  expect_true(pseu %in% masked$AE$USUBJID)
})

test_that("mask_cdisc attaches the key as an attribute", {
  masked <- mask_cdisc(list(DM = sdtm_dm))
  expect_true(inherits(attr(masked, "key"), "cdiscmask_key"))
})

test_that("unmask_domain recovers original USUBJID exactly", {
  key <- new_mask_key()
  dm_masked <- mask_domain(sdtm_dm, key)
  dm_back   <- unmask_domain(dm_masked, key)
  expect_identical(dm_back$USUBJID, sdtm_dm$USUBJID)
})

test_that("unmask_domain recovers original integer SUBJID exactly", {
  key <- new_mask_key()
  dm_masked <- mask_domain(sdtm_dm, key)
  dm_back   <- unmask_domain(dm_masked, key)
  expect_identical(dm_back$SUBJID, sdtm_dm$SUBJID)
})

test_that("unmask_domain recovers original dates exactly", {
  key <- new_mask_key()
  dm_masked <- mask_domain(sdtm_dm, key)
  dm_back   <- unmask_domain(dm_masked, key)
  expect_identical(dm_back$RFSTDTC, sdtm_dm$RFSTDTC)
  expect_identical(dm_back$RFENDTC, sdtm_dm$RFENDTC)
})

test_that("unmask_domain recovers original free-text exactly", {
  key <- new_mask_key()
  ae_masked <- mask_domain(sdtm_ae, key)
  ae_back   <- unmask_domain(ae_masked, key)
  expect_identical(ae_back$AETERM, sdtm_ae$AETERM)
})

test_that("unmask_domain errors when cdiscmask_cols attribute is absent", {
  key <- new_mask_key()
  expect_error(unmask_domain(sdtm_dm, key), "cdiscmask_cols")
})

test_that("save_mask_key and load_mask_key roundtrip correctly", {
  key <- new_mask_key()
  mask_domain(sdtm_dm, key)

  tmp <- tempfile(fileext = ".rds")
  on.exit(unlink(tmp))

  save_mask_key(key, tmp)
  key2 <- load_mask_key(tmp)

  expect_identical(key$id_map, key2$id_map)
  expect_identical(key$date_offsets, key2$date_offsets)
})
