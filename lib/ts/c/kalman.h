#include <cmath> 
#include "Eigen/Core"
#include "Eigen/Geometry"

using namespace Eigen;
#define PRINT_MAT(X) std::cout << #X << ":\n" << X << std::endl << std::endl
#define PI 3.1415926535

namespace TS {
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
      //std::cout << "in constructor of class Kalman" << std::endl;
    };
    inline ~Kalman() {
      //std::cout << "in destructor of class Kalman" << std::endl;
    };
    void set_data(Matrix<double, Dynamic, Dynamic> *data);
    void set_params(params p);
    Matrix<double, Dynamic, Dynamic> predict();
    void execute(int k);
    results* get();
    void em(int k);

  private:
    Matrix<double, Dynamic, Dynamic> *obs;
    params param;
    results r; 
  };
};
