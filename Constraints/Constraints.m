function [c, cc] = Constraints(x, constant, res)

% Define descipline results
LD = res.LD;
W_fuel = res.W_fuel;
W_wing = res.W_wing;

% Define required design variables
b = x(1);
c_r = x(2);
lambda = x(3);
Lambda_LE = x(4);
c_t = c_r*lambda;
s0 = constant.s0;
b_k = c_r-s0*tand(Lambda_LE);

% Constraints
S = (b_k*(c_r+c_t)+b/2*(c_t-c_r-s0*tand(Lambda_LE)))/2;
Lambda25_in = atand(3/4*s0*tand(Lambda_LE)/s0);
Lambda25_out = atand((1/4*c_r*(lambda-1)*tand(Lambda_LE)*(b/2+3/4*s0))/(b/2-s0));
W_TO_max = constant.W_aw+W_fuel+W_wing;
C_L_cr = 2*W_TO_max*9.81/(rho*V^2*S);

if Lambda25_in>Lambda25_out
    Lambda_25 = Lambda_in;
else
    Lambda_25 = Lambda_out;
end

cc1 = LD-x(19);
cc2 = W_fuel-x(20);
cc3 = W_wing-x(21);
cc = [cc1, cc2, cc3];    % Consistency constraints

c1 = W_TO_max/S - init.W_TO_max/init.S_ref;     % c1 >= ...
c2 = W_fuel/rho_fuel-V_tank*f_tank;             % c2 >= ...
c3 = C_L_cr-(0.86*cosd(Lambda_25))/1.3;         % c3 >= ...
c = [c1, c2, c3];                               % Inequality constraints