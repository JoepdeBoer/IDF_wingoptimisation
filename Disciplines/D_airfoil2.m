%Function D_airfoil2 to transform input Bernstein parameters (shape + class function method) to
%complete Airfoil coordinates

%output [upper surface y coord, lower surface y coord, Class function pos y
%coord, up surf thickness distribution, lw surf thickness distb, camber
%distb] = input (up surf Bernstein parameters, lw surf BS params,
%X-ordinates)
function[Xtu,Xtl,C,Thu,Thl,Cm] = D_airfoil2(Au,Al,X)

x = X(:,1);

N1 = 0.5;   %Class function N1
N2 = 1;     %Class function N2

zeta_u = 0.000;     %upper surface TE gap
zeta_l = -0.000;     %lower surface TE gap


nu = length(Au)-1;
nl = length(Al)-1;

%evaluate required functions for each X-coordinate
for i = 1:length(x)
    
    %calculate Class Function for x(i):
    C(i) = (x(i)^N1)*(1-x(i))^N2;
    
    %calculate Shape Functions for upper and lower surface at x(i)
    Su(i) = 0;  %Shape function initially zero
    for j = 0:nu
        Krnu = factorial(nu)/(factorial(j)*factorial(nu-j));
        Su(i) = Su(i) + Au(j+1)*Krnu*(1-x(i))^(nu-j)*x(i)^(j);
    end
    Sl(i) = 0;  %Shape function initially zero
    for k = 0:nl        
        Krnl = factorial(nl)/(factorial(k)*factorial(nl-k));
        Sl(i) = Sl(i) + Al(k+1)*Krnl*(1-x(i))^(nl-k)*x(i)^(k);
    end
    
    %calculate upper and lower surface ordinates at x(i)
    Yu(i) = C(i)*Su(i) + x(i)*zeta_u;
    Yl(i) = C(i)*Sl(i) + x(i)*zeta_l;
    
    Thu(i) = C(i)*(Su(i)-Sl(i))/2;    %calculate thickness distribution !TE thickness ignored!
    Thl(i) = C(i)*(Sl(i)-Su(i))/2;    %calculate thickness distribution !TE thickness ignored!
    Cm(i) = C(i)*(Su(i)+Sl(i))/2;    %calculate camber distribution !TE thickness ignored!
end

Yust = Yu';
Ylst = Yl';

%assemble airfoil coord matrix
Xtu = [x  Yust];
Xtl = [x  Ylst];