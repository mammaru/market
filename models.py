# coding: utf-8
import numpy as np
from numpy import linalg as la
import pandas as pd
from multiprocessing import Pool
from numba import jit

class LogisticRegression:
	def __init__(self, C=10000):
		self.C = C

	#@jit
	def fitting(self, X, y):
		print 'execute logistic regression'
		X = np.matrix(np.hstack([np.array([[1] for i in range(X.shape[0])]),X]))
		y = np.matrix(y)
		beta_old = la.inv(X.T*X)*X.T*y # initial value: regression coefficient
		beta_old = beta_old-beta_old # start with 0
		flag = True
		count = 0
		if self.C != 10000:
			C = self.C
			while flag:
				p = pd.DataFrame(X)		
				p = np.matrix(p.apply(lambda x: np.exp((np.matrix(x)*beta_old)[0,0])/(1+np.exp((np.matrix(x)*beta_old)[0,0])), axis=1)).T
				W = np.diag(np.array(p)[:,0])
				D = np.diag(np.array([C/abs(b) for b in beta_old.tolist()]))
				z = X*beta_old + la.inv(W)*(y-p)
				beta_new = la.inv(X.T*W*X + 2*D)*X.T*W*z
				if np.sum(abs(beta_old-beta_new))<1e-1 or count>10:
					print count, np.sum(abs(beta_old-beta_new))
					flag = False
				else:
					print '#: ',np.sum(abs(beta_old-beta_new))
					beta_old = beta_new
					count += 1
		else:
			while flag:
				p = pd.DataFrame(X)		
				p = np.matrix(p.apply(lambda x: np.exp((np.matrix(x)*beta_old)[0,0])/(1+np.exp((np.matrix(x)*beta_old)[0,0])), axis=1)).T
				W = np.diag(np.array(p)[:,0])
				z = X*beta_old + la.inv(W)*(y-p)
				beta_new = la.inv(X.T*W*X)*X.T*W*z
				if np.sum(abs(beta_old-beta_new))<1e-1 or count>10:
					print count, np.sum(abs(beta_old-beta_new))
					flag = False
				else:
					print '#: ',np.sum(abs(beta_old-beta_new))
					beta_old = beta_new
					count += 1
		self.beta = beta_new

	#@jit
	def prediction(self, X, th=0.5):
		X = np.matrix(np.hstack([np.array([[1] for i in range(X.shape[0])]),X]))
		def Pr(x):
			return np.exp(x*self.beta)/(1+np.exp(x*self.beta))
		return (pd.DataFrame(X).apply(lambda x:(1 if Pr(np.matrix(x))>th else 0),axis=1)).as_matrix()

	#@jit
	def ROC(self, X, y):
		y = np.array(y.T[0])
		def predict(th):
			yhat = self.prediction(X, th)
			print y-yhat
			TP = (y-yhat).tolist().count(0) - (y+yhat).tolist().count(0)
			FP = (y-yhat).tolist().count(-1)
			TN = (y-yhat).tolist().count(0) - (y+yhat).tolist().count(2)
			FN = (y-yhat).tolist().count(1)
			print 'threshold:', th, 'TP:', TP, 'FP:', FP, 'TN:', TN, 'FN:', FN
			sensitivity = float(TP)/(TP+FN)
			specificity = float(TN)/(FP+TN)
			return [sensitivity,1-specificity]
		pool = Pool()
		curve = pool.map(predict, np.linspace(0, 1, 100))
		pool.close()
		pool.join()
		print curve
		return [np.array(curve).T[0,:].tolist(),np.array(curve).T[1,:].tolist()]
