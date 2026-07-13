function [] = fcn_step1_PQ_fullbridge_smallestconstraint(Vs, Fnom, U_dc, f_switching, Mmod_index, phimod_index, Iaclimit, sim_time, Ts, latest_sim_name, step_M_init,step_fine,step_phi ,end_nb,IL_lim,If_lim,Imos_lim,Iripple_lim,Tj_lim)
%FCN_STEP1_PQ_FULLBRIDGE Gets main KPIs from simulation for defining Full
%bridge converter to define its PQ diagram until the first constraint is
%activated

%initialize loop parameters
k = 0; %initialize counter

Mmod_loop = Mmod_index; %modulation amplitude at each loop (M_p)
phimod_loop = phimod_index; %modulation phase at each loop (phi_m)
phi_target = phimod_index; %modulation phase wanted for next loop
step_M = step_M_init; %step in modulation amplitude at each loop
end_criteria = true; %variable that states the end of PQ diagram scanning - true (continue), false (first constraint is activated in all quadrants)
gain_M = [1,-1,1,-1]; %gain for change in modulation amplitude according to 4 quadrants
gain_phi = [1,1,-1,-1]; %gain for change in modulation phase according to 4 quadrants
quadrant = 1; %quadrant scanned at each loop
first_of_line = false; %quadrant scanned at each loop
M = []; %modulation amplitude array that saves all M_p scanned
phi_m = []; %modulation phase array that saves all M_p scanned

%initialize figure to verify PQ diagram in real time
figure(75), axis square, hold on, grid on, box on

xlabel('$P_s$ [kW]','interpreter','latex')
ylabel('$Q_s$ [kVAr]','interpreter','latex')

xlim([-1, 1])
ylim([-1, 1])

%loop beginning
while(end_criteria)

    k = k+1; %update counter

    idx1 = find(M == Mmod_loop);
    idx2 = find(round(phi_m,4) == round(phimod_loop,4));

    if(isempty(intersect(idx1, idx2))) %verifies if the (M_p, phi_m) point was already scanned in order to avoid over simulation
        %if the (M_p, phi_m) point is NEW, we simulate it

        %get input
        phi_m(k) = phimod_loop;
        M(k) = Mmod_loop;
    
        %get X model state variables (with simulink simulation)
        mdl = latest_sim_name;
        blk = mdl + "/Sine Wave";
        set_param(blk,"Phase",string(phimod_loop))
        set_param(blk,"Amplitude",string(Mmod_loop))
    
        sim(latest_sim_name);
    
        X_loop = ans;
    
        %get model output (P and Q for this point)
        out_loop = fcn_GetPower_fullbridge(X_loop,Ts,Fnom,f_switching);
    
        %save out
        P_alpha_beta(k) = out_loop(1); %active power
        Q_alpha_beta(k) = out_loop(2); %reactive power
        P_fft_50Hz(k) = out_loop(3); %active power
        Q_fft_50Hz(k) = out_loop(4); %reactive power
    
        %get arrays from sim results
        Vcap_sim = X_loop.v_cap.signals.values; %dc capacitor voltage
        ic_sim = X_loop.i_cap.signals.values; %dc capacitor current
        IMOS_sim = X_loop.i_MOS.signals.values; %mosfet current
        VMOS_sim = X_loop.v_MOS.signals.values; %mosfet voltage
        iL_sim = X_loop.i_L.signals.values; %inductor current
        vL_sim = X_loop.v_L.signals.values; %inductor voltage
        vinv_sim = X_loop.v_conv.signals.values; %inverter generated voltage
        vL_sim = X_loop.v_L.signals.values; %inductor voltage
        vinv_sim = X_loop.v_conv.signals.values; %inverter generated voltage
        vgrid_sim = X_loop.vg.signals.values; %ac grid voltage
        v_AB_sim = X_loop.v_AB.signals.values; %ac grid voltage
    
        %calculate KPIs
        IL_ripple(k) = fcn_ripple_calc(iL_sim,f_switching,Ts); %inductor current ripple
        dVcap(k) = max(Vcap_sim)-min(Vcap_sim);
        maxVcap(k) = max(abs(Vcap_sim));
        maxIMOS(k) = max(abs(IMOS_sim));
        rmsIMOS(k) = rms(IMOS_sim);
        maxVMOS(k) = max(abs(VMOS_sim));
        maxIc(k) = max(abs(ic_sim));
        dIc(k) = rms(ic_sim/4); %divided by 4 cause we consider 4 capacitors in parallel
        rmsIL(k) = rms(iL_sim);
        maxIL(k) = max(abs(iL_sim));
        dIL(k) = max(iL_sim)-min(iL_sim);
        maxVL(k) = max(abs(vL_sim))/2; %wdivided by 2 cause we consider 2 inductors in series
        Pdc_sim(k) = mean(X_loop.Pdc.signals.values); %dc-side power in inverter convention
        TJ(k) = fcn_temperature_calc(rmsIL(k),U_dc,f_switching);
        
        constraints(1,k) = (rmsIL(k)-If_lim)/If_lim; %fuse current constraint
        constraints(2,k) = (rmsIL(k)-IL_lim)/IL_lim; %inductance current constraint
        constraints(3,k) = (rmsIMOS(k)-Imos_lim)/Imos_lim; %mosfet current constraint
        constraints(4,k) = (IL_ripple(k)-Iripple_lim)/Iripple_lim; %inductor current ripple constraint
        constraints(5,k) = (TJ(k)-Tj_lim)/Tj_lim; %mosfet temperature constraint
    
        %verifies if we are close to constraints:
        %black x point - at least one constraint is activated, setting the PQ diagram limit 
        %red point - we are in the 80% to 100% zone of at least one constraint, finer step_M is required 
        %grey point - we are below the 80% to 100% zone of all constraints, not much detail is needed so big step_M can be used
        
        if(any(constraints(:,k)>=0)) %black x point - at least one constraint is activated, setting the PQ diagram limit
            index_over = find(constraints(:,k)>0);  %finds indexes of the constraints that were activated
            plot(P_fft_50Hz(k)/1000,Q_fft_50Hz(k)/1000,'xk','MarkerSize',9) % If RMS limit
            ind_phi = find(round(phi_m,4) == round(phi_target,4));
            rmsIL(ind_phi),
            step_M = step_M_init;

            if(any(constraints(index_over,ind_phi)<0)) % if the x is not the first point for this phi_m
                % we continue the scanning with a new phase target
                phi_target = phi_target + gain_phi(quadrant)*step_phi;
                Mmod_loop = safe_M - gain_M(quadrant)*2*step_M_init;
                step_M = step_M_init; %uses the last safe point to initialize the scanning with new phase target - avoids coming back to M_p = 0

            else % if the x is the first point for this phi_m, the quadrant is fully scanned (see end criteria verification)
                step_M = step_fine;
                first_of_line = true;
            end

        elseif(any(constraints(:,k)>= -0.2) && any(constraints(:,k)<0)) %red point - we are in the 80% to 100% zone of at least one constraint, finer step_M is required 
            step_M = step_fine;
            plot(P_fft_50Hz(k)/1000,Q_fft_50Hz(k)/1000,'.r','MarkerSize',9) % If RMS limit

        else %grey point - we are below the 80% to 100% zone of all constraints, not much detail is needed so big step_M can be used
            safe_M = Mmod_loop; %marks the modulation amplitude of the last grey point achieved (safe point)
            step_M = step_M_init;
            plot(P_fft_50Hz(k)/1000,Q_fft_50Hz(k)/1000,'.','Color',"#EBEBEB",'MarkerSize',9) % all points
        end
    end

    %Update modulation amplitude for next loop
    Mmod_loop = Mmod_loop + gain_M(quadrant)*step_M;

    %Update modulation phase for next loop
    phimod_loop = phi_target;

    %verify end criteria
    if(length(rmsIL)<end_nb) %end criteria can only be applied it at least 10 points were scanned
        end_criteria = true;

    else
        if(first_of_line) % if the x is the first point for this phi_m, the quadrant is fully scanned

            if(quadrant >= 4) %if the 4th quadrant is scanned, PQ diagram is fully scanned
                end_criteria = false;

            else %update quadrant to be scanned
                quadrant = quadrant + 1;
                Mmod_loop = Mmod_index;
                safe_M = Mmod_loop;

                if(quadrant >=3) % if quadrant 3 or 4, don't pass by phase phimod_index since it was already scanned in quadrant 1 and 2
                    phimod_loop = phimod_index + gain_phi(quadrant)*step_phi;
                    phi_target = phimod_index + gain_phi(quadrant)*step_phi;
                
                else
                    phimod_loop = phimod_index;
                    phi_target = phimod_index;
                end

                step_M = step_M_init; %reset modulation amplitude step to bigger step
                end_criteria = true;
                first_of_line = false; %reset first of line variable
            end
        else
            end_criteria = true;
        end
    end

end

%% Export data
save('brutasse0','-v7.3','-nocompression')

end

