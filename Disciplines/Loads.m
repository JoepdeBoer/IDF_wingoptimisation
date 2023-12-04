function [L, M_c4] = Loads(x, constant)

%% Loads
filename = 'A320';      % Filename for .INIT, .LOAD and .weight file file

% Flight conditions
M = constant.M_mo;      % Mach number [-]
h = x(18);              % Altitude [m]

% Properties
W_TO_max = 73500;       % Maximum take-off weight [kg]
ZFW = 3.1485e+04+x(21)+constant.payload_max;    % Zero-fuel weight [kg]
b = x(1);
c1 = x(2);
taper = x(3);
sweep = x(4);
kt = x(5:10);
kb = x(11:16);
dihedral = constant.dihedral;
s0 = constant.s0;
twist1 = constant.twist_r;
twist2 = constant.twist_k;
twist3 = constant.twist_t;
front_spar = constant.spar_front;
rear_spar = constant.spar_rear;
airfoil = constant.airfoil;          % Airfoil coordinate filename w/o file extension

% Wing incidence angle (degree)
AC.Wing.inc  = 0;   

%calculating required planform parameters
x2 = s0 * tand(sweep);
z2 = s0 * tand(dihedral);
c2 = c1 - x2;

x3 = b/2 * tand(sweep);
z3 = b/2 * tand(dihedral);
c3 = c1 * taper;

taper1 = c2/c1;
taper2 = c3/c2;

S1 = (c1 +c2)/2 * s0;
S2 = (c2+c3)/2 * (b/2 -s0);
S = (S1 + S2) * 2;
mac1 = 2/3 * c1 * (1 + taper1 + taper1^2)/(1 + taper1); 
mac2 = 2/3 * c2 * (1 + taper2 + taper2^2)/(1 + taper2); 
mac = (mac1 * S1 + mac2 * S2)/(S1 + S2);



% Wing planform geometry 
%                x    y     z   chord(m)    twist angle (deg) 
AC.Wing.Geom = [0     0     0     c1   twist1;
                  x2   s0   z2    c2   twist2;
                  x3   b/2  z3    c3   twist3];

AC.Wing.Airfoils    = [kt,kb;
                       kt,kb];
                  
AC.Wing.eta = [0;1];  % Spanwise location of the airfoil sections

% Viscous vs inviscid
AC.Visc  = 0;              % 0 for inviscid and 1 for viscous analysis
AC.Aero.MaxIterIndex = 150;    %Maximum number of Iteration for the
                                %convergence of viscous calculation
                                
                                
% Flight Condition
AC.Aero.alt   = h;                          % flight altitude (m)
AC.Aero.M     = M;                          % flight Mach number 
[T, a, P, rho] = atmosisa(AC.Aero.alt);     % Determine atmospheric properties at given height
nu = 1.45e-5;                               % Kinematic viscosity [N s/m^2]
AC.Aero.V     = AC.Aero.M * a;              % flight speed (m/s)
AC.Aero.rho   = rho;                        % air density  (kg/m3)
AC.Aero.Re    = AC.Aero.V  * mac / nu;      % reynolds number (bqased on mean aerodynamic chord)

%For loads CL = 
nmax = 2.5;
AC.Aero.CL    = nmax *  2 * W_TO_max * 9.81 / rho / AC.Aero.V^2 / S;   % lift coefficient - comment this line to run the code for given alpha%
%AC.Aero.Alpha = 2;             % angle of attack -  comment this line to run the code for given cl 


%% Solver
tic

Res = Q3D_solver(AC);

toc
%% Write .LOAD file
% Transform Yst
for i=1:length(Res.Wing.Yst)+1
    Yst(i) = ((Res.Wing.Yst(end)-Res.Wing.Yst(1))/(length(Res.Wing.Yst)-1))*i-((Res.Wing.Yst(end)-Res.Wing.Yst(1))/(length(Res.Wing.Yst)-1));
end

% Transform chord
c(1) = c1;
c(length(Res.Wing.Yst)+1) = c3;
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

% Calculate lift and moment
for i=1:length(Yst)
    L(i) = c(i)*cl(i)*0.5*rho*AC.Aero.V^2;
    M_c4(i) = cm_c4(i)*c(i)*mac*0.5*rho*AC.Aero.V^2;
end

% Write to txt
fid = fopen([filename, '.LOAD'], 'wt');
for i=1:length(Yst)
    fprintf(fid, '%f %f %f\n', Yst(i)/Yst(end), L(i), M_c4(i));
end

%% Write .INIT file
initFileWriter(W_TO_max, ZFW, S, b, airfoil, c1, c2, c3, AC.Wing.Geom(1,1), AC.Wing.Geom(2,1), AC.Wing.Geom(3,1), AC.Wing.Geom(1,2), AC.Wing.Geom(2,2), AC.Wing.Geom(3,2), AC.Wing.Geom(1,3), AC.Wing.Geom(2,3), AC.Wing.Geom(3,3), front_spar, rear_spar, filename)

end