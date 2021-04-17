function imbal = imbalance_algorithm_estimation(signal)
% imbalance_algorithm_estimation estimates the imbalance from a signal
%   imbal = imbalance_algorithm_estimation(signal) returns the amplitude
%   imbalance imbal of signal
    signal = delete_first_zeroes(signal);
    signal_real = real(signal);
    signal_imag = imag(signal);
    imbal = 0;
    N = 1000;
    for i = 100:(length(signal)/N)-1
        f_real = signal_real(i*N+1:i*N+N);
        f_imag = signal_imag(i*N+1:i*N+N);
        r = sqrt(std(f_real)./std(f_imag));
        %r = (max(f_real)-min(f_real))/(max(f_imag)-min(f_imag));
        if (r < 1)
            r = 1/r;
        end
        imbal = imbal + r;
    end
    imbal = imbal/(i-100);
    %imbal = sqrt(std(real(y.y(end-1000:end)))./std(imag(y.y(end-1000:end))));
end

