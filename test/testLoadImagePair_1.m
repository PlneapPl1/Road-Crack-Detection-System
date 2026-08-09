clear;
clc;
close all;

%% Initialize project

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

cfg = defaultConfig();

%% Select one road image

[file, path] = uigetfile( {'*.jpg' 'Road Images'}, 'Select a road image', cfg.testImageDir);
                                                                                                                                                                    
if isequal(file, 0)
    disp('Image selection cancelled.');
    return;
end

imagePath = fullfile(path, file);

%% Load image and ground truth

data = loadImagePair(imagePath);

%% Display results

figure( 'Name', 'Image Pair Test', 'NumberTitle', 'off');

subplot(1, 2, 1);
imshow(data.image);
title('Input Image');

subplot(1, 2, 2);

if data.hasGroundTruth
    imshow(data.groundTruth);
    title('Ground Truth');
else
    imshow(false(size(data.image, 1), size(data.image, 2)));
    title('Ground Truth Not Found');
end

%% Print information

fprintf('Image path: %s\n', data.imagePath);
fprintf('Base name: %s\n', data.baseName);
fprintf('Image size: %s\n', mat2str(size(data.image)));
fprintf('Ground truth available: %d\n', data.hasGroundTruth);

if data.hasGroundTruth
    fprintf('Ground truth path: %s\n', data.groundTruthPath);
    fprintf('Ground truth size: %s\n', ...
        mat2str(size(data.groundTruth)));
    fprintf('Ground truth class: %s\n', ...
        class(data.groundTruth));
end