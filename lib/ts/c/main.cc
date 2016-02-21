#include "kalman.h"

using namespace Eigen;
using namespace TS;

int main() {

  int NN = 50; // number of time points
  int pp = 10; // observation dimention
  int kk = 10; // system dimention
  // generate observation data
  Matrix<double, Dynamic, Dynamic> data = MatrixXd::Random(pp,NN);

  // generate Kalman instance and set observation data
  Kalman *kal = new Kalman(pp, kk);
  kal->set_data(&data);

  // execute kalman methods
  //kal->execute(kk);
  //results *r = kal->get();
  //PRINT_MAT(r->xp[0]);

  // EM algorithm that estimate parameters
  kal->em();
  Matrix<double, Dynamic, Dynamic> yhat = kal->predict();
  PRINT_MAT(yhat);
  //results *r = kal->get_results();
  //PRINT_MAT(data.col(NN-1));
  //PRINT_MAT(r->xs[NN-1]);
  delete kal;
  kal = NULL;

}
