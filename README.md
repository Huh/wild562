# wild562
April 2 lab excercises

```R
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

summ_fun <- function(x, param){
  tibble::tibble(
    Parameter = param,
    Mean = mean(x$BUGS$sims.list[[param]]),
    SD = sd(x$BUGS$sims.list[[param]]),
    LCL = quantile(x$BUGS$sims.list[[param]], probs = .025),
    UCL = quantile(x$BUGS$sims.list[[param]], probs = .975)
  )
}

grtr_zero <- function(x, param){
  sum(x$BUGS$sims.list[[param]] > 0)/length(x$BUGS$sims.list[[param]])
}

summ_fun(fit, "alpha")
summ_fun(fit, "ndvi_eff")

grtr_zero(fit, "alpha")
grtr_zero(fit, "ndvi_eff")


purrr::map_df(c("alpha", "ndvi_eff"), ~summ_fun(fit, .x))

#  More generic
purrr::map_df(params, ~summ_fun(fit, .x))

mcmcplots::mcmcplot(fit)


```

##  Models
```R
model{
#  Data are all caps
#  Parameters all lower case

#  Priors
alpha ~ dnorm(0, 0.001)
ndvi_eff ~ dnorm(0, 0.001)

# Alternative priors
# alpha ~ dunif(-10, 10)
# ndvi_eff ~ dunif(-10, 10)

# Linear Predictor
for(i in 1:NOBS){
  logit(p[i]) <- alpha + ndvi_eff * NDVI[i]
}

# Likelihood
for(i in 1:NOBS){
  PRES[i] ~ dbern(p[i])
}

}
```

```R
model{
#  Data are all caps
#  Parameters all lower case

#  Priors
alpha ~ dnorm(0, 0.001)
ndvi_eff ~ dnorm(0, 0.001)

#  Random Effect on individual
sd_ind ~ dunif(0, 100)
tau_ind <- 1/(sd_ind^2)

for(i in 1:NIND){
  ind_eff[i] ~ dnorm(0, tau_ind)
}

# Linear Predictor
for(i in 1:NOBS){
  logit(p[i]) <- alpha + ndvi_eff * NDVI[i] + ind_eff[IND[i]]
}

# Likelihood
for(i in 1:NOBS){
  PRES[i] ~ dbern(p[i])
}

}
```
