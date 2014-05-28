function [ distance, alignI, alignJ, partialImage ] = letterDistance(letterBase, letter2)
% letterDistance - calculate distance between two letters
%
% letterDistance(letterBase, letter2) takes on the input images of two
% symbols and returns calculated via mex-file distance between these
% letters, values alignI, alignJ, and image partialImage, which is a part 
% of letter2 on the intersection with letterBase for optimal shift.
% alignI, alignJ denote position in letterBase, where partialImage should
% be put to minimize the distance.

[ distance, alignI, alignJ, partialImage ] = letterDistace(letterBase, letter2);

end

