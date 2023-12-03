function [CO2, vararg] = IDF_optimiser(X)
    reference = [];
    % Denormalising 
    Design = X.*reference; % element whise multiplication
    % Initial guesses of discipline outputs
    LD_guess = X(18);
    Wf_guess = X(19);
    Wwing_guess = X(20);

    % Discilplines
    global couplings;
    couplings.LD = Aerodynamics(Design);
    couplings.W_fuel = Performance(Design,constants,reference);
    couplings.W_wing = 0; % TODO create a loads and structures function 

    % Objective function 
    CO2 = 3.16 * Wf;

end
    
