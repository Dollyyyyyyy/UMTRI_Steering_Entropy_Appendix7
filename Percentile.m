%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (C) Copyright 2010 by National Advanced Driving Simulator and
% Simulation Center, the University of Iowa and The University of Iowa.
% All rights reserved.
%
% Version: $ID$
% Authors: Created by Chris Schwarz and others at the NADS
%
% Description: This function calculates the cumulative distribution 
% function (CDF) for an input vector and optionally computes specific 
% percentiles requested by the user.
%
% Inputs:
%   - u: An input vector of numerical values.
%   - varargin: Optional percentiles to compute (values between 0 and 1).
%
% Outputs:
%   - CDF: A structure containing two fields:
%       - x: A vector representing the domain (input values).
%       - y: The cumulative probabilities corresponding to x.
%   - varargout: Optional outputs, each corresponding to a requested
%                percentile from varargin.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [CDF,varargout] = Percentile(u,varargin)
    % SF: Return immediately if the input vector `u` is empty
    if isempty(u)
        CDF = []; % SF: Assign an empty structure to `CDF`
        for i = 1:length(varargin)
            % SF: Ensure optional outputs are also empty
            varargout{i} = [];
        end
        return % SF: Exit the function early
    end

    % SF: Remove NaN values from the input vector to avoid computation errors
    u(isnan(u)) = [];

    % SF: Sort the input vector in ascending order
    u_sort = sort(u);

    % SF: Compute the number of valid elements in the sorted vector
    N = length(u_sort);

    % SF: Create an evenly spaced vector `x` over the range of the sorted input
    x = (u_sort(1):(u_sort(end) - u_sort(1)) / 100:u_sort(end))';
    Nx = length(x); % SF: Calculate the number of points in the evenly spaced vector

    % SF: Handle the case where the input vector is constant (has zero variance)
    if Nx == 0
        x = u; % SF: Set `x` to the original input vector
        Nx = length(x); % SF: Recalculate the number of points
    end

    % SF: Initialize the CDF probabilities vector `y` to zeros
    y = zeros(Nx, 1);

    % SF: Use a parallel loop to calculate the cumulative probabilities
    parfor j = 1:Nx
        % SF: Compute the proportion of elements in `u_sort` that are less than
        % or equal to the current value in `x(j)`
        y(j) = sum(u_sort <= x(j)) / N;
    end

    % SF: Store the results in the output structure `CDF`
    CDF.x = x; % SF: The evenly spaced vector representing the domain
    CDF.y = y; % SF: The cumulative probabilities corresponding to `x`

    % SF: Compute optional percentiles based on the requested probabilities
    for i = 1:length(varargin)
        % SF: Find the smallest index `K` where the CDF value is greater than
        % or equal to the requested percentile
        K = find(y >= varargin{i}, 1, 'first');

        % SF: Assign the corresponding `x` value (percentile) to the output
        varargout{i} = x(K);
    end
end
