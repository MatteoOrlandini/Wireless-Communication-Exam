function [ampImbEst phImbEst] = imbalance_estimation(signal)
    hIQComp = comm.IQImbalanceCompensator('CoefficientOutputPort',true);
    % Normalize the power of the signal
    normalized_signal = signal./std(signal);
    normalized_signal = reshape(normalized_signal, [], 1);
    [compSig,coef] = step(hIQComp,normalized_signal);
    [ampImbEst,phImbEst] = iqcoef2imbal(coef(end));
    release(hIQComp);
end

