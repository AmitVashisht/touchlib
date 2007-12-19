// Filter description
// ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ
// Name: Barrel Distortion Correction Filter
// Purpose: Correcting the barrel distortion of the lens
// Original author: Laurence Muller (aka Falcon4ever)

/*
Tool url:
http://www.multigesture.net/wp-content/uploads/2007/12/touchlib_barreldistortion_tool.zip

example of usage:
<barreldistortioncorrection label="barreldistortioncorrection1" />

Place the camera.yml (created by the calibration tool) in the same directory as the config.xml
*/

#include <BarrelDistortionCorrectionFilter.h>

BarrelDistortionCorrectionFilter::BarrelDistortionCorrectionFilter(char* s) : Filter(s)
{	
	CvFileNode *node;
	const char* configfile = "camera.yml";

	CvFileStorage *fs = cvOpenFileStorage( configfile, 0, CV_STORAGE_READ );

	node = cvGetFileNodeByName (fs, NULL, "camera_matrix");
	camera = (CvMat *) cvRead (fs, node);
	node = cvGetFileNodeByName (fs, NULL, "distortion_coefficients");
	dist_coeffs = (CvMat *) cvRead (fs, node);

	cvReleaseFileStorage (&fs);
}

BarrelDistortionCorrectionFilter::~BarrelDistortionCorrectionFilter()
{
}

void BarrelDistortionCorrectionFilter::kernel()
{    
    if( !destination )
    {
        destination = cvCreateImage(cvSize(source->width,source->height), source->depth, source->nChannels);
        destination->origin = source->origin;  // same vertical flip as source
    }
 	
	cvUndistort2( source, destination, camera, dist_coeffs );	
}
