function letters = showLetters( letterImages )
% showLetters - create an image containing all given letter images
%
% showLetters( letterImages ) takes on the input a column cell array of images and
% puts them onto one image. This image letters is returned. All the symbols
% are put into same boxes, which have the size enough to contain the biggest
% symbol. The final image is a close to square table of these boxes.

    maxSize = [0, 0];
    for i = 1:size(letterImages, 1)
        maxSize = max(maxSize, size(letterImages{i}));
    end
    maxSize = maxSize + 1;
    
    ncols = floor(size(letterImages, 1) ^ 0.5);
    nrows = floor((size(letterImages, 1) + ncols - 1) / ncols);
    image = zeros(nrows * maxSize(1), ncols * maxSize(2));
    
    currI = 1;
    currJ = 1;
    for i = 1:size(letterImages, 1)
        image(currI * maxSize(1):currI * maxSize(1) + size(letterImages{i}, 1) - 1, ...
              currJ * maxSize(2):currJ * maxSize(2) + size(letterImages{i}, 2) - 1) = ...
              letterImages{i};
        currJ = currJ + 1;
        if currJ > ncols
            currJ = 1;
            currI = currI + 1;
        end
    end    
    letters = image;
    
%     % this code provides visualization    
%     figure;
%     if any(letters > 1)
%         imshow(uint8(letters));
%     else
%         imshow(letters);
%     end
end

