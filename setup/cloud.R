install.packages(
  c(
    "fs",
    "remotes",
    "rmarkdown",
    "rprojroot",
    "rstudioapi",
    "targets",
    "tidyverse"
  )
)
remotes::install_github("stan-dev/cmdstanr")
root <- rprojroot::find_rstudio_root_file()
cmdstan <- file.path(root, "cmdstan")
fs::dir_create(cmdstan)
cmdstanr::install_cmdstan(cmdstan)
cmdstan <- list.files(cmdstan, full.names = TRUE)
writeLines(paste0("CMDSTAN=", cmdstan), file.path(root, ".Renviron"))
rstudioapi::restartSession()
