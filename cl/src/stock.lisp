(in-package :common-lisp)

(defpackage market.data.stock
	(:use common-lisp
				market.data
				clsql
				clsql-sqlite3))

(clsql:def-view-class test0()
		      ((test0-id 
			:accessor test0-id 
			:initarg :test0-id 
			:type integer 
			:db-kind :key 
			:db-constraints (:not-null :unique))
		       (test0-string
			:accessor test0-string
			:initarg :test0-string
			:type (clsql:varchar 10))
		       (test0-bool
			:accessor test0-bool
			:initarg :test0-bool
			:type boolean)))
