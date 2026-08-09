
function cfg = defaultConfig()
    %% Project root

    cfg.projectRoot = fileparts(fileparts(mfilename('fullpath')));


    %% Main folders

    cfg.dataRoot = fullfile(cfg.projectRoot, 'data');
    cfg.resultRoot = fullfile(cfg.projectRoot, 'results');
    cfg.scriptRoot = fullfile(cfg.projectRoot, 'scripts');
    cfg.srcRoot = fullfile(cfg.projectRoot, 'src');
    cfg.testRoot = fullfile(cfg.projectRoot, 'test');

    %% app and model folders
    
    cfg.appRoot = fullfile( cfg.srcRoot, 'm6_app');
    cfg.modelRoot = fullfile( cfg.srcRoot, 'm4_dl');
    
    %% Dataset folders

    cfg.trainImageDir = fullfile(cfg.dataRoot, 'train');
    cfg.testImageDir = fullfile(cfg.dataRoot, 'test');


    %% U-Net configuration

    cfg.unetModelPath = fullfile( cfg.modelRoot, 'trained_unet_final.mat');

    cfg.unetInputSize = [256 256 3];
    cfg.unetThreshold = 0.4;


    %% Otsu configuration

    %cfg.otsuGaussianSigma = 2.5;
    %cfg.otsuThresholdScale = 0.70;
    %cfg.otsuDarkQuantile = 0.08;
    cfg.otsu.gaussianSigma = 2.5;
    cfg.otsu.seedFactor = 0.70;
    cfg.otsu.seedCap = 0.03;
    cfg.otsu.growFactor = 0.80;
    cfg.otsu.growCap = 0.08;
    cfg.otsu.minArea = 80;
    cfg.otsu.closeRadius = 2;


    %% Sauvola configuration

    % Processing resolution
    cfg.sauvola.outputSize = [360 640];

    % Pre-processing
    cfg.sauvola.useCLAHE = true;
    cfg.sauvola.claheClipLimit = 0.02;

    % Sauvola normalization constant
    cfg.sauvola.R = 1.0;

    % Whether dark pixels are treated as cracks
    cfg.sauvola.detectDarkCracks = true;

    % Adaptive Sauvola

    cfg.sauvola.enableAdaptive = true;

    % Primary and fallback levels
    cfg.sauvola.adaptiveWindowSizes = [165 101 71];
    cfg.sauvola.adaptiveKValues = [0.55 0.45 0.35];

    % Quality check performed on the processing resolution
    cfg.sauvola.adaptiveQualityMinArea = 300;

    % Trigger fallback only when the primary result is nearly empty
    cfg.sauvola.adaptiveMinForegroundRatio = 0.001;
    cfg.sauvola.adaptiveMinLargestArea = 300;

    % Reject excessively dense fallback masks
    cfg.sauvola.adaptiveMaxForegroundRatio = 0.40;

    cfg.sauvola.adaptiveVerbose = false;

    %% Canny configuration

    %cfg.cannyGaussianSigma = 3.5;
    %cfg.cannyThreshold = [0.28 0.52];
    %cfg.cannyEdgeSigma = 1.5;
    cfg.canny.preGaussianSigma = 1.0;
    cfg.canny.internalSigma = 0.8;
    cfg.canny.darkWindow = 51;
    cfg.canny.darkStdFactor = 0.50;
    cfg.canny.supportRadius = 6;
    cfg.canny.minLength = 40;
    cfg.canny.spurIterations = 5;
    cfg.canny.closeRadius = 2;
    cfg.canny.outputRadius = 3;


    %% Post-processing configuration

    % Otsu
    cfg.post.otsuMinArea = 80;
    cfg.post.otsuClosingRadius = 1;

    % Sauvola

    cfg.post.sauvolaMinArea = 300;
    cfg.post.sauvolaClosingRadius = 1;
    cfg.post.sauvolaUseShapeFilter = true;
    cfg.post.sauvolaMinAspectRatio = 3.0;

    % Canny
    cfg.post.cannyInitialMinArea = 20;
    cfg.post.cannyMinEccentricity = 0.85;
    cfg.post.cannySpurIterations = 5;
    cfg.post.cannyClosingRadius = 1;
    cfg.post.cannyDilationRadius = 1;
    cfg.post.cannyFinalMinArea = 30;

    % U-Net

    % U-Net simple post-processing
    cfg.post.unetSimpleMinArea = 10;
    cfg.post.unetSimpleClosingRadius = 1;

    % U-Net hard post-processing
    cfg.post.unetCC.initialAreaRemove = 10;

    cfg.post.unetCC.minArea = 25;
    cfg.post.unetCC.minMajorLength = 20;
    cfg.post.unetCC.minEccentricity = 0.80;
    cfg.post.unetCC.minAspectRatio = 2.5;
    cfg.post.unetCC.minSkeletonLength = 18;

    cfg.post.unetCC.maxMeanWidth = 8;
    cfg.post.unetCC.minSkeletonDensity = 0.08;

    cfg.post.unetCC.maxCompactAspectRatio = 2.0;
    cfg.post.unetCC.compactSolidity = 0.90;
    cfg.post.unetCC.compactExtent = 0.45;

    cfg.post.unetCC.lineLength = 4;
    cfg.post.unetCC.finalAreaRemove = 20;

    %% Unet post processing setting

    % true:U-Net hard post; false:U-Net simple post
    cfg.post.useAggressiveUNetPost = false; 

    %% Overlay configuration

    cfg.overlayAlpha = 0.55;


    %% Status configuration

    cfg.statusResetDelay = 2;

    %% Evaluation configuration
    
    cfg.metricTolerance = 2;

    %% Output configuration

    cfg.saveAppScreenshot = true;
    cfg.saveMetricsCSV = true;


end