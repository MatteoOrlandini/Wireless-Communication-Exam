function [data1,data2,data3,data4,data5] = load_data(input)
    data1 = load(input(1));
    data2 = load(input(2));
    data3 = load(input(3));
    data4 = load(input(4));
    data5 = load(input(5));
end

