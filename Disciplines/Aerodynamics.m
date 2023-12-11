% Aerodynamics Discipline
% Input the design vector, guess for Wf, guess for Wwing
% Output L/D
function LD = Aerodynamics(X)
    % change Wf, Wwing with constant struct??
    AC = ACcreator(X, 0);
    Res = Q3D_solver(AC);    
    LD = Res.CLwing/Res.CDwing;
end