/* Kai Malowany 
Bard College Class of 2017
Senir Project submitted to the division of Science Mathematics and Computing
Advised by: Kieth O'Hara
Using OpenCV Mat objects and processing graphics to calcualted the distrotion 
between two images initially input as grids, desinged to divide image into triangular
sectionsbased on the structure of a geodesic projection dome and warp each triangle to 
fit the perspective distortion of each section of the dome in relation to the projector.*/

import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;

import org.opencv.core.Mat;
import org.opencv.core.CvType;

import Jama.*;
import processing.video.*;

OpenCV opencvSrc, opencvWarp, opencvTri;
PImage src, warp, tri, destTemp, dest, real;
int MAXIMGS = 13; //number of tirangles in projection surface

PGraphics output; //another option for final render

PImage[] imgs = new PImage[MAXIMGS];
int np1 = 0; //number of points in image 1
int np2 = 0; //number of points in image 2
int imgNum = 0; //number of warped pieces 

ArrayList<PVector> srcArray = new ArrayList<PVector>();
ArrayList<PVector> dstArray = new ArrayList<PVector>();

Mat warpMat; 

Point[] srcPoints = new Point[3];
Point[] dstPoints = new Point[3];

void setup() {
  real = loadImage("real.jpg");

  src = loadImage("grid layer.jpg"); 
  size(src.width * 2, src.height); 
  opencvSrc = new OpenCV(this, src); 
  opencvSrc.blur(1); 
  opencvSrc.threshold(120); 

  warp = loadImage("realgrid.jpg"); 
  opencvWarp = new OpenCV(this, warp); 
  opencvWarp.blur(1); 
  opencvWarp.threshold(120);

  output = createGraphics(src.width, src.height, JAVA2D);

  destTemp = createImage(src.width, src.height, RGB);
  dest = createImage(src.width, src.height, RGB);
}

void mousePressed() {
  int i = int(mouseX / (src.width)); 
  if (i == 0) {
    srcArray.add(np1, new PVector(mouseX % (src.width), mouseY % (src.height), 1));
    np1++;
    println("pic 1" + srcArray.get(np1-1));
  } else if (i == 1) {
    dstArray.add(np2, new PVector(mouseX % (src.width), mouseY % (src.height), 1));
    np2++;
    println("pic 2" + dstArray.get(np2-1));
  }
  if (np1 >=3 && np2 >= 3 && np1 == np2) {
    toPointArray(srcArray, dstArray);
    alphaTriangle(srcPoints, src);
    warpMat = warpPerspective(srcArray, dstArray, src.width, src.height);
    opencvTri.toPImage(warpMat, destTemp); 
    renderPixel(destTemp, dest);
    imgs[imgNum] = dest;
    imgNum++;
    println(imgNum);
    np1 = 0;
    np2 = 0;
    println("reset" + imgNum);
  }
}

void alphaTriangle(Point[] points, PImage img) {
  /*loop through the pixels in our image and based upon the three
  vertices selected for each triangle, calculate whether each pixel 
  exists in the triangle defined by three selected ponts, if so set alpha 
  value to max, if not set alpha value to 0. */ 
  
  
  tri = createImage(img.width, img.width, ARGB);

  Matrix alphaMat;

  double[][] array = {
    {
      points[0].x, points[1].x, points[2].x
    }
    , {
      points[0].y, points[1].y, points[2].y
    }
    , {
      1, 1, 1
    }
  };
  Matrix pointMat = new Matrix(array);
  pointMat.print(3, 3); 

  img.loadPixels();
  tri.loadPixels();

  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int loc = x + y*img.width;

      double[] tempArray = {
        x, y, 1
      };

      Matrix p = new Matrix(tempArray, 3); 

      float r = red(real.pixels[loc]);
      float g = green(real.pixels[loc]);
      float b = blue(real.pixels[loc]);

      alphaMat = pointMat.solve(p);

      if (alphaMat.get(0, 0) >= 0 && alphaMat.get(1, 0) >= 0 && alphaMat.get(2, 0) >= 0) {
        tri.pixels[loc] = color(r, g, b, 255);
      } else {
        tri.pixels[loc] = color(r, g, b, 0);
      }
    }
  }
  tri.updatePixels();
  opencvTri = new  OpenCV(this, tri);
}

void toPointArray(ArrayList<PVector> srcArray, ArrayList<PVector> dstArray) {
  //converts the PVector arrays created by mousepressed to Point object arrays 
  
  
  for (int i = 0; i <3; i++) {
    srcPoints[i] = new Point(srcArray.get(i).x, srcArray.get(i).y);
  }

  for (int i = 0; i <3; i++) {
    dstPoints[i] = new Point(dstArray.get(i).x, dstArray.get(i).y);
  }
}


Mat getTransform(ArrayList<PVector> srcArray, ArrayList<PVector> dstArray) {
  //same as OpenCV_warp except uisng arrays of 3 Points and 
  //Affine transformation matrices instead
  

  MatOfPoint2f srcMarker = new MatOfPoint2f();
  srcMarker.fromArray(srcPoints);

  MatOfPoint2f dstMarker = new MatOfPoint2f();
  dstMarker.fromArray(dstPoints);

  return Imgproc.getAffineTransform(dstMarker, srcMarker);
}

Mat warpPerspective(ArrayList<PVector> srcArray, ArrayList<PVector> dstArray, int w, int h) {
  Mat transform = getTransform(srcArray, dstArray);
  Mat unWarpedMarker = new Mat(w, h, CvType.CV_8UC1);    
  Imgproc.warpAffine(opencvTri.getColor(), unWarpedMarker, transform, new Size(w, h));
  return unWarpedMarker;
}

void renderPixel(PImage source, PImage dest) {
  /* using one master PImage, pull pixels from each separate rendering of tri
  in each call of alphaTriangle and tranfer all pixels with alpha values of 255 (not 0) 
  to the master PImage*/ 
  
  
  for (int y = 0; y < source.height; y++) {
    for (int x = 0; x < source.width; x++) {
      int loc = x + y*source.width;

      if (alpha(source.pixels[loc]) > 0) {
        dest.pixels[loc] = color(source.pixels[loc]);
      } else {
        continue;
      }
    }
  }
}

void draw() {
  if (imgNum < MAXIMGS) {
    image(src, 0, 0);
    noFill(); 
    stroke(0, 255, 0); 
    strokeWeight(4);
    translate(src.width, 0);
    image(warp, 0, 0);
  } else if (imgNum >= MAXIMGS) {
    int length = imgs.length;
    //println(length);
    int index = 0;
    output.beginDraw();
    
    
    //another option - construct a PGraphics object from the imgs array of PImages (one for each triangle) 
    /*while (index < length) { 
      output.image(imgs[index], 0, 0);
      //println("rendered PImage" + index +1); */
      
      
      index++;
    }
    output.endDraw();
    image(dest, 0, 0);
  }
}

