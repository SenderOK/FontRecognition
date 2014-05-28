function classifyFontsWavelet( pathToInfo )
% classifyFontsWavelet - solve the fonts recognition problem using wavelets
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
    trainingAnswers = cell(1, 0);
    trainingImages = 0;
    waveletFeatures = [];
    for i = 1:linesNumber
        currData = textscan(lines{i}, '%s', 'Delimiter', ';');
        if numel(currData{1}) > 1 
            % the file is from training set
            fprintf('Training on %s\n', currData{1}{1});
            tic;
            image = imread([pathToData, currData{1}{1}]);
            trainingImages = trainingImages + 1;
            [binaryTextImage, grayscaleTextImage] = preprocessTextImage(image);
            trainingAnswers{trainingImages} = [currData{1}{2}, ';', currData{1}{3}, ';', currData{1}{4}];
            %waveletFeatures = [waveletFeatures; extractWaveletFeatures(grayscaleTextImage)]; %#ok<AGROW>
            waveletFeatures = [waveletFeatures; ...
                extractWaveletFeatures(grayscaleTextImage, findLetters(binaryTextImage))]; %#ok<AGROW>            
            toc;
        end
    end
    m = mean(waveletFeatures);
    d = std(waveletFeatures);
    waveletFeatures = bsxfun(@minus, waveletFeatures, m);
    waveletFeatures = bsxfun(@rdivide, waveletFeatures, d);
    knnModel = ClassificationKNN.fit(waveletFeatures, 1:length(trainingAnswers), 'Distance', 'cityblock');
    
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
            %currWavelet = extractWaveletFeatures(grayscaleTextImage);
            currWavelet = extractWaveletFeatures(grayscaleTextImage, findLetters(binaryTextImage));
            currWavelet = (currWavelet - m) ./ d;
            closestAlphabetIndex = predict(knnModel, currWavelet);
            fprintf(resultFid, '%s;%s\n', lines{i}, trainingAnswers{closestAlphabetIndex});
            toc;
        end
    end    
    fclose('all');
end