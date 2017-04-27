//source image 
PImage source;      
//destination image
PImage destination; 
  
void setup(){ 
   //load an image from a file 
  source = loadImage("Bae.jpg");
  
  size(source.width, source.height);
   //create a blank image as the destination
  destination = createImage(source.width, source.height, RGB);   
}

void draw(){
  //establish the parameters for our image filter 
  float redThreshold = 85;
  float blueThreshold = 170;
  
  //we want to look at both images pixels
  source.loadPixels();
  destination.loadPixels();
  
  //loop through pixels and create the 1D pixel array
  for (int x = 0; x < source.width; x++){
    for (int y = 0; y < source.height; y++){
      int loc = x + y*source.width;
      
      //test the brightness and assign approproate color
      if (brightness(source.pixels[loc]) <= redThreshold){
        destination.pixels[loc] = color(2,23,129); //red
      }
      else if (brightness(source.pixels[loc]) > redThreshold && brightness(source.pixels[loc]) <= blueThreshold){
        destination.pixels[loc] = color(191,10,10); //blue
      }
      else {
        destination.pixels[loc] = color(255, 249, 195); //white
      }
    }
  }
  //we cahnged the pixels in the 'destination' image
  destination.updatePixels();
  //display destination image
  image(destination,0,0);
}
