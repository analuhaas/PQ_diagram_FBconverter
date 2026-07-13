function [] = fcn_plot_idclimit(Vdc)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Idc_max = 8;
Ps = Vdc*Idc_max;

plot([Ps/1000 Ps/1000],[-200000 200000]/1000,'--k','LineWidth',1,'HandleVisibility','off')
plot(-[Ps/1000 Ps/1000],[-200000 200000]/1000,'--k','LineWidth',1,'HandleVisibility','off')
    
end

