function props = findLetters( bwImage )    
% findLetters - extract symbols from given bwImage
%
% findLetters( bwImage ) takes on the input a binary image with text (it 
% could be generated by function preprocessTextImage) and returns the
% information about symbols in the format of function regionprops. 
% props is array of structures, each of which contains fields 'Area',
% 'Image' and 'BoundingBox' found by regionprops function.
%
% Only 60 percent of connectivity components are considered as symbols: 20
% percent of images with the area too small and 20 percent of images with
% area too big are ignored.

    props = regionprops(bwconncomp(bwImage, 4), 'Area', 'Image', 'BoundingBox');
    areas = [props.Area];
    [~, indicesSorted] = sort(areas); 
    props = props(indicesSorted);
    outliersThreshold = floor(length(props) * 0.20);
    props = props(1 + outliersThreshold : end - outliersThreshold);
    props = props(randperm(length(props)));
end
