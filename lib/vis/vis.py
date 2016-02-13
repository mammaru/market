from matplotlib import pyplot as plt

def heatmap(data, **labels):
	fig, axis = plt.subplots(figsize=(10, 10))
	heatmap = axis.pcolor(data, cmap=plt.cm.Reds)
	axis.set_xticks(np.arange(data.shape[0])+0.5, minor=False)
	axis.set_yticks(np.arange(data.shape[1])+0.5, minor=False)
	axis.invert_yaxis()
	axis.xaxis.tick_top()

	if labels:
		axis.set_xticklabels(labels["row"], minor=False)
		axis.set_yticklabels(labels["column"], minor=False)

	fig.show()
	#plt.savefig('image.png')
	
	return heatmap
