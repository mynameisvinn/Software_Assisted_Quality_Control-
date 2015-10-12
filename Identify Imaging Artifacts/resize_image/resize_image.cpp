#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <stdio.h>
#include <iostream>
#include <string.h>

/* 
@date: 10/12/15

function: to resize image "bay.jpg" to 10%, do $ ConsoleApplication_opencv_c2 bay.jpg .1

*/

using namespace cv;
using namespace std;


int main(int argc, const char** argv)
{

	Mat image, image_rescaled;
	float rescale_factor;
	string new_image_filename; 

	// read image path and grab rescale value from stdin
	image = imread(argv[1], 1);
	rescale_factor = atof(argv[2]); // atof converts string to float; atoi converts string to int

	// display image
	imshow("actual", image);
	waitKey(0);
	destroyWindow("actual");

	// check dimensions
	cout << image.size();

	// rescale http://codeyarns.com/2014/09/03/how-to-resize-or-rescale-in-opencv/
	resize(image, image_rescaled, cvSize(0, 0), rescale_factor, rescale_factor);

	// display rescaled image
	imshow("small", image_rescaled);
	waitKey(0);
	destroyWindow("small");

	cout << image_rescaled.size();

	// save to disk
	new_image_filename = string("small_") + argv[1];
	imwrite(new_image_filename, image_rescaled);

	return 0;
}