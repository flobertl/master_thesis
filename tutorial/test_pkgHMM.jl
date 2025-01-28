using HiddenMarkovModels
using Distributions  # Required for specifying emission probabilities

# Define the number of hidden and observable states
num_hidden_states = 2
num_observable_states = 2

# Transition probabilities (hidden state to hidden state)
A = [1/2 1/2;  # From hidden state 1
     1/2 1/2]  # From hidden state 2

# Emission probabilities defined as categorical distributions
# Each hidden state emits observations with specific probabilities
B = [Categorical([2/3, 1/3]),  # Hidden state 1 emits with these probabilities
     Categorical([1/3, 2/3])]  # Hidden state 2 emits with these probabilities

# Initial state distribution
π = [0.75, 0.25]

# Create the HMM
hmm = HMM(π, A, B)
typeof(hmm)

# Define an observation sequence (e.g., 1 for observed state 1, 2 for observed state 2)
observations = [2, 2]

typeof(observations)
println("Initial HMM:")
println(hmm)

# Use the Baum-Welch algorithm to re-estimate the HMM parameters
hmm_reestimated, logliklihoodHist = baum_welch(hmm, observations, max_iterations = 10)

println("\nReestimated HMM:")
println(hmm_reestimated)


