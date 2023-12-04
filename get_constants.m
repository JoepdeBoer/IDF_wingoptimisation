function constant = get_constants()
constant.s0 = 5.75;             % Kink semi-span [m]
constant.W_aw = 4.5735e4;       % Weight aircraft-wing [kg]
constant.W_TO_max_ref = 73500;  % Maximum take-off weight reference [kg]
constant.M_mo = 0.82;           % Maximum operating mach number [-]
constant.dihedral = 4.562;      % Dihedral angle [deg]
constant.twist_r = 3.8;         % Root twist [deg]
constant.twist_k = 0.6;         % Kink twist [deg]
constant.twist_t = -0.5;        % Tip twist [deg]
constant.spar_front = 0.2;      % Front spar location [x/c]
constant.spar_rear = 0.6;       % rear spar location [x/c]
constant.airfoil = 'withcomb135';     % Airfoil name
constant.payload = 14250;       % Design payload [kg]
constant.payload_max = 19190;   % Maximum payload [kg]
constant.R = 5000e3;            % Mission range [m]
constant.S_ref = 112.9059;      % Reference planform area [m^2]
constant.rho_fuel = 0.81715e3;  % Density fuel [kg/m^3]
constant.f_tank = 0.93;         % Fuel tank fraction [-]
end