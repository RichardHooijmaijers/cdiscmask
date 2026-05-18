library(safetyData)

test_that("shift_dates applies the same offset to a subject across two calls", {
  key <- new_mask_key()
  dm_shifted <- shift_dates(sdtm_dm, cols = "RFSTDTC", key = key)
  ae_shifted <- shift_dates(sdtm_ae, cols = "AESTDTC", key = key)

  # Pick subject 01-701-1015 and derive its offset from DM
  subj <- "01-701-1015"
  dm_row   <- sdtm_dm[sdtm_dm$USUBJID == subj, ]
  dm_shift <- dm_shifted[dm_shifted$USUBJID == subj, ]
  offset <- as.integer(as.Date(dm_shift$RFSTDTC[1]) - as.Date(dm_row$RFSTDTC[1]))

  # That same offset must apply in AE
  ae_row   <- sdtm_ae[sdtm_ae$USUBJID == subj, ]
  ae_shift <- ae_shifted[ae_shifted$USUBJID == subj, ]
  ae_orig_dates <- as.Date(ae_row$AESTDTC[!is.na(ae_row$AESTDTC)])
  ae_shift_dates <- as.Date(ae_shift$AESTDTC[!is.na(ae_shift$AESTDTC)])
  expect_equal(as.integer(ae_shift_dates - ae_orig_dates), rep(offset, length(ae_orig_dates)))
})

test_that("shift_dates shifts Date-class ADaM columns correctly", {
  key  <- new_mask_key()
  out  <- shift_dates(adam_adsl, cols = c("TRTSDT", "TRTEDT"), key = key)

  subj   <- adam_adsl$USUBJID[1]
  offset <- unname(key$date_offsets[subj])
  expect_equal(out$TRTSDT[1], adam_adsl$TRTSDT[1] + offset)
  expect_equal(out$TRTEDT[1], adam_adsl$TRTEDT[1] + offset)
})

test_that("shift_dates shifts DY integer columns arithmetically", {
  key <- new_mask_key()
  out <- shift_dates(sdtm_ae, cols = c("AESTDTC", "AESTDY"), key = key)

  subj <- sdtm_ae$USUBJID[1]
  offset <- unname(key$date_offsets[subj])
  expect_equal(out$AESTDY[1], sdtm_ae$AESTDY[1] + offset)
})

test_that("shift_dates preserves time component in datetime DTC strings", {
  key <- new_mask_key()
  out <- shift_dates(sdtm_lb, cols = "LBDTC", key = key)

  # Time part after 'T' must be unchanged
  orig_times <- sub("^\\d{4}-\\d{2}-\\d{2}", "", sdtm_lb$LBDTC)
  out_times  <- sub("^\\d{4}-\\d{2}-\\d{2}", "", out$LBDTC)
  expect_equal(orig_times, out_times)
})

test_that("shift_dates leaves NA values as NA", {
  key <- new_mask_key()
  out <- shift_dates(sdtm_ae, cols = "AEENDTC", key = key)
  expect_equal(is.na(out$AEENDTC), is.na(sdtm_ae$AEENDTC))
})
