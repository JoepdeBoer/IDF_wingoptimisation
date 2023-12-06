function V_tank = TankVolume(x, constant)

% V_tank = 15e3;

% Properties
b = x(1);               % Wing span [m]
c_r = x(2);             % Root chord length [m]
lambda = x(3);          % Taper ratio [-]
Lambda_LE = x(4);       % Leading edge sweep angle [deg]
c_k = c_r-constant.s0*tand(Lambda_LE);      % Kink chord length [m]
c_t = c_r*lambda;       % Tip chord length [m]
kt = x(5:10);
kb = x(11:16);

refinement = 1000;
chord = [c_r, c_k, c_t];
chord = array_interpolation(chord, refinement);
y = [0, constant.s0, b/2];
y = array_interpolation(y, refinement)

[Au, Al, Xtu, Xtl] = AirfoilFit(constant.airfoil);

i = 0;
j = 0;
for c=chord
    i = i+1;
    if y(i) > 0.85*b/2      % Exit loop at 0.85*span
        break;
    end
    l(i) = (constant.spar_rear-constant.spar_front)*c;          % Chordwise length of fuel tank [m]
    t_front_spar(i) = c*(Xtu(find(Xtu(:, 1)==constant.spar_front), 2) - Xtl(find(Xtl(:, 1)==constant.spar_front), 2));  % Airfoil thickness at front spar [m]
    t_rear_spar(i) = c*(Xtu(find(Xtu(:, 1)==constant.spar_rear), 2) - Xtl(find(Xtl(:, 1)==constant.spar_rear), 2));     % Airfoil thickness at rear spar [m]
    A_tank(i) = l(i)*(t_front_spar(i)+t_rear_spar(i))/2;        % Area of fuel tank cross-sectional area [m^2]
    if i>1
        j = j+1;
        dy(j) = y(i)-y(i-1);
        dV(j) = dy(j)*(A_tank(i)+A_tank(i-1))/2;                % Spanwise integration of fuel tank area [m^3]
    end
end

V_tank = sum(dV);

y = y(1:i-1);
chord = chord(1:i-1);
error = y(end)-(0.85*b/2);      % Spanwise length error (calculated values are missing over 'error' meters of span)

% %% Plots
% % Chord length
% figure
% plot(y, chord)
% xlabel('y [m]')
% ylabel('c [m]')
% grid on
% 
% % Area over span
% figure
% plot(y, A_tank, 'linewidth', 1);hold on
% xlabel('y [m]')
% ylabel('A_{tank} [m^2]')
% grid on