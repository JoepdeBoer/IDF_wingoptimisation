function [W_wing] = Structures()

%% Run Emwet
EMWET A320

% Extract data from .weight file
filePath = 'A320.weight';
fid = fopen(filePath, 'r');
firstLine = fgetl(fid);
W_wing = sscanf(firstLine, 'Wing total weight(kg) %f');
header = textscan(fid, '%s', 6);
data = textscan(fid, '%f%f%f%f%f%f');
fclose(fid);

% Extract the data into separate variables
eta = data{1};
c = data{2};
tu = data{3};
tl = data{4};
tfs = data{5};
trs = data{6};

end