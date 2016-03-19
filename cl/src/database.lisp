;;;(eval-when (:compile-toplevel)
;;;	(ql:quickload '(:clsql :clsql-sqlite3)))

(in-package :cl-user)

(defpackage database-interface
	(:use common-lisp
				clsql
				clsql-sqlite3)
	;;;(:import-from :clsql def-view-class connect create-view-from-class insert-records)
	(:nicknames dbi)
	(:export database
					 create-tables
					 store))

(in-package :database-interface)

(defclass database ()
	((adoptor
		:initarg :adoptor
		:initform (error "Must specify adoptor"))
	 (back-end
		:initarg :back-end
		:initform (error "Must specify back-end of clsql"))
	 connection))

(defgeneric create-tables (db view-classes)
	(:documentation "create tables from list of view classs"))

(defgeneric store (db data)
	(:documentation "store data into database"))

(defmethod initialize-instance :after ((db database) &key)
	(with-slots ((ad adoptor) (bk back-end) (con connection)) db
		(setf con (connect '(bk) :if-exists :old :database-type ad)) ))

(defmethod create-tables ((db database) view-classes)
	(with-slots ((con connection)) db
		(dolist (vc view-classes)
			(ignore-errors (create-view-from-class vc :database con)) )))

(defmethod store ((db database) data)
	(with-slots ((con connection)) db
		(let ((tbl-name (car data)) (attr (cadr data)) (dat (cddr data)))
			(dolist (d dat)
				(insert-records :into tbl-name
												:attributes attr
												:values d
												:database con) ))))

