function overlayImage = createOverlay(rgbImage, mask, cfg)

    % Inputs: rgbImage, mask and cfg
    
    % Output: overlayImage

    arguments
        rgbImage
        mask
        cfg struct
    end

    % Validate inputs

    if isempty(rgbImage)
        error( 'createOverlay:EmptyImage', 'The input image is empty.');
    end

    if isempty(mask)
        error( 'createOverlay:EmptyMask', 'The crack mask is empty.');
    end

    % Ensure RGB format

    if ismatrix(rgbImage) || size(rgbImage, 3) == 1

        rgbImage = repmat(rgbImage, [1 1 3]);

    elseif size(rgbImage, 3) ~= 3

        error( 'createOverlay:InvalidChannels', 'The image must have one or three channels.');
    end

    % Convert image and mask

    overlayImage = im2single(rgbImage);
    mask = logical(mask);

    % Match mask size to image size

    imageSize = size(overlayImage, [1 2]);

    if ~isequal(size(mask), imageSize)

        mask = imresize(mask, imageSize, 'nearest');
        mask = logical(mask);
    end

    % Read overlay transparency

    alpha = cfg.overlayAlpha;

    if alpha < 0 || alpha > 1
        error( 'createOverlay:InvalidAlpha', 'cfg.overlayAlpha must be between 0 and 1.');
    end

    % Apply red overlay

    redChannel = overlayImage(:, :, 1);
    greenChannel = overlayImage(:, :, 2);
    blueChannel = overlayImage(:, :, 3);

    redChannel(mask) = (1 - alpha) .* redChannel(mask) + alpha;
    greenChannel(mask) = (1 - alpha) .* greenChannel(mask);
    blueChannel(mask) = (1 - alpha) .* blueChannel(mask);

    overlayImage(:, :, 1) = redChannel;
    overlayImage(:, :, 2) = greenChannel;
    overlayImage(:, :, 3) = blueChannel;

end