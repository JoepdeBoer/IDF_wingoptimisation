function [x_rfine] = array_interpolation(x,ref)
% Inputs:
% - x: array
% - ref: refinement

if ref<1
    disp('Error array_interpolation: Refinement must be 1 or higher!')
else
    N=1;

for i=1:length(x)-1
    d_x(i) = (x(i+1)-x(i))/ref;
    x_rfine(N) = x(i);
    for p=N:N+ref-1
        x_rfine(p+1) = x_rfine(p)+d_x(i);
    end
    N = N+ref;
end
end

end