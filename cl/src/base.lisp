;;;(eval-when (:compile-toplevel)
;;;	(ql:quickload '(:clsql :clsql-sqlite3 cl-annot)))

(in-package :cl-user)

(defpackage market.base
	(:use common-lisp
				cl-annot
				crawl
				clsql
				clsql-sqlite3)
	(:import-from :alexandria with-gensyms)
	(:shadow database get update)
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

(defgeneric save (db)
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
(defmacro define-data-class (data-name (&rest tables) &body body)
	(with-gensyms (dbvar convar)
		`(progn
			 @export
			 (defclass ,data-name (database) ())		 
			 
			 (defmethod migrate ((,dbvar ,data-name))
				 (with-slots ((,convar connection)) ,dbvar
					 ,@(mapcar #'(lambda (tb) `(unless (table-exists-p ,(string tb) :database ,convar) (create-view-from-class ',tb :database ,convar))) tables)))
			 ,@body)))




;;;(setf cl-csv:*default-external-format* :sjis)

;;;(time (cl-csv:read-csv #P"daily.csv"))

;;;(caddr (cl-csv:read-csv #P"daily.csv" :trim-outer-whitespace t))

;;;(let ((data (cl-csv:read-csv #P"daily.csv" :trim-outer-whitespace t)))
;;;	(values (first data)
;;;					(rest (mapcar #'first data))))
		 ;(print (mapcar #'read-from-string (loop :for row :in (rest data)
			;																		:append (rest row)))))))


;;;(require 'clsql)
;;;(require 'clsql-sqlite3)

;;;(clsql:connect '("2016.sqlite3") :database-type :sqlite3)
;;;(clsql:locally-enable-sql-reader-syntax)
;;;(clsql:select 'code 'name :from 'names)
;;;(clsql:disconnect)


;;(get-stock "2016.sqlite3" 1002)


;;;(get-last-modified "2016.sqlite3")
