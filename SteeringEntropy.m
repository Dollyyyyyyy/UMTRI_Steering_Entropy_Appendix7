%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Version: $ID$
% Authors: Chris Schwarz
%
% Description: Implements steering entropy as documented in the paper:
% Boer, E.R., Rakauskas, M.E., Ward, N.J., Goodrich, M.A. (2005),
% "Steering Entropy Revisited", Proceedings of the Third International
% Driving Symposium on Human Factors in Driver Assessment, Training
% and Vehicle Design.
%     
% Steering entropy requires the calculation of a baseline window of data
% in order to calculate entropy for a section of steering data in an epoch
% of interest. This script uses 2 minutes of data for the baseline: the 
% first minute for the arburg filter, and the second for computing the 
% baseline entropy.
%
% The second half of the script uses the baseline entropy to calculate
% steering entropy on a given data epoch.
%
% The output SE is a structure array that allows several different
% baselines to be calculated and stored. The actual entropy is returned in
% the variable H. Ise is the index into the SE structure array. str is the
% steering wheel angle data in degrees. Fs is the sampling rate of the
% data in Hz. baseline is a boolean that is true for the baseline
% calculation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [SE,H] = SteeringEntropy(SE,Ise,str,Fs,baseline)
    % SF: Downsample the data to a target sampling rate for entropy calculation
    Fs_se = 4; % SF: Target sampling rate for steering entropy
    skip = round(Fs / Fs_se); % SF: Compute the downsampling factor (original Fs to target Fs_se)
    
    %% SF: Either calculate baseline entropy or steering entropy based on the flag
    if baseline
        % SF: Baseline Entropy Calculation
        N = min([120 * Fs, length(str)]); % SF: Limit baseline calculation to the first 2 minutes (120 seconds)
        if N < 90 * Fs
            % SF: Ensure at least 90 seconds of data is available for the baseline
            H = -1; % SF: Return -1 to indicate insufficient data
            return
        end
        
        % SF: Identify filter coefficients using the first minute of data
        B_pe = arburg(double(str(1:skip:floor(N / 2))), 3); % SF: Compute AR model coefficients (order 3)
        PE = filter(B_pe, 1, str(floor(N / 2) + 1:skip:N)); % SF: Apply the AR filter to the second minute of data
        
        % SF: Sort the prediction errors (PE) for percentile calculations
        PEsort = sort(PE); 
        
        % SF: Compute alpha percentiles (e.g., 20% and 80%)
        alpha = 0.2; 
        [CDF, Palpha, P1minusalpha] = Percentile(PEsort, alpha, 1 - alpha);
        
        % SF: Compute the central prediction error range
        pe_alpha = 0.5 * (abs(Palpha) + abs(P1minusalpha)); % SF: Mean absolute bounds
        M = 6; % SF: Number of bins for entropy calculation
        pe_vec = zeros(1, M);
        for j = 1:M
            pe_vec(j) = j * pe_alpha; % SF: Create bin edges based on multiples of pe_alpha
        end
        
        % SF: Define bin boundaries (lower and upper bounds)
        Z = 10e12; % SF: Arbitrary large value for extreme boundaries
        lb = [-Z, -fliplr(pe_vec), 0, pe_vec]; % SF: Lower bin edges
        ub = [-fliplr(pe_vec), 0, pe_vec, Z]; % SF: Upper bin edges
        
        % SF: Compute probabilities for each bin
        Pk = zeros(1, 2 * M + 2); % SF: Initialize probability vector
        for j = 1:length(lb)
            bin = lb(j) < PEsort & PEsort <= ub(j); % SF: Identify elements in the current bin
            Pk(j) = max([1e-3, sum(bin) / length(PEsort)]); % SF: Compute probability and ensure non-zero values
        end
        
        % SF: Calculate baseline entropy (Href)
        Href = sum(-Pk .* log2(Pk)); % SF: Shannon entropy formula
        
        % SF: Store the baseline results in the SE structure array
        SE(Ise).B_pe = B_pe; % SF: Filter coefficients
        SE(Ise).Pkbas = Pk; % SF: Baseline probabilities
        SE(Ise).lb = lb; % SF: Lower bin edges
        SE(Ise).ub = ub; % SF: Upper bin edges
        SE(Ise).Href = Href; % SF: Baseline entropy value
        SE(Ise).CDF = CDF; % SF: Cumulative distribution function (optional visualization data)
        H = -1; % SF: Indicate that no steering entropy is calculated in baseline mode
    else
        % SF: Steering Entropy Calculation
        if ~isfield(SE, 'B_pe')
            % SF: Ensure baseline data exists in the SE structure
            H = -1; % SF: Return -1 if no baseline data is found
            return
        elseif isempty(SE(Ise).B_pe)
            % SF: Ensure the baseline filter coefficients are not empty
            H = -1; % SF: Return -1 if coefficients are missing
            return
        end
        
        % SF: Apply baseline filter to the input steering data
        PE = filter(SE(Ise).B_pe, 1, str(1:skip:end)); 
        
        % SF: Sort the prediction errors for binning
        PEsort = sort(PE); 
        
        % SF: Compute probabilities for each bin based on the baseline bins
        Pk = zeros(1, length(SE(Ise).lb)); % SF: Initialize probability vector
        for j = 1:length(SE(Ise).lb)
            bin = SE(Ise).lb(j) < PEsort & PEsort <= SE(Ise).ub(j); % SF: Identify elements in the current bin
            Pk(j) = max([1e-3, sum(bin) / length(PEsort)]); % SF: Compute probabilities
        end
        
        % SF: Calculate steering entropy using baseline probabilities
        H = sum(-Pk .* log2(SE(Ise).Pkbas)); % SF: Entropy relative to the baseline distribution
    end
end
