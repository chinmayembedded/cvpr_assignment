close all;
clear all;

%% Edit the following line to the folder you unzipped the MSRCv2 dataset to
DATASET_FOLDER = 'MSRC_ObjCategImageDatabase_v2';

%% Folder that holds the results...
DESCRIPTOR_FOLDER = 'descriptors';
%% and within that folder, another folder to hold the descriptors
%% we are interested in working with
%DESCRIPTOR_SUBFOLDER = 'extract_rgb';
%DESCRIPTOR_SUBFOLDER='globalRGBhisto';
%DESCRIPTOR_SUBFOLDER='spatial_information';
DESCRIPTOR_SUBFOLDER='spatial_texture';
%DESCRIPTOR_SUBFOLDER='spatial_color_texture';

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
    thedst=cvpr_compare_cosine(query,candidate);
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


for tests=1:num_tests
    NIMG=size(ALLFEAT,1);           % number of images in collection
    queryimg=floor(rand()*NIMG);     % index of a random image
    gtruth = class_names(queryimg);
    
    % Compare distances
    dst=[];
    for i=1:NIMG
        candidate=ALLFEAT(i,:);
        query=ALLFEAT(queryimg,:);
        thedst=cvpr_compare_l1(query,candidate);
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
    
    ap(tests) = sum(precision .* last_correct) / class_count(1, tests);
end


MAP = mean(ap)
AP_sd = std(ap)
