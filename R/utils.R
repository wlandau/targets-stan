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
  quiet_begin()
  on.exit(quiet_end())
  cmdstan_model(model_file)
  model_file
}

#' @title Fit a batch of Stan models.
#' @description This function fits one model per dataset rep.
#' @return A data frame with one row per model fit and columns with
#'   diagnostics and summary statistics.
#' @param model_file Path to the Stan model source file.
#' @param data Data frame, multiple reps of simulated datasets.
#'   Must have a column called "rep".
#' @examples
#' library(cmdstanr)
#' library(tidyverse)
#' compile_model("stan/model.stan")
#' data <- map_dfr(seq_len(2), simulate_data_discrete)
#' map_sims(data, fit_model, model_file = "stan/model.stan")
map_sims <- function(data, fun, ...) {
  quiet_begin()
  on.exit(quiet_end())
  data %>%
    group_by(rep) %>%
    group_modify(fun, ...) %>%
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
#' quiet_begin()
#' out <- fit_model("stan/model.stan", simulate_data_discrete())
#' quiet_end()
#' out
quiet_begin <- function(code) {
  sink(nullfile(), type = "output")
  sink(file(nullfile(), open = "wb"), type = "message")
}

#' @title Unsuppress output and messages for code.
#' @description Used in the pipeline.
#' @return The result of running the code.
#' @param code Code to run quietly.
#' @examples
#' library(cmdstanr)
#' library(tidyverse)
#' compile_model("stan/model.stan")
#' quiet_begin()
#' out <- fit_model("stan/model.stan", simulate_data_discrete())
#' quiet_end()
#' out
quiet_end <- function(code) {
  sink(type = "output")
  sink(type = "message")
}
