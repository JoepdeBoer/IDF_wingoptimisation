function [] = plotHistory(history)
% Objective function plot
figure
plot(history.fval(:,1), '-x', 'color', [0, 0.4, 0.8], 'linewidth', 1);hold on
title('Objective function value history')
xlabel('Iteration [-]')
ylabel('Normalised value [-]')
grid on

% Consistency constraints plot
figure
plot(history.cc(:,1), '-x', 'color', [0, 0.4, 0.8], 'linewidth', 1);hold on
plot(history.cc(:,2), '-x', 'color', [0, 0.8, 0.4], 'linewidth', 1);hold on
plot(history.cc(:,3), '-x', 'color', [0.8, 0.4, 0], 'linewidth', 1);hold on
legend('ceq_1', 'ceq_2', 'ceq_3', 'location', 'best')
title('Consistency constraint history')
xlabel('Iteration [-]')
ylabel('Difference [-]')
grid on

% Inequality constraints plot
figure
plot(history.c(:,1), '-x', 'color', [0, 0.4, 0.8], 'linewidth', 1);hold on
plot(history.c(:,2), '-x', 'color', [0, 0.8, 0.4], 'linewidth', 1);hold on
plot(history.c(:,3), '-x', 'color', [0.8, 0.4, 0], 'linewidth', 1);hold on
legend('c_1', 'c_2', 'c_3', 'location', 'best')
title('Inequality constraint history')
xlabel('Iteration [-]')
ylabel('Normalised value [-]')
grid on

end