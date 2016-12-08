%REQUIRES: MIN DIMENSION OF INPUT IMAGE IS GREATER THAN GAUSS_SIGMA RATIO
%produces a "painting" of the input photograph in the pointilist style
%of Georges Suerat. Note that the funtion tends to fail on images with large
%regions of purple because it rotates purple hues towards yellow and lime
%green.

%I have had a bug where sometimes the function will write images as though 255
%is the max value and sometimes as through 1 is the max value. I'm not sure what
%causes this bug, but if you get an output that is completely black, you
%can try running the function a few times, or multiplying/dividing the
%result by 255 before displaying and writing to the output file.
function [] = dots(inputName, outputName)

    %DEFAULT PARAMETERS  
    if(nargin < 2)
        outputName = 'out.jpg';
        if (nargin < 1)
            inputName = 'eiffel-tower.jpg';
        end
    end
    
    %GLOBAL VARS 
    NUM_CHANNELS = 3;
    IM_MAX = 255;
    COLOR_JITTER_FACTOR = .4; %how much should colors deviate from the image sample
    INPUT_FOLDER = './inputs/';
    OUTPUT_FOLDER = './outputs/';
    
    %INITIALIZE USEFUL VARS
    inputIm = imread([INPUT_FOLDER inputName]);
    [h,w,~] = size(inputIm);
    minDim = min(h,w);
    dotRadius = minDim / 200;
    result = zeros(h,w,NUM_CHANNELS)+ 255.;
    result = result / IM_MAX;
    
    %DOT LOCATIONS
    stepSize = 1.5 * dotRadius;
    [X,Y] = meshgrid(1:stepSize:w, 1:stepSize:h);
    X = X(:);
    Y = Y(:) + dotRadius/2;
    sizeX = size(X);
    radii = (ones(sizeX) * dotRadius);
    %how far should be place dots from grid locations
    centerJitters = [1.5*(dotRadius.*rand(sizeX(1),2)), zeros(sizeX)];
    circleCenters = [X Y radii] + centerJitters;
    
    %SAMPLE COLORS
    rs = table2array(rowfun(@(col,row) (rand(1)*50 + inputIm(floor(min(h,row)),floor(min(w,col)),1)),array2table(circleCenters(:,1:2))));
    gs = table2array(rowfun(@(col,row) (rand(1)*50 + inputIm(floor(min(h,row)),floor(min(w,col)),2)),array2table(circleCenters(:,1:2))));
    bs = table2array(rowfun(@(col,row) (rand(1)*50 + inputIm(floor(min(h,row)),floor(min(w,col)),3)),array2table(circleCenters(:,1:2))));
    
    %OFFSET COLORS FROM TRUE SAMPLED VALUES
    redJitters = rand(sizeX(1),1)*COLOR_JITTER_FACTOR-.5*COLOR_JITTER_FACTOR;
    greenJitters = rand(sizeX(1),1)*COLOR_JITTER_FACTOR-.5*COLOR_JITTER_FACTOR;
    blueJitters = zeros(sizeX(1),1);%rand(sizeX(1),1)*COLOR_JITTER_FACTOR-.5*COLOR_JITTER_FACTOR;
    colorJitters = [redJitters greenJitters blueJitters];
    colors = double([rs gs bs])/IM_MAX + colorJitters;
    
    %RANDOMLY PERMUTE CIRCLES SO THERE ISN'T A VISIBLE BIAS IN THE IMAGE
    posAndColors = [circleCenters colors];
    posAndColors = posAndColors(randperm(size(posAndColors,1)),:,:);
    circleCenters = posAndColors(:,1:3,:);
    colors = posAndColors(:,4:6,:);
    
    %DRAW ALL OF THE CIRCLES IN PARALLEL (SEQUENTIAL IS DEATH HERE)
    result = insertShape(result, 'filledcircle', circleCenters, 'Opacity', .9, 'Color', colors);
    
    %CONVERT TO HSV FOR SOME MORE SPECIALIZED COLOR FILTERING
    hsv = rgb2hsv(result);
    
    %SATURATE THE YELLOWS AND ORANGES
    yellowOrangeMask = ((hsv(:,:,1) >= .1) & (hsv(:,:,1) <= .14));
    satFilter = cat(3,cat(3,[1],[1.2]),[1]);
    saturatedHSV = hsv;
    saturatedHSV(:,:,2) = roifilt2(satFilter,hsv(:,:,2),yellowOrangeMask);
    
    %DEVALUE(CLOSER TO BLACK) THE GREENS
    greenMask = ((saturatedHSV(:,:,1) > .19) & (saturatedHSV(:,:,1) <= .35));
    valFilter = .9;
    valFilteredHSV = saturatedHSV;
    valFilteredHSV(:,:,3) = roifilt2(valFilter,saturatedHSV(:,:,3),greenMask);
    
    %HUE ROTATE THE PURPLES TOWARDS YELLOW/LIME_GREEN
    purpleMask = ((hsv(:,:,1) >= .6) & (hsv(:,:,1) <= .75));
    hueFilteredHSV = valFilteredHSV;
    hueFilteredHSV(:,:,1) = roifilt2(saturatedHSV(:,:,1),purpleMask,@(hue)mod(hue+.5,1));
    
    %NOTE THAT IF THE OUTPUT IMAGE APPEARS COMPLETELY BLACK, MULTIPLY BY
    %255 HERE AND/OR RUN THE PIPELINE A FEW MORE TIMES
    result = hsv2rgb(hueFilteredHSV);
    imshow(result);
    imwrite(result,[OUTPUT_FOLDER, outputName])
end