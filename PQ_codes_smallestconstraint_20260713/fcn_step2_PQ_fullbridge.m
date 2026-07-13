function [] = fcn_step2_PQ_fullbridge(Vs,Fnom, U_dc, f_switching, M_index, phi_m_index, Iaclimit, sim_time, Ts, latest_sim_name,Rf,Lf,Il_lim,If_lim,Imos_lim,Iripple_lim,Tj_lim)
%FCN_STEP2_PQ_FULLBRIDGE Summary of this function goes here
%   Detailed explanation goes here

%% Load data
load(['brutasse0','.mat']); %brutasse0
Ps = P_fft_50Hz;
Qs = Q_fft_50Hz;

%% Sort data into categories of limits

%Capacitor limits
% ind_dVcap = find(dVcap<0.05*U_dc & dVcap>0.049*U_dc); %dc capacitor voltage ripple constraint - not used
% ind_Vcap = find(maxVcap > 158 & maxVcap <160); %dc capacitor max voltage constraint - not used
% ind_dIc = find(dIc < 1.6*0.07 & dIc > 1.6*0.068); %dc capacitor current ripple constraint - not used

%MOSFET limits
% ind_VMOS = find(maxVMOS > 118 & maxVMOS < 120); %MOSFET max voltage constraint - not used
ind_IMOS = find(rmsIMOS<=Imos_lim & rmsIMOS>=Imos_lim*0.9); %MOSFET RMS current constraint - from datasheet of Q1 and Q2 MOSFET
ind_TJ = find(TJ <=Tj_lim & TJ >=Tj_lim*0.9); %MOSFET temperature constraint - MOSFET datasheet
P_IMOS_all = Ps(ind_IMOS);
Q_IMOS_all = Qs(ind_IMOS);
P_Tj = Ps(ind_TJ);
Q_Tj = Qs(ind_TJ);

%Inductor current limit
ind_IL = find(rmsIL <= Il_lim & rmsIL >= Il_lim*0.85); %IL RMS current constraint - from datasheet of L1 and L2 it is 9 Arms
P_IL_all = Ps(ind_IL);
Q_IL_all = Qs(ind_IL);

% ind_VL = find(maxVL <80); %VL max voltage constraint - not used
ind_dIL = find(IL_ripple <= Iripple_lim & IL_ripple >= Iripple_lim*0.85); %IL ripple current constraint - defined according to Telles's book
P_dIL_all = Ps(ind_dIL);
Q_dIL_all = Qs(ind_dIL);

%Fuses current limit
ind_Ifuse = find(rmsIL <= If_lim & rmsIL >= If_lim*0.8); %IL RMS current constraint - from datasheet of L1 and L2 it is 9 Arms
P_If_all = Ps(ind_Ifuse);
Q_If_all = Qs(ind_Ifuse);

%% Extra indicators for plotting
ind_PQ_low = find(abs(Ps)<=4000 & abs(Qs)<=4000);

%% Plots

%Theorical constraints plot
figure(66), axis square, hold on, grid on, box on
    fcn_plot_mlimit(Vs,U_dc,Fnom,Rf,Lf,1)
    fcn_plot_ilimit(Vs,Iaclimit)
    fcn_plot_idclimit(U_dc)
    plot(Ps/1000,Qs/1000,'.','Color',"#EBEBEB") % all points
xlabel('$P_s$ [kW]','interpreter','latex')
ylabel('$Q_s$ [kVAr]','interpreter','latex')

xlim([-100, 100])
ylim([-100, 100])
legend('Theorical $M_p = 1$','AC current constraint','DC current constraint','All points','Interpreter','latex')

figure(67), axis square, hold on, grid on, box on
    fcn_plot_ilimit(Vs,Iaclimit)
    fcn_plot_idclimit(U_dc)
    plot(Ps/1000,Qs/1000,'.','Color',"#EBEBEB") % all points
xlabel('$P_s$ [kW]','interpreter','latex')
ylabel('$Q_s$ [kVAr]','interpreter','latex')

xlim([-0.8, 0.8])
ylim([-0.8, 0.8])
legend('AC current constraint','DC current constraint','All points','Interpreter','latex')

%Simulated constraints plot
figure(68), axis square, hold on, grid on, box on
    plot(Ps/1000,Qs/1000,'.','Color',"#EBEBEB") % all points
    fcn_plot_mlimit(Vs,U_dc,Fnom,Rf,Lf,1)
    plot(P_IL_all/1000,Q_IL_all/1000,'.b','MarkerSize',9) % IL RMS limit
    plot(P_If_all/1000,Q_If_all/1000,'.r','MarkerSize',9) % If RMS limit
    plot(P_IMOS_all/1000,Q_IMOS_all/1000,'.c','MarkerSize',9) % IMOS RMS limit
    plot(P_dIL_all/1000,Q_dIL_all/1000,'.m','MarkerSize',9) % IMOS RMS limit
    plot(P_Tj/1000,Q_Tj/1000,'.g') % Temperature limit
xlabel('$P_s$ [kW]','interpreter','latex')
ylabel('$Q_s$ [kVAr]','interpreter','latex')

xlim([-100, 100])
ylim([-100, 100])
legend('All points','Theorical $M_p = 1$','$I_L < '+string(Il_lim)+'$ A rms','$I_f < '+string(If_lim)+'$ A rms','$I_{MOS} < '+string(Imos_lim)+'$ A rms','$\Delta I_L < '+string(Iripple_lim)+'$ A','$T_J < '+string(Tj_lim)+'$ K','Interpreter','latex')

figure(69), axis square, hold on, grid on, box on
    fcn_plot_ilimit(Vs,Iaclimit)
    fcn_plot_idclimit(U_dc)
    plot(Ps/1000,Qs/1000,'.','Color',"#EBEBEB") % all points
    plot(P_IL_all/1000,Q_IL_all/1000,'.b','MarkerSize',9) % IL RMS limit
    plot(P_If_all/1000,Q_If_all/1000,'.r','MarkerSize',9) % IL RMS limit
    plot(P_IMOS_all/1000,Q_IMOS_all/1000,'.c','MarkerSize',9) % IMOS RMS limit
    plot(P_dIL_all/1000,Q_dIL_all/1000,'.m','MarkerSize',9) % IMOS RMS limit
    plot(P_Tj/1000,Q_Tj/1000,'.g') % Temperature limit
xlabel('$P_s$ [kW]','interpreter','latex')
ylabel('$Q_s$ [kVAr]','interpreter','latex')
xlim([-1, 1])
ylim([-1, 1])
legend('All points','$I_L < '+string(Il_lim)+'$ A rms','$I_f < '+string(If_lim)+'$ A rms','$I_{MOS} < '+string(Imos_lim)+'$ A rms','$\Delta I_L < '+string(Iripple_lim)+'$ A','$T_J < '+string(Tj_lim)+'$ K','Interpreter','latex')

%Colormaps according to current value
figure(70), axis square, hold on, grid on, box on

scatter(Ps/1000, Qs/1000, 20, rmsIL, 'filled') % color based on rmsIL

xlabel('$P_s$ [kW]','interpreter','latex')
ylabel('$Q_s$ [kVAr]','interpreter','latex')

xlim([-100, 100])
ylim([-100, 100])

colormap(jet)       % choose colormap
colorbar            % show color scale
c = colorbar;
c.Label.String = '$I$ [A rms]';
c.Label.Interpreter = 'latex';

figure(71), axis square, hold on, grid on, box on

scatter(Ps(ind_PQ_low)/1000, Qs(ind_PQ_low)/1000, 20, rmsIL(ind_PQ_low), 'filled') % color based on rmsIL
xlabel('$P_s$ [kW]','interpreter','latex')
ylabel('$Q_s$ [kVAr]','interpreter','latex')

xlim([-3.5, 3.5])
ylim([-3.5, 3.5])

colormap(jet)       % choose colormap
colorbar            % show color scale
c = colorbar;
c.Label.String = '$I$ [A rms]';
c.Label.Interpreter = 'latex';
end

