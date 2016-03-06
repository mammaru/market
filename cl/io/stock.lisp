(require 'cl-csv)
(require 'util)

;; 利用例
(download-file "daily.csv" "http://k-db.com/?p=all&download=csv")


(time
 (with-open-file (f "daily.csv" :direction :input :external-format :sjis)
	 (loop for line = (read-line f nil f)
			until (eq line f)
			count line)))

(time
 (with-open-file (f "daily.csv" :direction :input :external-format :sjis)
	 (loop with buffer = (make-string 4096 :element-type 'character :initial-element #\NULL)
			for bytes = (read-sequence buffer f)
			until (= bytes 0)
			sum (count #\Newline buffer :end bytes))))


(setf cl-csv:*default-external-format* :sjis)

(time
 (cl-csv:read-csv #P"daily.csv"))


(let ((data (cl-csv:read-csv #P"daily.csv")))
	(progn
		(print (first data))
		(print (rest (mapcar #'first data)))))
		 ;(print (mapcar #'read-from-string (loop :for row :in (rest data)
			;																		:append (rest row)))))))
