function [L, M_c4, AC] = Loads(x)

AC = ACcreator(x, 1);
Res = Q3D_solver(AC);

%% Write .LOAD file
% Transform Yst
for i=1:length(Res.Wing.Yst)+1
    Yst(i) = ((Res.Wing.Yst(end)-Res.Wing.Yst(1))/(length(Res.Wing.Yst)-1))*i-((Res.Wing.Yst(end)-Res.Wing.Yst(1))/(length(Res.Wing.Yst)-1));
end

% Transform chord
c(1) = x(2);
c(length(Res.Wing.Yst)+1) = x(2)*x(3);
for i=2:length(Res.Wing.chord)
    c(i) = (Res.Wing.chord(i)+Res.Wing.chord(i-1))/2;
end

% Transform cl
cl(1) = 0.5*(Res.Wing.cl(1)-Res.Wing.cl(2))+Res.Wing.cl(1);
cl(length(Res.Wing.Yst)+1) = 0.5*(Res.Wing.cl(end)-Res.Wing.cl(end-1))+Res.Wing.cl(end);
for i=2:length(Res.Wing.Yst)
    cl(i) = Res.Wing.cl(i-1) + 0.5*(Res.Wing.cl(i)-Res.Wing.cl(i-1));
end

% Transform cm4
cm_c4(1) = 0.5*(Res.Wing.cm_c4(1)-Res.Wing.cm_c4(2))+Res.Wing.cm_c4(1);
cm_c4(length(Res.Wing.Yst)+1) = 0.5*(Res.Wing.cm_c4(end)-Res.Wing.cm_c4(end-1))+Res.Wing.cm_c4(end);
for i=2:length(Res.Wing.Yst)
    cm_c4(i) = Res.Wing.cm_c4(i-1) + 0.5*(Res.Wing.cm_c4(i)-Res.Wing.cm_c4(i-1));
end

% Use for newer MATLAB version
% [~,a, ~, rho, nu] = atmosisa(AC.Aero.alt); % standard atmosphere calcs

% Use for old MATLAB version
[T, a, ~, rho] = atmosisa(AC.Aero.alt);         % standard atmosphere calcs
mu = 1.457 * 10^-6 * T^(3/2) / (T + 110.4);     % Dynamic viscousity (Emperical)
nu = mu/rho;                                    % Kinematic viscousity
mac = AC.Aero.Re*nu/AC.Aero.V;

% Calculate lift and moment
for i=1:length(Yst)
    L(i) = c(i)*cl(i)*0.5*AC.Aero.rho*AC.Aero.V^2;
    M_c4(i) = cm_c4(i)*c(i)*mac*0.5*AC.Aero.rho*AC.Aero.V^2;
end

% Write to txt
fid = fopen(['A320', '.LOAD'], 'wt');
for i=1:length(Yst)
    fprintf(fid, '%f %f %f\n', Yst(i)/Yst(end), L(i), M_c4(i));
end

%% Write .INIT file
% initFileWriter(W_TO_max, ZFW, S, b, airfoil, c1, c2, c3, AC.Wing.Geom(1,1), AC.Wing.Geom(2,1), AC.Wing.Geom(3,1), AC.Wing.Geom(1,2), AC.Wing.Geom(2,2), AC.Wing.Geom(3,2), AC.Wing.Geom(1,3), AC.Wing.Geom(2,3), AC.Wing.Geom(3,3), front_spar, rear_spar, 'A320')
initFileWriter(x, AC, 'A320');

end