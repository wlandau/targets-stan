#' @title Compile a Stan model and return a path to the compiled model output.
#' @description We return the paths to the Stan model specification
#'   and the compiled model file so `targets` can treat them as
#'   dynamic files and compile the model if either file changes.
#' @return Path to the compiled Stan model, which is just an RDS file.
#'   To run the model, you can read this file into a new R session with
#'   `readRDS()` and feed it to the `object` argument of `sampling()`.
#' @param model_file Path to a Stan model file.
#'   This is a text file with the model spceification.
#' @examples
#' library(cmdstanr)
#' compile_model("stan/model.stan")
compile_model <- function(model_file) {
  quiet(cmdstan_model(model_file))
  model_file
}

#' @title Fit a batch of Stan models.
#' @description This function fits one model per dataset sim.
#' @return A data frame with one row per model fit and columns with
#'   diagnostics and summary statistics.
#' @param data Data frame, multiple simulated datasets row-bound together.
#'   Must have a column called "sim".
#' @param model_file Path to the Stan model source file.
#' @examples
#' library(cmdstanr)
#' library(tidyverse)
#' compile_model("stan/model.stan")
#' data <- map_dfr(seq_len(2), ~simulate_data_discrete())
#' map_sims(data, model_file = "stan/model.stan")
map_sims <- function(data, model_file) {
  data %>%
    group_by(sim) %>%
    group_modify(~quiet(fit_model(.x, model_file = model_file))) %>%
    ungroup()
}

#' @title Suppress output and messages for code.
#' @description Used in the pipeline.
#' @return The result of running the code.
#' @param code Code to run quietly.
#' @examples
#' library(cmdstanr)
#' library(tidyverse)
#' compile_model("stan/model.stan")
#' quiet(fit_model("stan/model.stan", simulate_data_discrete()))
#' out
quiet <- function(code) {
  sink(nullfile())
  on.exit(sink())
  suppressMessages(code)
}
