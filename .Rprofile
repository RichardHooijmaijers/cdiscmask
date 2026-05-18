# Add tinytex binaries to PATH so R CMD check can build the PDF manual.
local({
  if (requireNamespace("tinytex", quietly = TRUE)) {
    root <- tinytex::tinytex_root()
    if (nzchar(root)) {
      bin <- file.path(root, "bin", .Platform$r_arch)
      if (!dir.exists(bin)) {
        # fallback for linux where arch dir is named differently
        candidates <- list.files(file.path(root, "bin"), full.names = TRUE)
        bin <- candidates[dir.exists(candidates)][1]
      }
      if (!is.na(bin) && dir.exists(bin)) {
        Sys.setenv(PATH = paste(bin, Sys.getenv("PATH"), sep = .Platform$path.sep))
      }
    }
  }
})
