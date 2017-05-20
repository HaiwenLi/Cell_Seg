function RunSeg(in_folder,out_folder)
% in_folder:输入文件夹（原图像文件）
% out_folder: 输出文件夹（处理结果和excel表格）
tic
MAX_CELL_NUM = 150;

if ~exist(out_folder,'dir')
    disp('No exist output folder, start to create the folder');
    mkdir(out_folder);
end
xls_filename = [out_folder '\cell_area.xlsx'];

% Search all images in in_folder
image_format = '.tif';
image_list = dir([in_folder '\*' image_format]);%search all images in the in_folder
cell_area = zeros(length(image_list),MAX_CELL_NUM);

for i=1:length(image_list)
    image_name = char(image_list(i).name);
    input_image_name = [in_folder '\' image_name];
    src = imread(input_image_name);
    [output_img,area] = Seg(src,MAX_CELL_NUM);
    output_image_name = [out_folder '\' image_name];
    cell_area(i,:) = area;
    imwrite(output_img,output_image_name);
    
    disp(['Processed ' image_name ',write data into file']);
    dot_pos = strfind(image_name,'.');
    image_name = {image_name(1:dot_pos-1)};
    xlswrite(xls_filename,image_name,1,['A' num2str(i)]);
    xlswrite(xls_filename,cell_area(i,:),1,['B' num2str(i)]);
end
time = toc

save([out_folder '\cell_area.mat'],'cell_area'); % save data with matlab format
end

