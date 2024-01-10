addpath(genpath('Constraints')); addpath(genpath('Disciplines')); addpath(genpath('Storage')); addpath(genpath('matlab-jsystem-master')); addpath(genpath('postprocessing'));

% Loading constant and ref
constant = get_constants();
ref = get_ref();

%% Inputs
airfoil = 'withcomb135';        % Specify name of initial airfoil coordinate .dat file
[Au, Al] = AirfoilFit(airfoil);     % Approximate Bernstein coefficients [-]

%% Create design vector (normalised)
x0(1:21) = 1;

% Bounds
lb(1) = 24/ref(1);
lb(2) = 0.75;
lb(3) = 0.1/ref(3);
lb(4) = 0.5/ref(4);
lb(5:10) =  1 - 0.2./abs(ref(5:10));
lb(11:14) = 1 - 0.2./abs(ref(11:14));
lb(15:16) = 1 - 0.2./abs(ref(15:16));
lb(17) = 0.9;
lb(18) = 0.9;
lb(19) = 0.8;
lb(20) = 0.5;
lb(21) = 0.5;

ub(1) = 52/ref(1);
ub(2) = 1.25;
ub(3) = 1/ref(3);
ub(4) = 48.5/ref(4);
ub(5:10) =  1 + 0.2./abs(ref(5:10));
ub(11:14) = 1 + 0.2./abs(ref(11:14));
ub(15:16) = 1 + 0.2./abs(ref(15:16));
ub(17) = 1.1;
ub(18) = 1.1;
ub(19) = 1.2;
ub(20) = 2;
ub(21) = 2;

%% Initial run
% global couplings
% [couplings.LD, Res] = Aerodynamics(x0.*ref);
% couplings.W_fuel = Performance(x0.*ref, constant, ref);
[L, M_c4, AC] = Loads(x0.*ref);
% couplings.W_wing = Structures();
% constant.W_aw = constant.W_TO_max_ref - couplings.W_wing - couplings.W_fuel;
% [c, cc] = Constraints(x0.*ref)
% V_tank = TankVolume(x0.*ref, constant);

%% Reference planform plot
figure
plot([AC.Wing.Geom(1,1), AC.Wing.Geom(2,1), AC.Wing.Geom(3,1), AC.Wing.Geom(3,1)+AC.Wing.Geom(3,4)], [AC.Wing.Geom(1,2), AC.Wing.Geom(2,2), AC.Wing.Geom(3,2), AC.Wing.Geom(3,2)], 'k', 'linewidth', 1); hold on
plot([AC.Wing.Geom(1,1)+AC.Wing.Geom(1,4), AC.Wing.Geom(2,1)+AC.Wing.Geom(2,4), AC.Wing.Geom(3,1)+AC.Wing.Geom(3,4)], [AC.Wing.Geom(1,2), AC.Wing.Geom(2,2), AC.Wing.Geom(3,2)], 'k', 'linewidth', 1); hold on
title('Reference wing planform')
xlabel('x [m]')
ylabel('y [m]')
axis([-5, 15, 0, 20])
pbaspect([1 1 1])

%% Optimisation
start_timer = tic;
[xsol, fval, exitflag, output, lambda, history, searchdir] = runfmincon(x0, lb, ub);
optimisation_time = toc(start_timer);

%% Optimized planform plot
AC = ACcreator(xsol.*ref, 1);

figure
plot([AC.Wing.Geom(1,1), AC.Wing.Geom(2,1), AC.Wing.Geom(3,1), AC.Wing.Geom(3,1)+AC.Wing.Geom(3,4)], [AC.Wing.Geom(1,2), AC.Wing.Geom(2,2), AC.Wing.Geom(3,2), AC.Wing.Geom(3,2)], 'k', 'linewidth', 1); hold on
plot([AC.Wing.Geom(1,1)+AC.Wing.Geom(1,4), AC.Wing.Geom(2,1)+AC.Wing.Geom(2,4), AC.Wing.Geom(3,1)+AC.Wing.Geom(3,4)], [AC.Wing.Geom(1,2), AC.Wing.Geom(2,2), AC.Wing.Geom(3,2)], 'k', 'linewidth', 1); hold on
title('Optimized wing planform')
xlabel('x [m]')
ylabel('y [m]')
axis([-5, 15, 0, 20])
pbaspect([1 1 1])

%% Optimised airfoil and wing plot
airfoilPlot(xsol, Au, Al);

%% Lift and drag distribution plots

% Cruise conditions aerodynamics viscous
[~, Res_cruise] = Aerodynamics(x0.*ref); % ref
[~, FinalRes_cruise] = Aerodynamics(xsol.*ref); % solu

% Critical conditions viscous...
critical_plane = ACcreator(x0.*ref, 1); % sets critical conditions but automatically inviscid
critical_plane.Visc = 0 ;               % sets it back to viscous
Res_crit = Q3D_solver(critical_plane);  % ref

critical_plane = ACcreator(xsol.*ref, 1); % sets critical conditions but automatically inviscid
critical_plane.Visc = 0 ;                 % sets it back to viscous
FinalRes_crit = Q3D_solver(critical_plane); % solu

%% plotting Lift curves
figure % Lift cruise
hold on; % Hold the current plot
a1 = plot(Res_cruise.Wing.Yst, Res_cruise.Wing.ccl,":o"); label1 = 'initial';
% scatter(Res_cruise.Wing.Yst, Res_cruise.Wing.ccl, 50, 'r');  % Scatter plot with red 

a2 = plot(FinalRes_cruise.Wing.Yst, FinalRes_cruise.Wing.ccl, "-o"); label2 = 'optimised';
% scatter(FinalRes_cruise.Wing.Yst, FinalRes_cruise.Wing.ccl, 50, 'r');  % Scatter plot with red 

legend(label1, label2);
title('Lift distribution Design Point')
xlabel('spanwise location [m]');
ylabel('$C_l \cdot c$ [m]', 'Interpreter', 'Latex');
ylim([0, Inf]);
hold off; % Release the current plot


figure % Lift at max loading
hold on; 
a1 = plot(Res_crit.Wing.Yst, Res_crit.Wing.ccl,':o' ); label1 = "initial";
% scatter(Res_crit.Wing.Yst, Res_crit.Wing.ccl, 50, 'red');

a2 = plot(FinalRes_crit.Wing.Yst, FinalRes_crit.Wing.ccl,'-o' ); label2 = "optimised";
% scatter(FinalRes_crit.Wing.Yst, FinalRes_crit.Wing.ccl, 50, 'red');

legend(label1, label2);
title('Lift distribution Critical Loading Point')
xlabel('spanwise location [m]');
ylabel('$C_l \cdot c$ [m]', 'Interpreter', 'Latex');
ylim([0, Inf]);
hold off;


%% prep drag curves
Final_chord = FinalRes_cruise.Wing.chord;
Initial_chord = Res_cruise.Wing.chord;

Finalsectionchord = chord(xsol.*ref, FinalRes_cruise.Section.Y);
Initialsectionchord = chord(x0.*ref, Res_cruise.Section.Y);

%induced drag
cdi_init = Res_cruise.Wing.cdi.*Initial_chord; 
cdi_opt  = FinalRes_cruise.Wing.cdi.*Final_chord;

%interpolated values as the sections dont match up
cdi_init_inter = interp1(Res_cruise.Wing.Yst,Res_cruise.Wing.cdi, Res_cruise.Section.Y, "linear", "extrap").* Initialsectionchord;
cdi_opt_inter = interp1(FinalRes_cruise.Wing.Yst,FinalRes_cruise.Wing.cdi, FinalRes_cruise.Section.Y, 'linear','extrap').* Finalsectionchord;

%profile/wave
cdp_init = Res_cruise.Section.Cd'.*Initialsectionchord;
cdp_opt = FinalRes_cruise.Section.Cd'.*Finalsectionchord;

%Total 
cdtot_init = cdi_init_inter + cdp_init;
cdtot_opt = cdi_opt_inter + cdp_opt;



%%
figure % Drag and components at cruise
hold on;

a1 = plot(Res_cruise.Wing.Yst, cdi_init, '--o', 'Color', 'red', MarkerSize=20); label1 = "induced drag initial";
a2 = plot(Res_cruise.Section.Y, cdp_init, ':x','Color', 'red',MarkerSize=20); label2 = "profile + wave drag initial";
a3 = plot(Res_cruise.Section.Y, cdtot_init, ':*', 'Color', 'red',MarkerSize=20); label3 = "total initial";
a4 = plot(FinalRes_cruise.Wing.Yst, cdi_opt, '--square', 'Color', 'black',MarkerSize=20); label4 = "induced drag optimised";
a5 = plot(FinalRes_cruise.Section.Y, cdp_opt, ':v', 'Color', 'black',MarkerSize=20); label5 = "profile + wave drag optimised";;
a6 = plot(FinalRes_cruise.Section.Y, cdtot_opt, 'Color', 'black',MarkerSize=20); label6 = "total optimised";


legend(label1,label2, label3, label4,label5, label6);
title('Drag Distribution, profile induced and total ')
xlabel('spanwise location [m]');
ylabel('$C_d \cdot c$ [m]', 'Interpreter', 'latex');
ylim([-0.05, 0.35]);
hold off;

%% Constraints evoluation
plotHistory(history);
