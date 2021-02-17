% signal must be a row vector
function [ampImbEst phImbEst] = imbalance_estimation(signal)
    hIQComp = comm.IQImbalanceCompensator('CoefficientOutputPort', true);
    % Normalize the power of the signal
    normalized_signal = signal./std(signal);
    % step processes the input data, normalized_signal, to produce the output for System object, hIQComp.
    [compSig,coef] = step(hIQComp,normalized_signal);
    % iqcoef2imbal Computes the amplitude imbalance and phase imbalance that a given compensator coefficient will correct.
    [ampImbEst,phImbEst] = iqcoef2imbal(coef(end));
    release(hIQComp);
end