/***********************************************************************************************
 * Kalman filter (and related methods)
 *
 *
 *
 *
 *
 **********************************************************************************************/
#include <iostream>
#include "Eigen/Core"
#include "Eigen/Geometry"

using namespace Eigen;

typedef struct {
  Matrix<double, Dynamic, Dynamic> F;
  Matrix<double, Dynamic, Dynamic> H;
  Matrix<double, Dynamic, Dynamic> Q;
  Matrix<double, Dynamic, Dynamic> R;
  Matrix<double, Dynamic, Dynamic> x0mean;
  Matrix<double, Dynamic, Dynamic> x0var;
} params;

class Kalman {
public:
  inline Kalman() {
	std::cout << "in constructor of class Kalman" << std::endl;
  };
  inline ~Kalman() {
	std::cout << "in destructor of class Kalman" << std::endl;
  };
  void set(Matrix<double, Dynamic, Dynamic> &data, params param);
  void predict(Matrix<double, Dynamic, Dynamic> &m);
  void execute(int k);

private:
  Matrix<double, Dynamic, Dynamic> *obs;
  params param;
};

void Kalman::set(Matrix<double, Dynamic, Dynamic> &data, params param) {
  obs = &data;
  param = param;
};

void Kalman::predict(Matrix<double, Dynamic, Dynamic> &m) {
  std::cout << "in execute of class Kalman" << std::endl;
  std::cout << "m\n" << m << std::endl;
};

void Kalman::execute(int k) {
  std::cout << "in execute of class Kalman" << std::endl;

  int N = (*obs).cols();
  int p = (*obs).rows();
  Matrix<double, Dynamic, 1> x0mean = param.x0mean;
  Matrix<double, Dynamic, Dynamic> x0var = param.x0var;		
  Matrix<double, Dynamic, Dynamic> F = param.F;
  Matrix<double, Dynamic, Dynamic> H = param.H;
  Matrix<double, Dynamic, Dynamic> Q = param.Q;
  Matrix<double, Dynamic, Dynamic> R = param.R;
  Matrix<double, Dynamic, Dynamic> **xp; //= np.matrix(np.empty([k, 0])).T #np.matrix(self.xp.T)
  Matrix<double, Dynamic, Dynamic> **xf; //= np.matrix(self.xf.T)
  Matrix<double, Dynamic, Dynamic> **xs; //= np.matrix(np.empty([k, 0])).T #np.matrix(self.xs.T)
  Matrix<double, Dynamic, Dynamic> **vp; //= self.vp
  Matrix<double, Dynamic, Dynamic> **vf;//= self.vf
  Matrix<double, Dynamic, Dynamic> **vs; //= self.vs
  Matrix<double, Dynamic, Dynamic> **vLag; //= self.vLag

  //x0 = np.matrix(np.random.multivariate_normal(x0mean.T.tolist()[0], np.asarray(x0var))).T;
  //xp = np.matrix(self.ssm.sys_eq(x0,F,Q));
  xp = F*x0mean;
  vp.append(F*x0var*F.T+Q);

  for(int i=0; i<N; i++) {
	//filtering
	K = vp[i]*H.T*(H*vp[i]*H.T+R).I;
	xf = xp[:,i]+K*(Yobs[:,i]-H*xp[:,i]) if i == 0 else np.hstack([xf, xp[:,i]+K*(Yobs[:,i]-H*xp[:,i])]);
	vf.append(vp[i]-K*H*vp[i]);
	//prediction
	xp = np.hstack([xp, F*xf[:,i]]);
	vp.append(F*vf[i]*F.T+Q);
  }
  // smoothing
  J = [np.matrix(np.zeros([k,k]))];
  xs = xf[:,N-1];
  vs.insert(0, vf[N-1]);
  vLag.insert(0, F*vf[N-2]-K*H*vf[N-2]);
  
  for(int i=N;i>0;i--) {
	J.insert(0, vf[i-1]*F.T*vp[i].I);
	xs = np.hstack([xf[:,i-1]+J[0]*(xs[:,0]-xp[:,i]),xs]);
	vs.insert(0, vf[i-2]+J[0]*(vs[0]-vp[i])*J[0].T);
  }
		
  for(int i=N;i>1;i--) {
	vLag.insert(0, vf[i-1]*J[i-1].T+J[i-1]*(vLag[0]-F*vf[i-1])*J[i-2].T);
  }
		
  J0 = x0var*F.T*vp[0].I;
  vLag[0] = vf[0]*J0.T+J[0]*(vLag[0]-F*vf[0])*J0.T;
  xs0 = x0mean+J0*(xs[:,0]-xp[:,0]);
  vs0 = x0var+J0*(vs[0]-vp[0])*J0.T;
		
  self.xs0 = DataFrame(xs0.T);
  self.xp = DataFrame(xp.T);
  self.vp = vp;
  self.xf = DataFrame(xf.T);
  self.vf = vf;
  self.xs0 = DataFrame(xs0.T);
  self.xs = DataFrame(xs.T);
  self.vs0 = vs0;
  self.vs = vs;
  self.vLag = vLag;
  
};

int main() {

  Kalman *k = new Kalman;
  
  double b[4][4];
  for(int i=0;i<4;i++){
	for(int j=0;j<4;j++){
	  b[i][j]=(double)i*j;
	}
  }
  int rows = sizeof(b)/sizeof(b[0]);
  int cols = sizeof(b[0])/sizeof(b[0][0]);  
  MatrixXd B = Map<Matrix<double, Dynamic, Dynamic> >(&(b[0][0]), rows, cols);
  std::cout << "B\n" << B << std::endl;

  (*k).predict(B);
  delete k;
  k = NULL;

}

/*
  Vector2f v1;
  Vector2f v2(1.0f, 0.5f);
  Vector3f v3(0.0f, 1.0f, -1.0f);

  std::cout << "v2\n" << v2 << std::endl;
  std::cout << "v3\n" << v3 << std::endl;

  Matrix3d m1;
  Matrix3d m2;

  m1 << 1.1, 0.0, 0.0,
	    0.4, 1.0, 0.0,
	    0.1, 0.0, 1.0;
  m2 << 1.0, 0.0, 1.0,
	    0.0, 2.0, 0.0,
	    0.0, 0.0, 1.0; 
  std::cout << "m1*m2 = \n" << m1 << "*" << m2 << "=" << m1*m2 << std::endl;

  double a[16];
  for(int i=0;i<16;i++){
	a[i]=(double)i;
  }
  Matrix4d A=Map<Matrix4d>(a);
  std::cout << "A\n" << A << std::endl;

*/
