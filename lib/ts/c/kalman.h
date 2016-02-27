#include <iostream>
#include <cmath>
#include "Eigen/Core"
#include "Eigen/Geometry"
#define PRINT_MAT(X) std::cout << #X << ":\n" << X << std::endl << std::endl
#define PI 3.1415926535

namespace ts {
  typedef struct {
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> F;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> H;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> Q;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> R;
    Eigen::Matrix<double, Eigen::Dynamic, 1> x0mean;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> x0var;
  } parameters;

  typedef struct {
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> *xp;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> *xf;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> *xs;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> *vp;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> *vf;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> *vs;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> *vl;
  } results;

  class Kalman {
    public:
      // variables
      Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> *obs;
      results sys;

      // methods
      Kalman() {};
      ~Kalman() {};
      void set_params(int, int, int);
      void set_params(parameters);
      void set_data(Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> *data);
      void set_data(double*, int, int, int);
      Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> predict();
      void execute();
      void em();

    private:
      // variables
      int sys_dim;
      int obs_dim;
      int N;
      parameters params;
  };
}
