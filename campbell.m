%This function produces a pop-art image in the style of Andy Warhol's
%Campbell's soup cans.
function [] = campbell(inputName, outputName)
    %DEFAULT PARAMETERS FOR TESTING  

    if(nargin < 2)
        outputName = 'holi-campbell.jpg';
        if (nargin < 1)
            inputName = 'holi.png';
        end
    end

    %GLOBAL VARS
    NUM_CHANNELS = 3;
    NUM_THRESHOLD_LEVELS = 2;
    INPUT_FOLDER = './inputs/';
    OUTPUT_FOLDER = './outputs/';
    
    inputIm = imread([INPUT_FOLDER inputName]);
    
    %initialize variables
    [h,w,~] = size(inputIm);
    minDim = min(h,w);
    thresholded = multithresh(inputIm,NUM_THRESHOLD_LEVELS);
    quantized = imquantize(inputIm, thresholded, [0 thresholded(2:end) 255]);
    
    %UN/COMMENT THESE LINES TO SMOOTH SPECKLED PATCHES OF THE OUTPUT
    quantized(:,:,1) = imfill(quantized(:,:,1),'holes');
    quantized(:,:,2) = imfill(quantized(:,:,2),'holes');
    quantized(:,:,3) = imfill(quantized(:,:,3),'holes');
    
    %Warhol Image
    result = zeros(h*2,w*2,NUM_CHANNELS);
    hsv = rgb2hsv(quantized);
    result(1:h,1:w,:) = hsv(:,:,:);
    
    hsv90 = hsv;
    hsv90(:,:,1) = mod(hsv90(:,:,1) + .25,1);
    result(1:h,w+1:end,:) = hsv90(:,:,:);
    
    hsv180 = hsv90;
    hsv180(:,:,1) = mod(hsv180(:,:,1) + .25,1);
    result(h+1:end,1:w,:) = hsv180(:,:,:);
    
    hsv270 = hsv180;
    hsv270(:,:,1) = mod(hsv270(:,:,1) + .25,1);
    result(h+1:end,w+1:end,:) = hsv270(:,:,:);
    
    result = hsv2rgb(result);
    
    imshow(result);
    imwrite(result,[OUTPUT_FOLDER, outputName]);
end