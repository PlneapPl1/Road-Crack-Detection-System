
function [rgbImage, grayImage] = preprocessImage(inputImage, cfg)

arguments
    inputImage
    cfg struct
end

% Validate input

if isempty(inputImage)
    error( 'preprocessImage:EmptyInput', 'The input image is empty.');
end

if ndims(inputImage) > 3
    error( 'preprocessImage:InvalidDimensions', ['The input image must be a 2-D grayscale image ', 'or a 3-D RGB image.']);
end

% Prepare RGB image for U-Net and grayscale image for classical methods

if ismatrix(inputImage) || size(inputImage, 3) == 1  % check if it is a 二维或者三维单通道的image; ||:或，前后只要有一者成立就是true.

    % Input is already grayscale
    grayImage = inputImage;

    % Keep height and width unchanged and copy the image
    % three times along the channel dimension
    rgbImage = repmat(inputImage, [1 1 3]);  %将它第一二维复制一次，第三维（通道）复制三次，由此转变成三通道图,生成 RGB 形式。

elseif size(inputImage, 3) == 3  %本来就是三通道图RGB, 不需要操作，直接input,

    % Input is already RGB
    rgbImage = inputImage;

    % Create a grayscale copy for classical methods
    grayImage = rgb2gray(inputImage);

else

    error( ...
        'preprocessImage:InvalidChannels', ...
        'The input image must have either one or three channels.');
end

% Keep both outputs as uint8 for consistent classical processing.

if islogical(rgbImage)  % logical false = 0 true  = 1

    rgbImage = uint8(rgbImage) * 255;  % 0 black, 255 white

elseif isa(rgbImage, 'double') || isa(rgbImage, 'single')

    rgbImage = im2uint8(mat2gray(rgbImage));
end

if islogical(grayImage)

    grayImage = uint8(grayImage) * 255;

elseif isa(grayImage, 'double') || isa(grayImage, 'single')

    grayImage = im2uint8(mat2gray(grayImage));
end

end