function [binaryTextImage, grayscaleTextImage] = preprocessTextImage(TextImage)
% preprocessTextImage - create an aligned binary image from given RGB image
%
% preprocessTextImage( TextImage ) takes on the input an M-by-N-by-3 matrix
% describing the initial RGB image with text. The function performs two
% main transformations on the image:
% - the image is binarized;
% - the image skew is detected and eliminated using Hough Transform.
%
% On the step of binarization Single Scale Retinex algorithm is used to
% compensate difference in illumination. It requires gaussian blurring to
% be performed.
%
% On the output there are both binary image and grayscale image - both deskewed.

    % binarisation step
    grayscaleImage = TextImage(:, :, 1) * 0.2126 + ...
                     TextImage(:, :, 2) * 0.7152 + ...
                     TextImage(:, :, 3) * 0.0722;

    % Create the gaussian filter
    % standard heuristic: radius ~ 3 * sigma
    filterSize = 101; % this number must be odd
    filterSigma = filterSize / 6;
    gaussianFilter = fspecial('gaussian', [filterSize, filterSize], filterSigma);
    blurredImage = imfilter(grayscaleImage, gaussianFilter, 'full');
    gap = (filterSize - 1) / 2;
    blurredImage = blurredImage(gap + 1:end-gap, gap + 1:end-gap);

    % this code provides visualization    
    % figure;
    % imshow(blurredImage)

    % Single-Scale Retinex algorithm
    threshold = 0.8; % this parameter is responsible for contrast
    SSRImage = log(double(grayscaleImage)) - log(double(blurredImage));
    SSRImage = max(min(SSRImage + threshold, threshold), 0) * 255 / threshold;

    % this code provides visualization    
    %imshow(uint8(SSRImage));
    
    % binarization itself
    binarizationThreshold = 0.8; 
    % every pixel with luminance more than this gets white
    binaryTextImage = im2bw(uint8(SSRImage), binarizationThreshold);
    % the image is inverted 
    % letters become white and significant for all Matlab functions
    binaryTextImage = ~binaryTextImage;

    % skew detection step
    % compute Hough transform
    mode = 'Sum';
    thetaRange = [-90:0.1:-85, 85:0.1:89.5];
    [H, T] = hough(binaryTextImage, 'RhoResolution', 2, 'Theta', thetaRange);
    thetaIndex = chooseSkewIndex(H, mode);

    rotationAngle = -sign(T(thetaIndex)) * 90 + T(thetaIndex);
    binaryTextImage = imrotate(binaryTextImage, rotationAngle, 'bilinear', 'crop');
    grayscaleTextImage = uint8(imrotate(255 - uint8(SSRImage), ...
        rotationAngle, 'bilinear', 'crop'));
end