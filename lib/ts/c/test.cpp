/***********************************************************************************************
 * Kalman filter (and related methods)
 *
 *
 *
 *
 *
 **********************************************************************************************/
#include <iostream>
#include <vector> 
#include "Eigen/Core"
#include "Eigen/Geometry"
#define PRINT_MAT(X) cout << #X << ":\n" << X << endl << endl

using namespace Eigen;

typedef struct {
  Matrix<double, Dynamic, Dynamic> F;
  Matrix<double, Dynamic, Dynamic> H;
  Matrix<double, Dynamic, Dynamic> Q;
  Matrix<double, Dynamic, Dynamic> R;
  Matrix<double, Dynamic, Dynamic> x0mean;
  Matrix<double, Dynamic, Dynamic> x0var;
} params;

class Kalman {
public:
  inline Kalman() {
	std::cout << "in constructor of class Kalman" << std::endl;
  };
  inline ~Kalman() {
	std::cout << "in destructor of class Kalman" << std::endl;
  };
  void set(Matrix<double, Dynamic, Dynamic> &data, params param);
  void predict(Matrix<double, Dynamic, Dynamic> &m);
  void execute(int k);

private:
  Matrix<double, Dynamic, Dynamic> *obs;
  params param;
};

void Kalman::set(Matrix<double, Dynamic, Dynamic> &data, params param) {
  obs = &data;
  param = param;
};

void Kalman::predict(Matrix<double, Dynamic, Dynamic> &m) {
  std::cout << "in execute of class Kalman" << std::endl;
  std::cout << "m\n" << m << std::endl;
};

void Kalman::execute(int k) {
  std::cout << "in execute of class Kalman" << std::endl;

  int N = obs->cols();
  int p = obs->rows();
  Matrix<double, Dynamic, 1> x0mean = param.x0mean;
  Matrix<double, Dynamic, Dynamic> x0var = param.x0var;		
  Matrix<double, Dynamic, Dynamic> F = param.F;
  Matrix<double, Dynamic, Dynamic> H = param.H;
  Matrix<double, Dynamic, Dynamic> Q = param.Q;
  Matrix<double, Dynamic, Dynamic> R = param.R;
  Matrix<double, Dynamic, Dynamic> *xp = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *xf = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *xs = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *vp = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *vf = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *vs = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *vLag = new MatrixXd[N];

  xp[0] = F*x0mean;
  vp[0] = F*x0var*F.transpose()+Q;

  Matrix<double, Dynamic, Dynamic> K;
  Matrix<double, Dynamic, Dynamic> *J = new MatrixXd[N];
  for(int i=0; i<N; i++) {
	//filtering
	K = vp[i]*H.transpose()*(H*vp[i]*H.transpose()+R).inverse();
	xf[i] = xp[i]+K*(obs->col(i)-H*xp[i]);
	vf[i] = vp[i]-K*H*vp[i];
	//prediction
	xp[i] = F*xf[i];
	vp[i] = F*vf[i]*F.transpose()+Q;
  }
  // smoothing
  //J = MatrixXd::Zero(k,k);
  xs[N-1] = xf[N-1];
  vs[N-1] = vf[N-1];
  vLag[N-1] = F*vf[N-2]-K*H*vf[N-2];
  
  for(int i=N-1;i>0;i--) {
	J[i-1] = vf[i-1]*F.transpose()*vp[i].inverse();
	xs[i-1] = xf[i-1]+J[i-1]*(xs[i]-xp[i]);
	vs[i-1] = vf[i-2]+J[i-1]*(vs[i]-vp[i])*J[i-1].transpose();
  }
		
  for(int i=N-1;i>1;i--) {
	vLag[i-1] = vf[i-1]*J[i-1].transpose()+J[i-1]*(vLag[i]-F*vf[i-1])*J[i-2].transpose();
  }
		
  J[0] = x0var*F.transpose()*vp[0].inverse();
  vLag[0] = vf[0]*J[0].transpose()+J[1]*(vLag[1]-F*vf[0])*J[0].transpose();
  xs[0] = x0mean+J[0]*(xs[1]-xp[0]);
  vs[0] = x0var+J[0]*(vs[1]-vp[0])*J[0].transpose();
		
  //self.xs0 = DataFrame(xs0.T);
  //self.xp = DataFrame(xp.T);
  //self.vp = vp;
  //self.xf = DataFrame(xf.T);
  //self.vf = vf;
  //self.xs0 = DataFrame(xs0.T);
  //self.xs = DataFrame(xs.T);
  //self.vs0 = vs0;
  //self.vs = vs;
  //self.vLag = vLag;
  
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

  k->predict(B);
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
