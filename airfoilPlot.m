function [] = airfoilPlot(xsol, Au, Al)
% Input:
% xsol: design vector
% Au: Bernstein coefficients upper airfoil
% Al: Bernstein coefficients lower airfoil

filename = 'withcomb135';
fid = fopen([filename, '.dat']);
coor = fscanf(fid, '%f\t%f', [2, inf]);
fclose(fid);

% Rearrange array in case structure is different
if coor(1,1) == 1
    index_0 = find(coor(1,:) == 0);
    coor = [flip(coor(:,1:index_0),2), coor(:,index_0+1:end)];
end

% Find airfoil coordinate discontinuity
for i=2:length(coor)
    dif(i) = coor(1,i)-coor(1,i-1);
    if dif(i) < 0
        pos_index = i-1;
        break
    end
end

X_up = coor(1,1:pos_index)';      %points for evaluation along x-axis
X_low = coor(1,pos_index+1:end)';      %points for evaluation along x-axis

[Xtu,Xtl,C] = D_airfoil2(Au,Al,X_up);
[Xtu_low,Xtl_low,C_low] = D_airfoil2(Au,Al,X_low);

% Optimised
Au_opt = xsol(5:10);    %upper-surface Bernstein coefficients
Al_opt = xsol(11:16);   %lower surface Bernstein coefficients

[Xtu_opt,Xtl_opt,C_opt] = D_airfoil2(Au_opt,Al_opt,X_up);
[Xtu_low_opt,Xtl_low_opt,C_low_opt] = D_airfoil2(Au_opt,Al_opt,X_low);

figure
hold on
plot(Xtu(:,1),Xtu(:,2),'k');                        %plot upper surface coords
plot([0; Xtl_low(:,1)],[0; Xtl_low(:,2)],'k');      %plot lower surface coords
plot(Xtu_opt(:,1),Xtu_opt(:,2),'r');                        %plot upper surface coords optimised
plot([0; Xtl_low_opt(:,1)],[0; Xtl_low_opt(:,2)],'r');      %plot lower surface coords optimised
legend('Reference', '', 'Optimised', '', 'location', 'se')
axis([0, 1, -0.3, 0.3]);
title('Airfoil')
xlabel('x/c [-]')
ylabel('y/c [-]')