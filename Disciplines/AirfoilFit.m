function [Au, Al, Xtu, Xtl] = AirfoilFit(airfoil)

%% Perform optimization
x0 = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5];
lb = [-0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -1, -1, -1, -1, -1, -1];
ub = [1, 1, 1, 1, 1, 1, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5];

options = optimset('Display','iter','Algorithm','sqp');

tic;
[x, fval, exitflag, output] = fmincon(@fitairfoil, x0, [], [], [], [], lb, ub, [], options);
t=toc;

% Import airfoil coordinates
filename = airfoil;
fid = fopen([filename, '.dat']);
coor = fscanf(fid, '%f\t%f', [2, inf]);
fclose(fid);

% Rearrange array in case structure is different
if coor(1,1) == 1
    index_0 = find(coor(1,:) == 0);
    coor = [flip(coor(:,1:index_0),2), coor(:,index_0+1:end)];
end

Au = [x(1) x(2) x(3) x(4) x(5) x(6)];         %upper-surface Bernstein coefficients
Al = [x(7) x(8) x(9) x(10) x(11) x(12)];    %lower surface Bernstein coefficients

% Find airfoil coordinate discontinuity
for i=2:length(coor)
    dif(i) = coor(1,i)-coor(1,i-1);
    if dif(i) < 0
        pos_index = i-1;
        break
    end
end

X_up = coor(1,1:pos_index)';            %points for evaluation along x-axis
X_low = coor(1,pos_index+1:end)';       %points for evaluation along x-axis

[Xtu,Xtl,C] = D_airfoil2(Au,Al,X_up);
[Xtu_low,Xtl_low,C_low] = D_airfoil2(Au,Al,X_low);

% figure
% hold on
% plot(Xtu(:,1),Xtu(:,2),'b');                %plot upper surface coords
% plot([0; Xtl_low(:,1)],[0; Xtl_low(:,2)],'b');        %plot lower surface coords
% plot(coor(1,1:pos_index), coor(2,1:pos_index), 'k--');          % Reference airfoil upper
% plot([0, coor(1,pos_index+1:end)], [0, coor(2,pos_index+1:end)], 'k--');  % Reference airfoil lower
% axis([0, 1, -0.3, 0.3]);