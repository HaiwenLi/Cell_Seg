function BW = MakeConvex(img)
% img: binary image

se = strel('disk',19, 8);
BW = imclose(img,se);
BW = imclose(BW,se);
BW = imfill(BW,'holes');
end