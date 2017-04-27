import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;

import org.opencv.core.Mat;
import org.opencv.core.CvType;

import Jama.*;
import processing.video.*;

//create the two opencv objects we will use for the images
OpenCV opencvSrc, opencvWarp; 
// create the PImage used to assign to the Opencv objects and for the final render 
PImage src, warp, dest; 

//set parameters of how many points we need to close the arrays
int np1 = 0;
int np2 = 0;
int imgNum = 0;

//create the arrays that will be given to getTransformation as input 
ArrayList<PVector> srcArray = new ArrayList<PVector>();
ArrayList<PVector> dstArray = new ArrayList<PVector>();

//define our Mat object
Mat warpMat; 

void setup() {
  src = loadImage("Grid.jpg"); //unwarped grid
  size(src.width * 2, src.height); 
  //establish src as an opencv object
  opencvSrc = new OpenCV(this, src); 
  opencvSrc.blur(1); 
  opencvSrc.threshold(120); 

  warp = loadImage("Griddist.jpg"); //distorted grid that we want to find the transformation of 
  opencvWarp = new OpenCV(this, warp); 
  opencvWarp.blur(1); 
  opencvWarp.threshold(120);
}

//using the mouse cursor, fill each of the PVector arrays with 4 cooresponding points from each image 
void mousePressed() {
  int i = int(mouseX / (src.width)); 
  //check to see if the cursor is in the left image (src) 
  if (i == 0) {
    //create a PVector of the mouse location in the form (mouseX, mouseY, 1) 
    srcArray.add(np1, new PVector(mouseX % (src.width), mouseY % (src.height), 1));
    np1++;
    //print out the loaction so we have conformation the array is being popualted 
    println("pic 1" + srcArray.get(np1-1));
    //check to see if cursor is in right image (warp) 
  } else if (i == 1) {
    dstArray.add(np2, new PVector(mouseX % (src.width), mouseY % (src.height), 1));
    np2++;
    println("pic 2" + dstArray.get(np2-1));
  }
  //if each array is populated by at least 4 PVector points initiate the matrix estimation 
  if (np1 >=4 && np2 >= 4 && np1 == np2) {
    warpMat = warpPerspective(srcArray, dstArray, src.width, src.height); 

  }
}

//using the populated PVector arrays and built in OpenCV finctions, to calculate the transformation 
//between the two images the points are sourced form
Mat getTransform(ArrayList<PVector> srcArray, ArrayList<PVector> dstArray) {
  Point[] srcPoints = new Point[4];
  Point[] dstPoints = new Point[4];
//convert each PVector ArrayList to an array of Points (a intrinsic prcessing object)
  for (int i = 0; i <4; i++) {
    srcPoints[i] = new Point(srcArray.get(i).x, srcArray.get(i).y);
  }

  for (int i = 0; i <4; i++) {
    dstPoints[i] = new Point(dstArray.get(i).x, dstArray.get(i).y);
  }
//create a MatOfPoint2f object from each of the point array
  MatOfPoint2f srcMarker = new MatOfPoint2f();
  srcMarker.fromArray(srcPoints);

  MatOfPoint2f dstMarker = new MatOfPoint2f();
  dstMarker.fromArray(dstPoints);
//using the Image Processing module in OpenCV build the Mat object using a built in 
//function getPerspetiveTransform. 
  return Imgproc.getPerspectiveTransform(dstMarker, srcMarker);
}

//applies the transformation Mat calculated above to the Opencv object created for src
Mat warpPerspective(ArrayList<PVector> srcArray, ArrayList<PVector> dstArray, int w, int h) {
  Mat transform = getTransform(srcArray, dstArray);
  Mat unWarpedMarker = new Mat(w, h, CvType.CV_8UC1);    
  Imgproc.warpPerspective(opencvSrc.getColor(), unWarpedMarker, transform, new Size(w, h));
  return unWarpedMarker;
}

void draw() {
  //if the PVector arrays are not yet full 
  if (np1 < 4 || np2 < 4) {
    image(src, 0, 0);
    noFill(); 
    stroke(0, 255, 0); 
    strokeWeight(4);
    translate(src.width, 0);
    image(warp, 0, 0);
    //once arryas are full create a new PImgae and convert the Mat of src and the transfomration matrix to that PImage.
  } else if (np1 >= 4 && np2 >= 4 && np1 == np2) {
    dest = createImage(src.width, src.height,ARGB);
    opencvSrc.toPImage(warpMat, dest);
    image(dest,0,0);
  }
}


