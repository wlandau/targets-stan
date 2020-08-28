#' @title Simulate data from the model.
#' @description Use a discrete covariate x.
#' @return A data frame with the following columns.
#'   * `y`: Simulated normal responses.
#'   * `x`: A simulated covariate of zeroes and ones.
#'   * `beta_true`: The value of the regression coefficient `beta`
#'     used to simulate the data.
#' @param ... Supports replication with purrr. Do not use.
#' @examples
#' library(tidyverse)
#' simulate_data_discrete()
simulate_data_discrete <- function(...) {
  alpha <- rnorm(1, 0, 1)
  beta <- rnorm(1, 0, 1)
  sigma <- runif(1, 0, 1)
  x <- rbinom(100, 1, 0.5)
  y <- rnorm(100, alpha + x * beta, sigma)
  rep <- basename(tempfile(pattern = "rep"))
  tibble(x = x, y = y, beta_true = beta, rep = rep)
}

#' @title Simulate data from the model.
#' @description Use a continuous covariate x.
#' @return A data frame with the following columns.
#'   * `y`: Simulated normal responses.
#'   * `x`: A simulated covariate of zeroes and ones.
#'   * `beta_true`: The value of the regression coefficient `beta`
#'     used to simulate the data.
#' @param ... Supports replication with purrr. Do not use.
#' @examples
#' library(tidyverse)
#' simulate_data_continuous()
simulate_data_continuous <- function(...) {
  alpha <- rnorm(1, 0, 1)
  beta <- rnorm(1, 0, 1)
  sigma <- runif(1, 0, 1)
  x <- rnorm(100, 1, 1)
  y <- rnorm(100, alpha + x * beta, sigma)
  rep <- basename(tempfile(pattern = "rep"))
  tibble(x = x, y = y, beta_true = beta, rep = rep)
}

#' @title Fit the Stan model to some data.
#' @description Fit the Stan model to some data. Where possible,
#'   it is best to return small summaries instead of entire
#'   chains worth of MCMC samples so data storage stays reasonably light.
#' @return A data frame with one row and columns with information
#'   about the model fit.
#' @param model_file Path to the Stan model source file.
#' @param data Data frame, a single rep of a simulated dataset.
#' @examples
#' library(cmdstanr)
#' library(tidyverse)
#' compile_model("stan/model.stan")
#' fit_model("stan/model.stan", simulate_data_discrete())
fit_model <- function(model_file, data) {
  model <- cmdstan_model(model_file)
  stan_data <- list(x = data$x, y = data$y, n = nrow(data))
  beta_true <- data$beta_true[1]
  fit <- model$sample(data = stan_data, refresh = 0)
  fit$summary() %>%
    filter(variable == "beta") %>%
    mutate(
      beta_true = beta_true,
      cover_beta = q5 < beta_true & beta_true < q95
    )
}

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
  cmdstan_model(model_file)
  model_file
}

#' @title Fit a batch of Stan models.
#' @description This function fits one model per dataset rep.
#' @return A data frame with one row per model fit and columns with
#'   diagnostics and summary statistics.
#' @param model_file Path to the Stan model source file.
#' @param data Data frame, multiple reps of simulated datasets.
#'   Must have a `rep` column.
#' @examples
#' library(cmdstanr)
#' library(tidyverse)
#' compile_model("stan/model.stan")
#' data <- map_dfr(seq_len(2), simulate_data_discrete)
#' fit_batch("stan/model.stan", data)
fit_batch <- function(model_file, data) {
  data %>%
    group_by(rep) %>%
    group_modify(~fit_model(model_file, .x)) %>%
    ungroup()
}

#' @title Suppress stdout for code.
#' @description Used in the pipeline.
#' @return The result of running the code.
#' @param code Code to run quietly.
#' @examples
#' library(cmdstanr)
#' library(tidyverse)
#' compile_model("stan/model.stan")
#' out <- quiet(fit_model("stan/model.stan", simulate_data_discrete()))
#' out
quiet <- function(code) {
  capture.output(out <- suppressMessages(code))
  out
}
