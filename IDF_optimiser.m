function [CO2_nd] = IDF_optimiser(X)
    %load('ref.mat');
    %load('constant.mat');
    ref = get_ref();
    constant = get_constants();

    % Denormalising 
    Design = X.*ref; % element whise multiplication

    % Discilplines
    global couplings;
    couplings.LD = Aerodynamics(Design)
    couplings.W_fuel = Performance(Design, constant, ref);
    Loads(Design);
    couplings.W_wing = Structures();

    % Objective function 
    CO2 = 3.16 * couplings.W_fuel;
    CO2_nd = couplings.W_fuel/ref(20);

end
    
