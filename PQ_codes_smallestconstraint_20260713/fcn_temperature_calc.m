function T_J = fcn_temperature_calc(IL_rms,U_dc,f_switching)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Temperature limit
T_A = 323;
R_JC = 1;
R_CA = 74;
T_rise = 11e-9;
T_fall = 6e-9;
ron_FET = 0.016;

P_cond = ron_FET*IL_rms^2;
P_sw = (U_dc*f_switching*(T_rise+T_fall))/2 * IL_rms*2/(sqrt(2)*pi);
P_Q1 = P_cond + P_sw;

T_J = T_A + (R_JC+R_CA)*P_Q1;

end

