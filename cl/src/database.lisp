(eval-when (:compile-toplevel :load-toplevel)
	(ql:quickload '(:clsql :clsql-sqlite3))
	(load "util.lisp"))

(in-package :common-lisp)

(defpackage market.database
	(:use common-lisp
				util
				clsql
				clsql-sqlite3)
	(:nicknames db)
	(:export database
					 store))

(in-package :market.database)

(defclass database ()
	((adoptor
		:initarg :adoptor
		:initform (error "Must specify adoptor"))
	 (back-end
		:initarg :back-end
		:initform (error "Must specify database"))
	 (pool
		:initarg :pool
		:initform 5
		:type 'number)
	 (timeout
		:initarg :timeout
		:initform 5000
		:type 'number)))

(defmacro with-db-config ((adptr pl tout) instance &body body)
	`(with-slots ((,adptr adoptor) (,pl pool) (,tout timeout)) ,instance
			 ,@body))

(defgeneric store (data db)
	(:documentation "store data into database"))

(defmethod initialize-instance :after ((db database) &key)
	(with-slots ((ad adoptor) (bk back-end)) db
		(clsql:with-database (con '(bk) :if-exists :old :database-type adoptor)
			(ignore-errors (clsql:create-view-from-class 'test0 :database con)))))

(defmethod store (data (db database))
	(with-slots ((ad adoptor) (bk back-end)) db
		(clsql:with-database (con '(bk) :if-exists :old :database-type adoptor)
			(dolist (d data)
				(clsql:insert-records :into prices
															:attributes '(date code open high low close volume adjusted)
															:values d
															:database con) ))))

