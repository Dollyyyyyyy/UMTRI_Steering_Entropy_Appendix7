# UMTRI Steering Entropy Code (Appendix 7)

This repository contains MATLAB code and documentation for calculating steering entropy as described in **Appendix 7** of the following technical report:

**Citation**:  
Green, P., Brennan-Carey, C., Wasi, H., Koca, E., Miller, B., and Fu, S. (2024). *UMTRI – U.S. Army Handbook of Driving Performance Measures and Statistics, version 1.0*. Technical Report, Ann Arbor, Michigan: University of Michigan Transportation Research Institute (UMTRI).

## Files
1. **`Percentile.m`**  
   - Function to calculate the cumulative distribution function (CDF) and specified percentiles.  
   - Includes support for optional user-defined percentiles.  
   - Handles NaN values and outputs a structured CDF with probabilities.

2. **`SteeringEntropy.m`**  
   - Function to calculate steering entropy using baseline and task conditions.  
   - Implements the methodology from Boer et al. (2005), with support for baseline filtering and task-specific entropy evaluation.  
   - Accepts steering data and sampling rates as inputs.  
   - Outputs baseline and task entropy values for analysis.

## Usage
### Prerequisites
- MATLAB R2018b or newer is recommended.
- Ensure all `.m` files are in your MATLAB path.

### Steps to Run
1. Clone this repository:
   ```bash
   git clone https://github.com/Dollyyyyyyy/UMTRI_Steering_Entropy_Appendix7.git
