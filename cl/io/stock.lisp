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


(let ((data (cl-csv:read-csv #P"daily.csv")))
	(values (first data)
					(rest (mapcar #'first data))))
		 ;(print (mapcar #'read-from-string (loop :for row :in (rest data)
			;																		:append (rest row)))))))
