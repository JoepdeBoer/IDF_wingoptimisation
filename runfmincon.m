function [xsol, fval, exitflag, output, lambda, history, searchdir] = runfmincon(x0, lb, ub)

% Set up shared variables with outfun
history.x = [];
history.fval = [];
history.c = [];
history.cc = [];
searchdir = [];
 
% Call optimization
options = optimoptions(@fmincon,'OutputFcn',@outfun);
% Options for optimization
options.OutputFcn       = @outfun;
options.Display         = 'iter-detailed';
options.Algorithm       = 'sqp';
options.DiffMinChange   = 1e-4;          % Minimum change while gradient searching 
options.DiffMaxChange   = 15e-2;         % Maximum change while gradient searching
options.TolCon          = 1e-2;          % Maximum Constraint violation
options.TolFun          = 1e-2;          % Optimallity Tolerance when is solution converged
%options.TolX           = 1e-4;          % Maximum difference between two subsequent design vectors
options.MaxIter         = 30;            % Maximum iterations
% options.UseParallel     = true;        % Tries to calculate gradient in parralel
[xsol,fval,exitflag,output,lambda] = fmincon(@(x) IDF_optimiser(x), x0, [], [], [], [], lb, ub, @(x) Constraints(x), options);

 function stop = outfun(x,optimValues,state)
     stop = false;
 
     switch state
         case 'init'
             hold on
         case 'iter'
         % Concatenate current point and objective function
         % value with history. x must be a row vector.
           history.fval = [history.fval; optimValues.fval];
           history.x = [history.x; x];
           [c, cc] = Constraints(x);
           history.c = [history.c; c];
           history.cc = [history.cc; cc];
         % Concatenate current search direction with 
         % searchdir.
           searchdir = [searchdir;... 
                        optimValues.searchdirection'];
%            figure
%            plot(x(1),x(2),'o');
         % Label points with iteration number and add title.
         % Add .15 to x(1) to separate label from plotted 'o'.
%            text(x(1)+.15,x(2),... 
%                 num2str(optimValues.iteration));
%            title('Sequence of Points Computed by fmincon');
         case 'done'
             hold off
         otherwise
     end
 end
end