(in-package :common-lisp)

(defpackage market.data
	(:use common-lisp
				market.utils)
	(:export update
					 get-data
					 get-last-modified))

(in-package :market.data)

(defclass market-data ()
	((database-name
		:initform (error "Must define database-name in child class"))
	 (updated-p
		:initform nil
		:reader updated-p)
	 (last-modified
		:initform nil
		:reader last-modified)))

(defgeneric update (data)
	(:documentation "Update database"))

(defgeneric get-data (data code)
	(:documentation "Import data from database"))
