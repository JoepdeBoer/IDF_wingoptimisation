function C = chord(Design, Y)
%CHORD calculates chord lenght 
%   For a given design vector and wing positions
%   Function will return an array with the corresponding chord lenghts

C = [];

constant = get_constants();

b = Design(1);
c1 = Design(2);
taper = Design(3);
sweepLE = Design(4);

sweepTE = constant.sweepTE;
s0 = constant.s0;
slope1 = tand(sweepTE) - tand(sweepLE);
c2 = c1 + s0 * slope1;
slope2 =  (c1 * taper - c2)/(b/2 - s0);

for i = 1:length(Y)
    y = Y(i);
    if y < s0
        c = c1 + y * slope1;
    else 
        c = c2 + (y-s0) * slope2;
    end
    C = [C, c];
end

end

