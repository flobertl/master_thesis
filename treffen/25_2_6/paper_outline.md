## Paper Outline for 
# Probabilistic Forecasting with HMM: A Usecase in Household Power Load Forecasting

## Introduction
- basis of HMM, previous application, lack of usage in forecasting
- Properties of power loads in households (stochstic, lack of data, seasonality)

## Theoretic Basis
- HMM Notation
- how to use HMM as distribution forecast

## Methodology
### Research questions:
- What is a good choice of the hyper parameters space to model a households power load and its characteristics?
- How far into the future can a realistic forecast be made?
- How does the model perform compared to other simple benchmarking models?
### Model setup
- discrete HMM
- State Space hidden
- Observation: Load (discretized), Timedata
- Choice of Hyperparameter
    - Numbers of States
        - limited by computational restrictions
    - Training Data
        - length also affects computational effort
    - Observations
        - Load
        - Additional dimension: Timedata, Seasonality
    - HMM specific Parameter: max #Iteration Init Values of Traingsalgo
### Data 
- Data explanations
- Diskussion of power load characteristics with graphics (variability, seasonality)
    - Mean, variance, median demand of course during a day for year/seasons.
    - ACF/fouriertransform to identify more patterns/periodicity?
- Division in Training and Test/Eval Data:
    - Households 
        - 5 Households for Model explaration, Hyperparameter Tuning
        - 10 Housholds for Benchmarking
    - Splitting 2 1/2 years timeseries in Training/Testing  
        - Fullyear models: 1year Training, 1 year testing (1/2 year not used, so no season biases)
        - Season specific models: 2:1 training-test split (for summer and fall), 1:1 split (for winter, spring)
            - additional question: How much does the model improve with more training data?
### Model Evaluation
- Likelihood
    - Question: Are models with different state space size compareable via likelihood? (experiments suggest yes, because of similar level; theoretic explanation?)
    - check overfitting:
        - If likelihood of the trainingset is significant higher than of the test set => Overfitting
- Visually by PIT Histogramm Plots
    - Histogram of the frequencies of the realized quantile given a distribution forecast
    - All quantiles should occur evenly
    - Necessary, but not sufficent for good distribution forecast 
- Scoring Rule
    - to qualitatively compare models
    - rabbit hole, which one should i take?
- Entropy 
    - describes level of "information" of distribution (Sharpness, informativness)
    - low entropy correlates to more deterministics (similar to small variance)
    - Goal: minimize entropy


### Hyperparameter Tuning
- Experiment with 5 households
    - One representative household for disussion
    - Repetition of all experiments with 4 households for reasurance
        - results in Appendix
- 1.Experiment: Basismodel
    - Fullyear model (1 year training, 1 year test)
    - 1-dim Observation: historic load 
    - 6 models with different number of hidden states (50-300)
    - Testing: 
        - Likelihood of Model (train data vs test data)
            - If difference between test and train big => overfitting
        - One-step-Prediction (one step ahead distribution prediction for each time instances of the Test Data)
            - PIT plots (result: Biases for Season and daytime)
            - Prob. Error Measure
            - avergae Entropy
- 2.Experiment: Saisonality
    - seperate models for different season (spring/summer/fall/winter) vs fullyear model with Season stamp as 2nd dimension of observation
    - varing state space size
    - Testing routine as in 1.experiment
    - Test for Summer/Fall models the differences of 1:1 to 2:1 training-test data split.
- 3.Experiment: Daytime
    - Using the best Model from 2.experiment
    - Adding timestamps to observations
    - Varying time block sizes and states 
    - Testing routine
- Further Experiments:
    - investigate longer forecast horizon
        - multiple step forecast and testing routine applied on each step
            - Consider PIT plots 
    - investigate different algo training setups (iter, init)
### Benchmarking
- Given the best hyperparameters, train model for the 10 households and calc evaluation measures
- Compare to benchmarking models:
    - Naive distribution forecast:
        - empirical distribution for each quarterhour of day
    - state of the art ML model?

## Summary
- Discussion of results
- open questions, outlook
    - 