x = xsol.*ref
ld = xsol(19);

M = x(17);      % Mach number [-]
h = x(18);      % Altitude [m]

M_cr_ref = ref(17);     % Mach number reference [-]
h_cr_ref = ref(18);     % Altitude reference [m]

[~,a] = atmosisa(h); % standard atmosphere calcs
[~,a_ref] = atmosisa(h_cr_ref); % standard atmosphere calcs
V = M*a;
V_cr_ref = M_cr_ref*a_ref;

eta = exp(-((V-V_cr_ref)^2/(2*70^2))-((h-h_cr_ref)^2/(2*2500^2)));
C_T_specific = 0.000165495;           % Janes all the worlds engines [1/s]
C_T = C_T_specific/eta;

offset = 0.1; % percentage offset of solution LD
n = 101; % number of points
LDlist = linspace(ld -offset, ld + offset, n); %points of evaluation for plotting
CO2 = zeros(0,n)'; %empty list for normalised kg CO2


for i = 1:n
    LD = LDlist(i) * 16.3 ; %denormalising
    CO2(i) = (exp(constant.R*LD^(-1)*C_T/V)/0.938-1)*(constant.W_aw+x(21)) * 3.16 / (5.753 * 10^4); % normalised to ref CO2 
end

computedLD  = ld *16.3
computedCO2 = (exp(constant.R*computedLD^(-1)*C_T/V)/0.938-1)*(constant.W_aw+x(21)) * 3.16 / (5.753 * 10^4); % normalised to ref CO2

actualLD = (xsol(19) - output.constrviolation) * 16.3;
actualCO2 = (exp(constant.R*actualLD^(-1)*C_T/V)/0.938-1)*(constant.W_aw+x(21)) * 3.16 / (5.753 * 10^4); % normalised to ref CO2

figure 
hold on 
plot(LDlist , CO2);
scatter(ld, computedCO2);
scatter(actualLD/16.3,actualCO2)
xlabel('Normalised L/D')
ylabel('Normalised CO2')
legend('', 'solution', 'actual')
hold off

diff = actualCO2 - computedCO2
ld


