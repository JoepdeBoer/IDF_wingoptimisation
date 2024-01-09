% Aerodynamics Discipline
% Input the design vector, guess for Wf, guess for Wwing
% Output L/D
function [LD, Res] = Aerodynamics(X)
    % change Wf, Wwing with constant struct??
    AC = ACcreator(X, 0);
    tic
    Res = Q3D_solver(AC);  
    toc
    constant = get_constants();
    
    % CD_aw scaling with dynamic pressure
    ref = get_ref();
    [~, a_ref, ~, rho_ref] = atmosisa(ref(18));     % standard atmosphere calcs
    [~, ~, ~, rho] = atmosisa(AC.Aero.alt);         % standard atmosphere calcs
    CD_aw = constant.CD_aw*(0.5*rho*AC.Aero.V^2)/(0.5*rho_ref*(ref(17)*a_ref)^2);
    

    LD = Res.CLwing/(Res.CDwing+CD_aw);
    CD_aw_next =  Res.CLwing/LD - Res.CDwing
end