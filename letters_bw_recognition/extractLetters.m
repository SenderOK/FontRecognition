function [alphabet, meanBoldness] = extractLetters( props )
% extractLetters - get the alphabet from the given array of symbol props
%
% extractLetters( props ) takes on the input the result of function
% regionprops. It performs naive clustering of binary symbol images and returns
% the mean alphabet - a cell-array of binary mean letter images for each found 
% cluster. Also it returns the meanBoldness - mean over the found alphabet 
% value of the fraction sum(sum(meanLetters{i})) / numel(meanLetters{i}).
    
    props = props(1:min(length(props), 500));
    
    alphabet = cell(0, 1);
    meanLetters = cell(0, 1);
    alphabetSize = 0;
    letterOccurences = [];
    for i = 1:size(props, 1)
        minDist = inf;
        closestLetter = 0;
        imageSize = numel(props(i).Image);
        for j = 1:alphabetSize
            [currDist, ~, ~, ~] = letterDistance(props(i).Image, alphabet{j});
            if currDist < minDist
                minDist = currDist;
                closestLetter = j;
            end
        end
        if minDist >= 0.15 * imageSize
            alphabetSize = alphabetSize + 1;
            alphabet{alphabetSize} = props(i).Image;
            meanLetters{alphabetSize} = double(props(i).Image);
            letterOccurences(alphabetSize) = 1;
        else
            letterOccurences(closestLetter) = letterOccurences(closestLetter) + 1;
            [~, alignI, alignJ, partialImage] = letterDistance(alphabet{closestLetter}, ...
                props(i).Image);
            meanLetters{closestLetter}(alignI:alignI + size(partialImage, 1) - 1, alignJ:alignJ + size(partialImage, 2) - 1) = ... 
            meanLetters{closestLetter}(alignI:alignI + size(partialImage, 1) - 1, ...
                                       alignJ:alignJ + size(partialImage, 2) - 1) + partialImage;
        end
    end

    meanBoldness = 0;
    binarizationThreshold = 0.5;
    for i = 1:length(meanLetters)
        meanLetters{i} = meanLetters{i} >= (letterOccurences(i) * binarizationThreshold);
        meanBoldness = meanBoldness + sum(sum(meanLetters{i})) / numel(meanLetters{i});
    end
    
    meanBoldness = meanBoldness / length(meanLetters);
    
    
%     % this code provides visualization of extracted alphabet

%     letterOccurences    
%     images = cell(size(props));
%     for i = 1:size(props, 1)
%         images{i} = props(i).Image;
%     end
%     showLetters(images);
     showLetters(meanLetters');    
%     showLetters(alphabet');
    
    alphabet = meanLetters;
end