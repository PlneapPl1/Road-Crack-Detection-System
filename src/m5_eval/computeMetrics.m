function metrics = computeMetrics(predMask, groundTruth, tolerance)

% Inputs: predMask groundTruth tolerance
% Output: metrics containing: .TP .FP .FN .TN .Dice .IoU .Precision .Recall .F1Score .Accuracy .Tolerance

    arguments
        predMask
        groundTruth
        tolerance (1,1) double ...
            {mustBeNonnegative, mustBeInteger} = 2
    end

    % Validate inputs

    if isempty(predMask)
        error( 'computeMetrics:EmptyPrediction', ...
            'The prediction mask is empty.');
    end

    if isempty(groundTruth)
        error( 'computeMetrics:EmptyGroundTruth', ...
            'The ground-truth mask is empty.');
    end

    if ~ismatrix(predMask) || ~ismatrix(groundTruth)
        error( 'computeMetrics:InvalidDimensions', ...
            'Both masks must be 2-D images.');
    end

    % Convert to logical masks

    predMask = logical(predMask);
    groundTruth = logical(groundTruth);

    % Match mask sizes

    if ~isequal(size(groundTruth), size(predMask))

        groundTruth = imresize( groundTruth, size(predMask), 'nearest');

        groundTruth = logical(groundTruth);
    end

    standardTP = nnz(predMask & groundTruth);
    standardFP = nnz(predMask & ~groundTruth);
    standardFN = nnz(~predMask & groundTruth);
    standardTN = nnz(~predMask & ~groundTruth);

    if tolerance > 0

        structuringElement = strel( 'disk', tolerance, 0);

        % GT region expanded for prediction matching
        groundTruthTolerance = imdilate( groundTruth, structuringElement);

        % Prediction region expanded for GT matching
        predictionTolerance = imdilate( predMask, structuringElement);

    else

        groundTruthTolerance = groundTruth;
        predictionTolerance = predMask;

    end

    matchedPredictionPixels = predMask & groundTruthTolerance;

    TPPrecision = nnz(matchedPredictionPixels);
    FP = nnz(predMask & ~groundTruthTolerance);

    matchedGroundTruthPixels = groundTruth & predictionTolerance;

    TPRecall = nnz(matchedGroundTruthPixels);
    FN = nnz(groundTruth & ~predictionTolerance);

    % Precision
    precisionDenominator = TPPrecision + FP;

    if precisionDenominator == 0
        precisionValue = 0;
    else
        precisionValue = TPPrecision / precisionDenominator;
    end

    % Recall
    recallDenominator = TPRecall + FN;

    if recallDenominator == 0
        recallValue = 0;
    else
        recallValue = TPRecall / recallDenominator;
    end

    % F1-score / tolerance-aware Dice
    if precisionValue + recallValue == 0
        f1Value = 0;
    else
        f1Value = 2 * precisionValue * recallValue / (precisionValue + recallValue);
    end

    diceValue = f1Value;

    % Tolerance-aware IoU

    toleranceIntersection = nnz( predictionTolerance & groundTruthTolerance);

    toleranceUnion = nnz( predictionTolerance | groundTruthTolerance);

    if toleranceUnion == 0
        iouValue = 0;
    else
        iouValue = toleranceIntersection / toleranceUnion;
    end

    % Standard pixel accuracy
    totalPixels = standardTP + standardFP + standardFN + standardTN;

    if totalPixels == 0
        accuracyValue = 0;
    else
        accuracyValue = (standardTP + standardTN) / totalPixels;
    end

    metrics = struct();

    metrics.TP = TPPrecision;
    metrics.TPPrecision = TPPrecision;
    metrics.TPRecall = TPRecall;

    metrics.FP = FP;
    metrics.FN = FN;
    metrics.TN = standardTN;

    metrics.Dice = diceValue;
    metrics.IoU = iouValue;
    metrics.Precision = precisionValue;
    metrics.Recall = recallValue;
    metrics.F1Score = f1Value;
    metrics.Accuracy = accuracyValue;

    metrics.Tolerance = tolerance;

end