# coding: utf-8
import numpy as np
import pandas as pd
import pylab as plt
from scipy import stats
from sklearn import svm, cross_validation, utils
from sklearn.grid_search import GridSearchCV

from db import *
from models import *

if __name__ == "__main__":
	#SIZE = 'large'

	if 1:
		small = DataBase("small")
		#small.store()
		small.summary()
		#train = mall.trains(d=100)
		train = small.trains2()
		X_all = train[0]
		y_all = train[1]
		fts = train[2]
		test = data.tests(fts)
		large = DataBase("large")
		large.summary()
		train_l = large.trains(f=fts)
		X_l = train_l[0]
		y_l = train_l[1]
		#fts = train[2]
		test_l = large.tests(fts)

	#try:
		#data.summary()
	#except NameError:
		#data = DataBase(SIZE)
		#data.summary()
		#data.store()

	#try:
		#train
	#except NameError:
		#train = data.trains(d=100)
		#train = data.trains2()
		#train = data.trains(fts)
		#X_all = train[0]
		#y_all = train[1]
		#fts = train[2]
		#test = data.tests(fts)

	X = stats.zscore(X_l,axis=0)
	y = y_l#stats.zscore(y_all,axis=0)
	#X_train,X_test,y_train,y_test = cross_validation.train_test_split(X,y,test_size=0.4,random_state=0)

	X_ = stats.zscore(test_l,axis=0)

	"""
	#from models import LogisticRegression
	#reload(models)
	# learning with training data
	estimator = LogisticRegression(C=1.0)
	estimator.fitting(X,y)

	# evaluate generated model
	sensitivity, _specificity = estimator.ROC(X,y)
	fig = plt.figure()
	ax = fig.add_subplot(1,1,1)
	ax.plot(_specificity, sensitivity)
	ax.set_xlabel('1-specificity')
	ax.set_ylabel('sensitivity')
	ax.set_title('ROC curve')
	fig.show()

	# prediction with test data
	yhat = estimator.prediction(X_)
	"""

	# support vector machine
	estimator = svm.LinearSVC(C=1.0)
	#estimator = svm.SVC(kernel='linear')
	#estimator.fit(X, column_or_1d(y))
	estimator.fit(X,utils.column_or_1d(y))
	print estimator.score(X_test,utils.column_or_1d(y_test))
	yhat = estimator.predict(X_)
	np.savetxt('./results/prediction_results_large.csv', yhat, delimiter=',', fmt='%d')

	"""
	parameters = [{'kernel': ['rbf'], 'gamma': [10**i for i in range(-4,0)], 'C': [10**i for i in range(1,4)]}]
	gscv = GridSearchCV(svm.SVC(), parameters, cv=5, scoring='mean_squared_error')
	gscv.fit(X, utils.column_or_1d(y))
	estimator = gscv.best_estimator_
	
	# prediction
	yhat = estimator.predict(X_)
	np.savetxt('./results/svm_prediction_results'+SIZE+'.csv', yhat, delimiter=',', fmt='%d')
	"""
	
