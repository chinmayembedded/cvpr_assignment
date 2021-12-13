function F = descriptor_spatial_texture(img, row_size, col_size, bins, thresh)

blur_filter = [1 1 1 ; 1 1 1 ; 1 1 1] ./ 9;
edge_filter_x =  [1 2 1 ; 0 0 0 ; -1 -2 -1] ./ 4;
edge_filter_y = edge_filter_x';
img_size = size(img);
img_height = img_size(1);
img_width = img_size(2);
gray_img = img(:,:,1) * 0.3 + img(:,:,2) * 0.59 + img(:,:,3) * 0.11;
dst = [];
for i = 1:row_size
    for j=1:col_size
        
        box_height = img_height/row_size;
        box_width = img_width/col_size;
        
        x1= round((i-1)*box_height);
        if x1<1
           x1 = 1;
        end
        x2 = round( i*box_height);
        
        y1= round((j-1)*box_width);
        if y1 <1
           y1 = 1;
        end
        y2 = round( j*box_width);
        %fprintf('%d %d %d %d\n',x1, y1, x2, y2);
        % Grids in image
        grid_img = gray_img(x1:x2, y1:y2, :);
        
   
        % Edge magnitude and edge direction
        blur_img = conv2(grid_img, blur_filter, 'same');
        Dx = conv2(blur_img, edge_filter_x, 'same');
        Dy = conv2(blur_img, edge_filter_y, 'same');
        
        magnitude = sqrt(Dx.^2 + Dy.^2);
        theta = atan2(Dy,Dx);
        
        theta = theta - min(reshape(theta, 1, []));
        
        hist = bins_histogram(magnitude, theta, bins, thresh);
        dst = [dst hist];
    end
end
F=dst;
return;


function F=bins_histogram(magnitude, theta, bins, thresh)

grid_res = size(theta);
height = grid_res(1);
width = grid_res(2);

bin_vals = [];
for i = 1:height
    for j = 1:width
        if magnitude(i, j) > thresh
            
            norm_theta = theta(i, j) / (2 * pi);
            bin_val = floor(norm_theta * bins);
            bin_vals = [bin_vals bin_val];
            
        end
    end
end

if size(bin_vals, 2) == 0
    F = zeros(1, bins);
else
    hist= histogram(bin_vals, bins, 'Normalization', 'probability');
    F = hist.Values;
end
return; 
