The Hidden Markov Model (HMM) is a well studied stochastic Process, which evolved around the 1980-ties laying the basis of early Speech Recognition. "Rabiner" With the rise of advanced machine learnings methods it moved out of the focus of recent research. However its simple but effective structure driven by the Markov Property in its core, it still finds applications in Decoding and Recognition. In this paper we aim to investigate using HMM in forecasting, which has been a rather overseen utilization in literature. In Hassan 2005 HMM was used to prognose stock market, whereas Ghasarian computed Wind Forecasts. In our suprise, both of these papers, as well as other investigated papers, restrict themselve on relative small HMM Models (number of hidden States <= 10), whereas with modern technology much bigger models are in the reach of computation and therefore more complex problems can be approached with HMM. 
Electric power load profiles of single households are a suitable application to test HMM as a forecasting method. Its strong stochastic characteristic holds many repetetive patterns like households specific habits, plus the usage of HMM can be interpreted in a meaningful way: While the hidden Markov  Chain can be represented by the unobservable process of people living their daily life, their behavior emmit an measureable output in form of electric power demand, which serve as observations of the HMM model.
Furthermore, claims the research topic of energy forecasting in the era of energy transition now more than ever relevant importanc... . Haben und Co critize in their "plentyful/ precise/ excessive" analysis of low voltage energy forecast literature the lack of "consideration" of power load as probabilistic "object" in most of the reviewed papers. Literature, which considers its probabilistic characterister, widely uses prediction intervals or quantiles estimation, and only a handfull of papers develope a framework to forecast complete probability distributions due to its computational complexity. The stochastic design of HMM implies already a probabilistic method and can further compute distribution forecasts very efficently. 


For a suitable application to apply this method, we chose to model electric power load of single households since they fullfill the necessary properties: of highly stochastic form, repetetive or recognisable pattern, season/daytime dependend


1. Introduction
- Thema context
- Properties of power loads in households (stochstic, lack of data, seasonality)
- lack of usage in forecasting
- literature review
- novelty and contribution

2.1 power load characteristics
  - Diskussion of power load characteristics with graphics (variability, seasonality)
    - Mean, variance, median demand of course during a day for year/seasons.
    - ACF/fouriertransform to identify more patterns/periodicity?
2.2 HMM basics 
2.3.HMM as distribution forecast
2.4 Evaluation metrics 

3. Development of forecasting HMM model
3.1 Model setup
 - discrete HMM
 - State Space hidden
 - Observation: Load (discretized), Timedata
3.2. Trainig
    Division in Training and Test/Eval Data:
    - Households 
        - 5 Households for Model explaration, Hyperparameter Tuning
        - 10 Housholds for Benchmarking
    - Splitting 2 1/2 years timeseries in Training/Testing  
        - Fullyear models: 1year Training, 1 year testing (1/2 year not used, so no season biases)
        - Season specific models: 2:1 training-test split (for summer and fall), 1:1 split (for winter, spring)
            - additional question: How much does the model improve with more training data?
3.3 Hyperparameter
    - Numbers of States
        - limited by computational restrictions
    - Training Data
        - length also affects computational effort
    - Observations
        - Load
        - Additional dimension: Timedata, Seasonality
    - HMM specific Parameter: max #Iteration Init Values of Traingsalgo

4. Modell Design
4.1 Data
  - Data explanations
  - Using data from different households
    Experiment with 5 households
    - One representative household for disussion
    - Repetition of all experiments with 4 households for reasurance
        - results in Appendix
4.2 Experiments
- Basismodel
- Saisonal model

5. Numerical evaluation
5.1 Experiments
- Basismodel
- Saisonal model
5.2 Benchmark test

6. Summary
- Discussion of results
- open questions, outlook 