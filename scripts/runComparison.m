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

[rgbImage, grayImage] = preprocessImage( data.image, cfg);

%% Define methods

methodNames = [ ...
    "Otsu", ...
    "Sauvola", ...
    "Canny", ...
    "U-Net"];

numMethods = numel(methodNames); %计算方法数量：4， 循环4次，每次处理不同的方法

rawMasks = cell(numMethods, 1); %4*1 cell 数组，储存四种方法的 Raw Mask，rawMasks{1} = otsu Raw Mask; rawMasks{2} = Sauvola Raw Mask;...
finalMasks = cell(numMethods, 1); 
overlays = cell(numMethods, 1);
rawMetrics = cell(numMethods, 1);
finalMetrics = cell(numMethods, 1); % cell 的每个格子可以放比较复杂或不同类型的内容
processingTimes = zeros(numMethods, 1); % zeros 只保存数值

%% Run methods

for index = 1:numMethods % index 从1-numMethods（4）循环

    methodName = methodNames(index); % methodNames(1)(otsu) to ... to methodNames(4)(unet)

    startTime = tic;

    switch methodName

        case {"Otsu", "Sauvola", "Canny"}

            rawMask = detectClassical( grayImage, methodName, cfg);

        case "U-Net"

            rawMask = inferUNet( rgbImage, cfg);

        otherwise

            error( 'runComparison:UnknownMethod', 'Unsupported method: %s', methodName);
    end

    finalMask = postprocessMask( rawMask, methodName, cfg);

    overlayImage = createOverlay( rgbImage, finalMask, cfg);

    processingTimes(index) = toc(startTime);

    rawMasks{index} = rawMask;
    finalMasks{index} = finalMask;
    overlays{index} = overlayImage;

    if data.hasGroundTruth

        rawMetrics{index} = computeMetrics( rawMask, data.groundTruth);

        finalMetrics{index} = computeMetrics( finalMask, data.groundTruth);

    end
end

%% Display masks and overlays

figure( 'Name', 'Road Crack Detection Comparison', 'NumberTitle', 'off');

subplot(3, 4, 1);
imshow(rgbImage);
title('Input Image');

subplot(3, 4, 2);

if data.hasGroundTruth
    imshow(data.groundTruth);
    title('Ground Truth');
else
    imshow(false(size(grayImage)));
    title('Ground Truth Not Found');
end

subplot(3, 4, 3);
imshow(grayImage);
title('Grayscale Image');

subplot(3, 4, 4);
axis off;

text( ...
    0.05, ...
    0.7, ...
    sprintf( ...
        ['Image: %s\n', ...
         'Size: %s\n', ...
         'Overlay alpha: %.2f'], ...
        data.baseName, ...
        mat2str(size(data.image)), ...
        cfg.overlayAlpha), ...
    'FontSize', 10, ...
    'Interpreter', 'none');

for index = 1:numMethods

    subplot(3, 4, 4 + index);
    imshow(rawMasks{index});
    title(sprintf('%s Raw', methodNames(index)));

    subplot(3, 4, 8 + index);
    imshow(overlays{index});
    title(sprintf('%s Overlay', methodNames(index)));
end

%% Build metrics table

if data.hasGroundTruth

    methodColumn = strings(numMethods * 2, 1);
    resultType = strings(numMethods * 2, 1);

    dice = zeros(numMethods * 2, 1);
    iou = zeros(numMethods * 2, 1);
    precision = zeros(numMethods * 2, 1);
    recall = zeros(numMethods * 2, 1);
    f1Score = zeros(numMethods * 2, 1);
    accuracy = zeros(numMethods * 2, 1);
    timeSeconds = zeros(numMethods * 2, 1);

    row = 0;

    for index = 1:numMethods

        row = row + 1;

        methodColumn(row) = methodNames(index);
        resultType(row) = "Raw";

        dice(row) = rawMetrics{index}.Dice;
        iou(row) = rawMetrics{index}.IoU;
        precision(row) = rawMetrics{index}.Precision;
        recall(row) = rawMetrics{index}.Recall;
        f1Score(row) = rawMetrics{index}.F1Score;
        accuracy(row) = rawMetrics{index}.Accuracy;
        timeSeconds(row) = processingTimes(index);

        row = row + 1;

        methodColumn(row) = methodNames(index);
        resultType(row) = "Final";

        dice(row) = finalMetrics{index}.Dice;
        iou(row) = finalMetrics{index}.IoU;
        precision(row) = finalMetrics{index}.Precision;
        recall(row) = finalMetrics{index}.Recall;
        f1Score(row) = finalMetrics{index}.F1Score;
        accuracy(row) = finalMetrics{index}.Accuracy;
        timeSeconds(row) = processingTimes(index);
    end

    comparisonTable = table( ...
        methodColumn, ...
        resultType, ...
        dice, ...
        iou, ...
        precision, ...
        recall, ...
        f1Score, ...
        accuracy, ...
        timeSeconds, ...
        'VariableNames', { ...
            'Method', ...
            'ResultType', ...
            'Dice', ...
            'IoU', ...
            'Precision', ...
            'Recall', ...
            'F1Score', ...
            'Accuracy', ...
            'TimeSeconds'});

    disp(comparisonTable);

else

    fprintf('Ground truth is unavailable. Metrics were not calculated.\n');
end