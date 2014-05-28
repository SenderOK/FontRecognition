#include "mex.h"
#include "matrix.h"
#include <vector>
#include <queue>
#include <cmath>

using namespace std;

const int inf = 1000000000;
const int di[4] = {-1, 0, 0, 1};
const int dj[4] = {0, -1, 1, 0};

int dist;

int distanceMap(vector<vector<int> > &intersectImage)
{
    if (intersectImage.size() == 0 || intersectImage[0].size() == 0) {
        return 0;
    }
    int m = intersectImage.size();
    int n = intersectImage[0].size();
    queue< pair<int, int> > coordinates;
    for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j ) {            
            if (intersectImage[i][j] == 0) {
                coordinates.push(pair<int, int>(i, j));
            } else {
                intersectImage[i][j] = inf;
            }
        }
    }
    
    int distSumSqr = 0;
    while (!coordinates.empty()) {
        pair<int, int> currPos = coordinates.front();
        coordinates.pop();
        for (int i = 0; i < 4; ++i) {
            int newI = currPos.first + di[i];
            int newJ = currPos.second + dj[i];
            if (newI >= 0 && newI < m && newJ >= 0 && newJ < n) {
                int dNew = intersectImage[currPos.first][currPos.second] + 1;
                if (intersectImage[newI][newJ] > dNew) {
                    intersectImage[newI][newJ] = dNew;
                    coordinates.push(pair<int, int> (newI, newJ));
                    distSumSqr += dNew * dNew;
                    if (distSumSqr > dist) {
                        return inf;
                    }
                }
            }
        }
    }
    return distSumSqr;
}

void imscale(vector<vector<mxLogical> >& image, double scale)
{
    int resM = int(floor(image.size() * scale + 0.5));
    int resN = int(floor(image[0].size() * scale + 0.5));
    vector<vector<mxLogical> > result(resM);
    for (int i = 0; i < resM; ++i) {
        result[i].resize(resN);
        for (int j = 0; j < resN; ++j) {
            result[i][j] = image[int(i / scale)][int(j / scale)];
        }
    }
    image = result;
}

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
	// validate the input
    if (nrhs != 2) {
	    mexErrMsgIdAndTxt("letterDistance:nrhs", "Two inputs required.");
    }

	if (nlhs != 4) {
    	mexErrMsgIdAndTxt("letterDistance:nlhs", "Four outputs required.");
	}
    
	if (!mxIsLogical(prhs[0]) || 
        mxGetNumberOfDimensions(prhs[0]) != 2 ||
		mxGetNumberOfElements(prhs[0]) == 0) {
		mexErrMsgIdAndTxt("letterDistance:nrhs", 
                "letterBase must be a 2D logical matrix");
	}
    
    if (!mxIsLogical(prhs[1]) || 
        mxGetNumberOfDimensions(prhs[1]) != 2 ||
		mxGetNumberOfElements(prhs[1]) == 0) {
		mexErrMsgIdAndTxt("letterDistance:nrhs", 
                "letter2 must be a 2D logical matrix");
	}
    
    mwSize letterBaseM = mxGetM(prhs[0]);
    mwSize letterBaseN = mxGetN(prhs[0]);
    mxLogical *letterBasePr = mxGetLogicals(prhs[0]);
    vector< vector<mxLogical> > letterBase(letterBaseM);
    for (mwSize i = 0; i < letterBaseM; ++i) {
        letterBase[i].resize(letterBaseN);
        for (mwSize j = 0; j < letterBaseN; ++j) {
            letterBase[i][j] = letterBasePr[i + j * letterBaseM];
        }
    }
    
    mwSize letter2M = mxGetM(prhs[1]);
    mwSize letter2N = mxGetN(prhs[1]);
    mxLogical *letter2Pr = mxGetLogicals(prhs[1]);
    vector< vector<mxLogical> > letter2(letter2M);
    for (mwSize i = 0; i < letter2M; ++i) {
        letter2[i].resize(letter2N);
        for (mwSize j = 0; j < letter2N; ++j) {
            letter2[i][j] = letter2Pr[i + j * letter2M];
        }
    }    
    // the input is obtained
    
    double dimensionThreshold = 5;
    // the same letters must have nearly the same dimensions
    if (fabs((double(letterBaseM) / letter2M) * letter2N - letterBaseN) > 
        dimensionThreshold) {
        plhs[0] = mxCreateDoubleScalar(double(inf));
        plhs[1] = mxCreateDoubleScalar(double(0));
        plhs[2] = mxCreateDoubleScalar(double(0));
        plhs[3] = mxCreateLogicalMatrix(mwSize(0), mwSize(0));
        return;
    }
    
    if (letterBaseM != letter2M) {
        imscale(letter2, double(letterBaseM) / letter2M);
        letter2M = letter2.size();
        letter2N = letter2[0].size();
    }
    
    const int shiftI[9] = {0, 0,  0, -1, 1, -1, -1,  1, 1};
    const int shiftJ[9] = {0, 1, -1,  0, 0, -1,  1, -1, 1};
    
    int bestI, bestJ;
    dist = inf;    
    
    for(int k = 0; k < 5; ++k) {
        int i = shiftI[k];
        int j = shiftJ[k];
        int letter2MinRow = max(1, 1 - i) - 1;
        int letter2MaxRow = min(letterBaseM - i, letter2M) - 1;
        int letter2MinCol = max(1, 1 - j) - 1;
        int letter2MaxCol = min(letterBaseN - j, letter2N) - 1;

        int letterBaseMinRow = max(1, 1 + i) - 1;
        int letterBaseMaxRow = min(i + letter2M, letterBaseM) - 1;
        int letterBaseMinCol = max(1, 1 + j) - 1;
        int letterBaseMaxCol = min(j + letter2N, letterBaseN) - 1;

        int intersectNrows = letterBaseMaxRow - letterBaseMinRow + 1;
        int intersectNcols = letterBaseMaxCol - letterBaseMinCol + 1;
        vector< vector<int> > intersectImage(intersectNrows);
        for (int p = 0; p < intersectNrows; ++p) {
            intersectImage[p].resize(intersectNcols);
            for (int q = 0; q < intersectNcols; ++q) {
                intersectImage[p][q] = 
                    letterBase[letterBaseMinRow + p][letterBaseMinCol + q] !=
                    letter2[letter2MinRow + p][letter2MinCol + q];
                // we have 1 if they differ
            }
        }

        int currDist = distanceMap(intersectImage);            
        if (currDist < dist) {
            dist = currDist;
            bestI = i;
            bestJ = j;
        }
    }
    
    // time to fill outputs
    plhs[0] = mxCreateDoubleScalar(double(dist));
           
    int letter2MinRow = max(1, 1 - bestI) - 1;
    int letter2MaxRow = min(letterBaseM - bestI, letter2M) - 1;
    int letter2MinCol = max(1, 1 - bestJ) - 1;
    int letter2MaxCol = min(letterBaseN - bestJ, letter2N) - 1;
            
    int letterBaseMinRow = max(1, 1 + bestI) - 1;
    int letterBaseMaxRow = min(bestI + letter2M, letterBaseM) - 1;
    int letterBaseMinCol = max(1, 1 + bestJ) - 1;
    int letterBaseMaxCol = min(bestJ + letter2N, letterBaseN) - 1;
    
    plhs[1] = mxCreateDoubleScalar(double(letterBaseMinRow + 1));
    plhs[2] = mxCreateDoubleScalar(double(letterBaseMinCol + 1));
        
    int intersectNrows = letterBaseMaxRow - letterBaseMinRow + 1;
    int intersectNcols = letterBaseMaxCol - letterBaseMinCol + 1;
    plhs[3] = mxCreateLogicalMatrix((mwSize)intersectNrows, (mwSize)intersectNcols);
    mxLogical *result = (mxLogical *)mxGetData(plhs[3]);
    for (int p = 0; p < intersectNrows; ++p) {
        for (int q = 0; q < intersectNcols; ++q) {
            result[p + q * intersectNrows] = 
                letter2[letter2MinRow + p][letter2MinCol + q];
        }
    }
}