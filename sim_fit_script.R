# Simulate and fit simple rsf
# Josh Nowak
################################################################################
library(R2jags)
library(purrr)
library(dplyr)

################################################################################
rsf_dat <- tibble::tibble(
  id = rep(1:3, each = 5),
  ndvi = rnorm(length(id)),
  pres = rbinom(length(id), size = 1, prob = plogis(0.5 + 0.3 * ndvi))
)

# Exploring priors
hist(plogis(rnorm(100000, 0, sqrt(1/0.001))), breaks = 100, col = "dodgerblue")
hist(plogis(rnorm(100000, 0, sqrt(1/0.5))), breaks = 100, col = "dodgerblue")
hist(plogis(runif(10000, -5, 5)))


# Gather data for JAGS - must be named list
jdat <- list(
  NOBS = nrow(rsf_dat),
  NIND = n_distinct(rsf_dat$id),

  IND = rsf_dat$id,
  NDVI = rsf_dat$ndvi,
  PRES = rsf_dat$pres
)

# Create initial values
jinits <- function(){
  list(
    alpha = rnorm(1),
    ndvi_eff = rnorm(1)
  )
}

# Parameters to monitor
params <- c("alpha", "ndvi_eff", "ind_eff", "sd_ind")

# Call JAGS
fit <- jags(
  data = jdat,
  inits = jinits,
  parameters.to.save = params,
  model.file = "./ndvi_rsf_re.txt",
  n.chains = 3,
  n.burnin = 500,
  n.iter = 600,
  n.thin = 1
)

# A function to summarise results, we write a function because this action will
# be repeated multiple times
summ_fun <- function(x, param){
  tibble::tibble(
    Parameter = param,
    Mean = mean(x$BUGS$sims.list[[param]]),
    SD = sd(x$BUGS$sims.list[[param]]),
    LCL = quantile(x$BUGS$sims.list[[param]], probs = .025),
    UCL = quantile(x$BUGS$sims.list[[param]], probs = .975)
  )
}

# A function to determine if a parameter value is greater than 0
grtr_zero <- function(x, param){
  sum(x$BUGS$sims.list[[param]] > 0)/length(x$BUGS$sims.list[[param]])
}

summ_fun(fit, "alpha")
summ_fun(fit, "ndvi_eff")

grtr_zero(fit, "alpha")
grtr_zero(fit, "ndvi_eff")

# The purrr package implements some clean functions aimed at the tenants of
#  functional programming, here we loop over a series of inputs while calling a
#  function
purrr::map_df(c("alpha", "ndvi_eff"), ~summ_fun(fit, .x))

#  More generic
purrr::map_df(params, ~summ_fun(fit, .x))

#  The mcmcplots package has several useful utilities to help with assessing
#   convergence and examining model outputs
mcmcplots::mcmcplot(fit)

#  Also check out the Bayesian task view in R and tidybayes in particular