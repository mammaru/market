import datetime
import os


def str_to_date(str_date):
	try:
		if (len(str_date)==10 and ':' not in str_date):
			str_date += ' 00:00:00'		
		tstr = str_date.replace('/','-')
		tdatetime = datetime.datetime.strptime(tstr, '%Y-%m-%d %H:%M:%S')
		
		tdate = datetime.date(tdatetime.year, tdatetime.month, tdatetime.day)
	except:
		if type(str_date) is datetime:
			return str_date
			#raise TypeError('given date is not string')
		else:
			print 'Format: \"2000-01-01 10:00:00\" or \"2000-01-01\"'
			raise
	else:
		return tdate

def gen_dates(start, end):
	if type(end) is int:
		if type(start) is str:
			if type(start) is str:
				start = str_to_date(start) 
			count = end
			for day in (start + datetime.timedelta(n) for n in range(count)):
				yield day
	else:
		if type(start) is str:
			start = str_to_date(start) 
		if type(end) is str:
			end = str_to_date(end) 
		count = (end-start).days+1
		for day in (start + datetime.timedelta(n) for n in range(count)):
			yield day

def get_dir_file(path):
	dirs = []
	files = []
	for item in os.listdir(path):
		if item == '.DS_Store': continue
		dirs.append(item) if os.path.isdir(os.path.join(os.path.abspath(path),item)) else files.append(item)
	return dirs, files

def walk_tree(directory):
    for root, dirs, files in os.walk(directory):
        yield root
        for f in files:
            yield os.path.join(root, f)
