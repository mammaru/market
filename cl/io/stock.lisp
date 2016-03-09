(in-package :market)

(defclass market-data ()
	((database-name
		:initform (error "Must define database-name in child class"))
	 (updated-p
		:initform nil
		:reader updated-p)
	 (last-modified
		:initform nil
		:reader last-modified)))

(defclass stock (market-data)
	(database-name
	 :initform "stock.sqlite3"))

(defgeneric update (market-data))

(defmethod initialize-instance :after ((market-data stock) &key)
	())

(defmethod update (market-data stock)
	(progn
		(download-file "http://k-db.com/?p=all&download=csv" "daily.csv")
		(setf cl-csv:*default-external-format* :sjis)
		(let ((daily-data (cl-csv:read-csv #P"daily.csv" :trim-outer-whitespace t)))
			(let ((date (caar daily-data) ) (column-name cadr daily-data))))))



(setf cl-csv:*default-external-format* :sjis)

(time
 (cl-csv:read-csv #P"daily.csv"))

(caddr (cl-csv:read-csv #P"daily.csv" :trim-outer-whitespace t))

(let ((data (cl-csv:read-csv #P"daily.csv" :trim-outer-whitespace t)))
	(values (first data)
					(rest (mapcar #'first data))))
		 ;(print (mapcar #'read-from-string (loop :for row :in (rest data)
			;																		:append (rest row)))))))


(require 'clsql)
(require 'clsql-sqlite3)

(clsql:connect '("2016.sqlite3") :database-type :sqlite3)
;;;(clsql:locally-enable-sql-reader-syntax)
(clsql:select 'code 'name :from 'names)
(clsql:disconnect)

(defun get-stock (db-name code)
	(clsql-sys:with-database (con db-name :if-exists :old :database-type :sqlite3)
		(let ((stmt (concatenate 'string "select dating_id, code, open, high, low, close from prices where code = " (write-to-string code))))
			(pprint stmt)
			(let ((stock (clsql-sys:query stmt :database con)))
				(pprint stock)))))

(get-stock "2016.sqlite3" 1002)

(defun get-last-modified (db-name)
	(clsql-sys:with-database (con db-name :if-exists :old :database-type :sqlite3)
		(let ((last-modified (clsql-sys:query "select max(id), date from datings" :database con :flatp t)))
			(pprint (cadar last-modified)))))

(get-last-modified "2016.sqlite3")
