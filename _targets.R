library(targets)
source("R/functions.R")
options(tidyverse.quiet = TRUE)

# Uncomment below to use local multicore computing
# when running tar_make_clustermq().
options(clustermq.scheduler = "multicore")

# Uncomment below to deploy targets to parallel jobs
# on a Sun Grid Engine cluster when running tar_make_clustermq().
# options(clustermq.scheduler = "sge", clustermq.template = "sge.tmpl")

tar_options(
  packages = c("coda", "fs", "rmarkdown", "rstan", "targets", "tidyverse")
)
tar_pipeline(
  tar_target(
    model_files,
    # Returns the paths to the Stan file and the compiled model RDS file
    # that rstan generates if you choose rstan_options(auto_write = TRUE).
    compile_model("stan/model.stan"),
    # format = "file" means the return value is a character vector of files,
    # and the `targets` package needs to watch for changes in the files
    # at those paths.
    format = "file",
    # Do not run on a parallel worker:
    deployment = "local"
  ),
  tar_target(
    index,
    seq_len(10), # Change the number of simulations here.
    deployment = "local"
  ),
  tar_target(
    data,
    simulate_data(),
    pattern = map(index),
    format = "fst_tbl"
  ),
  tar_target(
    fit,
    # We supply the Stan model specification file. Stan automatically
    # knows how to look for the compiled RDS model file, which
    # is what is really being used here because we compiled the model
    # ahead of time.
    fit_model(model_files[1], data),
    pattern = map(data),
    format = "fst_tbl"
  ),
  tar_target(
    report, {
      render("report.Rmd", quiet = TRUE)
      c(!!tar_knitr("report.Rmd"), "report.html")
    },
    format = "file",
    deployment = "local"
  )
)
