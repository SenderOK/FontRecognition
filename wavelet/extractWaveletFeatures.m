function features = extractWaveletFeatures(gsImage, props)
% extractWaveletFeatures - extract wavelet features from the given image
%
% extractWaveletFeatures(gsImage, props) takes on the input grayscale and
% props extracted from the binary image. If both of them are given, then the 
% features are extracted from the table of grayscale letter images produced 
% by showLetters.
%
% If only grayscale image is given, then the features are extracted right
% from it.

    sizeSquare = 30;
    if (nargin > 1)         
        props = props(1:min(sizeSquare * sizeSquare, length(props)));
        for i = 1:size(props, 1)        
            r = (props(i).BoundingBox(2) + 0.5) + (1:props(i).BoundingBox(4));
            c = (props(i).BoundingBox(1) + 0.5) + (1:props(i).BoundingBox(3));
            im = gsImage(r, c);
            im(~props(i).Image) = 0;
            props(i).Image = imresize(im, [25, NaN]);
        end
        
        len = length(props);
        for i = len + 1:sizeSquare * sizeSquare
            props(i) = props(i - len);
        end

        images = cell(size(props));
        for i = 1:size(props, 1)
            images{i} = props(i).Image;
        end
        image = showLetters(images);
    else
        image = gsImage;
    end

    nLevels = 4;
    features = [];

    for i = 1:nLevels
       [C, S] = wavedec2(image, 1, 'coif2');
       image = reshape(C(1:S(1, 1) * S(1, 2)), S(1, :));
       S(3, :) = S(2, :);
       S(4, :) = S(2, :);
       imagesNumels = cumsum([1; S(:, 1) .* S(:, 2)]);
       for j = 1:4
           currImage = C(imagesNumels(j):imagesNumels(j + 1) - 1);
           features = [features, mean(currImage), std(currImage)]; %#ok<AGROW>
       end
    end
    
    for i = 1:nLevels
       [C, S] = wavedec2(image, 1, 'coif3');
       image = reshape(C(1:S(1, 1) * S(1, 2)), S(1, :));
       S(3, :) = S(2, :);
       S(4, :) = S(2, :);
       imagesNumels = cumsum([1; S(:, 1) .* S(:, 2)]);
       for j = 1:4
           currImage = C(imagesNumels(j):imagesNumels(j + 1) - 1);
           features = [features, mean(currImage), std(currImage)]; %#ok<AGROW>
       end
    end
end