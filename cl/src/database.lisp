(in-package :common-lisp)

(defpackage database
	(:use common-lisp
				utils
				clsql
				clsql-sqlite3)
	(:nicknames db)
	(:export database
					 store))

(in-package :database)

(defclass database ()
	((adoptor
		:initarg :adoptor
		:initform (error "Must specify driver"))
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

(defgeneric store (database)
	(:documentation "store data into database"))

(defmethod initialize-instance :after ((db database) &key)
	(with-slots ((adoptor adoptor))
	(clsql:with-database (con '("localhost" "xxx" "xxx" nil) :if-exists :old :database-type :postgresql-socket)
		(ignore-errors (clsql:create-view-from-class 'test0 :database con))))

(defmethod store (database)
	)
