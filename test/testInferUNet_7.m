clear;
clc;
close all;

%% Initialize project

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

cfg = defaultConfig();

%% Select image

[file, path] = uigetfile( {'*.jpg', 'Road Images'}, 'Select a road image', cfg.testImageDir);

if isequal(file, 0)
    disp('Image selection cancelled.');
    return;
end

imagePath = fullfile(path, file);

%% Load and preprocess

data = loadImagePair(imagePath);

[rgbImage, ~] = preprocessImage( data.image, cfg);

%% Run U-Net inference

startTime = tic;

unetRaw = inferUNet( rgbImage, cfg);

processingTime = toc(startTime);

%% Optional post-processing

unetFinal = postprocessMask( unetRaw, 'U-Net', cfg);

%% Display

figure( 'Name', 'U-Net Inference Test', 'NumberTitle', 'off');

subplot(2, 2, 1);
imshow(rgbImage);
title('Input Image');

subplot(2, 2, 2);

if data.hasGroundTruth
    imshow(data.groundTruth);
    title('Ground Truth');
else
    imshow(false(size(unetRaw)));
    title('Ground Truth Not Found');
end

subplot(2, 2, 3);
imshow(unetRaw);
title('U-Net Raw Mask');

subplot(2, 2, 4);
imshow(unetFinal);
title('U-Net Final Mask');

fprintf('U-Net raw size: %s\n', mat2str(size(unetRaw)));
fprintf('U-Net raw class: %s\n', class(unetRaw));
fprintf('Processing time: %.3f s\n', processingTime);

if data.hasGroundTruth
    rawMetrics = computeMetrics( unetRaw, data.groundTruth);

    finalMetrics = computeMetrics( unetFinal, data.groundTruth);

    fprintf('\nRaw Dice: %.3f\n', rawMetrics.Dice);
    fprintf('Final Dice: %.3f\n', finalMetrics.Dice);
end