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
      Kalman(int obs_d, int sys_d);
      inline ~Kalman() {};
      void set_data(Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> *data);
      //void set_params(parameters p);
      Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> predict();
      void execute();
      //results* get_results();
      void em();

    private:
      // variables
      int sys_dim;
      int obs_dim;
      parameters params;
  };
};
