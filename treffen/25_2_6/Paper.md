1. Introduction
The Hidden Markov Model (HMM) is a well studied stochastic Process, which evolved around the 1980-ties laying the basis of early Speech Recognition. "Rabiner" With the rise of advanced machine learnings methods it moved out of the focus of recent research. However its simple but effective structure driven by the Markov Property in its core, it still finds applications in Decoding and Recognition. In this paper we aim to investigate using HMM in forecasting, which has been a rather overseen utilization in literature. In Hassan 2005 HMM was used to prognose stock market, whereas Ghasarian computed Wind Forecasts. In our suprise, both of these papers, as well as other investigated papers, restrict themselve on relative small HMM Models (number of hidden States <= 10), whereas with modern technology much bigger models are in the reach of computation and therefore more complex problems can be approached with HMM. 
Electric power load profiles of single households are a suitable application to test HMM as a forecasting method. Its strong stochastic characteristic holds many repetetive patterns like households specific habits, plus the usage of HMM can be interpreted in a meaningful way: While the hidden Markov  Chain can be represented by the unobservable process of people living their daily life, their behavior emmit an measureable output in form of electric power demand, which serve as observations of the HMM model.
Furthermore, the research topic of energy forecasting in the era of energy transition now more than ever relevant importanc... . Haben und Co critize in their "plentyful/ precise/ excessive" analysis of low voltage energy forecast literature the lack of "consideration" of power load as probabilistic "object" in most of the reviewed papers. Literature, which considers its probabilistic characterister, widely uses prediction intervals or quantiles estimation, and only a handfull of papers develope a framework to forecast complete probability distributions due to its computational complexity. HMM offers here a novel oppertunity, because its stochastic design implies already a probabilistic method and can further compute distribution forecasts straight forward and very efficently.
This paper researches the question, if HMM can be applied for probability forecasting. It investigates the optimal setting of the hyperparameter space and feature tuning in order to model the characteristics of households electric power load, like seasonality and daytime differences. As a preliminary result we concluded, that eventhough the proposed HMM model surpasses simple baseline models, in its proposed form does not achieve compareable results to state-of-the-art probabilistic load forecasting models. Furthermore, the integration of new features - like daytime or seasonality information - did not improve the prediction, as well as an increased number of hidden states, which led to the unresolved problem of overfitting the model.
The paper is structured as follows. Chapter 2 lays the theoretic foundation of Hidden Markov Models and explains the forecasting method. The application of HMM to power load data is introduced in chapter 3, while chapter 4 presents the proposed model design and applied data set. In chapter 5 the experiments and benchmark are conducted, which results are discussed in chapter 6.

HMM as Forecast
HMM are driven by a Markov chain in its core, which is described by a transistion matrix and initial probabilities. The characteristic of HMM is that this Markov process cannot be directly observed, thus "hidden". However, in each timeinstance an observation is emitted with a certain probability dependend on the current state of the hidden Markov Chain. This chapter explains the theory of HMM as a forecasting method, for a detailed introduction to HMM see RAabiner.

2.1 HMM Notation 
            \item $S=\{s_1,s_2,...,s_{|S|}\}$ - set of states
            \item $\vec{Z} = (Z_1, Z_2,..., Z_T) \in S^T$ - sequence of states
            \item $V =  \{v_1, v_2, ..., v_{|S|}\}$ - output alpla set
            \item $\vec{X} = (X_1, X_2, ..., X_T) \in V^T$ sequence of observations = observed output
        \end{itemize}
        $\Rightarrow$ The state of the Markov chain cannot be directly observed, instead a \\ ~ sequence of observation can be observed.
        \newline $\Rightarrow$ The Markov chain has hidden states
        
        \item Model assumptions
        \begin{enumerate}
            \item Markov property: $P(Z_t | Z_{t-1},..., Z_1) = P(Z_t | Z_{t-1})$
            \item Homogeneous Markov chain:  
            \newline $P(Z_{t+m} = s_j | Z_{t+m-1}=s_i) = P(Z_{t} = s_j | Z_{t-1} = s_i) = P(Z_{1} = s_j | Z_{0} = s_i)$
            \item Output independence assumption:
            \newline The observation at time $t$, i.e. $X_t$ depends only on the state of the Markov chain at time $t$, i.e. $Z_t$.
            \begin{align*}
                P(X_t = v_k | X_1,...,X_T, Z_1,..., Z_T) = P (X_t= v_k | Z_t)
            \end{align*}
        \end{enumerate}
        \item Parameters
        \begin{itemize}
            \item Matrix $\uuline{A}$ - $|S|\times|S|$ times probability transition matrix of the hidden Markov chain, i.e. $A_{ij}=P(Z_t= s_j | Z_{t-1} = s_i), \quad i,j= 1,...,|S|$
            \item Matrix $\uuline{B}$ - $|S|\times |V|$ times matrix describing the probability of the observations, given the state of the hidden Markov chain, \newline i.e. $B_{jk}=P(X_t= v_k | Z_{t} = s_i), \quad j= 1,...,|S|; k = 1,...,|V|$
- S State Space
- O Observation Space

- A transition matrix
- B observation matrix
- pi initial probabilities
- lambda(A,B, pi) describes full discrete HMM

- X_t hidden Markov Process (governed by Markov Property)
- Y_t observation Process

2.3.HMM as distribution forecast
- Given an Series of Observations (O_t) t in 1:T; calc P_hat(O_t+h) for h in 1:H
- Training: Baum-Welch Algorithm
    max( likelihood of observation )) = max P(O | lambda(A,B,pi))
- Forecast: Probability distribution
    given lambda(A, B, pi) calc P(O_t+h | O_1.. . O_T) = P(O_t+h | X_)





4. Modell Design
4.1 Data
  - Data explanations
  - Using data from different households
    Experiment with 5 households
    - One representative household for disussion
    - Repetition of all experiments with 4 households for reasurance
        - results in Appendix
  - Benchmarking with 10 Households.
4.2 Experiments
- Basismodel
- Seasonal model
- Daytime model
4.3. Benchmark Models

5. Numerical evaluation
5.1 Experiments
- Basismodel
- Saisonal model
5.2 Benchmark test

6. Summary
- Discussion of results
- open questions, outlook 