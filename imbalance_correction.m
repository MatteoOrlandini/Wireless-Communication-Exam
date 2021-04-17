function corrected_signal = imbalance_correction(signal, A, P)
% imbalance_correction corrects the imbalance of a signal 
%   corrected_signal = imbalance_correction(signal, A, P) returns an array
%   corrected_signal without the amplitude imbalance A and phase imbalance P
%   applied to signal
    X = [real(signal); imag(signal)];
    % iqimbal2coef converts an I/Q amplitude and phase imbalance 
    % to its equivalent compensator coefficient
    C = iqimbal2coef(A,P);
    R = [1+real(C) imag(C); imag(C) 1-real(C)];
    corrected_signal = R*X;
end