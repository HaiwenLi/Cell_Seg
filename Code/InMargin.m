function r = InMargin(img)
% Wheter the image is in margin
% img:binary image

r = false;
margin = 10;
[height,width] = size(img);
mask = ones(size(img));
mask(margin:height-margin,margin:width-margin) = 0;
if sum(sum(img.*mask))>0
    r = true;
end
end