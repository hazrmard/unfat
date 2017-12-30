% Unfat is a script that attempts to transform faces from before to after fat
% loss. It transforms images using two non-rigid registration approaches:
% 
% * Polynomial function,
% * Thin plate splines
% 
% The algorithm proceeds as follows:
% 
% Input: 2x images of equal size and capturing the same orientation of face.
% Input: A choice of method (1: polynomial, 2: splines),
% Input: Number or corresponding features on both faces to use as basis for
%         transformation.
% Input: Selection of matching feature points on both images for e.g click on
%         images to select eyes, lips, hairline, nose etc.
% 
% - The two point sets are first rigidly registered to each other to account
%  for any minor rotations and translations.
% - Based on the method, a matrix A is generated from a polynomial/spline
%  transformation of points selected from the 'after' or target image such that:
%     A * c = x
%  Where c is a matrix of weights for the terms in A, and x is the set of
%  points from the 'before' or source image. Using the point selections, the
%  constants are obtained as:
%     c = A \ x
%  Then using c and A, the rest of the image can be transformed. Constants
%  are chosen for the mapping from 'after' to 'before' images so that the
%  reverse transformation can be compatible with interpolation.
%  
%  Output: The 'before' image transformed to look like the 'after' image.

% sfile = input('Enter source image file name: ', 's');
% tfile = input('Enter target image file name: ', 's');
% method = imput('Enter method (1: polynomial, 2: spline): ');
% default arguments
sfile = 'imgs/1a.jpg';  % before
tfile = 'imgs/1b.jpg';  % after
method = 1;
source = rgb2gray(imread(sfile));
target = rgb2gray(imread(tfile));

% avoid graphics bugs
opengl('save', 'software');

% if cached==true, then load previously saved point sets
cached = true;
cachefile = 'cache.mat';

subplot(2,2,1); imshow(source); hold on;
subplot(2,2,2); imshow(target);  hold on;

if ~cached
    N = input('Enter number of features: ');

    % set up feature arrays
    xc1 = zeros(N,1);
    yc1 = zeros(N,1);
    xc2 = zeros(N,1);
    yc2 = zeros(N,1);


    % get features for before images
    subplot(2,2,1);
    title(0);
    for i=1:N
        [x, y] = ginput(1);
        xc1(i) = x;
        yc1(i) = y;
        plot(x, y, 'g*');
        title(i);
    end

    % get features for after images
    subplot(2,2,2);
    title(0);
    for i=1:N
        [x, y] = ginput(1);
        xc2(i) = x;
        yc2(i) = y;
        plot(x, y, 'r*');
        title(i);
    end

else
    load(cachefile);
    subplot(2,2,1); plot(xc1, yc1, 'g*');
    subplot(2,2,2); plot(xc2, yc2, 'r*');
end

save(cachefile, 'xc1', 'yc1', 'xc2', 'yc2', 'N');

[r, c] = size(source);
% Create a binary grid image to viisualize deformation
grid = double(binaryGrid(r, c, 8, 8));
[xg, yg] = meshgrid(1:c, 1:r);

% register source points to target points
[angle, scale, translation] = registerPoints([xc1 yc1], [xc2, yc2]);
% register source to target image
source = imresize(source, scale);
source = imrotate(source, angle, 'nearest', 'crop');
source = imtranslate(source, translation);
% transform source points
m1 = mean([xc1, yc1]);
centered = [xc1, yc1] - m1;
R = [cosd(angle), -sind(angle); sind(angle), cosd(angle)];
rotscaled = (scale * R * centered')';
translated = rotscaled + translation + m1;
xc1 = translated(:, 1);
yc1 = translated(:, 2);

% Polynomial transformation
if method == 1
    sourceMat = polyFunc(xc2, yc2);
    constants = sourceMat \ [xc1, yc1];
    xform = @(p)(polyFunc(p(:,1), p(:,2)) * constants);

% Thin-plate spline transformation
elseif method == 2    
    global cpx;
    global cpy;
    global splineconstants;
    cpx = xc1;
    cpy = yc1;
    sourceMat = splineFunc(xc2, yc2);
    splineconstants = sourceMat \ [0 0; 0 0; 0 0; xc1, yc1];
    xform = @trans;    
end

subplot(2,2,3); imshow(deformImage(xform, source, false));
subplot(2,2,4); imshow(deformImage(xform, grid, false));


function [ matrix ] = polyFunc( x, y )
% Args:
%   - x, y: vector / array of elements
% Returns:
%   - matrix: a n x 6 matrix, where each row is the transformed point
%   vector to be multiplied with coefficients and summed (in column-first precedence).
    n = numel(x);
    x = reshape(x, n, 1);
    y = reshape(y, n, 1);
    matrix = [ones(n, 1), x, y, x.*y, x.^2, y.^2];
end


function [ matrix ] = splineFunc ( x, y )
% Args:
%   - x, y: vector / array of elements
% Returns:
%   - matrix: a (3+n) x (3+n) matrix, where each row is the transformed point
%   vector to be multiplied with coefficients and summed (in column-first precedence).
    global cpx;
    global cpy;
    n = numel(x);
    x = reshape(x, n, 1);
    y = reshape(y, n, 1);
    FSum = [0 0 0 ones(1, numel(cpx))];
    xFSum = [0 0 0 cpx'];
    yFSum = [0 0 0 cpy'];
    r2 =  (x-cpx').^2 + (y-cpy').^2;
    r2logr2 = r2 .* log(r2);
    r2logr2(isnan(r2logr2)) = 0;
    f = [ones(n, 1), x, y, r2logr2];
    matrix = [FSum; xFSum; yFSum; f];
end

function [t] = trans(p)
% The transformation function for points using the thin plate spline matrix
% returned by splineFunc.
    global splineconstants;
    t = splineFunc(p(:,1), p(:,2)) * splineconstants;
    t = t(4:end, :);
end