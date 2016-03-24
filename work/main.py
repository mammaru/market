# coding: utf-8
import numpy as np
import pandas as pd
import networkx as nx
from matplotlib import pyplot as plt
import sys,os

try:
	sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/lib')
except:
	sys.path.append(os.getcwd() + '/lib')
from database import io
from ts import kalman, svar
from vis import *
#from kalman import *


if __name__ == "__main__":
	#reload(ts)
	if 0:
		if 0:
			st = io.Stock()
			price_raw = st.get_close('2015-01-01',365)

		price = price_raw
		#print price_raw.describe()

		if 1:
			# na
			#price = price.interpolate()
			price = price.fillna(method='ffill') # fill na with next value
			#price = price.dropna(axis=1) # delete all clumns that has na element

		if 0:
			# logalization
			price = price.applymap(lambda x: np.log(x))

		if 1:
			# normalization
			#m = price.mean(1)
			#s = price.std(1)
			#price = price.sub(m,axis=0).div(s,axis=0)
			price = price.apply(lambda x: (x - np.mean(x)) / (np.max(x) - np.min(x)))

		if 1:
			#print price.columns.map(lambda x: x < 5000)
			price = price.ix[:,price.columns.map(lambda x: x < 2000)]
			#print data
		data = price
	else:
		data = price

	# plot data
	if 1:
		#print data.describe()
		line = data[1001]
   		plt.plot(line)
   		plt.show()


	# SVAR
	if 0:
		svar = svar.SparseVAR()
		svar.set_data(data)
		#svar.regression(5)

		interval = np.arange(2,3,0.5)
		B = svar.GCV(interval)
		B = pd.DataFrame(B.T, index=data.columns, columns=data.columns)
	if 0:
		viz.heatmap(np.array(B))
	if 0:
		DG = nx.DiGraph()
		idxs = B.index.tolist()
		#print idxs
		for idx_from in idxs:
			for idx_to in idxs:
				#print idx_from, idx_to
				#print B.loc[idx_from, idx_to]
				if B.ix[idx_from,idx_to]!=0:
					#print B.ix[idx_from,idx_to]
					DG.add_edge(idx_from, idx_to, weight=B.ix[idx_from,idx_to])
		pos = nx.spring_layout(DG)
		nx.draw_networkx_nodes(DG, pos, node_size = 100, node_color = 'w')
		nx.draw_networkx_edges(DG, pos)
		nx.draw_networkx_labels(DG, pos, font_size = 12, font_family = 'sans-serif', font_color = 'r')
		plt.xticks([])
		plt.yticks([])
		plt.show()



	# kalman and EM
	if 0:
		sys_k = 5
		em = kalman.EM(data, sys_k)
		em.execute()

	if 0:
		fig, axes = plt.subplots(np.int(np.ceil(sys_k/3.0)), 3, sharex=True)
		j = 0
		for i in range(3):
			while j<sys_k:
				if sys_k<=3:
					axes[j%3].plot(data[0][j], "k--", label="obs")
					axes[j%3].plot(em.kl.xp[j], label="prd")
					axes[j%3].legend(loc="best")
					axes[j%3].set_title(j)
				else:
					axes[i, j%3].plot(data[0][j], "k--", label="obs")
					axes[i, j%3].plot(em.kl.xp[j], label="prd")
					axes[i, j%3].legend(loc="best")
					axes[i, j%3].set_title(j)
				j += 1
				if j%3 == 2: break

		fig.show()

	   	#loss = data[0]-em.kl.xs
   		#plt.plot(loss)
	   	#plt.plot(em.llh)
   		#plt.show()
