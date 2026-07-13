%% Clean everything
close all, clear all, clc

% 20260302, ana-luiza.haas-bezerra@centralesupelec.fr - Version 1
% 20260319, ana-luiza.haas-bezerra@centralesupelec.fr - Updated to be in
% Bogdan's format

%% Inputs

%Simulation files
latest_sim_name = 'PQ_FBconverter_TWIST200kHz_20260708'; 

% External AC parameters
Fnom = 50; %ac frequency [Hz]
Vs = 60; %ac source voltage [V]

% External parameters DC
U_dc = 75; %dc source voltage [V]
source_V = U_dc; %initial capacitor voltage [V]

% Converter and PWM parameters
f_switching = 200e3; %TWIST switching frequency [Hz]
twist_low_side_L = 33e-6; %declared in the simulink model as well - doesn't change simulink parameter
twist_low_side_rL = 20e-3; %declared in the simulink model as well - doesn't change simulink parameter
twist_FET_Ron = 0.016; %declared in the simulink model as well - doesn't change simulink parameter
Rf = 2*(twist_FET_Ron + twist_low_side_rL); %resistance used to calculate theorical PQ diagram
Lf = twist_low_side_L; %inductance used to calculate theorical PQ diagram

% Limits considered in the PQ diagram
Iac_limit = 10; %ac-side current limit [A] - AC grid external limit
If_lim = 7; %low-side fuse current limit [A rms]
Il_lim = 13; %low-side inductance current limit [A rms]
Imos_lim = 40; %MOSFET current limit [A rms]
Iripple_lim = 1.5; %inductance current ripple limit [App]
Tj_lim = 448; %MOSFET temperature limit [K]

%Simulation times
sim_time = 0.1; % [s] Overall simulation time
Ts = 1e-7; % [s] Simulation sample period
%% Variables

%initial modulation parameters
Mmod_index = 0.8; %initial modulation amplitude (M_p)
phimod_index = 0; %initial modulation phase (phi_m)

%step parameters used to form the PQ diagram
step_phi = pi/1944; %step used to scan different modulation phases
step_init = 0.002; %initial step used to scan different modulation amplitudes
step_fine = 0.001; %smaller step used to scan different modulation amplitudes (if constraint is in the 80% range)

end_nb = 10; % Minimum of points to enable end criteria verification for PQ diagram generation
%% Calculate data

fcn_step1_PQ_fullbridge_smallestconstraint(Vs, Fnom, U_dc, f_switching, Mmod_index, phimod_index, Iac_limit, sim_time, Ts, latest_sim_name,step_init,step_fine,step_phi,end_nb,Il_lim,If_lim,Imos_lim,Iripple_lim,Tj_lim);

%% Extract and plot
% addpath('C:\Users\ana\Documents\PhD\Presentations et livrables\Templates_Loic\figure_PP_QUEVAL_20231221\core') % Add figure_PP folder to the path

fcn_step2_PQ_fullbridge(Vs, Fnom, U_dc, f_switching, Mmod_index, phimod_index, Iac_limit, sim_time, Ts, latest_sim_name,Rf,Lf,Il_lim,If_lim,Imos_lim,Iripple_lim,Tj_lim);

% figure_PP(66,'Figures/PQ_FBconverter_TWISTmodel_Theorical_constraints_zoomout.png','width',8.75,'height',6,'color','rgb')
% figure_PP(67,'Figures/PQ_FBconverter_TWISTmodel_Theorical_constraints.png','width',8.75,'height',6,'color','rgb')
% figure_PP(68,'Figures/PQ_FBconverter_TWISTmodel_Sim_constraints_zoomout.png','width',8.75,'height',6,'color','rgb')
% figure_PP(69,'Figures/PQ_FBconverter_TWISTmodel_Sim_constraints.png','width',8.75,'height',6,'color','rgb')
% figure_PP(70,'PQ_FBconverter_TWISTmodel_Sim_Icolormap_zoomout.png','width',8.75,'height',6,'color','rgb')
% figure_PP(71,'Figures/PQ_FBconverter_TWISTmodel_Sim_Icolormap_zoomout.png','width',8.75,'height',6,'color','rgb')