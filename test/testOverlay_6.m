clear;
clc;
close all;

%% Initialize project

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

cfg = defaultConfig();

% Select image

[file, path] = uigetfile( {'*.jpg', 'Road Images'}, 'Select a road image', cfg.testImageDir);

if isequal(file, 0)
    disp('Image selection cancelled.');
    return;
end

imagePath = fullfile(path, file);

%% Load and preprocess

data = loadImagePair(imagePath);

[rgbImage, grayImage] = preprocessImage( data.image, cfg);

%% Generate raw masks

otsuRaw = detectClassical( grayImage, 'Otsu', cfg);

sauvolaRaw = detectClassical( grayImage, 'Sauvola', cfg);

cannyRaw = detectClassical( grayImage, 'Canny', cfg);

%% Apply post-processing

otsuFinal = postprocessMask( otsuRaw, 'Otsu', cfg);

sauvolaFinal = postprocessMask( sauvolaRaw, 'Sauvola', cfg);

cannyFinal = postprocessMask( cannyRaw, 'Canny', cfg);

%% Create overlays

otsuOverlay = createOverlay( rgbImage, otsuFinal, cfg);

sauvolaOverlay = createOverlay( rgbImage, sauvolaFinal, cfg);

cannyOverlay = createOverlay( rgbImage, cannyFinal, cfg);

%% Display results

figure( 'Name', 'Overlay Test', 'NumberTitle', 'off');

subplot(2, 3, 1);
imshow(rgbImage);
title('Input Image');

subplot(2, 3, 2);

if data.hasGroundTruth
    imshow(data.groundTruth);
    title('Ground Truth');
else
    imshow(false(size(grayImage)));
    title('Ground Truth Not Found');
end

subplot(2, 3, 3);
axis off;

text( ...
    0.15, ...
    0.5, ...
    sprintf('Overlay alpha: %.2f', cfg.overlayAlpha), ...
    'FontSize', ...
    12);

subplot(2, 3, 4);
imshow(otsuOverlay);
title('Otsu Overlay');

subplot(2, 3, 5);
imshow(sauvolaOverlay);
title('Sauvola Overlay');

subplot(2, 3, 6);
imshow(cannyOverlay);
title('Canny Overlay');