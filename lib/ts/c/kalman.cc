/***********************************************************************************************
 * Kalman
 *  - prediction, filtering, smoothing using current parameters
 *  - parameter estimation by EM method using observation data
 *
 *
 *
 **********************************************************************************************/
#include "kalman.h"

using namespace TS;
using namespace Eigen;

void Kalman::set_params(int n, int obs_d, int sys_d) {
  obs_dim = obs_d;
  sys_dim = sys_d;
  N = n;
  params.F = MatrixXd::Random(sys_d,sys_d);
  params.H = MatrixXd::Random(obs_d,sys_d);
  params.Q = MatrixXd::Identity(sys_d,sys_d);
  params.R = MatrixXd::Identity(obs_d,obs_d);
  params.x0mean = MatrixXd::Random(sys_d,1);
  params.x0var = MatrixXd::Identity(sys_d,sys_d);
}

void Kalman::set_params(parameters p) {
  params.F = p.F;
  params.H = p.H;
  params.Q = p.Q;
  params.R = p.R;
  params.x0mean = p.x0mean;
  params.x0var = p.x0var;
  obs_dim = p.H.rows();
  sys_dim = p.H.cols();
}

void Kalman::set_data(Matrix<double, Dynamic, Dynamic> *data) {
  if(obs_dim!=data->rows()) {
      std::cerr << "dimention of given data is not correct." << std::endl;
  }else {
    obs = data;
    //PRINT_MAT(data->col(0));
    //PRINT_MAT(obs->col(0));
  }
}

void Kalman::set_data(double* data, int n, int obs_d, int sys_d) {
  set_params(n, obs_d, sys_d);
  MatrixXd d = Map<Matrix<double, Dynamic, Dynamic> >(data, obs_d, n);
  set_data(&d);
}

Matrix<double, Dynamic, Dynamic> Kalman::predict() {
  //int N = obs->cols();
  //int p = obs->rows();
  Matrix<double, Dynamic, Dynamic> yhat;
  yhat = MatrixXd::Zero(obs_dim, N);
  for(int i=0; i<N; i++) {
    yhat.col(i) = params.H*sys.xs[i];
  }
  return(yhat);
}

void Kalman::execute() {
  //std::cout << N << std::endl;
  //PRINT_MAT(obs->col(0));
  //std::cout << "in execute of class Kalman" << std::endl;
  //int N = obs->cols();
  //int p = obs->rows();
  //Matrix<double, Dynamic, 1> x0 = params.x0mean;
  //Matrix<double, Dynamic, Dynamic> v0 = params.x0var;
  //Matrix<double, Dynamic, Dynamic> F = params.F;
  //Matrix<double, Dynamic, Dynamic> H = params.H;
  //Matrix<double, Dynamic, Dynamic> Q = params.Q;
  //Matrix<double, Dynamic, Dynamic> R = params.R;
  Matrix<double, Dynamic, Dynamic> *xp = new MatrixXd[N+1];
  Matrix<double, Dynamic, Dynamic> *xf = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *xs = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *vp = new MatrixXd[N+1];
  Matrix<double, Dynamic, Dynamic> *vf = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *vs = new MatrixXd[N];
  Matrix<double, Dynamic, Dynamic> *vl = new MatrixXd[N];

  //PRINT_MAT(Q);
  xp[0] = params.x0mean;
  vp[0] = params.x0var;

  Matrix<double, Dynamic, Dynamic> K;
  Matrix<double, Dynamic, Dynamic> *J = new MatrixXd[N];
  for(int i=0; i<N; i++) {
    //filtering
    //PRINT_MAT(obs->col(i));
    K = vp[i]*params.H.transpose()*(params.H*vp[i]*params.H.transpose()+params.R).inverse(); // kalman gain
	  xf[i] = xp[i]+K*(obs->col(i)-params.H*xp[i]);
	  vf[i] = vp[i]-K*params.H*vp[i];
	  //prediction
	  xp[i+1] = params.F*xf[i];
	  vp[i+1] = params.F*vf[i]*params.F.transpose()+params.Q;
  }
  // smoothing
  xs[N-1] = xf[N-1];
  vs[N-1] = vf[N-1];
  vl[N-1] = params.F*vf[N-2]-K*params.H*params.F*vf[N-2];
  //PRINT_MAT(xs[N-1]);

  for(int i=N-1; i>0; i--) {
	  J[i-1] = vf[i-1]*params.F.transpose()*vp[i].inverse();
	  xs[i-1] = xf[i-1]+J[i-1]*(xs[i]-xp[i]);
	  vs[i-1] = vf[i-1]+J[i-1]*(vs[i]-vp[i])*J[i-1].transpose();
  }
  //PRINT_MAT(J[0]);
  for(int i=N-1; i>1; i--) {
	  vl[i-1] = vf[i-1]*J[i-2].transpose()+J[i-1]*(vl[i]-params.F*vf[i-1])*J[i-2].transpose();
  }
  //PRINT_MAT(vl[1]);
  // store results
  sys.xp = xp;
  sys.xf = xf;
  sys.xs = xs;
  sys.vp = vp;
  sys.vf = vf;
  sys.vs = vs;
  sys.vl = vl;
  //PRINT_MAT(sys.xp[0]);
}

void Kalman::em() {
  //int N = obs->cols();
  int p = obs_dim;
  int k = sys_dim;
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
    execute(); // kalman smoother

    S11 = MatrixXd::Zero(k,k);
    S10 = MatrixXd::Zero(k,k);
    S00 = MatrixXd::Zero(k,k);
    Syy = MatrixXd::Zero(p,p);
    Syx = MatrixXd::Zero(p,k);
    for(int i=1; i<N; i++) {
      S11 += sys.xs[i]*sys.xs[i].transpose() + sys.vs[i];
      S10 += sys.xs[i]*sys.xs[i-1].transpose() + sys.vl[i];
      S00 += sys.xs[i-1]*sys.xs[i-1].transpose() + sys.vs[i-1];
      Syy += obs->col(i)*obs->col(i).transpose();
      Syx += obs->col(i)*sys.xs[i].transpose();
    }

    //PRINT_MAT(log((params.x0var).determinant()));
    //PRINT_MAT((params.x0var.inverse()*(sys.vs[0]+(sys.xs[0]-params.x0mean)*(sys.xs[0]-params.x0mean).transpose())).trace());
    //PRINT_MAT(N*log(params.R.determinant()));
    //PRINT_MAT((params.R.inverse()*(Syy+params.H*S11*params.H.transpose()-Syx*params.H.transpose()-params.H*Syx.transpose())).trace());
    //PRINT_MAT(N*log(params.Q.determinant()));
    //PRINT_MAT((params.Q.inverse()*(S11+params.F*S00*params.F.transpose()-S10*params.F.transpose()-params.F*S10.transpose())).trace());
    //PRINT_MAT((k+N*(k+p))*log(2*PI));
    double logllh = log((params.x0var).determinant()) + (params.x0var.inverse()*(sys.vs[0]+(sys.xs[0]-params.x0mean)*(sys.xs[0]-params.x0mean).transpose())).trace() + N*log(params.R.determinant()) + (params.R.inverse()*(Syy+params.H*S11*params.H.transpose()-Syx*params.H.transpose()-params.H*Syx.transpose())).trace() + N*log(params.Q.determinant()) + (params.Q.inverse()*(S11+params.F*S00*params.F.transpose()-S10*params.F.transpose()-params.F*S10.transpose())).trace() + (k+N*(k+p))*log(2*PI);

    logllh = -logllh/2.0;
    llh[count] = logllh;

    // M step (update parameters that maximize log likelihood)
    params.F = S10*S00.inverse();
    params.H = Syx*S11.inverse();
    params.Q = (S11 - S10*S00.inverse()*S10.transpose())/N;
    params.R = (((Syy - Syx*S11.inverse()*Syx.transpose()).diagonal())/N).asDiagonal();
    params.x0mean = sys.xs[0];
    params.x0var = sys.vs[0];

    if(count>0) {
      diff = std::abs(llh[count] - llh[count-1]);
    }
    std::cout << count << ": " << logllh << std::endl;
  }

}
