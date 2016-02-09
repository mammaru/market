# coding: utf-8
import numpy as np
import pandas as pd
#from scipy import stats
from scipy import io, sparse
#from multiprocessing import Pool
#from numba import jit
import json
import sqlite3

import os

class DataBase:
	def __init__(self):
		self.available = self.__get_available()
		self.summary()

	def __get_available(self):
		types = get_dir_file('../data/')[0]
		available = {}
		for data_type in types:
			available[data_type] = os.path.abspath(os.path.dirname('../data/'+data_type+'/db/'))
		return available		

	def summary(self):
		print "Summary--------------------------------------:"
		print self.available
		for k, v in self.available:
			print k, v

	def store(self):
		c = self.conn
		""" storing features """
		print 'loading file'
		inputs = []		
		with open('./data/training-data-'+self.size+'.txt','r') as f:
			for line in f:
				inputs.extend([x.strip('\n').replace('X,','').replace('Y,','') for x in (line.split('\t'))[1].split(',')])
		inputs_set = sorted([x for x in set(inputs)])
		i = 0
		l = []
		print "storing features into database"
		for x in inputs_set:
			if(x!='' and len(x)>1):
				l.append((x, x[0], int(x[1:])))
				i += 1
				if i % 100000 == 0:
					c.executemany('insert into features (name,feature,number) values(?,?,?)',l)
					c.commit()
					l = []
		c.executemany('insert into features (name,feature,number) values(?,?,?)',l)
		c.commit()
		""" storing data """
		with open('./data/training-data-'+self.size+'.txt','r') as f:
			print "storing training data"
			i = 0
			l = []
			ll = []
			for line in f:
				tmp = line.strip('\n').replace('X,','').replace('Y,','').split('\t')
				l.append((i, tmp[1], int(tmp[0])))				
				inputs = tmp[1].split(',')
				ll.extend([(i, x) for x in inputs])
				i += 1
				if i % 100000 == 0:
					c.executemany('insert into train(id,inputs,output) values(?,?,?)',l)
					c.executemany('insert into train_features(train_id,feature_name) values(?,?)',ll)
					c.commit()
					l = []
					ll = []
			c.executemany('insert into train(id,inputs,output) values(?,?,?)',l)
			c.executemany('insert into train_features(train_id,feature_name) values(?,?)',ll)
			c.commit()
		with open('./data/test-data-'+self.size+'.txt','r') as f:
			print "storing test data"
			i = 0
			l = []
			ll = []
			for line in f:
				tmp = line.strip('\n').replace('X,','').replace('Y,','')
				l.append((i, tmp))				
				inputs = tmp.split(',')
				ll.extend([(i, x) for x in inputs])
				i += 1
				if i % 100000 == 0:
					c.executemany('insert into test(id,inputs) values(?,?)',l)
					c.executemany('insert into test_features(test_id,feature_name) values(?,?)',ll)
					c.commit()
					l = []
					ll = []
			c.executemany('insert into test(id,inputs) values(?,?)',l)
			c.executemany('insert into test_features(test_id,feature_name) values(?,?)',ll)
			c.commit()
		self.summary()	
		#c.close()

	#@jit
	def features(self, set=True, test=False):
		c = self.conn.cursor()
		if set:
			c.execute('select name from features')
			fts = [ft[0] for ft in c]			
		elif test:
			c.execute('select inputs from test')
			fts = [ft[0].split(',') for ft in c]
		else:
			c.execute('select inputs from train')
			fts = [ft[0].split(',') for ft in c]
		c.close()
		return fts

	#@jit
	def train(self,id_or_output='outputs'):
		if id_or_output=='outputs':
			c = self.conn.cursor()
			c.execute('select output from train')
			outputs = [x[0] for x in c]
			c.close()
			return outputs
		else:
			t = (id_or_output,)
			c = self.conn.cursor()
			c.execute('select output, inputs from train where id=?',t)
			fts = list([ft for ft in c][0])		
			c.close()
			fts.append(fts.pop(1).split(','))
			return fts

	#@jit
	def test(self,id):
		t = (id,)
		c = self.conn.cursor()
		c.execute('select inputs from test where id=?',t)
		fts = list([ft[0] for ft in c])[0].split(',')	
		c.close()
		return fts

	#@jit
	def trains(self, d=50, N=0, f=[]):
		if len(f)>0:
			print 'features:', f
			if N==0:
				N = self.N_train
			y = self.train()[:N]
			samples = self.features(set=False)
			result = [np.array([map(lambda x: 1 if x in samples[i] else 0, f) for i in range(N)]), np.array(y).T, f]
			return result
		if N==0:
			N = self.N_train
		fts = self.features()
		y = self.train()[:N]
		if d == self.p:
			#pool = Pool()
			result = [np.array([map(lambda x: 1 if x in self.train(i)[1] else 0, fts) for i in range(N)]), np.array(y).T, fts]
			#pool.close()
			#pool.join()
			return result
		elif d < self.p and d > 0:
			print 'creating correlations'
			corr = []
			for ft in fts:
				sample = [(1 if ft in self.train(i)[1] else 0) for i in range(N)]
				corr.append(abs(np.corrcoef(np.array(sample),np.array(y))[0,1]))
			print 'sorting correlations'
			corr = pd.Series(corr,index=fts).order(ascending=False)
			#print corr
			selected_fts = corr.head(d).index.tolist()
			print 'selected', d, 'features are:\n', selected_fts
			print 'creating train data'
			#pool = Pool()
			result = [np.array([map(lambda x: 1 if x in self.train(i)[1] else 0, selected_fts) for i in range(N)]), np.array([[x] for x in y]), selected_fts]
			#pool.close()
			#pool.join()
			return result
		else:
			print 'augument must be natural number lower than or equal to', self.p

	#@jit
	def trains2(self, N=0):
		print 'selecting features by Pearson\'s t-test'
		if N==0:
			N = self.N_train
		fts = self.features()
		selected_fts = []
		y = self.train()[:N]
		print 'execute t-test for each features'
		samples = self.features(set=False)
		for ft in fts:
			sample = [(1 if ft in samples[i] else 0) for i in range(N)]
			if stats.ttest_rel(sample,y)[1] < 0.01:
				selected_fts.append(ft)
		print 'selected', len(selected_fts), 'features are:\n', selected_fts
		print 'creating train data'
		#pool = Pool(2)
		result = [np.array([map(lambda x: 1 if x in samples[i] else 0, selected_fts) for i in range(N)]), np.array([[x] for x in y]), selected_fts]
		#pool.close()
		#pool.join()
		return result

	#@jit
	def trains_all(self, N=0):
		print 'start constructing sparse matrix of training data'
		if N==0:
			N = self.N_train
		fts = self.features()
		y = self.train()[:N]
		print 'making indeces of features'
		A = sparse.lil_matrix((N,self.p))
		samples = self.features(set=False)
		idxs = [[fts.index(x) for x in samples[i]] for i in range(len(samples))]
		print 'making sparse matrix'
		for i in range(len(idxs)):
			#print idx
			V = np.array([1 for j in range(len(idxs[i]))])
			I = np.array([0 for j in range(len(idxs[i]))])
			J = np.array(idxs[i])
			#print V, I, J
			row = sparse.coo_matrix((V,(I,J)),shape=(1,self.p))
			A[i,:] = row
			#if stats.ttest_rel(sample,y)[1] < 0.01:
				#selected_fts.append(ft)
		#print 'selected', len(selected_fts), 'features are:\n', selected_fts
		#print 'creating train data'
		#pool = Pool(2)
		#result = [np.array([map(lambda x: 1 if x in samples[i] else 0, selected_fts) for i in range(N)]), np.array([[x] for x in y]), selected_fts]
		#pool.close()
		#pool.join()
		return A


	#@jit
	def tests(self, fts):
		print 'creating test data'
		samples = self.features(set=False,test=True)		
		#pool = Pool(2)
		result = np.array([map(lambda x: 1 if x in samples[i] else 0, fts) for i in range(self.N_test)])
		#pool.close()
		#pool.join()
		return result

	#@jit
	def tests_all(self, N=0):
		print 'start constructing sparse matrix of test data'
		if N==0:
			N = self.N_test
		fts = self.features()
		y = self.test()[:N]
		print 'making indeces of features'
		A = sparse.lil_matrix((N,self.p))
		samples = self.features(set=False,test=True)
		idxs = [[fts.index(x) for x in samples[i]] for i in range(len(samples))]
		print 'making sparse matrix'
		for i in range(len(idxs)):
			#print idx
			V = np.array([1 for j in range(len(idxs[i]))])
			I = np.array([0 for j in range(len(idxs[i]))])
			J = np.array(idxs[i])
			#print V, I, J
			row = sparse.coo_matrix((V,(I,J)),shape=(1,self.p))
			A[i,:] = row
		print 'creating test data'
		samples = self.features(set=False,test=True)		
		#pool = Pool(2)
		result = np.array([map(lambda x: 1 if x in samples[i] else 0, fts) for i in range(self.N_test)])
		#pool.close()
		#pool.join()
		return result


	def parse_sparse_matrix_file(type):
		if self.p <1000:
			sp_mat = np.load('small-'+type+'.npy')
		else:
			sp_mat = np.load('large-'+type+'.npy')
		mt = sp_mat.todense()
		return mt


def get_dir_file(path):
	dirs = []
	files = []
	for item in os.listdir(path):
		if item == '.DS_Store': continue
		dirs.append(item) if os.path.isdir(os.path.abspath(path)+'/'+item) else files.append(item)
	return dirs, files












def get_features(size):
	print 'createing set of features'
	inputs = []
	for line in open('./data/training-data-'+size+'.txt','r'):
		tmp = line.split('\t')
		output_data = int(tmp[0])
		inputs.extend([x.strip('\n') for x in tmp[1].split(',')])
	print len(inputs)
	#inputs_set = sorted([x for x in set(inputs)])
	#inputs = pd.DataFrame([inputs.count(x) for x in inputs_set],index=inputs_set,columns=['frequency'])
	#inputs.to_csv('./data/features-frequency-'+size+'.csv')
	#features = {"X":[],"Y":[],"Z":[]}
	#for x in inputs_set:
		#if(x!='' and len(x)>1):
			#feature = x[0]
			#number = x[1:]
			#features[feature].append(number)
	#features["X"].sort()
	#features["Y"].sort()
	#features["Z"].sort()
   	#with open('./data/features-'+size+'.json', 'w') as f:
		#json.dump(features, f, sort_keys=True, indent=4)

def parse_file(data_type,size):
	print 'parsing data'
	with open('./data/'+data_type+'-data-'+size+'.txt','r') as f:
		data = []
		lines = f.readlines()
		if data_type=="training":
			for string in lines:
				sample = {}
				tmp = string.strip('\n').split('\t')
				sample["output"] = int(tmp[0])
				sample['inputs'] = tmp[1].split(',')
				data.append(sample)
		elif data_type=="test":
			for string in lines:
				sample = {}
				sample["inputs"] = string.strip('\n').split(',')
				data.append(sample)
		return data

def structurize_data(data):
	print 'structuring data'
	count = 0
	for sample in data:
		features = {'X':{'numbers':[]},'Y':{'numbers':[]},'Z':{'numbers':[]}}
		for x in sample['inputs']:
			if(x!='' and len(x)>1):
				feature = x[0]
				number = int(x[1:])
				features[feature]['numbers'].append(number)
			features['X']['n'] = len(features['X']['numbers'])
			#features['X']['mean'] = np.mean(features['X']['numbers'])
			#features['X']['numbers'].sort()
			#features['Y']['numbers'].sort()
			features['Y']['n'] = len(features['Y']['numbers'])
			#features['Y']['mean'] = np.mean(features['Y']['numbers'])
			#features['Z']['numbers'].sort()
			features['Z']['n'] = len(features['Z']['numbers'])
			#features['Z']['mean'] = np.mean(features['Z']['numbers'])
		data[count]['inputs'] = features
		count += 1
	return data



def select_features_by_correlation(data,features,num_ft=50):
	print 'selecting features by correlation'
	y = [x['output'] for x in data]
	idx1 = ['X' for x in features['X']]
	idx1.extend(['Y' for x in features['Y']])
	idx1.extend(['Z' for x in features['Z']])
	idx2 = [x for x in features['X']]
	idx2.extend([x for x in features['Y']])
	idx2.extend([x for x in features['Z']])
	corr = pd.DataFrame(columns=['correlation'],index=[idx1,idx2])
	for xyz in ['X','Y','Z']:
		#fts = [xyz+str(x) for x in features[xyz]['numbers']]
		fts = features[xyz]
		for ft in fts:
			x = []
			for smpl in data:
				x.append(1 if (ft in smpl['inputs'][xyz]['numbers']) else 0)
			#print abs(np.corrcoef(x, y)[0,1])
			#print corr.ix[xyz,ft]
			corr.ix[xyz,ft]['correlation'] = abs(np.corrcoef(x, y)[0,1])
			#print corr.ix[xyz,ft]
	corr_sorted = corr.sort('correlation').tail(num_ft)
	selected_inputs = pd.DataFrame()
	for idx in corr_sorted.index:
		x = []
		for smpl in data:
			x.append(1 if (idx[1] in smpl['inputs'][idx[0]]['numbers']) else 0)
		x = pd.DataFrame(x)
		selected_inputs = pd.concat([selected_inputs, x],axis=1)
	selected_inputs.columns = [[x[0] for x in corr_sorted.index],[x[1] for x in corr_sorted.index]]
	selected_inputs = pd.concat([selected_inputs,pd.DataFrame([x['inputs']['X']['n'] for x in data], columns=[['X'],['n']])],axis=1)
	selected_inputs = pd.concat([selected_inputs,pd.DataFrame([x['inputs']['Y']['n'] for x in data], columns=[['Y'],['n']])],axis=1)
	selected_inputs = pd.concat([selected_inputs,pd.DataFrame([x['inputs']['Z']['n'] for x in data], columns=[['Z'],['n']])],axis=1)
	return selected_inputs #corr_sorted
