install.packages(
  c(
    "extraDistr",
    "fs",
    "fst",
    "remotes",
    "rmarkdown",
    "rprojroot",
    "rstudioapi",
    "tidyverse"
  )
)
remotes::install_github("wlandau/targets")
remotes::install_github("wlandau/tarchetypes")
remotes::install_github("stan-dev/cmdstanr")
root <- rprojroot::find_rstudio_root_file()
cmdstan <- file.path(root, "cmdstan")
fs::dir_create(cmdstan)
cmdstanr::install_cmdstan(cmdstan)
cmdstan <- max(list.files(cmdstan, full.names = TRUE))
writeLines(paste0("CMDSTAN=", cmdstan), file.path(root, ".Renviron"))
rstudioapi::restartSession()
