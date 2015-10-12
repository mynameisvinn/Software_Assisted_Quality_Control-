#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <stdio.h>
#include <iostream>
#include <cmath>

/*
function:
---------
created on 9/9/15.

function applies laplacian convolution to determine absence of edges, a scenario indicative of blurriness. 

a blurred image will not have steep 2nd derivatives, 

in blurry images, pixel values change gradually through the matrix. the slow and gradual change in intensities means
blurry images will not have steep 2nd derivatives. we can find "flat" pixels through laplacian convolution, a procedure
that calculates 2nd derivatives.


returns:
-------
variance of image pixels following laplacian operation. variance can be thresholded to remove blurry images.

on detecting blurring through laplacian operation, review http://www.pyimagesearch.com/2015/09/07/blur-detection-with-opencv/
laplacian code: http://docs.opencv.org/master/de/db2/laplace_8cpp-example.html#gsc.tab=0
*/

using namespace cv;
using namespace std;

Mat calculate_laplacian(Mat *src_gray_ptr); // function for laplacian convolution
float calculate_variance(Mat abs_dst); // function for variance calculation, following laplacian convolution


int main(int argc, const char** argv)
{
	
	Mat src, src_gray, *src_gray_ptr, abs_dst;	

	// read and inspect image
	src = imread(argv[1], 1); // second flag: -1 loads color; 0 for grayscale; 1 for unchanged
	
	// exception handling if file doesnt exist
	if (!src.data)
	{
		cout << "no image!";
			return -1;
	}

	imshow("actual", src);
	waitKey(0);
	destroyWindow("actual");

	

	// denoise by blurring with a gaussian filter
	// laplacian operation is highly sensitive to noise since it takes the second derivative
	GaussianBlur(src, src, Size(3, 3), 0, 0, BORDER_DEFAULT);

	// convert "src" matrix to grayscale "src_gray" matrix
	cvtColor(src, src_gray, CV_RGB2GRAY);

	// inspect grayscale image
	imshow("grayscale", src_gray);
	waitKey(0);
	destroyWindow("grayscale");

	// apply laplacian convolution to grayscale image
	src_gray_ptr = &src_gray; // grab matrix address with &
	abs_dst = calculate_laplacian(src_gray_ptr); // pass (aka pointer) to laplacian function

	// calculate variance follow laplacian convolution
	calculate_variance(abs_dst);

	return 0;

}


Mat calculate_laplacian(Mat *src_gray_ptr){
	
	/*
	function:
	---------
	applies laplacian convolution to grayscale image. although laplacian is typically used to detect edges, we'll use laplacian convolved image to detect presence
	steep 2nd derivatives, which are prevalent in in-focus images.
	*/
	
	// initialize matrices for operations
	Mat src_gray, raw_dst, abs_dst;
	
	// initialize arguments for laplacian operator
	int kernel_size = 3;
	int scale = 1;
	int delta = 0;
	int ddepth = CV_16S;

	// grab actual matrix from pointer
	src_gray = *src_gray_ptr;
	
	// apply laplacian convolution to grayscale image and store results in "raw_dst" matrix
	Laplacian(src_gray, raw_dst, ddepth, kernel_size, scale, delta, BORDER_DEFAULT); // dst is the laplacian output
	convertScaleAbs(raw_dst, abs_dst); // since laplacian values can be negative, we want to take the absolute value
	
	// inspect laplacian image
	imshow("laplacian", abs_dst);
	waitKey(0);
	destroyWindow("laplacian");
	
	// return abs_dst matrix for variance calculation
	return abs_dst;
}



float calculate_variance(Mat abs_dst){

	/*
	function:
	---------
	calculates variance from image array. first, the mean pixel value is calculated. then, the sum of squared difference between each pixel and the mean pixel value is calculated.

	reference: https://stackoverflow.com/questions/19098875/mean-variance-in-c-with-2d-array
	*/

		

	int cols, rows;
	float sum_of_values = 0; // accumulator to calculate average
	float sum_of_squared_differences = 0; // accumulator to calculate variance

	float mean_pixel_value, variance;

	cols = abs_dst.cols;
	rows = abs_dst.rows;

	// loop through each pixel in the image to calculate mean value
	for (int i = 0; i < cols; i++) {
		for (int j = 0; j < rows; j++) {

			// accessing image matrix values at http://opencvexamples.blogspot.com/2013/10/assessing-pixel-values-of-image.html
			// since this is a grayscale image, pixel_value will be a scalar value. otherwise it would be a vector.
			Scalar pixel_value = abs_dst.at<uchar>(i, j); 
			sum_of_values += pixel_value.val[0];
		}
	}

	// mean pixel value is simply sum divided by matrix size
	mean_pixel_value = sum_of_values / (cols * rows);

	// now looop through each pixel to calculate squared difference 
	for (int i = 0; i < cols; i++) {
		for (int j = 0; j < rows; j++) {

			// grayscale value means variable should be scalar
			Scalar pixel_value = abs_dst.at<uchar>(i, j);
			sum_of_squared_differences += ((pixel_value.val[0] - mean_pixel_value) * (pixel_value.val[0] - mean_pixel_value));
		}
	}

	variance = sum_of_squared_differences / (cols * rows);

	cout << variance;
	
	return variance;
}