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
  non_sensitive <- c("AGE", "SEX", "RACE", "COUNTRY")
  all_sensitive <- unlist(cols[c("subject_id", "dates", "dy", "free_text")])
  expect_true(all(!non_sensitive %in% all_sensitive))
})

test_that("detect_sensitive_cols flags AETERM as free text in AE", {
  cols <- detect_sensitive_cols(sdtm_ae)
  expect_true("AETERM" %in% cols$free_text)
})

test_that("detect_sensitive_cols flags STUDYID as free text", {
  cols <- detect_sensitive_cols(sdtm_dm)
  expect_true("STUDYID" %in% cols$free_text)
})

test_that("detect_sensitive_cols flags ARM and ARMCD as free text in DM", {
  cols <- detect_sensitive_cols(sdtm_dm)
  expect_true("ARM"     %in% cols$free_text)
  expect_true("ARMCD"   %in% cols$free_text)
  expect_true("ACTARM"  %in% cols$free_text)
  expect_true("ACTARMCD" %in% cols$free_text)
})

test_that("detect_sensitive_cols flags character TRT columns but not numeric ones", {
  cols <- detect_sensitive_cols(adam_adsl)
  # Character treatment cols should be masked (adam_adsl has TRT01P and TRT01A)
  expect_true("TRT01P"  %in% cols$free_text)
  expect_true("TRT01A"  %in% cols$free_text)
  # Numeric treatment code columns must NOT be masked
  expect_false("TRT01PN" %in% cols$free_text)
  expect_false("TRT01AN" %in% cols$free_text)
  expect_false("TRTDUR"  %in% cols$free_text)
  # Date treatment cols are already in dates, not free_text
  expect_false("TRTSDT" %in% cols$free_text)
})
