#include "kalman.h"
#include "mvrandom.h"

using namespace Eigen;
using namespace TS;

int main() {

  //std::cout << randn(0, 0.1) << std::endl;

  int NN = 50; // number of time points
  int pp = 5; // observation dimention
  int kk = 5; // system dimention

  // generate observation data
  double data[pp][NN];
  for(int i=0; i<pp; i++) {
    for(int j=0; j<NN; j++) {
      data[i][j] = randn(0, 0.1);
    }
  }

  // generate Kalman instance and set observation data
  Kalman *kal = new Kalman();
  //kal->set_data(&(data[0][0]), NN, pp, kk);
  MatrixXd tmp = Map<Matrix<double, Dynamic, Dynamic> >(&(data[0][0]), pp, NN);
  kal->set_params(NN, pp, kk);
  kal->set_data(&tmp);

  // execute kalman methods
  kal->execute();
  results r = kal->sys;
  PRINT_MAT(r.xp[0]);

  // EM algorithm that estimate parameters
  kal->em();

  // prediction based on estimated parameters
  Matrix<double, Dynamic, Dynamic> yhat = kal->predict();
  PRINT_MAT(yhat);
  //results *r = kal->get_results();
  //PRINT_MAT(data.col(NN-1));
  //PRINT_MAT(r->xs[NN-1]);
  delete kal;
  kal = NULL;

}
