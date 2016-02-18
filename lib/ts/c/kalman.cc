/***********************************************************************************************
 * Kalman
 *  - prediction, filtering, smoothing using current parameters
 *  - parameter estimation by EM method using observation data
 *
 *
 *
 **********************************************************************************************/
#include <iostream>
#include "kalman.h"

using namespace TS;

void Kalman::set_data(Matrix<double, Dynamic, Dynamic> *data) {
  obs = data;
};

void Kalman::set_params(params p) {
  param = p;
};

results* Kalman::get() {
  return(&r);
};

Matrix<double, Dynamic, Dynamic> Kalman::predict() {
  int N = obs->cols();
  int p = obs->rows();
  Matrix<double, Dynamic, Dynamic> yhat;
  yhat = MatrixXd::Zero(p,N);
  for(int i=0; i<N; i++) {
    yhat.col(i) = param.H*r.xs[i];
  }
  return(yhat);
};

void Kalman::execute(int k) {
  //std::cout << "in execute of class Kalman" << std::endl;

  int N = obs->cols();
  //int p = obs->rows();
  //Matrix<double, Dynamic, 1> x0 = param.x0mean;
  //Matrix<double, Dynamic, Dynamic> v0 = param.x0var;		
  //Matrix<double, Dynamic, Dynamic> F = param.F;
  //Matrix<double, Dynamic, Dynamic> H = param.H;
  //Matrix<double, Dynamic, Dynamic> Q = param.Q;
  //Matrix<double, Dynamic, Dynamic> R = param.R;
  Matrix<double, Dynamic, Dynamic> *xp = new MatrixXd[N+1];
  Matrix<double, Dynamic, Dynamic> *xf = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *xs = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *vp = new MatrixXd[N+1];
  Matrix<double, Dynamic, Dynamic> *vf = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *vs = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *vl = new MatrixXd[N];

  //PRINT_MAT(Q);
  xp[0] = param.x0mean;
  vp[0] = param.x0var;
  
  Matrix<double, Dynamic, Dynamic> K;
  Matrix<double, Dynamic, Dynamic> *J = new MatrixXd[N];
  for(int i=0; i<N; i++) {
	//filtering
	K = vp[i]*param.H.transpose()*(param.H*vp[i]*param.H.transpose()+param.R).inverse(); // kalman gain
	xf[i] = xp[i]+K*(obs->col(i)-param.H*xp[i]);
	vf[i] = vp[i]-K*param.H*vp[i];
	//prediction
	xp[i+1] = param.F*xf[i];
	vp[i+1] = param.F*vf[i]*param.F.transpose()+param.Q;
  }
  // smoothing
  xs[N-1] = xf[N-1];
  vs[N-1] = vf[N-1];
  vl[N-1] = param.F*vf[N-2]-K*param.H*param.F*vf[N-2];
  //PRINT_MAT(xs[N-1]);
  
  for(int i=N-1; i>0; i--) {
	J[i-1] = vf[i-1]*param.F.transpose()*vp[i].inverse();
	xs[i-1] = xf[i-1]+J[i-1]*(xs[i]-xp[i]);
	vs[i-1] = vf[i-1]+J[i-1]*(vs[i]-vp[i])*J[i-1].transpose();
  }
  //PRINT_MAT(J[0]);
  for(int i=N-1; i>1; i--) {
	vl[i-1] = vf[i-1]*J[i-2].transpose()+J[i-1]*(vl[i]-param.F*vf[i-1])*J[i-2].transpose();
  }
  //PRINT_MAT(vl[1]);
  // store results
  r.xp = xp;
  r.xf = xf;
  r.xs = xs;
  r.vp = vp;
  r.vf = vf;
  r.vs = vs;
  r.vl = vl;
  //PRINT_MAT(r.xp[0]);
};

void Kalman::em(int k) {
  int N = obs->cols();
  int p = obs->rows();
  //Matrix<double, Dynamic, 1> x0;
  //Matrix<double, Dynamic, Dynamic> v0;
  //Matrix<double, Dynamic, Dynamic> F;
  //Matrix<double, Dynamic, Dynamic> Q;
  //Matrix<double, Dynamic, Dynamic> H;
  //Matrix<double, Dynamic, Dynamic> R;
  Matrix<double, Dynamic, Dynamic> S11;
  Matrix<double, Dynamic, Dynamic> S10;
  Matrix<double, Dynamic, Dynamic> S00;
  Matrix<double, Dynamic, Dynamic> Syy;
  Matrix<double, Dynamic, Dynamic> Syx;

  double *llh = new double[N];
  llh[0] = -10e20;

  int count = 0;
  double diff = 100;
  while(diff>1e-3 && count<1000) {
    count++;

    // E step
    execute(k); // kalman smoother

    S11 = MatrixXd::Zero(k,k);
    S10 = MatrixXd::Zero(k,k);
    S00 = MatrixXd::Zero(k,k);
    Syy = MatrixXd::Zero(p,p);
    Syx = MatrixXd::Zero(p,k);
    for(int i=1; i<N; i++) {
      S11 += r.xs[i]*r.xs[i].transpose() + r.vs[i];
      S10 += r.xs[i]*r.xs[i-1].transpose() + r.vl[i];
      S00 += r.xs[i-1]*r.xs[i-1].transpose() + r.vs[i-1];
      Syy += obs->col(i)*obs->col(i).transpose();
      Syx += obs->col(i)*r.xs[i].transpose();
    }

    //PRINT_MAT(log((param.x0var).determinant()));
    //PRINT_MAT((param.x0var.inverse()*(r.vs[0]+(r.xs[0]-param.x0mean)*(r.xs[0]-param.x0mean).transpose())).trace());
    //PRINT_MAT(N*log(param.R.determinant()));
    //PRINT_MAT((param.R.inverse()*(Syy+param.H*S11*param.H.transpose()-Syx*param.H.transpose()-param.H*Syx.transpose())).trace());
    //PRINT_MAT(N*log(param.Q.determinant()));
    //PRINT_MAT((param.Q.inverse()*(S11+param.F*S00*param.F.transpose()-S10*param.F.transpose()-param.F*S10.transpose())).trace());
    //PRINT_MAT((k+N*(k+p))*log(2*PI));
    double logllh = log((param.x0var).determinant()) + (param.x0var.inverse()*(r.vs[0]+(r.xs[0]-param.x0mean)*(r.xs[0]-param.x0mean).transpose())).trace() + N*log(param.R.determinant()) + (param.R.inverse()*(Syy+param.H*S11*param.H.transpose()-Syx*param.H.transpose()-param.H*Syx.transpose())).trace() + N*log(param.Q.determinant()) + (param.Q.inverse()*(S11+param.F*S00*param.F.transpose()-S10*param.F.transpose()-param.F*S10.transpose())).trace() + (k+N*(k+p))*log(2*PI);

    logllh = -logllh/2.0;
    llh[count] = logllh;
    
    // M step (update parameters that maximize log likelihood)
    param.F = S10*S00.inverse();
    param.H = Syx*S11.inverse();
    param.Q = (S11 - S10*S00.inverse()*S10.transpose())/N;
    param.R = (((Syy - Syx*S11.inverse()*Syx.transpose()).diagonal())/N).asDiagonal();
    param.x0mean = r.xs[0];
    param.x0var = r.vs[0];

    if(count>0) {
      diff = std::abs(llh[count] - llh[count-1]);
    }
    std::cout << count << ": " << logllh << std::endl;
  }

}
