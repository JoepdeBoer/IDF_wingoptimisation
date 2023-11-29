%% Aerodynamic solver setting
clear all
close all
clc

filename = 'A320';      % Filename for .INIT, .LOAD and .weight file file

%Design weight
MTOmax = 73500;         % Maximum take-off mass [kg]
ZFM = 60500;            % Zero-fuel mass [kg]

WTOmax = MTOmax * 9.81;
ZFW = ZFM * 9.81;

% Flight conditions
Mcr = 0.78; % cruise mach not the mach for load calculation that is done in accreator
hcr = 11.280;
Waw = WTOmax * 0.7; % TODO make better guess
Wf = WTOmax - Waw - 0.1 * WTOmax ; %TODO make better guess for fuel weight
Wwing = WTOmax - Wf - Waw; % TODO make better guess for wing weight 


%inputs planform
c1 = 6.1;
taper = 0.268852459;
b = 34.09;
sweep = 24.506;
front_spar = 0.2;
rear_spar = 0.6;

X = [b, c1, taper, sweep, 0.192392936732350, 0.0653141645170239,...
    0.221217406157354, 0.0724162633146400, 0.229988611159206,...
    0.313396932618784, -0.185506217628836, -0.134457419499340,...
    -0.0387763254380645, -0.392501124442199, 0.0603430027877033,...
    0.267973110203190, Mcr, hcr] % Design vector

AC = ACcreator(X,Wf,Wwing,1) % creates the AC structure for the loads calculation

%% Solver
tic

Res = Q3D_solver(AC)

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
    M(i) = cm_c4(i)*c(i)*mac*0.5*rho*AC.Aero.V^2;
end

% Write to txt
fid = fopen([filename, '.LOAD'], 'wt');
for i=1:length(Yst)
    fprintf(fid, '%f %f %f\n', Yst(i)/Yst(end), L(i), M(i));
end

%% Write .INIT file
initFileWriter(MTOmax, MFW, S, b, airfoil, c1, c2, c3, AC.Wing.Geom(1,1), AC.Wing.Geom(2,1), AC.Wing.Geom(3,1), AC.Wing.Geom(1,2), AC.Wing.Geom(2,2), AC.Wing.Geom(3,2), AC.Wing.Geom(1,3), AC.Wing.Geom(2,3), AC.Wing.Geom(3,3), front_spar, rear_spar, filename)

%% Run Emwet
EMWET A320