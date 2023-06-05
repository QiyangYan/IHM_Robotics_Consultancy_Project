clear all
close all

%% configuration
% webcamlist % get name from this
cam = webcam('FaceTime HD Camera');
% preview(cam)

%% video processing
disp("Video processing start")

for n = 1:200
    img = snapshot(cam);
    img = imgaussfilt(img);
    imshow(img)
    hold on;

    hsv_img = rgb2hsv(img);
    mask = getMask(hsv_img);
    mask = medfilt2(mask);
    seOpening = strel('disk', 5);
    mask = imopen(mask,seOpening);
    mask = imclose(mask,seOpening);
    
    
    % Calculate the centroid using regionprops, based on the bounding box
    s = regionprops(mask, 'Centroid');
    if ~isempty(s)
        centroid = s.Centroid;
        centroidX = centroid(1);
        centroidY = centroid(2);
        disp(['Centroid coordinates: (', num2str(centroidX), ', ', num2str(centroidY), ')']);
        plot(centroidX, centroidY, 'r+', 'MarkerSize', 10);
        hold on;
    end
    
    % % Calculate the bounding box using regionprops
    % s = regionprops(mask, 'BoundingBox');
    % boundingBox = s.BoundingBox;
    % 
    % % Display the bounding box on the original image
    % rectangle('Position', boundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
    % hold off;
   
    
    % draw contour
    contourData = bwboundaries(mask);
    for k = 1:numel(contourData)
        contour = contourData{k};
        plot(contour(:,2), contour(:,1), 'y', 'LineWidth', 2);
        hold on;
    end
end

%% END
delete(cam)
disp("END")



%% Functions
function mask = getMask(hsv_img) 
    
    % light_green = [35, 60, 30] ./ 255;
    % dark_green = [99, 255, 255] ./ 255;
    light_green = [40, 60, 100] ./ 255; % within gripper
    dark_green = [99, 255, 255] ./ 255;

    % light_purple = [110, 43, 46] ./ 255;
    % dark_purple = [155, 255, 255] ./ 255;
    % 
    % light_yellow = [18, 65, 46] ./ 255;
    % dark_yellow = [30, 255, 255] ./ 255;
    % 
    % light_red = [0, 43, 46] ./ 255;
    % dark_red = [5, 255, 255] ./ 255;
    % 
    % light_blue = [100, 60, 50] ./ 255;
    % dark_blue = [117, 255, 255] ./ 255;
    
    % 提取H、S、V通道
    H = hsv_img(:, :, 1);
    S = hsv_img(:, :, 2);
    V = hsv_img(:, :, 3);
    
    % get mask
    mask = (H > light_green(1) & H < dark_green(1)) & (S > light_green(2) & S < dark_green(2)) & (V > light_green(3) & V < dark_green(3));

end