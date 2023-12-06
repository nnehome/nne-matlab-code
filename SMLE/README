# SMLE Estimation

---------------

These Matlab code files implement the simulated maximum likelihood (SMLE) using the smoothed likelihood approach to estimate sequential search model.

Use the code `main_mle.m` to run a Monte Carlo experiment to estimate the model from a simulated dataset. The smoothing parameter can be set by the `w` variable.

The following functions are used in the script, which are explained in the description below.

`model_seq_search.m`

This function generates outcomes based on sequential search model. This function is adapted from the replication code of Ursu "The Power of Rankings" (2018).

`monte_carlo_data.m`

This script generates a dataset of consumer search under a “true” value of the search model parameter, for the purpose of Monte Carlo experiments. It uses the function `model_seq_search.m` to simulate the search and purchase choices. The data is saved in a file `data.mat`.

`liklOutsideFE.m`

This function calculates the log-likelihood for one consumer using the smoothed likelihood approach. The function is adapted from the replication code of Ursu "The Power of Rankings" (2018).

`Objective_mle.m`

This function returns the negative value of the sum of the log-likelihood by calling the `liklOutsideFE.m` function.
