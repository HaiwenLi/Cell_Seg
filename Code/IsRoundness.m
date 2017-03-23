function r = IsRoundness(bw)
% Measure the roundness of binary image bw

area = regionprops(bw,'Area');
area = area.Area;
perimeter = regionprops(bw,'Perimeter');
perimeter = perimeter.Perimeter;
r = 4*pi*area/perimeter^2;

end