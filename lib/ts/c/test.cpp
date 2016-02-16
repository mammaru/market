/***********************************************************************************************
 * Kalman filter (and related methods)
 *
 *
 *
 *
 *
 **********************************************************************************************/
#include <iostream>
#include "Eigen/Core"
#include "Eigen/Geometry"

using namespace Eigen;

typedef struct {
  Matrix<double, Dynamic, Dynamic> F;
  Matrix<double, Dynamic, Dynamic> H;
  Matrix<double, Dynamic, Dynamic> Q;
  Matrix<double, Dynamic, Dynamic> R;
} params;

class Kalman {
public:
  inline Kalman() {
	std::cout << "in constructor of class Kalman" << std::endl;
  };
  inline ~Kalman() {
	std::cout << "in destructor of class Kalman" << std::endl;
  };
  void set_params(params p);
  void execute(Matrix<double, Dynamic, Dynamic> &m);
  void predict(Matrix<double, Dynamic, Dynamic> &data);
private:
  params p;
};

void Kalman::execute(Matrix<double, Dynamic, Dynamic> &m) {
  std::cout << "in execute of class Kalman" << std::endl;
  std::cout << "m\n" << m << std::endl;
};


int main() {

  Kalman *k = new Kalman;
  
  double b[4][4];
  for(int i=0;i<4;i++){
	for(int j=0;j<4;j++){
	  b[i][j]=(double)i*j;
	}
  }
  int rows = sizeof(b)/sizeof(b[0]);
  int cols = sizeof(b[0])/sizeof(b[0][0]);  
  MatrixXd B = Map<Matrix<double, Dynamic, Dynamic> >(&(b[0][0]), rows, cols);
  std::cout << "B\n" << B << std::endl;

  (*k).execute(B);
  delete k;
  k = NULL;

}

/*
  Vector2f v1;
  Vector2f v2(1.0f, 0.5f);
  Vector3f v3(0.0f, 1.0f, -1.0f);

  std::cout << "v2\n" << v2 << std::endl;
  std::cout << "v3\n" << v3 << std::endl;

  Matrix3d m1;
  Matrix3d m2;

  m1 << 1.1, 0.0, 0.0,
	    0.4, 1.0, 0.0,
	    0.1, 0.0, 1.0;
  m2 << 1.0, 0.0, 1.0,
	    0.0, 2.0, 0.0,
	    0.0, 0.0, 1.0; 
  std::cout << "m1*m2 = \n" << m1 << "*" << m2 << "=" << m1*m2 << std::endl;

  double a[16];
  for(int i=0;i<16;i++){
	a[i]=(double)i;
  }
  Matrix4d A=Map<Matrix4d>(a);
  std::cout << "A\n" << A << std::endl;

*/
