---
output:
  pdf_document: default
  html_document: default
---
# Methodology for Basis Experiments
This document describes the methodology for the experiments with the goal to find solid hyperparameter and optimal parameter settings for a simple HMM prediction model.

# General HMM Experiment Design

## Basis Model
- HMM Model with Parameters A (Transition Matrix) and B (Emission Matrix)
- The observation state space is 1-dimensional electric demand
- The hidden state space is unknown, but the number of hidden states is a variable parameter which has to be optimized.

## Data
- The Data set consists of 15 Households electric demand timeseries with a granulation of 15min intervals and a total length of 2 years.
- each timeseries is normalized, by dividing with the max element to be between [0, 1]
- Data is discretized, which for we conduct a sensitivity analysis (see later chapter)

- For first basis experiments 5 Households are randomly choosen. 
- Training are conducted on the first year, Tests/validation are conducted on the second Year* 
(* Discussion with other option: Tests first 2 weeks of each season of second year; validation weeks 3 + 4 - to reduce computation?)

## Training
- Given a fixed number of hidden state, the model is trained with the Baum-Welch Algorithm
- Init values are randomly choosen; max iteration of algo is set to 100
- Resulting: A and B
- pi (initial distribution of the model) is set to the stationary distribution of A

## Forecast and Test 
- Given a model (A, B, pi), for each time instance of the test set the probability distribution is calculated as sliding-window one-step-ahead predictions
    - Sliding-window: only a fixed number of historic data points are used for each prediction, (eg. the last week); To determine the size of the sliding window (= H) a sensitivity analysis is conducted
    - one-step-ahead: predictions are made only for the next quarter hour. Thus, for the prediction of time instance T, the model uses the data of time T-1, T-2,..., T-H.
- the discrete probabilty distribution will be transformed to a piecwise-linear continouse probability distribution, and further its 100 quantiles (1%, 2%, ..., 100% quantile) are computed.
- For each instance, the CRPS-Score is calculated based on the 100 quantiles and the true realization
- The Mean-CRPS of all instances serves as final evaluation metric for one specific model. 

# Experiment Design for Basis Experiments

Given now the three variable hyperparameters (number of hidden states, discretization method, historic sliding window size), two following sensitivity analysis are conducted, where one hyperparameter is fixed and the other two are optimized. The experiment is repeated for 5 different households, to investigate similarities/differences in model behavior to different data (Sensitivity of hyperparameters).

## Sensitivity Analysis 1: Discretization
- Goal: Investigate best type of discretization and optimal parameter setting. 
- Two different types of discretization are tested.
    - Type 1: equidistant discretization \
    The continues dataset of demand data is discretized into bins with equal ranges, eg. 0-100 Watts; 100-200 Watts; 200-300 Watts...; The representative value of each bin is its middle point.
    - Type 2: Occurance-balanced  discretization \
    The buckets are choosen so that each bin holds the same amount of datapoints of the data set, thus areas with more data points have a higher resolution than less frequented areas. The representative of the bin is defined by the value of its median data point.
- Both types are tested with varying number of bins and number of hidden states. The historic window length is set to be sufficiently large (>100).
- For one representative household the results are presentet graphicly to visually show the characteristics of HMMs with different discretization; while the results of the remaining 4 households are documented in a table to varify the presented results of the representiv household. 

## Sensitiviy Analysis 2: Historic Window Length

- Goal: Investigate what is a suitable size of the historic window lingth for HMM predictions, thus choose the smallest size for which the the prediction accuracy has converged.
- Given the optimal settings for discretization, test varying sizes of historic window length and number of hidden states. 
- Results are similar to the first analysis presented.
- If resulting optimal minimum size is bigger than the window size choosen in sensitivity analysis 1, the sensitivity analysis 1 has to be repeated.