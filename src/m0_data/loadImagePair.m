
function data = loadImagePair(imagePath)

% Input: imagePath 

% Output: data containing:.image. imagePath .baseName .groundTruth .groundTruthPath .hasGroundTruth

arguments
    imagePath {mustBeTextScalar}
end

imagePath = char(imagePath);

% Validate image path

if ~isfile(imagePath)
    error( 'loadImagePair:ImageNotFound', 'Input image not found: %s', imagePath);
end

% Load input image

inputImage = imread(imagePath);

[imageFolder, baseName, ~] = fileparts(imagePath);

% Locate same-name PNG ground truth

candidateNames = { [baseName '.png'], [baseName '_mask.png']};

groundTruthPath = '';
hasGroundTruth = false;

for k = 1:numel(candidateNames)

    candidate = fullfile(imageFolder,candidateNames{k});

    if isfile(candidate)

        groundTruthPath = candidate;
        hasGroundTruth = true;
        break;

    end
end

if hasGroundTruth

    groundTruthRaw = imread(groundTruthPath);

    % Convert RGB ground truth to grayscale if necessary
    if ndims(groundTruthRaw) == 3 && ...
            size(groundTruthRaw, 3) == 3

        groundTruthRaw = rgb2gray(groundTruthRaw);
    end

    % Convert 0/1 or 0/255 labels to logical mask
    groundTruth = groundTruthRaw > 0;

    % Match the input image size
    imageSize = size(inputImage, [1 2]);

    if ~isequal(size(groundTruth), imageSize)

        groundTruth = imresize( ...
            groundTruth, ...
            imageSize, ...
            'nearest');
    end

    groundTruth = logical(groundTruth);

else

    groundTruth = [];
    groundTruthPath = '';
end

% Package outputs

data = struct();

data.image = inputImage;
data.imagePath = imagePath;
data.baseName = baseName;

data.groundTruth = groundTruth;
data.groundTruthPath = groundTruthPath;
data.hasGroundTruth = hasGroundTruth;

end