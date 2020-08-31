library(targets)
library(tarchetypes)
source("R/functions.R")
source("R/utils.R")
options(tidyverse.quiet = TRUE)

# Uncomment below to use local multicore computing
# when running tar_make_clustermq().
options(clustermq.scheduler = "multicore")

# Uncomment below to deploy targets to parallel jobs
# on a Sun Grid Engine cluster when running tar_make_clustermq().
# options(clustermq.scheduler = "sge", clustermq.template = "sge.tmpl")

# These packages only get loaded if a target needs to run.
tar_option_set(packages = c("cmdstanr", "rmarkdown", "tidyverse"))

tar_pipeline(
  tar_target(
    model_file,
    # Returns the paths to the Stan source file.
    # cmdstanr skips compilation if the model is up to date.
    compile_model("stan/model.stan"),
    # format = "file" means the return value is a character vector of files,
    # and the `targets` package needs to watch for changes in the files
    # at those paths.
    format = "file",
    # Do not run on a parallel worker:
    deployment = "local"
  ),
  tar_target(
    index_batch,
    seq_len(2), # Change the number of simulation batches here.
    deployment = "local"
  ),
  tar_target(
    index_sim,
    seq_len(2), # Change the number of simulations per batch here.
    deployment = "local"
  ),
  tar_target(
    data_continuous,
    map_dfr(index_sim, simulate_data_continuous),
    pattern = map(index_batch),
    format = "fst_tbl"
  ),
  tar_target(
    data_discrete,
    map_dfr(index_sim, simulate_data_discrete),
    pattern = map(index_batch),
    format = "fst_tbl"
  ),
  tar_target(
    fit_continuous,
    # We supply the Stan model specification file target,
    # not the literal path name. This is because {targets}
    # needs to know the model targets depend on the model compilation target.
    map_reps(data_continuous, fit_model, model_file = model_file),
    pattern = map(data_continuous),
    format = "fst_tbl"
  ),
  tar_target(
    fit_discrete,
    map_reps(data_discrete, fit_model, model_file = model_file),
    pattern = map(data_discrete),
    format = "fst_tbl"
  ),
  tar_render(report, "report.Rmd")
)
