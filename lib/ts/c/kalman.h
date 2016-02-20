#include <iostream>
#include <cmath>
#include "Eigen/Core"
#include "Eigen/Geometry"
#define PRINT_MAT(X) std::cout << #X << ":\n" << X << std::endl << std::endl
#define PI 3.1415926535

namespace TS {
  typedef struct {
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> F;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> H;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> Q;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> R;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> x0mean;
    Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> x0var;
  } params;

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
      inline Kalman() {};
      inline ~Kalman() {};
      void set_data(Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> *data);
      void set_params(params p);
      Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> predict();
      void execute(int k);
      results* get();
      void em(int k);
    private:
      
      Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> *obs;
      params param;
      results r; 
  };
};
