function  AC = ACcreator(X, Wf, Wwing, Loads)


%input the design vector 
%output the AC data structure as required by Q3D for AERO

%constants From the subsonic design book ? check the numbers TODO
dihedral = 4.561896822; 
s0 = 5.75;
twist1 = 3.8;
twist2 = 0.6;
twist3 = -0.5;

%Constants to change when making consistent in reference run
Waw = 42220 * 9.81; % TODO estimate this nummber better

%renaming design vector to variables for readabillity
b = X(1); % wing span
c1 = X(2); % root chord
taper = X(3); % taperratio
sweep = X(4); % LE sweep !
kt = X(5:11); % top surface coefficients
kb = X(11:17); % bottom surface coefficients
altitude = X(end); % flight altitude (m)

%Depending on dicipline variables
if Loads == 1
    nmax = 2.5;
    Mach = 0.82;
    W = Wf + Wwing + Waw; % WTO_max
    AC.visc = 0 % inviscid anlysis for loads
else
    nmax = 1;
    Mach = X(17);
    W = sqrt((Wf + Wwing + Waw) * ( Waw - Wwing));% Design Weight
    AC.visc = 1 % viscid analysis for aerodynamics
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
AC.Aero.alt  = altitude
[~,a, ~, rho, nu] = atmosisa(AC.Aero.alt); % standard atmosphere calcs
AC.Aero.V     = AC.Aero.M * a;            % flight speed (m/s)
AC.Aero.rho   = rho;                      % air density  (kg/m3)
AC.Aero.Re    = AC.Aero.V  * mac / nu ;   % reynolds number (based on mac)
AC.Aero.CL    = nmax *  2 * W / rho / AC.Aero.V^2 / S; % CL

end