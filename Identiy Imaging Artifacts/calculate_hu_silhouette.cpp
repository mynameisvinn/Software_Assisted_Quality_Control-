#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <stdio.h>
#include <iostream>

using namespace cv;
using namespace std;

Mat image1, image2, imagegray1, imagegray2, imageresult1, imageresult2;
vector<vector<Point>>contours1, contours2; // vector of vector of points; C++ has a vector class unlike C
vector<Vec4i>hierarchy1, hierarchy2; // idx for contours

double score; // similarity score
int thresh = 150; // for thresholding

int calculate_hu(Mat imageresult1, Mat imageresult2); // this function performs the shape matching

int main(int argc, const char** argv)
{

	// argc = number of command line arguments 
	// argv = array of command line arguments

	// read file into memory
	image1 = imread(argv[1], 1); // 0th element in array refers to script name
	image2 = imread(argv[2], 1);

	// convert image to grayscale
	cvtColor(image1, imagegray1, CV_BGR2GRAY);
	cvtColor(image2, imagegray2, CV_BGR2GRAY);

	// detect edges
	Canny(imagegray1, imageresult1, thresh, thresh * 2);
	Canny(imagegray2, imageresult2, thresh, thresh * 2);

	// call calculate hu moments to match shapes
	calculate_hu(imageresult1, imageresult2);
	return 0;
}

int calculate_hu(Mat imageresult1, Mat imageresult2){

	// given two images, calculate contours for both objects

	findContours(imageresult1, contours1, hierarchy1, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cvPoint(0, 0));
	findContours(imageresult2, contours2, hierarchy2, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cvPoint(0, 0));

	/////////////////////////////////////////////////////

	// find largest contour in 1st image
	int largest_area_img1 = 0;
	int largest_contour_index_img1 = 0;

	for (int i = 0; i < contours1.size(); i++) // iterate through each contour. 
	{
		double a = contourArea(contours1[i], false);  //  Find the area of contour
		if (a > largest_area_img1){
			largest_area_img1 = a;
			largest_contour_index_img1 = i;                //Store the index of largest contour
		}
	}

	// create blank screen for displaying image 1's largest contour
	Mat dst1(imageresult1.rows, imageresult1.cols, CV_8UC1, Scalar::all(0));

	// white lines for contour
	Scalar color(255, 255, 255);

	// select "largest_contour_index" from "hierarchy1", which is a list of contours
	// then, draw the largest contour onto blank dst 
	drawContours(dst1, contours1, largest_contour_index_img1, color, 1, 8, hierarchy1);
	imshow("largest contour for image 1", dst1);
	waitKey(0);
	destroyWindow("largest contour for image 1");

	/////////////////////////////////////////////////////

	// find largest contour in 2nd image
	int largest_area_img2 = 0;
	int largest_contour_index_img2 = 0;

	for (int i = 0; i < contours2.size(); i++) // iterate through each contour. 
	{
		double a = contourArea(contours2[i], false);  //  Find the area of contour
		if (a > largest_area_img2){
			largest_area_img2 = a;
			largest_contour_index_img2 = i;                //Store the index of largest contour
		}
	}

	// create blank screen for displaying image 1's largest contour
	Mat dst2(imageresult1.rows, imageresult1.cols, CV_8UC1, Scalar::all(0));

	// select "largest_contour_index_img2" from "hierarchy2", which is a list of contours
	// then, draw the largest contour onto blank dst 
	drawContours(dst2, contours2, largest_contour_index_img2, color, 1, 8, hierarchy2);
	imshow("largest contour for image 2", dst2);
	waitKey(0);
	destroyWindow("largest contour for image 2"); // clean up windows


	/////////////////////////////////////////////////////

	// print shape similarity
	// need to extract largest contour using the "largest contour index" key
	double score = matchShapes(contours1[largest_contour_index_img1], contours2[largest_contour_index_img2], CV_CONTOURS_MATCH_I1, 0);
	cout << "similarity distance: " << score;


	return 0;
}