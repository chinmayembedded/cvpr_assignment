function F = descriptor_spatial(img, row_size, col_size)

img_size = size(img);
img_height = img_size(1);
img_width = img_size(2);
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
        grid_img = img(x1:x2, y1:y2, :);
        rgb_vals = extract_rgb(grid_img);
        dst = [dst rgb_vals(1) rgb_vals(2) rgb_vals(3)];
    end
end
F=dst;
return;

