% Aerodynamics Discipline
% Input the design vector, guess for Wf, guess for Wwing
% Output L/D
function [LD, C_D_aw] = Aerodynamics(X)
    % change Wf, Wwing with constant struct??
    AC = ACcreator(X, 0);
    Res = Q3D_solver(AC);    
    LD_wing = Res.CLwing/Res.CDwing;
    C_D_aw = Res.CLwing*1/X(19)-Res.CDwing;
    LD = Res.CLwing/(Res.CDwing+C_D_aw);
    % hello
end