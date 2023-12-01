%% Inputs
airfoil = 'Withcomb135';        % Specify name of initial airfoil coordinate .dat file

%% Design variables
b = 34.09;              % Wing span [m]
c_r = 6.1;              % Root chord [m]
lambda = 0.269;         % Taper ratio [-]
Lambda_LE = 24.506;     % Leading edge sweep [m]
[Au, Al] = AirfoilFit(airfoil);     % Approximate Bernstein coefficients [-]
M_cr = 0.78;            % Cruise mach number [-]
h_cr = 11278;           % Cruise altitude [m]

% Store reference values
ref(1) = b;
ref(2) = c_r;
ref(3) = lambda;
ref(4) = Lambda_LE;
ref(5:10) = 1;
ref(11:16) = 1;
ref(17) = M_cr;
ref(18) = h_cr;

% Create design vector (normalised)
x0(1) = b/ref(1);
x0(2) = c_r/ref(2);
x0(3) = lambda/ref(3);
x0(4) = Lambda_LE/ref(4);
x0(5:10) = Au/ref(5:10);
x0(11:16) = Al/ref(11:16);
x0(17) = M_cr/ref(17);
x0(18) = h_cr/ref(18);

%% Constants
constant.M_mo = 0.82;           % Maximum operating mach number [-]
constant.dihedral = 4.562;      % Dihedral angle [deg]
constant.s0 = 5.75;             % Kink semi-span [m]
constant.twist_r = 3.8;         % Root twist [deg]
constant.twist_k = 0.6;         % Kink twist [deg]
constant.twist_t = -0.5;        % Tip twist [deg]
constant.spar_front = 0.2;      % Front spar location [x/c]
constant.spar_rear = 0.6;       % rear spar location [x/c]
constant.airfoil = airfoil;     % Airfoil name
constant.payload = 14250;       % Design payload [kg]
constant.payload_max = 19190;   % Maximum payload [kg]
constant.R = 5000e3;            % Mission range [m]
constant.W_aw = 4.5735e4;       % Weight aircraft-wing [kg]

%% Inital values
init.W_TO_max = 73500;

%% Target variables
target.LD = 18.76;
target.W_fuel = 17940;
target.W_wing = 9825;

%% Other variables
OEW = 3.1485e+04+target.W_wing;     % Operational empty weight [kg]

%% Initial run
[L, M_c4] = Loads(x0.*ref, constant, target);
res.W_wing = Structures;
constant.W_aw = init.W_TO_max - W_wing - target.W_fuel;
res.W_fuel = Performance(x0.*ref, constant, ref, target);
res.LD = 18;
[c, cc] = Constraints(x0.*ref, constant, res)