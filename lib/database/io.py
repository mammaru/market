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
		codes = self.d.code()
		if len(dates)==1:
			st = self.get(dates[0])
			closes = pd.DataFrame(index=[1], columns=codes)
			for s in st['stocks']:
				closes[s['code']][1] = s['price']['close']
			closes.index = [dates[0]]
			#closes.append(skelton, index=dates[0])
				#arr.append(s['price']['close'])
			#return np.array(arr)
			return closes
		else:
			sts = self.get(dates[0],dates[1])
			closes = pd.DataFrame(columns=codes)
			for st in sts:
				closes = closes.append(pd.DataFrame(index=[st['date']], columns=codes))
				for s in st['stocks']:
					closes[s['code']][st['date']] = s['price']['close']
			return closes
