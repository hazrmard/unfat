# Unfat

*Unfat* is a Matlab script that uses non-rigid image registration to transform
before/after weight loss face pictures. See documentation in `unfat.m` for
details. *unfat* transforms images using two non-rigid registration approaches:

* Polynomial function,
* Thin plate splines

## Algorithm

Input: 2x images of equal size and capturing the same orientation of face.

Input: A choice of method (1: polynomial, 2: splines),

Input: Number or corresponding features on both faces to use as basis for
        transformation.

Input: Selection of matching feature points on both images for e.g click on
        images to select eyes, lips, hairline, nose etc.

The two point sets are first rigidly registered to each other to account
for any minor rotations and translations.

Based on the method, a matrix A is generated from a polynomial/spline
transformation of points selected from the 'after' or target image such that:

    A * c = x

Where c is a matrix of weights for the terms in A, and x is the set of
points from the 'before' or source image. Using the point selections, the
constants are obtained as:

    c = A \ x

 Then using c and A, the rest of the image can be transformed. Constants
 are chosen for the mapping from 'after' to 'before' images so that the
 reverse transformation can be compatible with interpolation.

 Output: The 'before' image transformed to look like the 'after' image.

## References

* A. Goshtasby, "Registration of images with geometric distortions," in IEEE
Transactions on Geoscience and Remote Sensing, vol. 26, no. 1, pp. 60-64,
Jan 1988. doi: 10.1109/36.3000

* EECE 6367 - Advanced Image Processing, Vanderbilt University by Benoit Dawant