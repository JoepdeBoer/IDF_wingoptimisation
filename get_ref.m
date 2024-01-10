function ref = get_ref()
    Au = [0.233657473793488	0.0799311311431370	0.267480351078855	0.0897753764779299	0.277977484145020	0.381590212828450];
    Al = [-0.225334607742923	-0.163728263890913	-0.0463343730922910	-0.477955820288272	0.0741479732319931	0.325206660477090];
    b = 34.09;              % Wing span [m]
    c_r = 7;                % Root chord [m]
    lambda = 0.234;         % Taper ratio [-]
    Lambda_LE = 24.506;     % Leading edge sweep [m]
    
    M_cr = 0.78;            % Cruise mach number [-]
    h_cr = 11278;           % Cruise altitude [m]
    LD = 16.3;              % Target variable lift/drag ratio [-] https://arc.aiaa.org/doi/pdf/10.2514/6.2005-121
    W_fuel = 18205;         % Target variable W_fuel [kg]
    W_wing = 8429.9;        % Target variable W_wing [kg]
    
    % Store reference values
    ref(1) = b;
    ref(2) = c_r;
    ref(3) = lambda;
    ref(4) = Lambda_LE;
    ref(5:10) = Au;
    ref(11:16) = Al;
    ref(17) = M_cr;
    ref(18) = h_cr;
    % Target variables reference
    ref(19) = LD;
    ref(20) = W_fuel;
    ref(21) = W_wing;
end
