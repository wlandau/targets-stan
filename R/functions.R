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

#' @title Simulate data from the model.
#' @description Simulate data from the model.
#' @return A data frame with the following columns.
#'   * `y`: Simulated normal responses.
#'   * `x`: A simulated covariate of zeroes and ones.
#'   * `beta_true`: The value of the regression coefficient `beta`
#'     used to simulate the data.
#' @examples
#' library(tidyverse)
#' simulate_data_favorable()
simulate_data_favorable <- function() {
  alpha <- rnorm(1, 0, 1)
  beta <- rnorm(1, 0, 1)
  sigma <- runif(1, 0, 1)
  x <- rbinom(100, 1, 0.5)
  y <- rnorm(100, alpha + x * beta, sigma)
  tibble(x = x, y = y, beta_true = beta)
}

#' @title Fit the Stan model to some data.
#' @description Fit the Stan model to some data. Where possible,
#'   it is best to return small summaries instead of entire
#'   chains worth of MCMC samples so data storage stays reasonably light.
#' @return A data frame with one row and the following columns.
#'   * `cover_beta`: Logical, whether the true value of `beta`
#'     is covered in the 50% credible interval from the model.
#'   * `beta_true`: True value of `beta` used to simulate the original data.
#'   * `beta_25`: posterior 25th percentile of `beta`.
#'   * `beta_median`: posterior median of `beta`.
#'   * `beta_75`: posterior 75th percentile of `beta`.
#'   * `psrf`: Maximum potential scale reduction factor across all the
#'     model parameters. A value above 1.1 is traditionally considered
#'     evidence of lack of convergence.
#'   * `ess`: Minimum effective sample size across all the model parameters.
#'     If this value is far lower than the number of non-warmup MCMC
#'     iterations, this is evidence of MCMC autocorrelation, which could mean
#'     the model needs reparameterization.
#' @examples
#' library(cmdstanr)
#' library(tidyverse)
#' compile_model("stan/model.stan")
#' fit_model("stan/model.stan", simulate_data_favorable())
fit_model <- function(model_file, data) {
  stan_data <- list(x = data$x, y = data$y, n = nrow(data))
  model <- cmdstan_model(model_file)
  fit <- model$sample(data = stan_data, refresh = 0)
  beta_true <- data$beta_true[1]
  fit$summary() %>%
    filter(variable == "beta") %>%
    mutate(
      beta_true = beta_true,
      cover_beta = q5 < beta_true & beta_true < q95
    )
}

#' @title Suppress stdout for code.
#' @description Used in the pipeline.
#' @return The result of running the code.
#' @param code Code to run quietly.
#' @examples
#' library(coda)
#' library(cmdstanr)
#' library(tidyverse)
#' compile_model("stan/model.stan")
#' out <- quiet(fit_model("stan/model.stan", simulate_data_favorable()))
#' out
quiet <- function(code) {
  capture.output(out <- suppressMessages(code))
  out
}
