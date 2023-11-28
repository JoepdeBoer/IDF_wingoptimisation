function [] = initFileWriter(MTOW, ZFW, S, span, airfoil, chord_1, chord_2, chord_3, x1, x2, x3, y1, y2, y3, z1, z2, z3, front_spar_chord, rear_spar_chord, filename)

%% Constants
n_max = 2.5;            % Maximum load factor [-]
n_planform = 3;         % Number of sections for defining planform [-]
n_airfoil = 2;          % Number of sections for defining airfoil [-]
eta_1 = 0;              % Span root airfoil section [-]
eta_2 = 1;              % Span tip airfoil section [-]
n_engine = 1;           % Number of engines per wing [-]
start_tank = 0.1;         % Spanwise fraction start of wing fuel tank [-]
end_tank = 0.85;        % Spanwise fraction end of wing fuel tank [-]
eta_engine = 0.35;      % Spanwise position fuel tank [-]
m_engine = 2000;        % Engine mass [kg]
E = 70e9;               % Young's modulus [N/m^2]
rho_struct = 2800;      % Density aluminum [kg/m^3]
sigma_yt = 295e6;       % Aluminum tensile yield stress [N/m^2]
sigma_yc = 295e6;       % Aluminum compressive yield stress [N/m^2]
F = 0.96;               % Stiffened panel efficiency factor [-]
rib_pitch = 0.5;        % Rib pitch [m]
display_option = 1;     % Display option

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