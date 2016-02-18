#include "kalman.cc"

using namespace TS;

int main() {

  Kalman *kal = new Kalman;
  int NN = 100; // time points
  int pp = 20; // observation
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
  
  //kal->execute(kk);
  //results *r = kal->get();
  //PRINT_MAT(r->xp[0]);

  kal->em(kk);
  Matrix<double, Dynamic, Dynamic> yhat = kal->predict();
  PRINT_MAT(yhat);
  //results *r = kal->get();
  //PRINT_MAT(data.col(NN-1));
  //PRINT_MAT(r->xs[NN-1]);
  delete kal;
  kal = NULL;

}
