function  AC = ACcreator(X, aero_loads)
% Inputs: 
% - X: design vector NON NORMALISED!
% - aero_loads: '0' Aerodynamics / '1' Loads
% Output the AC data structure as required by Q3D for AERO

constant = get_constants();

%constants From the subsonic design book ? check the numbers TODO
dihedral = constant.dihedral; 
s0 = constant.s0;
twist1 = constant.twist_r;
twist2 = constant.twist_k;
twist3 = constant.twist_t;

%Constants to change when making consistent in reference run
W_aw = constant.W_aw * 9.81; % TODO estimate this nummber better

%renaming design vector to variables for readabillity
b = X(1); % wing span
c1 = X(2); % root chord
taper = X(3); % taperratio
sweep = X(4); % LE sweep !
kt = X(5:11); % top surface coefficients
kb = X(11:17); % bottom surface coefficients
altitude = X(18); % flight altitude (m)

%Depending on dicipline variables
if aero_loads == 1
    nmax = 2.5;
    Mach = constant.M_mo;
    W = X(20) + X(21) + W_aw; % WTO_max
    AC.visc = 0; % inviscid anlysis for loads
else
    nmax = 1;
    Mach = X(17);
    W = sqrt((X(20) + X(21) + W_aw) * ( W_aw - X(21)));% Design Weight
    AC.visc = 1; % viscid analysis for aerodynamics
end


%calculating required planform parameters
x2 = s0 * tand(sweep); % x loc of kink LE
z2 = s0 * tand(dihedral); % z loc of kink LE 
c2 = c1 - x2; % chord lenght at kink
x3 = b/2 * tand(sweep); % x loc of tip LE
z3 = b/2 * tand(dihedral); % z loc of tip LE
c3 = c1 * taper; % chord lenght of tip
taper1 = c2/c1; % taper from root to kink
taper2 = c3/c2; % taper from kink to tip

S1 = (c1 +c2)/2 * s0; % surface area inboard section
S2 = (c2+c3)/2 * (b/2 -s0); % surface area outboard section
S = (S1 + S2) * 2; % full wing surface area
mac1 = 2/3 * c1 * (1 + taper1 + taper1^2)/(1 + taper1); % mac inboard section
mac2 = 2/3 * c2 * (1 + taper2 + taper2^2)/(1 + taper2); % mac outboard section
mac = (mac1 * S1 + mac2 * S2)/(S1 + S2); % total wing mac



%Building the data structure
AC.Aero.M = Mach;  % flight Mach number for loads NOT FOR AERO!!
%                x    y     z   chord(m)    twist angle (deg) 
AC.Wing.Geom = [0     0     0     c1   twist1;
                  x2   s0   z2    c2   twist2;
                  x3   b/2  z3    c3   twist3];

AC.Wing.Airfoils    = [kt,kb;
                       kt,kb];
AC.Wing.inc  = 0;              % Wing incidence angle (degree)
AC.Wing.eta = [0;1];           % Spanwise location of the airfoil sections
AC.Aero.MaxIterIndex = 150;    %Maximum number of Iteration for the
                               %convergence of viscous calculatio TODO
                               %inviscid so is this required?

% Flight Condition
AC.Aero.alt  = altitude;

% Use for newer MATLAB version
% [~,a, ~, rho, nu] = atmosisa(AC.Aero.alt); % standard atmosphere calcs

% Use for old MATLAB version
[~,a, ~, rho] = atmosisa(AC.Aero.alt);      % standard atmosphere calcs
nu = 1.45e-5;                               % Kinematic viscosity [N s/m^2]

AC.Aero.V     = AC.Aero.M * a;              % flight speed (m/s)
AC.Aero.rho   = rho;                        % air density  (kg/m3)
AC.Aero.Re    = AC.Aero.V  * mac / nu ;     % reynolds number (based on mac)
AC.Aero.CL    = nmax *  2 * W / rho / AC.Aero.V^2 / S; % CL

end