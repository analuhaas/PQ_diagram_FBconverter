function [] = fcn_plot_ilimit(Vs,Is)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

phi_s_loop = 0:2*pi/100:2*pi;
Ps = 1/2*Vs*Is*sqrt(2)*cos(phi_s_loop);
Qs = 1/2*Vs*Is*sqrt(2)*sin(phi_s_loop);
        
plot(Ps/1000,Qs/1000,':k','LineWidth',1,'HandleVisibility','off')
    
end

