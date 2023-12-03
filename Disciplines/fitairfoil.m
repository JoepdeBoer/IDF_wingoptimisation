function error = fitairfoil(x)
% Function used to find optimal airfoil fit using CST

% Import airfoil coordinates
filename = 'withcomb135';
fid = fopen(['C:\Users\luukh\Documents\Studie\Q1\MDO for Aerospace Applications (AE4205)\2023\Tutorial\Exercises\Tutorial 2\Assignment tutorial 2\airfoils\', filename, '.dat']);
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

X_up = coor(1,1:pos_index)';      %points for evaluation along x-axis
X_low = coor(1,pos_index+1:end)';      %points for evaluation along x-axis

[Xtu,Xtl,C] = D_airfoil2(Au,Al,X_up);
[Xtu_low,Xtl_low,C_low] = D_airfoil2(Au,Al,X_low);

err_up = Xtu(:,2)-coor(2,1:pos_index)';
err_low = Xtl_low(:,2)-coor(2,pos_index+1:end)';

error = sum(err_up.^2)+sum(err_low.^2);

% val = zeros(1,length(error));
% val(1) = error(1);
% for i=2:length(error)
%     val(i) = val(i-1)*error(i);
% end
% 
% fopt = val(end);