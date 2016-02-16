/***********************************************************************************************
 * Kalman filter (and related methods)
 *
 *
 *
 *
 *
 **********************************************************************************************/
#include <iostream>
//#include <vector> 
#include "Eigen/Core"
#include "Eigen/Geometry"

using namespace Eigen;
#define PRINT_MAT(X) std::cout << #X << ":\n" << X << std::endl << std::endl

typedef struct {
  Matrix<double, Dynamic, Dynamic> F;
  Matrix<double, Dynamic, Dynamic> H;
  Matrix<double, Dynamic, Dynamic> Q;
  Matrix<double, Dynamic, Dynamic> R;
  Matrix<double, Dynamic, Dynamic> x0mean;
  Matrix<double, Dynamic, Dynamic> x0var;
} params;

typedef struct {
  Matrix<double, Dynamic, Dynamic> *xp;
  Matrix<double, Dynamic, Dynamic> *xf;
  Matrix<double, Dynamic, Dynamic> *xs;
  Matrix<double, Dynamic, Dynamic> *vp;
  Matrix<double, Dynamic, Dynamic> *vf;
  Matrix<double, Dynamic, Dynamic> *vs;
  Matrix<double, Dynamic, Dynamic> *vl;
} results;


class Kalman {
public:
  inline Kalman() {
	std::cout << "in constructor of class Kalman" << std::endl;
  };
  inline ~Kalman() {
	std::cout << "in destructor of class Kalman" << std::endl;
  };
  void set_data(Matrix<double, Dynamic, Dynamic> *data);
  void set_params(params p);
  void predict(Matrix<double, Dynamic, Dynamic> &m);
  void execute(int k);
  results* get();

private:
  Matrix<double, Dynamic, Dynamic> *obs;
  params param;
  results r; 
};

void Kalman::set_data(Matrix<double, Dynamic, Dynamic> *data) {
  obs = data;
};

void Kalman::set_params(params p) {
  param = p;
};

results* Kalman::get() {
  return(&r);
};

void Kalman::predict(Matrix<double, Dynamic, Dynamic> &m) {
  std::cout << "in execute of class Kalman" << std::endl;
  std::cout << "m\n" << m << std::endl;
};

void Kalman::execute(int k) {
  std::cout << "in execute of class Kalman" << std::endl;

  int N = obs->cols();
  int p = obs->rows();
  Matrix<double, Dynamic, 1> x0 = param.x0mean;
  Matrix<double, Dynamic, Dynamic> v0 = param.x0var;		
  Matrix<double, Dynamic, Dynamic> F = param.F;
  Matrix<double, Dynamic, Dynamic> H = param.H;
  Matrix<double, Dynamic, Dynamic> Q = param.Q;
  Matrix<double, Dynamic, Dynamic> R = param.R;
  Matrix<double, Dynamic, Dynamic> *xp = new MatrixXd[N+1];
  Matrix<double, Dynamic, Dynamic> *xf = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *xs = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *vp = new MatrixXd[N+1];
  Matrix<double, Dynamic, Dynamic> *vf = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *vs = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *vl = new MatrixXd[N];

  xp[0] = x0;
  vp[0] = v0;
  
  Matrix<double, Dynamic, Dynamic> K;
  Matrix<double, Dynamic, Dynamic> *J = new MatrixXd[N];
  for(int i=0; i<N; i++) {
	//filtering
	K = vp[i]*H.transpose()*(H*vp[i]*H.transpose()+R).inverse(); // kalman gain
	xf[i] = xp[i]+K*(obs->col(i)-H*xp[i]);
	vf[i] = vp[i]-K*H*vp[i];
	//prediction
	xp[i+1] = F*xf[i];
	vp[i+1] = F*vf[i]*F.transpose()+Q;
  }
  // smoothing
  xs[N-1] = xf[N-1];
  vs[N-1] = vf[N-1];
  vl[N-1] = F*vf[N-2]-K*H*F*vf[N-2];
  
  for(int i=N-1; i>0; i--) {
	J[i-1] = vf[i-1]*F.transpose()*vp[i].inverse();
	xs[i-1] = xf[i-1]+J[i-1]*(xs[i]-xp[i]);
	vs[i-1] = vf[i-1]+J[i-1]*(vs[i]-vp[i])*J[i-1].transpose();
  }
		
  for(int i=N-1; i>1; i--) {
	vl[i-1] = vf[i-1]*J[i-2].transpose()+J[i-1]*(vl[i]-F*vf[i-1])*J[i-2].transpose();
  }

  r.xp = xp;
  
};

int main() {

  Kalman *kal = new Kalman;
  int NN = 100; // time points
  int pp = 50; // observation
  int kk = 10; // system
  
  Matrix<double, Dynamic, Dynamic> data = MatrixXd::Random(pp,NN);
  params p;
  p.F = MatrixXd::Random(kk,kk);
  p.H = MatrixXd::Random(pp,kk);
  p.Q = MatrixXd::Identity(kk,kk);
  p.R = MatrixXd::Identity(pp,pp);
  p.x0mean = MatrixXd::Random(kk,1);
  p.x0var = MatrixXd::Identity(kk,kk);
  kal->set_data(&data);
  kal->set_params(p);
  
  kal->execute(kk);

  results *r = kal->get();
  PRINT_MAT(r->xp[0]);
  
  delete kal;
  kal = NULL;

}
