
function rawMask = detectClassical(grayImage, methodName, cfg)

% Inputs: grayImage - Single-channel grayscale road image, methodName - 'Otsu', 'Sauvola', or 'Canny', cfg - Project configuration structure

% Output: rawMask    - Logical raw crack mask before post-processing

    arguments
        grayImage
        methodName {mustBeTextScalar}
        cfg struct
    end

    % Validate grayscale image

    if isempty(grayImage)
        error( 'detectClassical:EmptyInput', 'The grayscale input image is empty.');
    end

    if ~ismatrix(grayImage)
        error( 'detectClassical:InvalidImage', 'grayImage must be a single-channel 2-D image.');
    end

    % Standardize grayscale image to double in [0, 1]
    if islogical(grayImage)

        grayImage = double(grayImage);

    elseif isinteger(grayImage)

        grayImage = im2double(grayImage);

    else

        grayImage = im2double(mat2gray(grayImage));

    end

    originalSize = size(grayImage);

    switch lower(char(methodName))

        case 'otsu'

            % Raw Otsu: global threshold with dark polarity
            otsuThreshold = graythresh(grayImage);

            rawMask = grayImage < otsuThreshold;


        case 'sauvola'

            % Validate Sauvola configuration
            if ~isfield(cfg, 'sauvola')

                error( 'detectClassical:MissingSauvolaConfig', ...
                    'The configuration does not contain cfg.sauvola.');

            end

            P = cfg.sauvola;

            requiredFields = { ...
                'outputSize', ...
                'useCLAHE', ...
                'claheClipLimit', ...
                'R', ...
                'detectDarkCracks', ...
                'enableAdaptive', ...
                'adaptiveWindowSizes', ...
                'adaptiveKValues', ...
                'adaptiveQualityMinArea', ...
                'adaptiveMinForegroundRatio', ...
                'adaptiveMinLargestArea', ...
                'adaptiveMaxForegroundRatio', ...
                'adaptiveVerbose'};


            for fieldIndex = 1:numel(requiredFields)

                if ~isfield(P, requiredFields{fieldIndex})

                    error( 'detectClassical:MissingSauvolaParameter', ...
                        'Missing Sauvola parameter: cfg.sauvola.%s', ...
                        requiredFields{fieldIndex});

                end

            end

            if numel(P.adaptiveWindowSizes) ~= numel(P.adaptiveKValues)

                error( 'detectClassical:InvalidAdaptiveSauvolaConfig', ...
                    ['cfg.sauvola.adaptiveWindowSizes and ', ...
                    'cfg.sauvola.adaptiveKValues must have ', ...
                    'the same number of elements.']);

            end

            % Process at the same resolution used during parameter tuning

            originalSize = size(grayImage);

            if originalSize(1) > originalSize(2)

                processingSize = fliplr(P.outputSize);   % [640 360]

            else

                processingSize = P.outputSize;           % [360 640]

            end

            sauvolaImage = imresize( grayImage, ...
                processingSize, 'bilinear');

            % CLAHE enhancement
            if P.useCLAHE

                sauvolaImage = adapthisteq( sauvolaImage, ...
                    'ClipLimit',  P.claheClipLimit);

            end

            % Configure parameter levels

            if P.enableAdaptive

                windowCandidates = P.adaptiveWindowSizes(:)';

                kCandidates = P.adaptiveKValues(:)';

            else

                % Use only the first parameter level
                windowCandidates = P.adaptiveWindowSizes(1);

                kCandidates = P.adaptiveKValues(1);

            end

            % Adaptive Sauvola: primary result with conditional fallback

            numberOfLevels = numel(windowCandidates);
            candidateMasks = cell(1, numberOfLevels);

            candidateForegroundRatios = zeros(1, numberOfLevels);
            candidateLargestAreas = zeros(1, numberOfLevels);

            selectedLevel = 1;

            for levelIndex = 1:numberOfLevels

                windowSize = round(windowCandidates(levelIndex));
                currentK = kCandidates(levelIndex);

                % Ensure valid odd window size
                windowSize = max(windowSize, 3);

                if mod(windowSize, 2) == 0
                    windowSize = windowSize + 1;
                end

                maximumWindowSize = min(size(sauvolaImage));

                if mod(maximumWindowSize, 2) == 0
                    maximumWindowSize = maximumWindowSize - 1;
                end

                windowSize = min(windowSize, maximumWindowSize);

                % Local mean and standard deviation
                localKernel = ones( ...
                    windowSize, ...
                    windowSize, ...
                    'double') / windowSize^2;

                localMean = imfilter( ...
                    sauvolaImage, ...
                    localKernel, ...
                    'symmetric', ...
                    'same');

                localMeanSquare = imfilter( ...
                    sauvolaImage .^ 2, ...
                    localKernel, ...
                    'symmetric', ...
                    'same');

                localVariance = max( ...
                    localMeanSquare - localMean .^ 2, ...
                    0);

                localStd = sqrt(localVariance);

                % Threshold map
                thresholdMap = localMean .* ...
                    (1 + currentK .* ...
                    (localStd ./ P.R - 1));

                thresholdMap = min(max(thresholdMap, 0), 1);

                % Candidate mask
                if P.detectDarkCracks
                    candidateMask = sauvolaImage < thresholdMap;
                else
                    candidateMask = sauvolaImage > thresholdMap;
                end

                candidateMask = logical(candidateMask);
                candidateMasks{levelIndex} = candidateMask;

                % Quality information
                foregroundRatio = nnz(candidateMask) / numel(candidateMask);

                qualityMask = bwareaopen( ...
                    candidateMask, ...
                    P.adaptiveQualityMinArea, ...
                    8);

                connectedComponents = bwconncomp(qualityMask, 8);

                if connectedComponents.NumObjects > 0

                    componentSizes = cellfun( ...
                        @numel, ...
                        connectedComponents.PixelIdxList);

                    largestArea = max(componentSizes);

                else

                    largestArea = 0;

                end

                candidateForegroundRatios(levelIndex) = foregroundRatio;
                candidateLargestAreas(levelIndex) = largestArea;

            end


            %% Select primary result unless it clearly failed

            selectedLevel = 1;

            primaryForegroundRatio = candidateForegroundRatios(1);
            primaryLargestArea = candidateLargestAreas(1);

            primaryFailed = ...
                primaryForegroundRatio < P.adaptiveMinForegroundRatio || ...
                primaryLargestArea < P.adaptiveMinLargestArea;

            if P.enableAdaptive && primaryFailed

                % Try fallback levels in order.
                % Select the first fallback that passes the minimum-quality checks.

                fallbackFound = false;

                for levelIndex = 2:numberOfLevels

                    currentRatio = candidateForegroundRatios(levelIndex);
                    currentLargestArea = candidateLargestAreas(levelIndex);

                    fallbackValid = ...
                        currentRatio >= P.adaptiveMinForegroundRatio && ...
                        currentRatio <= P.adaptiveMaxForegroundRatio && ...
                        currentLargestArea >= P.adaptiveMinLargestArea;

                    if fallbackValid

                        selectedLevel = levelIndex;
                        fallbackFound = true;
                        break;

                    end

                end

                % If none passes, keep the original primary result.
                % This avoids replacing a weak result with an even noisier result.
                if ~fallbackFound
                    selectedLevel = 1;
                end

            end

            workingMask = candidateMasks{selectedLevel};


            % Optional debugging output

            if P.adaptiveVerbose

                fprintf( ...
                    ['Adaptive Sauvola: level=%d, ', ...
                    'window=%d, k=%.2f, ', ...
                    'foregroundRatio=%.4f, ', ...
                    'largestArea=%d\n'], ...
                    selectedLevel, ...
                    windowCandidates(selectedLevel), ...
                    kCandidates(selectedLevel), ...
                    candidateForegroundRatios(selectedLevel), ...
                    candidateLargestAreas(selectedLevel));

            end


            % Restore raw mask to original image size

            rawMask = imresize( workingMask, originalSize, 'nearest');



        case 'canny'

            % Raw Canny: MATLAB automatic threshold
            rawMask = edge(grayImage, 'Canny');


        otherwise

            error( 'detectClassical:UnknownMethod', ...
                ['Unsupported classical method: %s. ', ...
                'Use Otsu, Sauvola, or Canny.'], methodName);

    end

    rawMask = logical(rawMask);

end