library(safetyData)

test_that("mask_domain returns same column names and types for non-sensitive cols", {
  key <- new_mask_key()
  out <- mask_domain(sdtm_dm, key, domain = "DM")

  safe_cols <- c("AGE", "SEX", "RACE", "COUNTRY", "DOMAIN")
  for (col in safe_cols) {
    expect_identical(out[[col]], sdtm_dm[[col]], label = paste("column", col))
  }
})

test_that("mask_domain masks STUDYID with category-preserving label", {
  key <- new_mask_key()
  out <- mask_domain(sdtm_dm, key, domain = "DM")

  expect_false(any(out$STUDYID %in% sdtm_dm$STUDYID))
  expect_true(all(grepl("^STUDYID-", out$STUDYID)))
  # All rows have the same label (single study)
  expect_equal(length(unique(out$STUDYID)), 1L)
})

test_that("mask_domain masks ARM columns", {
  key <- new_mask_key()
  out <- mask_domain(sdtm_dm, key, domain = "DM")

  expect_false(any(out$ARM %in% sdtm_dm$ARM))
  expect_true(all(grepl("^ARM-", out$ARM)))
  # Number of unique ARM labels equals number of unique original arms
  expect_equal(length(unique(out$ARM)), length(unique(sdtm_dm$ARM)))
})

test_that("mask_domain masks character TRT columns in ADaM", {
  key <- new_mask_key()
  out <- mask_domain(adam_adsl, key)

  expect_false(any(out$TRT01P %in% adam_adsl$TRT01P))
  expect_true(all(grepl("^TRT01P-", out$TRT01P)))
  expect_equal(length(unique(out$TRT01P)), length(unique(adam_adsl$TRT01P)))
})

test_that("mask_domain leaves numeric TRT columns unchanged", {
  key <- new_mask_key()
  out <- mask_domain(adam_adsl, key)
  expect_identical(out$TRT01PN, adam_adsl$TRT01PN)
  expect_identical(out$TRTAN,   adam_adsl$TRTAN)
})

test_that("mask_cdisc applies identical subject-ID pseudonyms across all domains", {
  masked <- mask_cdisc(list(DM = sdtm_dm, AE = sdtm_ae, LB = sdtm_lb))

  dm_ids <- unique(masked$DM$USUBJID)
  ae_ids <- unique(masked$AE$USUBJID)
  lb_ids <- unique(masked$LB$USUBJID)

  expect_true(all(ae_ids %in% dm_ids))
  expect_true(all(lb_ids %in% dm_ids))

  orig_subj <- sdtm_dm$USUBJID[1]
  key  <- attr(masked, "key")
  pseu <- key$id_map[orig_subj]
  expect_true(pseu %in% masked$DM$USUBJID)
  expect_true(pseu %in% masked$AE$USUBJID)
})

test_that("mask_cdisc reuses STUDYID label across domains", {
  masked <- mask_cdisc(list(DM = sdtm_dm, AE = sdtm_ae))
  expect_equal(unique(masked$DM$STUDYID), unique(masked$AE$STUDYID))
})

test_that("mask_cdisc attaches the key as an attribute", {
  masked <- mask_cdisc(list(DM = sdtm_dm))
  expect_true(inherits(attr(masked, "key"), "cdiscmask_key"))
})

test_that("mask_free_text produces unique label per unique original value", {
  key <- new_mask_key()
  ae  <- mask_domain(sdtm_ae, key, domain = "AE")

  n_orig   <- length(unique(sdtm_ae$AETERM))
  n_masked <- length(unique(ae$AETERM))
  expect_equal(n_orig, n_masked)
})

test_that("mask_free_text reuses labels for the same term across two masked datasets", {
  key  <- new_mask_key()
  ae1  <- mask_domain(sdtm_ae[1:100, ], key)
  ae2  <- mask_domain(sdtm_ae[101:200, ], key)

  # Any term present in both slices should have the same label
  shared_terms <- intersect(sdtm_ae$AETERM[1:100], sdtm_ae$AETERM[101:200])
  for (term in head(shared_terms, 5)) {
    label1 <- unique(ae1$AETERM[sdtm_ae$AETERM[1:100]   == term])
    label2 <- unique(ae2$AETERM[sdtm_ae$AETERM[101:200] == term])
    expect_equal(label1, label2)
  }
})

test_that("unmask_domain recovers original USUBJID exactly", {
  key <- new_mask_key()
  out <- unmask_domain(mask_domain(sdtm_dm, key), key)
  expect_identical(out$USUBJID, sdtm_dm$USUBJID)
})

test_that("unmask_domain recovers original integer SUBJID exactly", {
  key <- new_mask_key()
  out <- unmask_domain(mask_domain(sdtm_dm, key), key)
  expect_identical(out$SUBJID, sdtm_dm$SUBJID)
})

test_that("unmask_domain recovers original dates exactly", {
  key <- new_mask_key()
  out <- unmask_domain(mask_domain(sdtm_dm, key), key)
  expect_identical(out$RFSTDTC, sdtm_dm$RFSTDTC)
  expect_identical(out$RFENDTC, sdtm_dm$RFENDTC)
})

test_that("unmask_domain recovers original AETERM exactly", {
  key <- new_mask_key()
  out <- unmask_domain(mask_domain(sdtm_ae, key), key)
  expect_identical(out$AETERM, sdtm_ae$AETERM)
})

test_that("unmask_domain recovers original ARM exactly", {
  key <- new_mask_key()
  out <- unmask_domain(mask_domain(sdtm_dm, key), key)
  expect_identical(out$ARM, sdtm_dm$ARM)
})

test_that("unmask_domain recovers original STUDYID exactly", {
  key <- new_mask_key()
  out <- unmask_domain(mask_domain(sdtm_dm, key), key)
  expect_identical(out$STUDYID, sdtm_dm$STUDYID)
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

  expect_identical(key$id_map,       key2$id_map)
  expect_identical(key$date_offsets, key2$date_offsets)
  expect_identical(key$free_text,    key2$free_text)
})
