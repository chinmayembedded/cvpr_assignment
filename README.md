**GRADES ACHIEVED - 100%**

**Steps to run the code**

1. Run the descriptor
    * Descriptor file: cvpr_computedescriptors.m
    * Steps to run the descriptor
        * Modify OUT_SUBFOLDER variable as per the type of descriptor e.g ['extract_rgb', 'globalRGBhisto', 'spatial_information'], 'spatial_texture', 'spatial_color_texture']
        * Modify function call from line 25-28
        * Run the script
    * Descriptors will be stored per image in the mentioned OUT_SUBFOLDER if folder is already created else, create new folder.
2. Run the visual search
    * Visual search files: cvpr_visualsearch.m, cvpr_visualsearch_pca.m
    * Modify DESCRIPTOR_SUBFOLDER as mentioned in descriptor
    * Select approapriate distance metrics by calling following functions
        * cvpr_compare_l1
        * cvpr_compare_euclidean
        * cvpr_compare_cosine
        * cvpe_compare_mahalanobis
    *Run the script to calculate average precision, recall, mAP and standard deviation.


**Script descriptions**

1. Feature descriptors
    * descriptor_spatial.m - Spatial color descriptor function
    * descriptor_spatial_texture - Spatial texture descriptor function
    * descriptor_spatial_color_texture - Spatial texture and color descriptor function
    * descriptor_gch - Global color histogram function
    * extract_rgb - Extract rgb descriptor function
2. Distance metrics
    * cvpr_compare_l1 - L1 norm distance function takes two inpur dimensional vectors
    * cvpr_compare_euclidean - L2 norm distance function takes two inpur dimensional vectors
    * cvpr_compare_cosine - Cosine distance function takes two inpur dimensional vectors
    * cvpr_compare_mahalanobis - Mahalanobis distance between query and candidate eigen vectors


**Object classification**
1. Steps to run the code
    * Object classification script (svm_classification.m) is based on above feature descriptors
    * First run the descriptor and save the descriptors in file
    * Mention the descriptor folder in DESCRIPTOR_SUBFOLDER
    * Run the script svm_classification.m