function [output,cell_area] = Seg(src,MAX_CELL_NUM)
% Use watershed to segment cells
% Adustable parameters:
% alpha:    To find candicate cell regions;
% min_area: To remove candidate cell whose area is less than this value;
% max_area: To remove candidate cell whose area is lager than this value;
% Roundness_Threshold: Select a round cell and remove the space among cells
%                      since the space isn't round;

Roundness_Threshold = 0.8; %细胞圆度阈值
min_area = 2000;           %允许的最小细胞面积
max_area = 20000;          %允许的最大细胞面积

%% Step 1: Sharp edges of cell
% convert color image into gray image
sharp_src = imsharpen(src,'Radius',3.0,'Amount',0.9);
if size(src,3) == 3
    img = double(rgb2gray(sharp_src));
else
    img = double(sharp_src);
end

% Smooth the image to depress the noise in the cell
hsize = [5,5];
sigma = 2.0;
h = fspecial('gaussian',hsize,sigma);
smooth_img = imfilter(img,h);

% Compute gradient distribution
sobel_h = fspecial('sobel');
grad = (imfilter(smooth_img,sobel_h,'replicate').^2 + ...
        imfilter(smooth_img,sobel_h','replicate').^2).^0.5;

% Compute the mask image of cell
alpha = 1.2;
cell_grad_value = mean(mean(grad))*alpha;
mask = grad <= cell_grad_value;
se = strel('disk',3,8);
mask = imopen(mask,se);
mask = bwareaopen(~mask,200,8); % remove small objects

D = bwdist(~mask);
L1 = watershed(D);
BW = RemoveObject(L1,min_area,max_area);

%% Step 2: Segmentation
% Compute the cell edge
mask(BW) = 0;
se = strel('disk',3,8);
mask = imclose(mask,se);

w = [1 1 1; 1 -8 1; 1 1 1];
lap_img = imfilter(img, w, 'replicate');

beta = 3.0; % Have little compact on final results!
sharp_grad = abs(grad - beta*lap_img.*mask);
sharp_grad = imfilter(sharp_grad,h);

G2 = imimposemin(sharp_grad,~mask);
L = watershed(G2);

% Find all cells
max_label_num = max(max(L));
Final_Seg = false(size(img));
cell_index = 0;
cell_centers = zeros(MAX_CELL_NUM,2);
cell_area = zeros(MAX_CELL_NUM,1);
for i=1:max_label_num
    cell_region = (L==i);
    region_area = sum(sum(cell_region));
    if region_area<min_area || region_area>max_area
        continue;
    else
        cell_region = imfill(cell_region,'holes');
        cell_region = MakeConvex(cell_region);
        if ~InMargin(cell_region) && (IsRoundness(cell_region) > Roundness_Threshold)
            % Judge the roundness of cell
            cell_index = cell_index+1;
            if cell_index > MAX_CELL_NUM
                disp('Cell num exceed the max num');
                break;
            end
            Final_Seg(cell_region) = cell_index;
            [cell_y,cell_x] = find(cell_region>0);
            cell_centers(cell_index,:) = [mean(cell_x),mean(cell_y)];
            cell_area(cell_index,:) = length(cell_x);
        end
    end
end
cell_centers = cell_centers(1:cell_index,:);
cell_area(cell_index+1:end) = nan;

label_img = src;
red = label_img(:,:,1);
red(Final_Seg>0) = 255;
label_img(:,:,1) = red;
image(label_img);hold on;axis off;
for i=1:size(cell_centers,1)
    text(cell_centers(i,1),cell_centers(i,2),num2str(i),'FontSize',10);
end
hold off;
current_frame = getframe();
output = current_frame.cdata;
end

