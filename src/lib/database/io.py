import numpy as np
import pandas as pd
#from pandas import DataFrame, Series
from util import *
from db import *

class Stock:
	def __init__(self):
		self.d = DataBase()
		self.d.summary()

	def get_stock(self, *dates):
		print 'Loading stocks ',
		if len(dates)==1:
			print 'Date:', dates[0]
			st = self.d.stock(dates[0])
			return st
		else:
			dates = list(gen_dates(dates[0], dates[-1]))
			print 'Date:', dates[0], '>>', dates[-1]
			N = len(list(dates))
			n = 0
			sts = []
			for day in dates:
				if n%10==0:
					print '*',
				else:
					n+=1  
				st = self.d.stock(day.strftime('%Y-%m-%d'))
				if st:
					sts.append(st)
		print ''
		return sts

	def get_close(self, *dates):
		print 'Loading all company codes'
		codes = self.d.code()
		if len(dates)==1:
			st = self.get_stock(dates[0])
			closes = pd.DataFrame(index=[1], columns=codes)
			for s in st['stocks']:
				closes[s['code']][1] = s['price']['close']
			closes.index = [dates[0]]
			return closes
		else:
			print 'Generating DataFrame'
			sts = self.get_stock(dates[0],dates[1])
			closes = pd.DataFrame(columns=codes)
			for st in sts:
				closes = closes.append(pd.DataFrame(index=[st['date']], columns=codes))
				for s in st['stocks']:
					closes[s['code']][st['date']] = s['price']['close']
			return closes
