function [] = fcn_plot_mlimit(Vs,Udc,f,Rf,Lf,M)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

phi_s_loop = 0:2*pi/100:2*pi;
% phi_s_loop = 0;
% M = 0:0.1:1;
omega = 2*pi*f;
Vm=M*Udc;
V_s = Vs/sqrt(2);
V_m = Vm/sqrt(2);

Ps = (V_s*(Rf*V_m*cos(phi_s_loop) - Rf*V_s + Lf*V_m*omega*sin(phi_s_loop)))/(Lf^2*omega^2 + Rf^2);
Qs = -(V_s*(Lf*V_s*omega + Rf*V_m*sin(phi_s_loop) - Lf*V_m*omega*cos(phi_s_loop)))/(Lf^2*omega^2 + Rf^2);

plot(Ps/1000,Qs/1000,'.k','LineWidth',1)

end

