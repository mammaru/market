# distutils: language = c++
# distutils: sources = Rectangle.cpp

cdef extern from "kalman.h" namespace "ts":
    cdef cppclass Kalman:
      Kalman()  except +
      # ~Kalman() {};
	  Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> *obs
      results sys
      void set_params(int, int, int)
      void set_params(parameters)
      void set_data(Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> *data)
      void set_data(double*, int, int, int)
      Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> predict()
      void execute()
      void em()
    #private:
      // variables
      int sys_dim
      int obs_dim
      int N
      parameters params