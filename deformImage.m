function [ imgt ] = deformImage( xform, img, forward )
%DEFORMIMAGE computes the deformed image by the xform transformation.
% Args:
%   - xform (function handle): The spatial transformation which takes
%        a n x 2 matrix of coordinates and returns a n x 2 matrix of
%        transformed points in [col, row] order.
%   - img (matrix): The image to distort. Can be logical, single, or double.
%        If logical, no interpolation is done.
%   - forward (logical): Whether xform is the forward transform or reverse
%        transform on the image. Forward transform takes current image's
%        coordinates and maps them to output image. Reverse transform
%        samples output image pixels and maps them to input image.

    [r, c] = size(img);
    % get coordinates to transform using xform
    [xgrid, ygrid] = meshgrid(1:c, 1:r);
    % transform and extract vectors of x and y
    transformed = xform([xgrid(:), ygrid(:)]);
    xt = transformed(:, 1); yt = transformed(:, 2);
    % filter points that transformed out of image bounds
    valid = ((1 <= xt) & (xt <= c)) & ((1 <= yt) & (yt <= r));
    xt = xt(valid);
    yt = yt(valid);
    inds = 1:r*c;
    validinds = inds(valid);
    
    imgt = zeros(r, c, class(img));
    if (forward)
        imgt(sub2ind([r, c], floor(yt), floor(xt))) = img(valid);
    else
       if islogical(img)
           imgt(valid) = img(sub2ind([r, c], floor(yt), floor(xt)));
       else
           interpolated = interp2(xgrid, ygrid, single(img), xt, yt, 'linear', 0);
           imgt(validinds) = interpolated;
       end
    end

end