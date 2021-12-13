close all;
clear all;

DATASET_FOLDER = 'MSRC_ObjCategImageDatabase_v2';
DESCRIPTOR_FOLDER = 'descriptors';

DESCRIPTOR_SUBFOLDER='spatial_color_texture';

ALLFEAT=[];
ALLFILES=cell(1,0);
%class_names = cell(1,0);
ctr=1;

allfiles=dir (fullfile([DATASET_FOLDER,'/Images/*.bmp']));
for filenum=1:length(allfiles)
    fname=allfiles(filenum).name;
    imgfname_full=([DATASET_FOLDER,'/Images/',fname]);
    img=double(imread(imgfname_full))./255;
    thesefeat=[];
    featfile=[DESCRIPTOR_FOLDER,'/',DESCRIPTOR_SUBFOLDER,'/',fname(1:end-4),'.mat']; %replace .bmp with .mat
    load(featfile,'F');
    ALLFILES{ctr}=imgfname_full;
    class = split(fname, '_');
    %class_names{ctr}=class{1};
    [r, col] = size(F);
    F(:, col+1) = str2num(class{1});
    ALLFEAT=[ALLFEAT; F];
    ctr=ctr+1;
end
[m,n] = size(ALLFEAT) ;
idx = randperm(m) ;
ALLFEAT(idx,:) = ALLFEAT(:,:);
proportion = 0.3;
train_percentage = floor(proportion * m);
train_dataset = ALLFEAT(1:train_percentage, :);
test_dataset = ALLFEAT(train_percentage:end, :);

train_x = train_dataset(:,1:col); 
train_y = train_dataset(:,col+1);
test_x = test_dataset(:,1:col); 
test_y = test_dataset(:,col+1);

classifier = fitcecoc(train_x, train_y);
predicted_labels = predict(classifier, test_x);
conf_mat = confusionmat(test_y, predicted_labels);
confusionMat = conf_mat;
precision = @(confusionMat) diag(confusionMat)./sum(confusionMat,2);
recall = @(confusionMat) diag(confusionMat)./sum(confusionMat,1)';
f1_scores = @(confusionMat) 2*(precision(confusionMat).*recall(confusionMat))./(precision(confusionMat)+recall(confusionMat));
mean_f1 = @(confusionMat) mean(f1_scores(confusionMat));

recall_1 = recall(conf_mat)
precision_1 = precision(conf_mat)
f1_scores_1 = f1_scores(conf_mat)
mean_f1_1 = mean_f1(conf_mat)
