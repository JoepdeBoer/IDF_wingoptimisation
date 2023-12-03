function [W_fuel] = Performance(x, constant, ref)

% Design variables
M = x(17);      % Mach number [-]
h = x(18);      % Altitude [m]

M_cr_ref = ref(17);     % Mach number reference [-]
h_cr_ref = ref(18);     % Altitude reference [m]

[~,a] = atmosisa(h); % standard atmosphere calcs
[~,a_ref] = atmosisa(h_cr_ref); % standard atmosphere calcs
V = M*a;
V_cr_ref = M_cr_ref*a_ref;

eta = exp(-((V-V_cr_ref)^2/(2*70^2))-((h-h_cr_ref)^2/(2*2500^2)));
C_T_specific = 1.8639e-4;           % Specific fuel consumption [1/s]
C_T = C_T_specific/eta;
W_fuel = (exp(constant.R*x(19)^(-1)*C_T/V)/0.938-1)*(constant.W_aw+x(21));  

end