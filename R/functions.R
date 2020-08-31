#' @title Simulate data from the model.
#' @description Use a continuous covariate x.
#' @return A data frame with the following columns.
#'   * `y`: Simulated normal responses.
#'   * `x`: A simulated covariate of zeroes and ones.
#'   * `beta_true`: The value of the regression coefficient `beta`
#'     used to simulate the data.
#' @examples
#' library(tidyverse)
#' simulate_data_continuous()
simulate_data_continuous <- function() {
  alpha <- rnorm(1, 0, 1)
  beta <- rnorm(1, 0, 1)
  sigma <- runif(1, 0, 1)
  x <- rnorm(100, 1, 1) # continuous covariate
  y <- rnorm(100, alpha + x * beta, sigma)
  sim <- basename(tempfile(pattern = "sim"))
  tibble(x = x, y = y, beta_true = beta, sim = sim)
}

#' @title Simulate data from the model.
#' @description Use a discrete covariate x.
#' @return A data frame with the following columns.
#'   * `y`: Simulated normal responses.
#'   * `x`: A simulated covariate of zeroes and ones.
#'   * `beta_true`: The value of the regression coefficient `beta`
#'     used to simulate the data.
#' @examples
#' library(tidyverse)
#' simulate_data_discrete()
simulate_data_discrete <- function() {
  alpha <- rnorm(1, 0, 1)
  beta <- rnorm(1, 0, 1)
  sigma <- runif(1, 0, 1)
  x <- rbinom(100, 1, 0.5) # discrete covariate
  y <- rnorm(100, alpha + x * beta, sigma)
  sim <- basename(tempfile(pattern = "sim"))
  tibble(x = x, y = y, beta_true = beta, sim = sim)
}

#' @title Fit the Stan model to some data.
#' @description Fit the Stan model to some data. Where possible,
#'   it is best to return small summaries instead of entire
#'   chains worth of MCMC samples so data storage stays reasonably light.
#' @return A data frame with one row and columns with information
#'   about the model fit.
#' @param model_file Path to the Stan model source file.
#' @param data Data frame, a single simulated dataset.
#' @examples
#' library(cmdstanr)
#' library(tidyverse)
#' compile_model("stan/model.stan")
#' fit_model(simulate_data_discrete(), "stan/model.stan")
fit_model <- function(data, model_file) {
  stan_data <- list(x = data$x, y = data$y, n = nrow(data))
  truth <- data$beta_true[1]
  model <- cmdstan_model(model_file)
  fit <- model$sample(data = stan_data, refresh = 0)
  fit$summary() %>%
    filter(variable == "beta") %>%
    mutate(beta_true = truth, cover_beta = q5 < truth & truth < q95)
}
