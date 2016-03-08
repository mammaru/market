(require 'cl-csv)
(require 'util)

(defclass market ()
	(database))

(defgeneric update (market)
	(:documentation "update data"))

(defclass stock (market)
	)

(download-file "daily.csv" "http://k-db.com/?p=all&download=csv")



(setf cl-csv:*default-external-format* :sjis)

(time
 (cl-csv:read-csv #P"daily.csv"))


(let ((data (cl-csv:read-csv #P"daily.csv" :trim-outer-whitespace t)))
	(values (first data)
					(rest (mapcar #'first data))))
		 ;(print (mapcar #'read-from-string (loop :for row :in (rest data)
			;																		:append (rest row)))))))


(require 'clsql)
(require 'clsql-sqlite3)
(clsql:connect '("2016.sqlite3") :database-type :sqlite3)
;(clsql:locally-enable-sql-reader-syntax)
(clsql:select 'code 'name :from 'names)
(clsql:disconnect)

(defun get-stock (db-name code)
	(clsql-sys:with-database (con db-name :if-exists :old :database-type :sqlite3)
		(let ((stmt (concatenate 'string "select * from prices where code = " (write-to-string code))))
			(pprint stmt)
			(let ((stock (clsql-sys:query stmt :database con)))
				(pprint stock)))))

(defun get-last-modified (db-name)
	(clsql-sys:with-database (con db-name :if-exists :old :database-type :sqlite3)
		(let ((last-modified (clsql-sys:query "select max(id), date from datings" :database con :flatp t)))
			(cadar last-modified))))
