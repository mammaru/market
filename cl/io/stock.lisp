(provide 'market)

(defpackage market
	(:use common-lisp cl-csv util cl-fad)
	(:export update stock))
(require 'cl-csv)
(require 'util)

(defmacro with-download-csv (uri file-name &optional (variable-name 'data) &body body)
	(progn
		(download-file uri file-name)
		(setf cl-csv:*default-external-format* :sjis)
		`(let ((,variable-name ,(cl-csv:read-csv file-name :trim-outer-whitespace t)))
			 ,@body)
		(cl-fad:delete-directory-and-files file-name)))

(defun update ()
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
		(let ((stmt (concatenate 'string "select * from prices where code = " (write-to-string code))))
			(pprint stmt)
			(let ((stock (clsql-sys:query stmt :database con)))
				(pprint stock)))))

(defun get-last-modified (db-name)
	(clsql-sys:with-database (con db-name :if-exists :old :database-type :sqlite3)
		(let ((last-modified (clsql-sys:query "select max(id), date from datings" :database con :flatp t)))
			(cadar last-modified))))
