function index = chooseSkewIndex( H, mode )
% chooseSkewIndex - find an index of rotation angle acccording to Hough matrix
%
% chooseSkewIndex( H, mode ) takes on the input the output matrix of
% MatLab function hough and the string mode, defining which criterion should be
% used to find the optimal skew angle.
%
% Mode can be 'Sum' or 'SumGradient'.
% If the mode 'Sum' is chosen, then the sum of squares is maximized.
% If the mode 'SumGradient' is chosen, then the sum of squared differences 
% is maximized.

    if strcmp(mode, 'Sum')  
        alignmentQualityEstimate = sum(H .^ 2);
    elseif strcmp(mode, 'SumGradient')
        alignmentQualityEstimate = sum(diff(H) .^ 2);
    else
        error('chooseSkewIndex: Unknown mode');
    end

    [~, index] = max(alignmentQualityEstimate);
end

