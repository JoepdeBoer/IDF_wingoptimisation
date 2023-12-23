% Aerodynamics Discipline
% Input the design vector, guess for Wf, guess for Wwing
% Output L/D
function [LD, Res] = Aerodynamics(X)
    % change Wf, Wwing with constant struct??
    AC = ACcreator(X, 0);
    Res = Q3D_solver(AC);  
    constant = get_constants();
    LD = Res.CLwing/(Res.CDwing+constant.CD_aw);
    % hello
end