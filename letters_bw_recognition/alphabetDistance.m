function dist = alphabetDistance( alphabet1, alphabet2 )
% alphabetDistance - calculate distance between the two alphabets
%
% alphabetDistance( alphabet1, alphabet2 ) takes on the input two cell
% arrays of alphabets provided by the function extractLetters and
% calculates the number of symbols of the first alphabet that have no
% corresponding images in the second image.

    dist = 0;
    for i = 1:length(alphabet1)
        similarFound = false;
        imageSize = numel(alphabet1{i});
        for j = 1:length(alphabet2)
            [currDist, ~, ~, ~] = letterDistance(alphabet1{i}, alphabet2{j});
            if currDist < 0.12 * imageSize
                %fprintf('%d was found similar to %d, distance = %d, imSize = %d\n', i, j, currDist, imageSize);
                similarFound = true;
                break;
            end
        end
        if ~similarFound
            dist = dist + 1;
        end
    end
end

