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
#define PI 3.1415926535

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
  void em(int k);

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

  // store results
  //r.x0mean = x0;
  //r.x0var = v0;
  r.xp = xp;
  r.xf = xf;
  r.xs = xs;
  r.vp = vp;
  r.vf = vf;
  r.vs = vs;
  r.vl = vl;                    
};

void Kalman::em(int k) {
  int N = obs->cols();
  int p = obs->rows();
  Matrix<double, Dynamic, 1> x0;
  Matrix<double, Dynamic, Dynamic> v0;
  Matrix<double, Dynamic, Dynamic> F;
  Matrix<double, Dynamic, Dynamic> Q;
  Matrix<double, Dynamic, Dynamic> H;
  Matrix<double, Dynamic, Dynamic> R;
  Matrix<double, Dynamic, Dynamic> S11;
  Matrix<double, Dynamic, Dynamic> S10;
  Matrix<double, Dynamic, Dynamic> S00;
  Matrix<double, Dynamic, Dynamic> Syy;
  Matrix<double, Dynamic, Dynamic> Syx;

  double *llh = new double[N];  

  int count = 0;
  double diff = 100;
  while(diff>1e-3 and count<5000) {

    // E step
    execute(k); //kalman smoother

    S11 = r.xs[0]*r.xs[0].transpose() + r.vs[0];
    S10 = r.xs[0]*r.xs[0].transpose() + r.vl[0];
    S00 = r.xs[0]*r.xs[0].transpose() + param.x0var;
    Syy = obs->col(0)*obs->col(0).transpose();
    Syx = obs->col(0)*r.xs[0].transpose();
    for(int i=1; i<N; i++) {
      S11 = S11 + r.xs[i-1]*r.xs[i-1].transpose() + r.vs[i-1];
      S10 = S10 + r.xs[i-1]*r.xs[i-2].transpose() + r.vl[i-1];
      S00 = S00 + r.xs[i-2]*r.xs[i-2].transpose() + r.vs[i-2];
      Syy = Syy + obs->col(i-1)*obs->col(i-1).transpose();
      Syx = Syx + obs->col(i-1)*r.xs[i-1].transpose();
    }
    
    double logllh = log((param.x0var).determinant()) + (param.x0var.inverse()*(r.vs[0]+(r.xs[0]-param.x0mean)*(r.xs[0]-param.x0mean).transpose())).trace() + N*log(param.R.determinant()) + (param.R.inverse()*(Syy+param.H*S11*param.H.transpose()-Syx*param.H.transpose()-param.H*Syx.transpose())).trace() + N*log(param.Q.determinant()) + (param.Q.inverse()*(S11+param.F*S00*param.F.transpose()-S10*param.F.transpose()-param.F*S10.transpose())).trace() + (k+N*(k+p))*log(2*PI);

    logllh = (-1/2)*logllh;
    llh[count] = logllh;
    
    // M step (update parameters that maximize log likelihood)
    param.F = S10*S00.inverse();
    param.H = Syx*S11.inverse();
    param.Q = (S11 - S10*S00.inverse()*S10.transpose())/N;
    param.R = (((Syy - Syx*S11.inverse()*Syx.transpose()).diagonal()).array()/N).matrix();
    param.x0mean = r.xs[0].transpose();
    param.x0var = r.vs[0];
       
    if(count>0) {
      diff = std::abs(llh[count] - llh[count-1]);
    }
    count += 1;
  }    

}










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
