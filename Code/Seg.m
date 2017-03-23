function output = Seg(src)
% Use watershed to segment cells
% Adustable parameters:
% alpha:    To find candicate cell regions;
% min_area: To remove candidate cell whose area is less than this value;
% max_area: To remove candidate cell whose area is lager than this value;
% Roundness_Threshold: Select a round cell and remove the space among cells
%                      since the space isn't round;

close all;

%% Step 1: Sharp edges of cell
% convert color image into gray image
sharp_src = imsharpen(src,'Radius',3.0,'Amount',0.9);
img = double(rgb2gray(sharp_src));

% Smooth the image to depress the noise in the cell
hsize = [5,5];
sigma = 2.0;
h = fspecial('gaussian',hsize,sigma);
smooth_img = imfilter(img,h);
% figure;imagesc(smooth_img);axis image;

% Compute gradient distribution
sobel_h = fspecial('sobel');
grad = (imfilter(smooth_img,sobel_h,'replicate').^2 + ...
        imfilter(smooth_img,sobel_h','replicate').^2).^0.5;
% figure; imagesc(grad);axis image;

% Compute the mask image of cell
alpha = 1.2;
cell_grad_value = mean(mean(grad))*alpha;
mask = grad <= cell_grad_value;
se = strel('disk',3,8);
mask = imopen(mask,se);
mask = bwareaopen(~mask,200,8); % remove small objects
% figure; imagesc(mask);axis image;

min_area = 2000;
max_area = 20000;
D = bwdist(~mask);
L1 = watershed(D);
BW = RemoveObject(L1,min_area,max_area);
% figure;imagesc(BW);

%% Step 2: Segmentation
% Compute the cell edge
mask(BW) = 0;
se = strel('disk',3,8);
mask = imclose(mask,se);

w = [1 1 1; 1 -8 1; 1 1 1];
lap_img = imfilter(img, w, 'replicate');
% figure;imagesc(lap_img);axis image;

beta = 3.0; % Have little compact on final results!
sharp_grad = abs(grad - beta*lap_img.*mask);
sharp_grad = imfilter(sharp_grad,h);
figure;imagesc(sharp_grad);axis image;

G2 = imimposemin(sharp_grad,~mask);
L = watershed(G2);
figure;imagesc(L);axis image;

% Find all cells
Roundness_Threshold = 0.8;
cell_num = 0;
max_label = max(max(L));
cell_area = zeros(max_label,1);
Final_Seg = false(size(img));
for i=1:max_label
    cell_region = (L==i);
    region_area = sum(sum(cell_region));
    if region_area<min_area || region_area>max_area
        continue;
    else
        cell_region = imfill(cell_region,'holes');
        cell_region = MakeConvex(cell_region);
        %imagesc(cell_region);axis image;
        if ~InMargin(cell_region) && (IsRoundness(cell_region) > Roundness_Threshold)
            % Judge the roundness of cell
            cell_num = cell_num+1;
            cell_area(cell_num) = sum(sum(cell_region));
            Final_Seg(cell_region) = 1;
        end
    end
end
cell_area = cell_area(1:cell_num); % Final cell area
figure;imagesc(Final_Seg);axis image;

output = src;
red = output(:,:,1);
red(Final_Seg) = 255;
output(:,:,1) = red;
figure;imagesc(output);axis image;
end

