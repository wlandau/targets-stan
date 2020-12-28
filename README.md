
# `targets` R package Stan model example

[![Launch RStudio Cloud](https://img.shields.io/badge/RStudio-Cloud-blue)](https://rstudio.cloud/project/1430719/)

The goal of this workflow is to validate a small Bayesian model using simulation-based calibration (SBC; Cook, Gelman, and Rubin 2006; Talts et al. 2020). We simulate multiple datasets from the model and fit the model on each dataset. For each model fit, we determine if the 50% credible interval of the regression coefficient `beta` contains the true value of `beta` used to generate the data. If we implemented the model correctly, roughly 50% of the models should recapture the true `beta` in 50% credible intervals.

## The model

``` r
y_i ~ iid Normal(alpha + x_i * beta, sigma^2)
alpha ~ Normal(0, 1)
beta ~ Normal(0, 1)
sigma ~ HalfCauchy(0, 1)
```

## The `targets` pipeline

The [`targets`](https://github.com/wlandau/targets) R package manages the workflow. It automatically skips steps of the pipeline when the results are already up to date, which is critical for Bayesian data analysis because it usually takes a long time to run Markov chain Monte Carlo. It also helps users understand and communicate this work with tools like the interactive dependency graph below.

``` r
library(targets)
tar_visnetwork()
```

![](./images/graph.png)

## File structure

The files in this example are organized as follows.

``` r
├── run.sh
├── run.R
├── _targets.R
├── _targets/
├── sge.tmpl
├── R
│   ├── functions.R
│   └── utils.R
├── stan
│   └── model.stan
└── report.Rmd
```

<table style="width:11%;">
<colgroup>
<col width="5%" />
<col width="5%" />
</colgroup>
<thead>
<tr class="header">
<th>File</th>
<th>Purpose</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><a href="https://github.com/wlandau/targets-stan/blob/main/run.sh"><code>run.sh</code></a></td>
<td>Shell script to run <a href="https://github.com/wlandau/targets-stan/blob/main/run.R"><code>run.R</code></a> in a persistent background process. Works on Unix-like systems. Helpful for long computations on servers.</td>
</tr>
<tr class="even">
<td><a href="https://github.com/wlandau/targets-stan/blob/main/run.R"><code>run.R</code></a></td>
<td>R script to run <code>tar_make()</code> or <code>tar_make_clustermq()</code> (uncomment the function of your choice.)</td>
</tr>
<tr class="odd">
<td><a href="https://github.com/wlandau/targets-stan/blob/main/_targets.R"><code>_targets.R</code></a></td>
<td>The special R script that declares the <a href="https://github.com/wlandau/targets"><code>targets</code></a> pipeline. See <code>tar_script()</code> for details.</td>
</tr>
<tr class="even">
<td><a href="https://github.com/wlandau/targets-stan/blob/main/sge.tmpl"><code>sge.tmpl</code></a></td>
<td>A <a href="https://github.com/mschubert/clustermq"><code>clustermq</code></a> template file to deploy targets in parallel to a Sun Grid Engine cluster. The comments in this file explain some of the choices behind the pipeline construction and arguments to <code>tar_target()</code>.</td>
</tr>
<tr class="odd">
<td><a href="https://github.com/wlandau/targets-stan/blob/main/R/functions.R"><code>R/functions.R</code></a></td>
<td>A custom R script with the most important user-defined functions.</td>
</tr>
<tr class="even">
<td><a href="https://github.com/wlandau/targets-stan/blob/main/R/functions.R"><code>R/utils.R</code></a></td>
<td>A custom R script with helper functions.</td>
</tr>
<tr class="odd">
<td><a href="https://github.com/wlandau/targets-stan/blob/main/stan/model.stan"><code>stan/model.stan</code></a></td>
<td>The specification of our Stan model.</td>
</tr>
<tr class="even">
<td><a href="https://github.com/wlandau/targets-stan/blob/main/report.Rmd"><code>report.Rmd</code></a></td>
<td>An R Markdown report summarizing the results of the analysis. For more information on how to include R Markdown reports as reproducible components of the pipeline, see the <code>tar_render()</code> function from the <a href="https://wlandau.github.io/tarchetypes"><code>tarchetypes</code></a> package and the <a href="https://wlandau.github.io/targets-manual/files.html#literate-programming">literate programming chapter of the manual</a>.</td>
</tr>
</tbody>
</table>

## How to access

This project has an [RStudio Cloud](https://rstudio.cloud/project/1430719/) workspace that lets you try out the example code in the cloud with only a web browser and an internet connection. Unfortunately, as [explained here](https://community.rstudio.com/t/stan-on-rstudio-cloud-not-working/49224/3), `rstan` cannot currently compile models in RStudio Cloud because it hits the 1 GB memory limit. The Stan maintainers will likely fix this at some point.

## How to run

1.  If you are running locally instead of [this RStudio cloud workspace](https://rstudio.cloud/project/1430691)
    1.  Install the [`targets`](https://github.com/wlandau/targets) package, as well as the packages listed in the `tar_option_set()` call in [`_targets.R`](https://github.com/wlandau/targets-stan/blob/main/_targets.R).
    2.  Download the files in [this repository](https://github.com/wlandau/targets-stan), either [through Git](https://happygitwithr.com/existing-github-first.html#new-rstudio-project-via-git-clone) or through [this link](https://github.com/wlandau/targets-stan/archive/main.zip).
2.  Run the `targets` pipeline by either running [`run.R`](https://github.com/wlandau/targets-stan/blob/main/run.R) or [`run.sh`](https://github.com/wlandau/targets-stan/blob/main/run.sh). (The latter is for Unix-like systems only). This computation could take a while.
3.  View the validation results in the output `report.html` file.
4.  Make changes to the R code or Stan model, rerun the pipeline, and watch `targets` skip steps that are already up to date.

## Scale out

This computation is currently downsized for pedagogical purposes. To scale it up, open the [`_targets.R`](https://github.com/wlandau/targets-stan/blob/main/_targets.R) script and increase the number of simulations (the number inside `seq_len()` in the `index` target).

## High-performance computing

You can run this project locally on your laptop or remotely on a cluster. You have several choices, and they each require modifications to [`run.R`](https://github.com/wlandau/targets-stan/blob/main/run.R) and [`_targets.R`](https://github.com/wlandau/targets-stan/blob/main/_targets.R).

<table style="width:22%;">
<colgroup>
<col width="5%" />
<col width="5%" />
<col width="5%" />
<col width="5%" />
</colgroup>
<thead>
<tr class="header">
<th>Mode</th>
<th>When to use</th>
<th>Instructions for <a href="https://github.com/wlandau/targets-stan/blob/main/run.R"><code>run.R</code></a></th>
<th>Instructions for <a href="https://github.com/wlandau/targets-stan/blob/main/_targets.R"><code>_targets.R</code></a></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Sequential</td>
<td>Low-spec local machine or Windows.</td>
<td>Uncomment <code>tar_make()</code></td>
<td>No action required.</td>
</tr>
<tr class="even">
<td>Local multicore</td>
<td>Local machine with a Unix-like OS.</td>
<td>Uncomment <code>tar_make_clustermq()</code></td>
<td>Uncomment <code>options(clustermq.scheduler = &quot;multicore&quot;)</code></td>
</tr>
<tr class="odd">
<td>Sun Grid Engine</td>
<td>Sun Grid Engine cluster.</td>
<td>Uncomment <code>tar_make_clustermq()</code></td>
<td>Uncomment <code>options(clustermq.scheduler = &quot;sge&quot;, clustermq.template = &quot;sge.tmpl&quot;)</code></td>
</tr>
</tbody>
</table>

## stantargets

The [`stantargets`](https://github.com/wlandau/stantargets) R package is an extension to [`targets`](https://github.com/wlandau/targets) and [`cmdstanr`](https://github.com/stan-dev/cmdstanr) for Bayesian data analysis. [`stantargets`](https://github.com/wlandau/stantargets) makes it super easy to set up useful scalable Stan pipelines that automatically parallelize the computation and skip expensive steps when the results are already up to date. Minimal custom code is required, and there is no need to manually configure branching, so usage is much easier than [`targets`](https://github.com/wlandau/targets) alone. [`stantargets`](https://github.com/wlandau/stantargets) can access all of [`cmdstanr`](https://github.com/stan-dev/cmdstanr)’s major algorithms (MCMC, variational Bayes, and optimization) and it supports both single-fit workflows and multi-rep simulation studies.

[`stantargets`](https://github.com/wlandau/stantargets) condenses the workflow in this repo down to [this simple pipeline statement](https://wlandau.github.io/stantargets/articles/mcmc_rep.html) without loss of technical sophistication or computing power. The former requires users to think carefully about dynamic branching and file tracking, and the latter uses domain knowledge to abstract away these intimidating concepts.

## References

Cook, Samantha R., Andrew Gelman, and Donald B. Rubin. 2006. “Validation of Software for Bayesian Models Using Posterior Quantiles.” *Journal of Computational and Graphical Statistics* 15 (3). \[American Statistical Association, Taylor & Francis, Ltd., Institute of Mathematical Statistics, Interface Foundation of America\]: 675–92. <http://www.jstor.org/stable/27594203>.

Talts, Sean, Michael Betancourt, Daniel Simpson, Aki Vehtari, and Andrew Gelman. 2020. “Validating Bayesian Inference Algorithms with Simulation-Based Calibration.”
