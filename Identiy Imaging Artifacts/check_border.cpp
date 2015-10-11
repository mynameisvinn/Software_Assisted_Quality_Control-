#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <stdio.h>
#include <iostream>
#include <cmath>

/**
function: border inspection for off-centered scans
*/

using namespace cv;
using namespace std;

// some functions
Mat crop_right_roi(Mat *ptr, int padding);
Mat crop_left_roi(Mat *ptr, int padding);
Mat extract_histogram(Mat cropped_image);


int main(int argc, const char** argv)
{

	Mat image, cropped_image, right_border_roi_histogram, left_border_roi_histogram, *ptr;
	int padding;

	// read image path and grab padding value from command line
	image = imread(argv[1], 1);
	padding = atoi(argv[2]);

	ptr = &image;

	// display image
	// imshow("actual", image);
	// waitKey(0);
	// destroyWindow("actual");

	// first, crop right ROI according to padding value and extract corresponding histogram
	cropped_image = crop_right_roi(ptr, padding);
	right_border_roi_histogram = extract_histogram(cropped_image);

	// repeat for left border
	cropped_image = crop_left_roi(ptr, padding);
	left_border_roi_histogram = extract_histogram(cropped_image);

	// compare histograms using chi squared
	cout << "chi square distance: " << compareHist(right_border_roi_histogram, left_border_roi_histogram, CV_COMP_CHISQR) << "\n";

	return 0;
}


Mat crop_right_roi(Mat *ptr, int padding){

	Rect roi;
	Mat new_image, image_crop;
	
	new_image = *ptr;

	roi.x = new_image.cols - padding;
	roi.y = 0;
	roi.width = padding;
	roi.height = new_image.rows - 1;

	// image_crop = new_image(roi);
	// imshow("cropped", image_crop);
	// waitKey(0);
	// destroyWindow("cropped");

	return image_crop; // cropped image will be used to generate histogram
}

Mat crop_left_roi(Mat *ptr, int padding){

	Rect roi;
	Mat new_image, image_crop;

	new_image = *ptr;

	roi.x = 0;
	roi.y = 0;
	roi.width = padding;
	roi.height = new_image.rows - 1;
	
	// image_crop = new_image(roi);
	// imshow("cropped", image_crop);
	// waitKey(0);
	// destroyWindow("cropped");

	return image_crop; // cropped image will be used to generate histogram
}

Mat extract_histogram(Mat cropped_image){

	Mat roi_histogram;
	vector<Mat> bgr_planes;
	split(cropped_image, bgr_planes);

	// establish the number of bins
	int histSize = 256;

	// set the ranges ( for B,G,R) )
	float range[] = { 0, 256 };
	const float* histRange = { range };

	bool uniform = true; bool accumulate = false;

	Mat b_hist, g_hist, r_hist;

	// histogram fun
	calcHist(&bgr_planes[0], 1, 0, Mat(), b_hist, 1, &histSize, &histRange, uniform, accumulate);
	calcHist(&bgr_planes[1], 1, 0, Mat(), g_hist, 1, &histSize, &histRange, uniform, accumulate);
	calcHist(&bgr_planes[2], 1, 0, Mat(), r_hist, 1, &histSize, &histRange, uniform, accumulate);

	// draw histograms for B, G and R
	int hist_w = 512; int hist_h = 400;
	int bin_w = cvRound((double)hist_w / histSize);

	Mat histImage(hist_h, hist_w, CV_8UC3, Scalar(0, 0, 0));

	// normalize the result to [ 0, histImage.rows ] - this will improve similarity calculation
	normalize(b_hist, b_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat());
	normalize(g_hist, g_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat());
	normalize(r_hist, r_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat());

	/// draw for each channel
	for (int i = 1; i < histSize; i++)
	{
		line(histImage, Point(bin_w*(i - 1), hist_h - cvRound(b_hist.at<float>(i - 1))),
			Point(bin_w*(i), hist_h - cvRound(b_hist.at<float>(i))),
			Scalar(255, 0, 0), 2, 8, 0);
		line(histImage, Point(bin_w*(i - 1), hist_h - cvRound(g_hist.at<float>(i - 1))),
			Point(bin_w*(i), hist_h - cvRound(g_hist.at<float>(i))),
			Scalar(0, 255, 0), 2, 8, 0);
		line(histImage, Point(bin_w*(i - 1), hist_h - cvRound(r_hist.at<float>(i - 1))),
			Point(bin_w*(i), hist_h - cvRound(r_hist.at<float>(i))),
			Scalar(0, 0, 255), 2, 8, 0);
	}

	// display pretty histograms
	namedWindow("calcHist Demo", CV_WINDOW_AUTOSIZE);
	imshow("calcHist Demo", histImage);
	waitKey(0);

	// compare histogram for red channel
	return r_hist;
}