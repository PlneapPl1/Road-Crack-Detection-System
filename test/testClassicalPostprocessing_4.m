clear;
clc;
close all;

% Initialize project

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

cfg = defaultConfig();

% Select input image

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

%% Display results

figure( 'Name', 'Post-processing Test', 'NumberTitle', 'off');

subplot(3, 3, 1);
imshow(rgbImage);
title('Input Image');

subplot(3, 3, 2);
imshow(data.groundTruth);
title('Ground Truth');

subplot(3, 3, 3);
axis off;
text( 0.1, 0.5, sprintf( ['Otsu min area: %d\n', 'Sauvola min area: %d\n', 'Canny final min area: %d'], ...
        cfg.post.otsuMinArea, ...
        cfg.post.sauvolaMinArea, ...
        cfg.post.cannyFinalMinArea), 'FontSize', 11);

subplot(3, 3, 4);
imshow(otsuRaw);
title('Otsu Raw');

subplot(3, 3, 7);
imshow(otsuFinal);
title('Otsu Final');

subplot(3, 3, 6);
imshow(cannyRaw);
title('Canny Raw');

subplot(3, 3, 5);
imshow(sauvolaRaw);
title('Sauvola Raw');

subplot(3, 3, 8);
imshow(sauvolaFinal);
title('Sauvola Final');

subplot(3, 3, 9);
imshow(cannyFinal);
title('Canny Final');

%% Print foreground-pixel counts

fprintf('Otsu raw pixels:      %d\n', nnz(otsuRaw));
fprintf('Otsu final pixels:    %d\n', nnz(otsuFinal));

fprintf('Sauvola raw pixels:   %d\n', nnz(sauvolaRaw));
fprintf('Sauvola final pixels: %d\n', nnz(sauvolaFinal));

fprintf('Canny raw pixels:     %d\n', nnz(cannyRaw));
fprintf('Canny final pixels:   %d\n', nnz(cannyFinal));