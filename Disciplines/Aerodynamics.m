% Aerodynamics Discipline
% Input the design vector, guess for Wf, guess for Wwing
% Output L/D
function LD = Aerodymanics(X, Wf, Wwing)
    % change Wf, Wwing with constant struct??
    AC = ACcreator(X, Wf, Wwing, 0)
    Res = Q3D_solver(AC)
    LD = Res.CLwing/Res.CDiwing
end

