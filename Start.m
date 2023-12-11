addpath(genpath('Constraints')); addpath(genpath('Disciplines'));

%% Inputs
airfoil = 'withcomb135';        % Specify name of initial airfoil coordinate .dat file

%% Design variables
b = 34.09;              % Wing span [m]
c_r = 6.1;              % Root chord [m]
lambda = 0.269;         % Taper ratio [-]
Lambda_LE = 24.506;     % Leading edge sweep [m]
[Au, Al] = AirfoilFit(airfoil);     % Approximate Bernstein coefficients [-]
M_cr = 0.78;            % Cruise mach number [-]
h_cr = 11278;           % Cruise altitude [m]
LD = 18.76;             % Target variable lift/drag ratio [-]
W_fuel = 17940;         % Target variable W_fuel [kg]
W_wing = 6445.3836;     % Target variable W_wing [kg]

% Store reference values
ref(1) = b;
ref(2) = c_r;
ref(3) = lambda;
ref(4) = Lambda_LE;
ref(5:10) = 1;
ref(11:16) = 1;
ref(17) = M_cr;
ref(18) = h_cr;
% Target variables reference
ref(19) = LD;
ref(20) = W_fuel;
ref(21) = W_wing;
% Create design vector (normalised)
x0(1) = b/ref(1);
x0(2) = c_r/ref(2);
x0(3) = lambda/ref(3);
x0(4) = Lambda_LE/ref(4);
x0(5:10) = Au./ref(5:10);
x0(11:16) = Al./ref(11:16);
x0(17) = M_cr/ref(17);
x0(18) = h_cr/ref(18);
% Target variables
x0(19) = LD/ref(19);
x0(20) = W_fuel/ref(20);
x0(21) = W_wing/ref(21);

% Bounds
lb(1) = 24/ref(1);
lb(2) = 0.75;
lb(3) = 0.1/ref(3);
lb(4) = 0.5/ref(4);
lb(5:10) = x0(5:10)-0.2;
lb(11:16) = x0(11:16)-0.2;
lb(17) = 0.9;
lb(18) = 0.9;

ub(1) = 52/ref(1);
ub(2) = 1.25;
ub(3) = 1/ref(3);
ub(4) = 31.9/ref(4);
ub(5:10) = x0(5:10)+0.2;
ub(11:16) = x0(11:16)+0.2;
ub(17) = 1.1;
ub(18) = 1.1;

%% Constants
constant = get_constants();

%% Other variables
OEW = 3.1485e+04+x0(21)*ref(21);     % Operational empty weight [kg]

%% Initial run
global couplings
[couplings.LD, C_D_aw] = Aerodynamics(x0.*ref);

[L, M_c4, AC] = Loads(x0.*ref);
couplings.W_wing = Structures;
constant.W_aw = constant.W_TO_max_ref - W_wing - W_fuel;
couplings.W_fuel = Performance(x0.*ref, constant, ref);
[c, cc] = Constraints(x0.*ref, ref);
V_tank = TankVolume(x0.*ref, constant);

%% Wing planform plot
figure
plot([AC.Wing.Geom(1,1), AC.Wing.Geom(2,1), AC.Wing.Geom(3,1), AC.Wing.Geom(3,1)+AC.Wing.Geom(3,4)], [AC.Wing.Geom(1,2), AC.Wing.Geom(2,2), AC.Wing.Geom(3,2), AC.Wing.Geom(3,2)], 'k', 'linewidth', 1); hold on
plot([AC.Wing.Geom(1,1)+AC.Wing.Geom(1,4), AC.Wing.Geom(2,1)+AC.Wing.Geom(2,4), AC.Wing.Geom(3,1)+AC.Wing.Geom(3,4)], [AC.Wing.Geom(1,2), AC.Wing.Geom(2,2), AC.Wing.Geom(3,2)], 'k', 'linewidth', 1); hold on
title('Wing planform')
xlabel('x [m]')
ylabel('y [m]')
axis([-5, 15, 0, 20])
pbaspect([1 1 1])

%% Optimisation
% Options for optimization
options.Display         = 'iter-detailed';
options.Algorithm       = 'sqp';
options.FunValCheck     = 'off';
options.DiffMinChange   = 1e-6;         % Minimum change while gradient searching
options.DiffMaxChange   = 5e-2;         % Maximum change while gradient searching
options.TolCon          = 1e-6;         % Maximum difference between two subsequent constraint vectors [c and ceq]
options.TolFun          = 1e-6;         % Maximum difference between two subsequent objective value
options.TolX            = 1e-6;         % Maximum difference between two subsequent design vectors
options.MaxIter         = 30;           % Maximum iterations

[x, FVAL, EXITFLAG, OUTPUT] = fmincon(@(x) IDF_optimiser(x), x0, [], [], [], [], lb, ub, @(x) Constraints(x), options)