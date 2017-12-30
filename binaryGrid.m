function [ grid ] = binaryGrid( r, c, rint, cint )
%BINARYGRID generates a boolean r x c array of gridlines separated by
%specified intervals.
% Args:
%   - r, c (int): Rows and columns in grid,
%   -rint, cint (int): Interval between repeating grid lines.

    grid = zeros(r, c, 'logical');
    grid(rint:rint:r, :) = 1;
    grid(:, cint:cint:c) = 1;

end

