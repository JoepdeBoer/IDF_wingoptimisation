function [CO2] = IDF_optimiser(X)
    %% Design variables
    airfoil = 'withcomb135';
    b = 34.09;              % Wing span [m]
    c_r = 6.1;              % Root chord [m]
    lambda = 0.269;         % Taper ratio [-]
    Lambda_LE = 24.506;     % Leading edge sweep [m]
    M_cr = 0.78;            % Cruise mach number [-]
    h_cr = 11278;           % Cruise altitude [m]
    LD = 18.76;             % Target variable lift/drag ratio [-]
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

    % Denormalising 
    Design = X.*ref; % element whise multiplication
    % Initial guesses of discipline outputs
    LD_guess = X(19);
    W_fuel_guess = X(20);
    W_wing_guess = X(21);

    % Discilplines
    global couplings;
    couplings.LD = Aerodynamics(Design);
    couplings.W_fuel = Performance(Design, constant, reference);
    Loads(Design, constant);
    couplings.W_wing = Structures();

    % Objective function 
    CO2 = 3.16 * couplings.W_fuel;

end
    
