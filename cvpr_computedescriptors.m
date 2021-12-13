close all;
clear all;
clc;
DATASET_FOLDER = 'MSRC_ObjCategImageDatabase_v2';
OUT_FOLDER = 'descriptors';
%OUT_SUBFOLDER = 'extract_rgb'
%OUT_SUBFOLDER='globalRGBhisto';
%OUT_SUBFOLDER = 'spatial_information';
%OUT_SUBFOLDER = 'spatial_texture';
OUT_SUBFOLDER = 'spatial_color_texture';

allfiles=dir (fullfile([DATASET_FOLDER,'/Images/*.bmp']));

for filenum=1:length(allfiles)
    fname=allfiles(filenum).name;
    fprintf('Processing file %d/%d - %s\n',filenum,length(allfiles),fname);
    tic;
    imgfname_full=([DATASET_FOLDER,'/Images/',fname]);
    img=double(imread(imgfname_full))./255;
    fout=[OUT_FOLDER,'/',OUT_SUBFOLDER,'/',fname(1:end-4),'.mat'];%replace .bmp with .mat
    
    %F=extract_rgb(img);
    % Global color histogram
    %bin_size = 4;
    %F = descriptor_gch(img, bin_size);
    %F = descriptor_spatial(img, 4, 4);
    %F = descriptor_spatial_texture(img, 6, 6, 8, 0.09);
    F = descriptor_spatial_color_texture(img, 6, 8, 8, 0.09);
    save(fout,'F');
    toc
end

%% To compute bin size
%{
map_plots=[];
max_bins=20;
for grid = 2:2:max_bins
    
        for filenum=1:length(allfiles)
        fname=allfiles(filenum).name;
        fprintf('Processing file %d/%d - %s\n',filenum,length(allfiles),fname);
        tic;
        imgfname_full=([DATASET_FOLDER,'/Images/',fname]);
        img=double(imread(imgfname_full))./255;
        fout=[OUT_FOLDER,'/',OUT_SUBFOLDER,'/',fname(1:end-4),'.mat'];%replace .bmp with .mat
        %F = descriptor_spatial_texture(img, row, col);
        F = descriptor_spatial_texture(img, 6, 8, grid, 0.09);
        save(fout,'F');
        toc
    
        end
        map = visual_search_func() ;
        map_plots=[map_plots ; grid map];
        %B(row/2, col/2) = map;
    
end
scatter(map_plots(:,1), map_plots(:,2), 'filled')
xlim([0 0.22 ])

%}

%% To compute 3D plots
%{
map_plots=[];
max_row = 16;
max_col = 16;
[X,Y] = meshgrid(2:2:max_row);
B = zeros(max_row/2, max_col/2);
for row = 2:2:max_row
    for col = 2:2:max_col
        for filenum=1:length(allfiles)
        fname=allfiles(filenum).name;
        fprintf('Processing file %d/%d - %s\n',filenum,length(allfiles),fname);
        tic;
        imgfname_full=([DATASET_FOLDER,'/Images/',fname]);
        img=double(imread(imgfname_full))./255;
        fout=[OUT_FOLDER,'/',OUT_SUBFOLDER,'/',fname(1:end-4),'.mat'];%replace .bmp with .mat
        F = descriptor_gch(img, 4);
        %F = descriptor_spatial_texture(img, row, col);
        %F = descriptor_spatial_texture(img, row, col, 8, 0.09);
        save(fout,'F');
        toc
    
        end
        map = visual_search_func() ;
        map_plots=[map_plots ; row col map];
        B(row/2, col/2) = map;
    end
end

mesh(X, Y, B, 'FaceAlpha','0.1', FaceColor = 'flat');
title(OUT_SUBFOLDER);
xlabel('Number of rows');
ylabel('Number of columns');
zlabel('mAP values')
%}