function ref = get_ref()
    b = 34.09;              % Wing span [m]
    c_r = 7;                % Root chord [m]
    lambda = 0.234;         % Taper ratio [-]
    Lambda_LE = 24.506;     % Leading edge sweep [m]
    M_cr = 0.78;            % Cruise mach number [-]
    h_cr = 11278;           % Cruise altitude [m]
    LD = 19;                % Target variable lift/drag ratio [-]
    W_fuel = 17940;         % Target variable W_fuel [kg]
    W_wing = 9825;          % Target variable W_wing [kg]
    
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
end
