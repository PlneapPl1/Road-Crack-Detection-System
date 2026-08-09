function rawMask = inferUNet(rgbImage, appCfg)

    persistent net modelCfg modelPath

    % Load model once
    if isempty(net) || isempty(modelPath) || ...
            ~strcmp(modelPath, appCfg.unetModelPath)

        if ~isfile(appCfg.unetModelPath)

            error( ...
                'UNet:ModelMissing',...
                'Cannot find model: %s',...
                appCfg.unetModelPath);

        end
        
        S = load(appCfg.unetModelPath, 'net', 'cfg');

        net = S.net;
        modelCfg = S.cfg;
        modelPath = appCfg.unetModelPath;

    end

    % Ensure RGB input
    if ndims(rgbImage) == 2 || size(rgbImage, 3) == 1
        rgbImage = repmat(rgbImage(:, :, 1), [1 1 3]);
    elseif size(rgbImage, 3) > 3
        rgbImage = rgbImage(:, :, 1:3);
    end

    % Convert image type
    if islogical(rgbImage)
        rgbImage = uint8(rgbImage) * 255;
    elseif isfloat(rgbImage)
        rgbImage = im2uint8(rgbImage);
    end

    patchSize = modelCfg.patchSize;
    stride = modelCfg.inferencePatchStride;
    threshold = modelCfg.threshold;

    imageHeight = size(rgbImage, 1);
    imageWidth = size(rgbImage, 2);

    % Pad images smaller than one patch
    paddedHeight = max(imageHeight, patchSize);
    paddedWidth = max(imageWidth, patchSize);

    paddedImage = zeros( paddedHeight, paddedWidth, ...
        3, 'like', rgbImage);

    paddedImage(1:imageHeight, 1:imageWidth, :) = rgbImage;

    rowStarts = calculatePatchStarts( paddedHeight, ...
        patchSize, stride);

    columnStarts = calculatePatchStarts( paddedWidth, ...
        patchSize, stride);

    scoreSum = zeros( paddedHeight, ...
        paddedWidth, 'single');

    scoreCount = zeros( paddedHeight, ...
        paddedWidth, 'single');

    crackClassIndex = find( string(modelCfg.classNames) == "crack", 1);

    if isempty(crackClassIndex)
        error( 'UNet:CrackClassMissing', ...
            'The model configuration does not contain a crack class.');
    end

    for row = rowStarts

        for column = columnStarts

            patch = paddedImage( row:row + patchSize - 1, ...
                column:column + patchSize - 1, :);
            try

                [~, ~, scores] = semanticseg( patch, net, ...
                'ExecutionEnvironment', 'gpu');

            catch

                [~,~,scores] = semanticseg( patch, net, ...
                'ExecutionEnvironment','cpu');

            end

            crackScore = single(scores(:, :, crackClassIndex));

            rowRange = row:row + patchSize - 1;
            columnRange = column:column + patchSize - 1;

            scoreSum(rowRange, columnRange) = ...
                scoreSum(rowRange, columnRange) + crackScore;

            scoreCount(rowRange, columnRange) = ...
                scoreCount(rowRange, columnRange) + 1;

        end
    end

    probabilityMap = scoreSum ./ max(scoreCount, 1);

    % Apply trained probability threshold
    rawMask = probabilityMap >= threshold;

    % Restore original image size
    rawMask = rawMask(1:imageHeight, 1:imageWidth);
    rawMask = logical(rawMask);

end


function starts = calculatePatchStarts(fullLength, patchSize, stride)

    lastStart = fullLength - patchSize + 1;

    starts = 1:stride:lastStart;

    if isempty(starts)
        starts = 1;
    elseif starts(end) ~= lastStart
        starts(end + 1) = lastStart;
    end

end