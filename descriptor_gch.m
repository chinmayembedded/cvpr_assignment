function F = descriptor_gch(img, bin_size)


img = floor(img.*bin_size);

bins = (img(:,:,1)*bin_size^2) + (img(:,:,2)*bin_size) + img(:,:,3);

max_bins = size(bins,1)*size(bins,2);
bin_values = reshape(bins, 1, max_bins);

rgb_hist_values = histogram(bin_values, bin_size^3, 'Normalization', 'probability');
rgb_hist_values = rgb_hist_values.Values;
F = rgb_hist_values;

return;

