function [simout] = delete_first_zeroes(signal)
    i = 1;
    while signal(i) == 0
        i = i + 1;
    end
    simout = signal(i:end);  
end

