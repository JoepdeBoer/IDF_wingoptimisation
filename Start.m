addpath(genpath('Constraints')); addpath(genpath('Disciplines')); addpath(genpath('Storage')); addpath(genpath('matlab-jsystem-master'));

% Loading constant and ref
constant = get_constants();
ref = get_ref();

%% Inputs
airfoil = 'withcomb135';        % Specify name of initial airfoil coordinate .dat file
[Au, Al] = AirfoilFit(airfoil);     % Approximate Bernstein coefficients [-]

% Create design vector (normalised)
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
lb(19) = 0.5;
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
ub(19) = 2;
ub(20) = 2;
ub(21) = 2;

%% Other variables
OEW = 3.1485e+04+x0(21)*ref(21);     % Operational empty weight [kg]

%% Initial run
global couplings
[couplings.LD, Res] = Aerodynamics(x0.*ref);
couplings.W_fuel = Performance(x0.*ref, constant, ref);
[L, M_c4, AC] = Loads(x0.*ref);
couplings.W_wing = Structures();
constant.W_aw = constant.W_TO_max_ref - couplings.W_wing - couplings.W_fuel;
% [c, cc] = Constraints(x0.*ref)
V_tank = TankVolume(x0.*ref, constant);

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
airfoilPlot(x0, Au, Al);

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

% plotting 
figure % Lift cruise
hold on; % Hold the current plot
a1 = plot(Res_cruise.Wing.Yst, Res_cruise.Wing.ccl); label1 = 'initial';
scatter(Res_cruise.Wing.Yst, Res_cruise.Wing.ccl, 50, 'r');  % Scatter plot with red 

a2 = plot(FinalRes_cruise.Wing.Yst, FinalRes_cruise.Wing.ccl); label2 = 'optimised';
scatter(FinalRes_cruise.Wing.Yst, FinalRes_cruise.Wing.ccl, 50, 'r');  % Scatter plot with red 

legend([a1,a2],[label1, label2]);
title('Lift distribution Design Point')
xlabel('spanwise location [m]');
ylabel('$C_l \cdot c$ [m]', 'Interpreter', 'Latex');
ylim([0, Inf]);
hold off; % Release the current plot


figure % Lift at max loading
hold on; 
a1 = plot(Res_crit.Wing.Yst, Res_crit.Wing.ccl ); label1 = "initial";
scatter(Res.Wing.Yst, Res_crit.Wing.ccl, 50, 'red');

a2 = plot(FinalRes_crit.Wing.Yst, FinalRes_crit.Wing.ccl ); label2 = "optimised";
scatter(FinalRes_crit.Wing.Yst, FinalRes_crit.Wing.ccl, 50, 'red');

legend([a1,a2],[label1, label2]);
title('Lift distribution Critical Loading Point')
xlabel('spanwise location [m]');
ylabel('$C_l \cdot c$ [m]', 'Interpreter', 'Latex');
ylim([0, Inf]);
hold off;

Final_chord = FinalRes_cruise.Wing.ccl./FinalRes_cruise.Wing.cl;
Initial_chord = Res_cruise.Wing.ccl./Res_cruise.Wing.cl;


figure % Drag and components at cruise
hold on;

cdi_init = Res_cruise.Wing.cdi.*Initial_chord; 
cdi_opt  = FinalRes_cruise.Wing.cdi.*Final_chord;

cdp_init = Res_cruise.Section.Cd.*Initial_chord;
cdp_opt = FinalRes.Section.Cd.*Final_chord;

cdtot_init = cdi_init + cdp_init;
cdtot_opt = cdi_opt + cdp_opt;


a1 = plot(Res_cruise.Wing.Yst, cdi_init); label1 = "induced drag initial";
scatter(Res_cruise.Wing.Yst, cdi_init, 50, 'red');

a2 = plot(Res.Section.Y, cdp_init); label2 = "profile + wave drag initial";
scatter(Res.Section.Y, cdp_init, 50, 'black');

a3 = plot(Res.Section.Y, cdtot_init); label3 = "total initial";
scatter(Res.Section.Y, cdtot_init, 50, 'black');

a4 = plot(FinalRes_cruise.Wing.Yst, cdi_opt); label4 = "induced drag optimised";
scatter(FinalRes_cruise.Wing.Yst, cdi_opt, 50, 'red');

a5 = plot(FinalRes.Section.Y, cdp_opt); label5 = "profile + wave drag optimised";
scatter(FinalRes.Section.Y, cdp_opt, 50, 'black');

a6 = plot(FinalRes.Section.Y, cdtot_opt); label6 = "total optimised";
scatter(FinalRes.Section.Y, cdtot_opt, 50, 'black');

legend([a1,a2,a3,a4,a5,a6],[label1, label2, label3, label4, label5, label6]);
title('Drag Distribution, profile induced and total ')
xlabel('spanwise location [m]');
ylabel('$C_d \cdot c$ [m]', 'Interperter', 'Latex');
ylim([0, Inf]);
hold off;

%% Constraints evoluation
plotHistory(history);
