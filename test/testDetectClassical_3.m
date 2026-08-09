clear;
clc;
close all;

%% Initialize project

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

cfg = defaultConfig();

%% Select input image

[file, path] = uigetfile( {'*.jpg', 'Road Images'}, 'Select a road image', cfg.testImageDir);

if isequal(file, 0)
    disp('Image selection cancelled.');
    return;
end

imagePath = fullfile(path, file);

% Load image and ground truth

data = loadImagePair(imagePath);

% Preprocess image

[rgbImage, grayImage] = preprocessImage( data.image, cfg);

%% Run classical detection methods

otsuMask = detectClassical( grayImage, 'Otsu', cfg);

sauvolaMask = detectClassical( grayImage, 'Sauvola', cfg);

cannyMask = detectClassical( grayImage, 'Canny', cfg);

%% Display results

figure( 'Name', 'Classical Detection Test', 'NumberTitle', 'off');

subplot(2, 3, 1);
imshow(rgbImage);
title('Input Image');

subplot(2, 3, 2);
imshow(grayImage);
title('Grayscale Image');

subplot(2, 3, 3);

if data.hasGroundTruth
    imshow(data.groundTruth);
    title('Ground Truth');
else
    imshow(false(size(grayImage)));
    title('Ground Truth Not Found');
end

subplot(2, 3, 4);
imshow(otsuMask);
title('Otsu Raw Mask');

subplot(2, 3, 5);
imshow(sauvolaMask);
title('Sauvola Raw Mask');

subplot(2, 3, 6);
imshow(cannyMask);
title('Canny Raw Mask');

%% Print output information

fprintf('Image: %s\n', data.baseName);
fprintf('Image size: %s\n', mat2str(size(data.image)));
fprintf('Gray size: %s\n', mat2str(size(grayImage)));

fprintf('\nOtsu mask:\n');
fprintf('  Size: %s\n', mat2str(size(otsuMask)));
fprintf('  Class: %s\n', class(otsuMask));
fprintf('  Foreground pixels: %d\n', nnz(otsuMask));

fprintf('\nSauvola mask:\n');
fprintf('  Size: %s\n', mat2str(size(sauvolaMask)));
fprintf('  Class: %s\n', class(sauvolaMask));
fprintf('  Foreground pixels: %d\n', nnz(sauvolaMask));

fprintf('\nCanny mask:\n');
fprintf('  Size: %s\n', mat2str(size(cannyMask)));
fprintf('  Class: %s\n', class(cannyMask));
fprintf('  Foreground pixels: %d\n', nnz(cannyMask));