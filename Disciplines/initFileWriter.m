function [] = initFileWriter(x, AC, filename)
%% Constants
constant = get_constants();
airfoil = constant.airfoil;     % Airfoil coordinate file name [-]
front_spar_chord = constant.spar_front;
rear_spar_chord = constant.spar_rear;
n_max = 2.5;            % Maximum load factor [-]
n_planform = 3;         % Number of sections for defining planform [-]
n_airfoil = 2;          % Number of sections for defining airfoil [-]
eta_1 = 0;              % Span root airfoil section [-]
eta_2 = 1;              % Span tip airfoil section [-]
n_engine = 1;           % Number of engines per wing [-]
start_tank = 0.1;       % Spanwise fraction start of wing fuel tank [-]
end_tank = 0.85;        % Spanwise fraction end of wing fuel tank [-]
eta_engine = 0.338;     % Spanwise position fuel tank [-]
m_engine = 2331;        % Engine mass [kg] (ref: EASA Type-certificate Data Sheet)
E = 70e9;               % Young's modulus [N/m^2]
rho_struct = 2800;      % Density aluminum [kg/m^3]
sigma_yt = 295e6;       % Aluminum tensile yield stress [N/m^2]
sigma_yc = 295e6;       % Aluminum compressive yield stress [N/m^2]
F = 0.96;               % Stiffened panel efficiency factor [-]
rib_pitch = 0.5;        % Rib pitch [m]
display_option = 1;     % Display option

%% Variables
span = x(1);
x1 = AC.Wing.Geom(1,1);
x2 = AC.Wing.Geom(2,1);
x3 = AC.Wing.Geom(3,1);
y1 = AC.Wing.Geom(1,2);
y2 = AC.Wing.Geom(2,2);
y3 = AC.Wing.Geom(3,2);
z1 = AC.Wing.Geom(1,3);
z2 = AC.Wing.Geom(2,3);
z3 = AC.Wing.Geom(3,3);
chord_1 = AC.Wing.Geom(1,4);
chord_2 = AC.Wing.Geom(2,4);
chord_3 = AC.Wing.Geom(3,4);
S1 = (chord_1 + chord_2)/2 * constant.s0; % surface area inboard section
S2 = (chord_2+chord_3)/2 * (span/2 - constant.s0); % surface area outboard section
S = (S1 + S2) * 2; % full wing surface area
W_fuel = x(20);
W_wing = x(21);
ZFW = 3.1485e+04+x(21)+constant.payload_max;    % Zero-fuel weight [kg]
MTOW = W_fuel + W_wing + constant.W_aw;         % Maximum take-off weight [kg]

%% Write .init
filename = [filename, '.INIT'];
fid = fopen(filename, 'wt');
fprintf(fid, '%g %g\n', MTOW, ZFW);
fprintf(fid, '%g\n', n_max);
fprintf(fid, '%g %g %g %g\n', S, span, n_planform, n_airfoil);
fprintf(fid, '%g %s\n', eta_1, airfoil);
fprintf(fid, '%g %s\n', eta_2, airfoil);
fprintf(fid, '%g %g %g %g %g %g\n', chord_1, x1, y1, z1, front_spar_chord, rear_spar_chord);
fprintf(fid, '%g %g %g %g %g %g\n', chord_2, x2, y2, z2, front_spar_chord, rear_spar_chord);
fprintf(fid, '%g %g %g %g %g %g\n', chord_3, x3, y3, z3, front_spar_chord, rear_spar_chord);
fprintf(fid, '%g %g\n', start_tank, end_tank);
fprintf(fid, '%g\n', n_engine);
fprintf(fid, '%g %g\n', eta_engine, m_engine);
fprintf(fid, '%g %g %g %g\n', E, rho_struct, sigma_yt, sigma_yc);
fprintf(fid, '%g %g %g %g\n', E, rho_struct, sigma_yt, sigma_yc);
fprintf(fid, '%g %g %g %g\n', E, rho_struct, sigma_yt, sigma_yc);
fprintf(fid, '%g %g %g %g\n', E, rho_struct, sigma_yt, sigma_yc);
fprintf(fid, '%g %g\n', F, rib_pitch);
fprintf(fid, '%g\n', display_option);
fclose(fid);

end