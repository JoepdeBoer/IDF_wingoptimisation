function [c, cc] = Constraints(x)
% Input:
% x: normalised design vector

%load('constant.mat');
%load('ref.mat');
constant = get_constants();
ref = get_ref();

% Define descipline results
global couplings;
LD = couplings.LD;
W_fuel = couplings.W_fuel;
W_wing = couplings.W_wing;

% Define required design variables s0
b = x(1)*ref(1);
c_r = x(2)*ref(2);
lambda = x(3)*ref(3);
Lambda_LE = x(4)*ref(4);
c_t = c_r*lambda;
s0 = constant.s0;
c_k = c_r-s0*tand(Lambda_LE)+s0*tand(constant.sweepTE);
AC = ACcreator(x.*ref, 0);

% Calculating planform
S1 = (c_r +c_k)/2 * s0;
S2 = (c_k+c_t)/2 * (b/2 -s0);
S = (S1 + S2) * 2;

% Constraints
Lambda25_in = atand(3/4*s0*tand(Lambda_LE)/s0);
Lambda25_out = atand((1/4*c_r*(lambda-1)*tand(Lambda_LE)*(b/2+3/4*s0))/(b/2-s0));
W_TO_max = constant.W_aw+W_fuel+W_wing;
C_L_cr = 2*W_TO_max*9.81/(AC.Aero.rho*AC.Aero.V^2*S);

if Lambda25_in>Lambda25_out
    Lambda_25 = Lambda25_in;
else
    Lambda_25 = Lambda25_out;
end

% Fuel tank volume
V_tank = TankVolume(x.*ref, constant);

cc1 = x(19)-LD/ref(19);
cc2 = x(20)-W_fuel/ref(20);
cc3 = x(21)-W_wing/ref(21);
cc = [cc1, cc2, cc3]    % Consistency constraints

c1 = (W_TO_max/S)/(constant.W_TO_max_ref/constant.S_ref) - 1;       % c1 >= ...
c2 = (W_fuel/constant.rho_fuel-V_tank*constant.f_tank)/(constant.W_fuel_ref/constant.rho_fuel-constant.V_tank_ref*constant.f_tank);     % c2 >= ...
c3 = (C_L_cr-(0.86*cosd(Lambda_25))/1.3)/(constant.C_L_cr_ref-(0.86*cosd(constant.Lambda_25_ref))/1.3);     % c3 >= ...
c = [c1, c2, c3]   % Inequality constraints