library(safetyData)

test_that("detect_sensitive_cols identifies subject ID columns", {
  cols <- detect_sensitive_cols(sdtm_dm)
  expect_setequal(cols$subject_id, c("USUBJID", "SUBJID"))
})

test_that("detect_sensitive_cols flags DTC columns as dates", {
  cols <- detect_sensitive_cols(sdtm_dm)
  expect_true("RFSTDTC" %in% cols$dates)
  expect_true("RFENDTC" %in% cols$dates)
  expect_true("DTHDTC"  %in% cols$dates)
})

test_that("detect_sensitive_cols flags Date-class columns (ADaM) as dates", {
  cols <- detect_sensitive_cols(adam_adsl)
  expect_true("TRTSDT" %in% cols$dates)
  expect_true("TRTEDT" %in% cols$dates)
})

test_that("detect_sensitive_cols flags DY columns separately", {
  cols <- detect_sensitive_cols(sdtm_dm)
  expect_true("DMDY" %in% cols$dy)
  expect_false("DMDY" %in% cols$dates)
})

test_that("detect_sensitive_cols does not flag non-sensitive columns", {
  cols <- detect_sensitive_cols(sdtm_dm)
  non_sensitive <- c("AGE", "SEX", "RACE", "ARM", "COUNTRY")
  expect_true(all(!non_sensitive %in% unlist(cols[c("subject_id", "dates", "dy", "free_text")])))
})

test_that("detect_sensitive_cols flags AETERM as free text in AE", {
  cols <- detect_sensitive_cols(sdtm_ae)
  expect_true("AETERM" %in% cols$free_text)
})
