import Jama.*; 

Matrix x;

double [][] arrayA = {
  {
    0, 2, 0
  }
  , {
    0, 0, 2
  }
  , {
    1, 1, 1
  }
};
Matrix A = new Matrix(arrayA);

double[] arrayB = {
  0, 1, 1
}; 

Matrix B = new Matrix(arrayB, 3);

x = A.solve(B);

x.print(3, 1);

