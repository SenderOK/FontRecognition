function classifyFonts( pathToInfo )
% trainFonts - solve the fonts recognition problem
%
% classifyFontsWavelet( pathToInfo ) takes on the input path to the
% file containing data about training and testing sets.
%
% Example: classifyFontsWavelet(".\info.txt");

    rng(1543);
    fid = fopen(pathToInfo, 'r');
    pathToData = pathToInfo(1:max(strfind(pathToInfo, filesep)));
  
    lines = cell(0, 1);
    linesNumber = 0;
    
    line = fgetl(fid);
    while ~isequal(line, -1) 
        linesNumber = linesNumber + 1;
        lines{linesNumber} = line;
        line = fgetl(fid);
    end
    % the data is read
    
    % training cycle
    trainingAlphabets = cell(1, 0);
    trainingAnswers = cell(1, 0);
    alphabetsNumber = 0;
    waveletFeatures = [];
    boldnessEstimates = [];
    for i = 1:linesNumber
        currData = textscan(lines{i}, '%s', 'Delimiter', ';');
        if numel(currData{1}) > 1 
            % the file is from training set
            fprintf('Training on %s\n', currData{1}{1});
            tic;
            image = imread([pathToData, currData{1}{1}]);
            alphabetsNumber = alphabetsNumber + 1;
            [binaryTextImage, grayscaleTextImage] = preprocessTextImage(image);
            props = findLetters(binaryTextImage);
            [trainingAlphabets{alphabetsNumber}, boldness] = extractLetters(props);
            trainingAnswers{alphabetsNumber} = currData{1}(2:4);
            
            waveletFeatures = [waveletFeatures; extractWaveletFeatures(grayscaleTextImage, props)]; %#ok<AGROW>
            boldnessEstimates = [boldnessEstimates; boldness]; %#ok<AGROW>
            toc;
        end
    end
    m = mean(waveletFeatures);
    d = std(waveletFeatures);
    waveletFeatures = bsxfun(@minus, waveletFeatures, m);
    waveletFeatures = bsxfun(@rdivide, waveletFeatures, d);
    
    resultFid = fopen('result.txt', 'w');
    % testing cycle
    for i = 1:linesNumber
        currData = textscan(lines{i}, '%s', 'Delimiter', ';'); 
        if numel(currData{1}) == 1
            % we are reading test section
            fprintf('Testing on %s\n', currData{1}{1});
            tic;
            image = imread([pathToData, currData{1}{1}]);
            [binaryTextImage, grayscaleTextImage] = preprocessTextImage(image);
            props = findLetters(binaryTextImage);
            [currAlphabet, boldness] = extractLetters(props);
            currWavelet = extractWaveletFeatures(grayscaleTextImage, props);
            currWavelet = (currWavelet - m) ./ d;
                                                                     
            recognized1 = 0;
            closestAlphabetIndex = 0;
            recognized2 = 0;
            secondClosestAlphabetIndex = 0;
            % in this cycle we will find two closest alphabets
            for j = 1:alphabetsNumber
                currAlphabetDistance = alphabetDistance(currAlphabet, trainingAlphabets{j});
                
                if recognized2 < length(currAlphabet) - currAlphabetDistance
                    recognized2 = length(currAlphabet) - currAlphabetDistance;
                    secondClosestAlphabetIndex = j;
                    if recognized1 < recognized2
                        tmp = recognized1;
                        recognized1 = recognized2;
                        recognized2 = tmp;
                        
                        tmp = closestAlphabetIndex;
                        closestAlphabetIndex = secondClosestAlphabetIndex;
                        secondClosestAlphabetIndex = tmp;
                    end
                end
            end
            fprintf('Closest alphabets: similarity to first = %d; similarity to second = %d; gap = %d\n', ...
                    recognized1, recognized2, recognized1 - recognized2);
                
            % correction stage
            if abs(recognized1 - recognized2) < 2
                if strcmp(trainingAnswers{closestAlphabetIndex}{1}, trainingAnswers{secondClosestAlphabetIndex}{1}) && ...
                   ~strcmp(trainingAnswers{closestAlphabetIndex}{2}, trainingAnswers{secondClosestAlphabetIndex}{2})
                    fprintf('resolving boldness conflict\n');
                    if abs(boldnessEstimates(secondClosestAlphabetIndex) - boldness) < ...
                       abs(boldnessEstimates(closestAlphabetIndex) - boldness)
                        closestAlphabetIndex = secondClosestAlphabetIndex;
                    end
                elseif (recognized1 == recognized2) && ...
                    (sum(abs(waveletFeatures(secondClosestAlphabetIndex, :) - currWavelet)) < ...
                     sum(abs(waveletFeatures(closestAlphabetIndex, :) - currWavelet)))
                     closestAlphabetIndex = secondClosestAlphabetIndex;
                end
            end
            fprintf(resultFid, '%s;%s;%s;%s\n', lines{i}, trainingAnswers{closestAlphabetIndex}{1}, ...
                trainingAnswers{closestAlphabetIndex}{2}, trainingAnswers{closestAlphabetIndex}{3});
            toc;
        end
    end
    fclose('all');
end