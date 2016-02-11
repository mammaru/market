import numpy as np
import pandas as pd
#from pandas import DataFrame, Series
from util import *
from db import *

class Stock:
	def __init__(self):
		self.d = DataBase()
		self.d.summary()

	def get(self, *dates):
		if len(dates)==1:
			st = self.d.stock(dates[0])
			return st
		else:
			dates = gen_dates(dates[0], dates[-1])
			sts = []
			for day in dates:
				st = self.d.stock(day.strftime('%Y-%m-%d'))
				if st:
					sts.append(st)
		return sts

	def get_close(self, *dates):
		if len(dates)==1:
			st = self.get(dates[0])
			arr = []
			for s in st['stocks']:
				arr.append(s['price']['close'])
			return np.array(arr)
		else:
			sts = self.get(dates[0],dates[1])
			arr = []
			d = []
			codes = []
			for st in sts:
				d.append(st['date'])
				ar = [s['price']['close'] for s in st['stocks']]
				if len(codes)==0:
					codes = [s['code'] for s in st['stocks']] 
				#for s in st['stocks']:
					#ar.append(s['price']['close'])
				arr.append(ar)
			print d
			return pd.DataFrame(np.array(arr),index=codes,columns=d)

if __name__ == '__main__':
	st = Stock()
	s = st.get_close('2015-01-05',10)
	print s
