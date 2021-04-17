function simout = delete_first_zeroes(signal)
% delete_first_zeroes delete the first zeroes from a signal
%   simout = delete_first_zeroes(signal) delete first zeroes from signal
%   array and returns the array simout
    i = 1;
    while signal(i) == 0
        i = i + 1;
    end
    simout = signal(i:end);  
end

