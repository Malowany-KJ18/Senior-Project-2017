PImage one, two, thr, fou; 
PGraphics test; 

void setup() {
  size(200, 200);
  one = createImage(100, 100, RGB); 
  two = createImage(100, 100, RGB);
  thr = createImage(100, 100, RGB);
  fou = createImage(100, 100, RGB);

  test = createGraphics(200, 200);
}



void draw() {
  one.loadPixels();
  two.loadPixels();
  thr.loadPixels();
  fou.loadPixels();
  for (int i = 0; i < one.pixels.length; i++) {
    one.pixels[i] = color(158, 11, 15);
  }
  for (int i = 0; i < two.pixels.length; i++) {
    two.pixels[i] = color(255, 242, 0);
  }
  for (int i = 0; i < thr.pixels.length; i++) {
    thr.pixels[i] = color(27, 20, 100);
  }
  for (int i = 0; i < fou.pixels.length; i++) {
    fou.pixels[i] = color(242, 109, 125);
  }
  test.beginDraw(); 
  test.background(100); 
  test.image(one, 0, 0); 
  test.image(two, 100, 0); 
  test.image(thr, 0, 100); 
  test.image(fou, 100, 100); 

  test.endDraw();
  image(test, 0, 0);
}

