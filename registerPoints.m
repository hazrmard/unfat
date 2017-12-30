function [ a, s, t ] = registerPoints( x, y )
%registerPoints uses SVD to map one set of points to another (set x to set
%y).
% Args:
%   - x, y: N x 2 arrays of x/y coords
% Returns:
%   - a: angle in degrees of rotation of x to y
%   - s: scaling factor
%   - t: translation vector from x to y

mx = mean(x);
my = mean(y);

nx = x - mx;
ny = y - my;

C = nx' * ny;

[U, D, V] = svd(C);

% Following section attempts to find an optimal scaling between x and y
% point sets. Currently scaling is set to 1.
% https://stackoverflow.com/questions/13432805/finding-translation-and-scale-on-two-sets-of-points-to-get-least-square-error-in#32244818
if det(C) < 0
    D(2,2) = D(2,2) * -1;
end
ss = sum(ny(:, 1).^2 + ny(:, 2).^2) / length(ny(:, 1));  % variance magnitude

R = V * diag([1, det(V*U)]) *V';    % Rotation matrix
a = abs(acos(R(1,1))) * 180 / pi;   % Rotation angle (degrees)
% s = trace(D) / ss;                % scale factor
s = 1;
t = my - (s * R * mx')';            % translation vector
end

