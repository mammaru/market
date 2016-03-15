(in-package :common-lisp)

(defpackage market
	(:use common-lisp
				util)
	(:export stock
					 update
					 get-data
					 get-last-modified))

(in-package :market)

(defclass market-data ()
	((database-name
		:initform (error "Must define database-name in child class"))
	 (database
	 	:initform (error "Must define database class"))
	 (updated-p
		:initform nil
		:reader updated-p)
	 (last-modified
		:initform nil
		:reader last-modified)))

(defclass stock (market-data)
	((database-name
	 :initform "2016.sqlite3")))

(defgeneric update (data)
	(:documentation "Update database"))

(defgeneric get-data (data code)
	(:documentation "Import data from database"))

(defmethod initialize-instance :after ((data stock) &key)
	())

(defmethod get-last-modified ((data stock))
	(with-slots ((db-name database-name)) data
		(clsql-sys:with-database (con db-name :if-exists :old :database-type :sqlite3)
			(let ((last-modified (clsql-sys:query "select max(id), date from datings" :database con :flatp t)))
				(cadar last-modified) ))))

(defmethod update ((data market-data))
	(pprint "parent class method called"))

(defmethod update ((data stock))
	(if (not (string= (today) (get-last-modified data)))
			(progn
				(download-file "http://k-db.com/?p=all&download=csv" "daily.csv")
				(setf cl-csv:*default-external-format* :sjis)
				(let* ((daily-data (cl-csv:read-csv #P"daily.csv" :trim-outer-whitespace t))
							 (date (caar daily-data))
							 (column-name (cadr daily-data)))
					(pprint date)
					(pprint column-name) ))
			t)
	(call-next-method))

(defmethod outdated-p ((mk-data stock))
	(if (not (string= (today) (get-last-modified mk-data))) t nil))

(defmethod update2 ((mk-data stock))
	(with-slots ((db database)) mk-data
		(if (outdated-p mk-data)
				(store data db)
				t))
	(call-next-method))

(defmethod get-data ((data stock) code)
	(with-slots ((db-name database-name)) data
			(clsql-sys:with-database (con db-name :if-exists :old :database-type :sqlite3)
				(let ((stmt (concatenate 'string "select dating_id, code, open, high, low, close from prices where code = " (write-to-string code))))
;;					(pprint stmt)
					(let ((stock (clsql-sys:query stmt :database con)))
						(pprint stock) )))))




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
