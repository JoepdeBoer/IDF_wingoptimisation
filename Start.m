addpath(genpath('Constraints')); addpath(genpath('Disciplines')); addpath(genpath('Storage')); addpath(genpath('matlab-jsystem-master'));

% Loading constant and ref
constant = get_constants();
ref = get_ref();

%% Inputs
airfoil = 'withcomb135';        % Specify name of initial airfoil coordinate .dat file


[Au, Al] = AirfoilFit(airfoil);     % Approximate Bernstein coefficients [-]

% Create design vector (normalised)
x0(1:4) = 1;
x0(5:10) = Au; % non normalised airfoil 
x0(11:16) = Al;
x0(17:21) = 1;

% Bounds
lb(1) = 24/ref(1);
lb(2) = 0.75;
lb(3) = 0.1/ref(3);
lb(4) = 0.5/ref(4);
lb(5:10) = x0(5:10)-0.2;
lb(11:16) = x0(11:16)-0.2;
lb(17) = 0.9;
lb(18) = 0.9;
lb(19) = 0.5;
lb(20) = 0.5;
lb(21) = 0.5;

ub(1) = 52/ref(1);
ub(2) = 1.25;
ub(3) = 0.5/ref(3);
ub(4) = 48.5/ref(4);
ub(5:10) = x0(5:10)+0.2;
ub(11:16) = x0(11:16)+0.2;
ub(17) = 1.1;
ub(18) = 1.1;
ub(19) = 2;
ub(20) = 2;
ub(21) = 2;

%% Other variables
OEW = 3.1485e+04+x0(21)*ref(21);     % Operational empty weight [kg]

%% Initial run
global couplings
[couplings.LD, CD_aw, Res] = Aerodynamics(x0.*ref); 

[L, M_c4, AC] = Loads(x0.*ref);
couplings.W_wing = Structures();
constant.W_aw = constant.W_TO_max_ref - couplings.W_wing - ref(20);
couplings.W_fuel = Performance(x0.*ref, constant, ref);
% [c, cc] = Constraints(x0.*ref);
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
tic;
[xsol, fval, history, searchdir] = runfmincon(x0, lb, ub);
t=toc;

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

%% Optimised airfoil plot
airfoilPlot(xsol, Au, Al);