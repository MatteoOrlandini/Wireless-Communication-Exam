function [ampImbEst phImbEst] = imbalance_estimation(signal)
% imbalance_estimation estimates the amplitude and phase imbalance from a
% signal using comm.IQImbalanceCompensator
%   [ampImbEst phImbEst] = imbalance_estimation(signal) estimates the
%   amplitude ampImbEst and phase phImbEst imbalance from row vector signal
    hIQComp = comm.IQImbalanceCompensator('CoefficientOutputPort', true);
    % Normalize the power of the signal
    normalized_signal = signal./std(signal);
    % step processes the input data, normalized_signal, to produce the output for System object, hIQComp.
    [compSig,coef] = step(hIQComp,normalized_signal);
    % iqcoef2imbal Computes the amplitude imbalance and phase imbalance that a given compensator coefficient will correct.
    [ampImbEst,phImbEst] = iqcoef2imbal(coef(end));
    release(hIQComp);
end