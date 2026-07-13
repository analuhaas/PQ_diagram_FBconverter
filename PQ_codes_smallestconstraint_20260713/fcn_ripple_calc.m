function ripple_max = fcn_ripple_calc(data,f_sw,Ts)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Tsw = 1/f_sw;
Nsw = round(Tsw / Ts); %nb samples per switching period

% Nb of windows of switching within a fundamental period
num_windows = floor(length(data)/Nsw);

ripple_values = zeros(1, num_windows);

for k = 5:num_windows-5
    idx_start = (k-1)*Nsw + 1;
    idx_end   = k*Nsw;
    
    segment = data(idx_start:idx_end);
    
    ripple_values(k) = max(segment) - min(segment);
end

ripple_max = max(ripple_values);

end

