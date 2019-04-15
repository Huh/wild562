# WILD562 Lab

The code in this repo was created during a lab with WILD 562. The sim_fit script shows the user one simple way to simulate data for a binomial regression, in this case a resource selection function (RSF). The script also allows the user to fit a basic regression considering covariates (model_one.txt) and a second model with an individual random effect (model_two.txt). For the sake of creating good habits a few functions were written in the script to help with summarizing results, but please recognize that there are established packages that accomplish these same tasks better than what was written here (https://github.com/mjskay/tidybayes). 

The purpose of these scripts is to provide a simple entry point that allows the user to become familiar with the simulated/fit workflow and the qwerks of running an analysis in R. For those interested in fitting RSFs in R I would consider reading the ecology and spatial task views in R to get a feel for the types of analyses that are packaged for you. In addition, those interested in Bayesian methods should consider alternative ways to call the models such as rjags, rstan and jagsUI.

### Project

This repository was created using a RStudio project. Users are encouraged to clone or fork the repository and then create/open a project of their own. The project will set the working directory and ease sharing...as they do.

### Warranty
This code comes with no warranty implied or otherwise.
