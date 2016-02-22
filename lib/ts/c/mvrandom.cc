#include "mvrandom.h"
#include <random>

double randn (double mu, double sigma) {
  std::random_device rd;
  std::mt19937 gen(rd());
  std::normal_distribution<> d(mu, sigma);
  return d(gen);
};
