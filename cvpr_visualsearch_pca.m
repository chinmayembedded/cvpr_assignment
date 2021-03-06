%% EEE3032 - Computer Vision and Pattern Recognition (ee3.cvpr)
%%
%% cvpr_visualsearch.m
%% Skeleton code provided as part of the coursework assessment
%%
%% This code will load in all descriptors pre-computed (by the
%% function cvpr_computedescriptors) from the images in the MSRCv2 dataset.
%%
%% It will pick a descriptor at random and compare all other descriptors to
%% it - by calling cvpr_compare.  In doing so it will rank the images by
%% similarity to the randomly picked descriptor.  Note that initially the
%% function cvpr_compare returns a random number - you need to code it
%% so that it returns the Euclidean distance or some other distance metric
%% between the two descriptors it is passed.
%%
%% (c) John Collomosse 2010  (J.Collomosse@surrey.ac.uk)
%% Centre for Vision Speech and Signal Processing (CVSSP)
%% University of Surrey, United Kingdom

close all;
clear all;

%% Edit the following line to the folder you unzipped the MSRCv2 dataset to
DATASET_FOLDER = 'MSRC_ObjCategImageDatabase_v2';

%% Folder that holds the results...
DESCRIPTOR_FOLDER = 'descriptors';
%% and within that folder, another folder to hold the descriptors
%% we are interested in working with

%DESCRIPTOR_SUBFOLDER='globalRGBhisto';
%DESCRIPTOR_SUBFOLDER='spatial_information';
%DESCRIPTOR_SUBFOLDER='spatial_texture';
DESCRIPTOR_SUBFOLDER='spatial_color_texture';

%% 1) Load all the descriptors into "ALLFEAT"
%% each row of ALLFEAT is a descriptor (is an image)

ALLFEAT=[];
ALLFILES=cell(1,0);
class_names = [];
ctr=1;
allfiles=dir (fullfile([DATASET_FOLDER,'/Images/*.bmp']));
for filenum=1:length(allfiles)
    fname=allfiles(filenum).name;
    imgfname_full=([DATASET_FOLDER,'/Images/',fname]);
    img=double(imread(imgfname_full))./255;
    thesefeat=[];
    featfile=[DESCRIPTOR_FOLDER,'/',DESCRIPTOR_SUBFOLDER,'/',fname(1:end-4),'.mat'];%replace .bmp with .mat
    load(featfile,'F');
    ALLFILES{ctr}=imgfname_full;
    class = split(fname, '_');
    class_names(ctr)=str2num(class{1});
    ALLFEAT=[ALLFEAT ; F];
    ctr=ctr+1;
end





%% 2) Pick an image at random to be the query
NIMG=size(ALLFEAT,1);           % number of images in collection
queryimg=floor(rand()*NIMG);    % index of a random image




%% 3) Compute the distance of image to the query
dst=[];
for i=1:NIMG
    candidate=ALLFEAT(i,:);
    query=ALLFEAT(queryimg,:);
    thedst=cvpr_compare_euclidean(query,candidate);
    dst=[dst ; [thedst i]];
end
dst=sortrows(dst,1);  % sort the results

%% 4) Visualise the results
%% These may be a little hard to see using imgshow
%% If you have access, try using imshow(outdisplay) or imagesc(outdisplay)

SHOW=10; % Show top 15 results
dst=dst(1:SHOW,:);
outdisplay=[];
for i=1:size(dst,1)
   img=imread(ALLFILES{dst(i,2)});
   img=img(1:2:end,1:2:end,:); % make image a quarter size
   img=img(1:100,:,:); % crop image to uniform size vertically (some MSVC images are different heights)
   outdisplay=[outdisplay img];
end
imshow(outdisplay);
axis off;


% Count number of images per category

total_categories = 20;
class_count = histogram(class_names);
class_count = class_count.Values;

num_tests = 20;
ap = zeros([1, num_tests]);
%ALLFEAT = ALLFEAT';
size(ALLFEAT)

Eigen = eigen_model(ALLFEAT);
Eigen = eigen_model_deflate(Eigen, 0.986);
ALLFEAT=ALLFEAT-repmat(Eigen.mean,size(ALLFEAT,1),1);
ALLFEAT=((Eigen.vector')*(ALLFEAT))';

for tests=1:num_tests
    NIMG=size(ALLFEAT,1);           % number of images in collection
    queryimg=floor(rand()*NIMG);     % index of a random image
    gtruth = class_names(queryimg);
    
    % Compare distances
    dst=[];
    for i=1:NIMG
        candidate=ALLFEAT(i,:);
        query=ALLFEAT(queryimg,:);
        thedst=cvpr_compare_mahalanobis(Eigen, query,candidate);
        ground_truth = class_names(i);
        dst=[dst ; [thedst ground_truth i ]];
    end
    dst=sortrows(dst,1);
    
    % Precision-recall
    precision= zeros([1, NIMG]);
    recall= zeros([1, NIMG]);
    last_correct = zeros([1, NIMG]);
    query_details = dst(1,:);
    query_class = query_details(1,2);
    
    for index=1:NIMG
        rows = dst(1:index, :);
        correct = 0;
        incorrect = 0;
        for j=1:index
             row = rows(j, :);
             pred_class = row(2);
             if pred_class == query_class
                 correct = correct + 1;
                 if j==index
                    last_correct(index) = 1;
                 end
             else
                 incorrect = incorrect + 1;
             end
        end
        
        precision(index) = correct/index;
        recall(index) = correct/class_count(1, query_class);
    end
    
    figure(1)
    plot(recall, precision);
    hold on;
    title('Precision recall Curve');
    xlabel('Recall');
    ylabel('Precision');
    
    ap(tests) = sum(precision .* last_correct) / class_count(1,tests);;
end


mAP = mean(ap)
std_ap = std(ap)


function Eigen= eigen_model(features)

Eigen.row = size(features, 1)
Eigen.col = size(features, 2)

% Calculate mean
Eigen.mean= mean(features);

% Subtract mean from data points
features = features-repmat(Eigen.mean, Eigen.row, 1);

% Covariance 
cov = (1/Eigen.row) * (features * features');

% Decompose covariance metrics using EVD

[U V]=eig(cov);

% Descending sort of eigen values and vectors
ones_matrix = ones(size(V,2),1);
linear_v = V * ones_matrix;
uv_comb = [linear_v U'];
uv_comb = flipud(sortrows(uv_comb,1));
U = uv_comb(:,2:end)';
V = uv_comb(:,1);

% Eigen vector and value decomposition
Eigen.vector=U;
Eigen.value=V;

end

function Eigen = eigen_model_deflate(Eigen, parameters)
    energy = sum(abs(Eigen.value));
    temp_energy = 0;
    index = 0;
    for i=1:size(Eigen.vector, 2)
    if temp_energy <= energy * parameters
        temp_energy = temp_energy+ Eigen.value(i);
        index = index + 1;
    else 
        break;
    end   
    end
    Eigen.vector=Eigen.vector(:,1: index);            
    Eigen.value=Eigen.value(1: index);
end

