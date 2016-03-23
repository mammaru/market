;;;(eval-when (:compile-toplevel)
;;;	(ql:quickload '(:clsql :clsql-sqlite3 cl-annot)))

(in-package :cl-user)

(defpackage market.base
	(:use common-lisp
				cl-annot
				cl-csv
				crawl
				clsql
				clsql-sqlite3)
	(:import-from :alexandria with-gensyms)
	(:shadow database get update data)
	(:nicknames mktbase))

(in-package :market.base)
(annot:enable-annot-syntax)

(defclass database ()
	((config
		:initarg :db-config
		:initform '(:adoptor :sqlite3 :back-end (":memory:")))
	 connection))


;;; generic functions
(defgeneric migrate (db)
	(:documentation "create tables"))

(defgeneric save (db table-name data)
	(:documentation "save data of list form"))

(defgeneric update (db)
	(:documentation "Update database"))

(defgeneric find-by-id (db table-name id)
	(:documentation "get data by specifing id"))

;;; methods
(defmethod initialize-instance :after ((db database) &key)
	(with-slots (config (con connection)) db
		(let ((adoptor (getf config :adoptor)) (back-end (getf config :back-end)))
			(setf con (connect back-end :if-exists :old :database-type adoptor)) )
		(migrate db)))

@export
(defmethod save ((db database) table-name data)
	(with-slots ((con connection)) db
		(insert-records :into table-name
										;;;:attributes st-attr
										:values data
										:database con) ))

@export
(defmethod find-by-id ((db database) table-name id)
	(with-slots ((con connection)) db
		(let ((stmt (concatenate 'string "select * from " table-name " where id = " (write-to-string id))))
			(pprint stmt)
			(query stmt :database con) )))


;;; basic view classes
(def-view-class price-movement ()
	((open
		:initarg :open
		:type float)
	 (high
		:initarg :high
		:type float)
	 (low
		:initarg :low
		:type float)
	 (close
		:initarg :close
		:type float)
	 (volume
		:initarg :volume
	 :type integer)
	 (adjusted
		:initarg :adjusted
		:type float) ))


;;; utilities
;@export
(defmacro define-data-class (data-name (&rest tables) &body methods)
	(with-gensyms (dbvar convar)
		(labels ((make-methods (x)
							 (loop for item in x
									collect	(destructuring-bind (sp-name (data-var) &body body) item
														`(@export
															(defmethod ,sp-name (,data-var)
																,@body))))))
			`(progn
				 @export
				 (defclass ,data-name (database) ())		 
				 
				 (defmethod migrate ((,dbvar ,data-name))
					 (with-slots ((,convar connection)) ,dbvar
						 ,@(mapcar #'(lambda (tb) `(unless (table-exists-p ,(string tb) :database ,convar) (create-view-from-class ',tb :database ,convar))) tables)))
				 
				 ,@(funcall #'make-methods (car methods))) )))
