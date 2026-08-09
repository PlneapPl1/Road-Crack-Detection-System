clear;
clc;
close all;

%% Initialize project

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

cfg = defaultConfig();

%% Select an input image

[file, path] = uigetfile( {'*.jpg', 'Image Files'}, 'Select a road image');

if isequal(file, 0)
    disp('No image selected.');
    return;
end

inputImage = imread(fullfile(path, file));

%% Run preprocessing module

[rgbImage, grayImage] = preprocessImage(inputImage, cfg);

%% Display results

figure( 'Name', 'Preprocessing Test', 'NumberTitle', 'off');

subplot(1, 3, 1);
imshow(inputImage);
title('Input Image');

subplot(1, 3, 2);
imshow(rgbImage);
title(sprintf('RGB Image: %s', class(rgbImage)));

subplot(1, 3, 3);
imshow(grayImage);
title(sprintf('Grayscale Image: %s', class(grayImage)));

%% Print information

fprintf('Input size:      %s\n', mat2str(size(inputImage)));
fprintf('RGB size:        %s\n', mat2str(size(rgbImage)));
fprintf('Grayscale size:  %s\n', mat2str(size(grayImage)));

fprintf('Input class:     %s\n', class(inputImage));
fprintf('RGB class:       %s\n', class(rgbImage));
fprintf('Grayscale class: %s\n', class(grayImage));