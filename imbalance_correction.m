function [corrected_signal] = imbalance_correction(signal, A, P)
    X = [real(signal); imag(signal)];
    % iqimbal2coef converts an I/Q amplitude and phase imbalance 
    % to its equivalent compensator coefficient
    C = iqimbal2coef(A,P);
    R = [1+real(C) imag(C); imag(C) 1-real(C)];
    corrected_signal = R*X;
end