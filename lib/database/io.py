import db

class Stock:
	def __init__(self):
		self.d = db.DataBase()
		self.d.summary()

	def get(self, *dates):
		if len(dates)==1:
			return self.d.stock(dates[0])

if __name__ == '__main__':
	st = Stock()
	s = st.get('2016-02-05')
	print s['stocks'][0]
