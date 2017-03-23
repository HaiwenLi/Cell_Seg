function BW = RemoveObject(img,area_d,area_u)
% remove objects whose area is less than area_d or lager than area_u
% img is labelled.

max_label = max(max(img));
BW = false(size(img));
for i=1:max_label
    region = (img==i);
    region_area = sum(sum(region));
    if region_area<area_d || region_area>area_u
        BW(region) = 0;
    else 
        BW(region) = 1;
    end
end

se1 = strel('disk',5);
se2 = strel('disk',5);
BW = imerode(BW,se1);
BW = imclose(BW,se2);
end
