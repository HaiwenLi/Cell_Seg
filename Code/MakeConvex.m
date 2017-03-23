function BW = MakeConvex(img)
% img: binary image

se = strel('disk',21, 8);
BW = imclose(img,se);
BW = imclose(BW,se);
BW = imfill(BW,'holes');

se = strel('disk',3, 8);
BW = imerode(BW,se);
BW = imfill(BW,'holes');
end