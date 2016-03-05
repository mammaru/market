(require 'drakma)
(require 'cl-csv)

(defun download-file (filename uri)
  (with-open-file (out filename
											 :direction :output
											 :if-exists :supersede
											 :element-type '(unsigned-byte 8))
    (with-open-stream (input (drakma:http-request uri :want-stream t :connection-timeout nil))
      (loop :for b := (read-byte input nil -1)
				 :until (minusp b)
				 :do (write-byte b out)))))

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

(time
 (let ((data (cl-csv:read-csv #P"daily.csv")))
	 (values (apply #'vector (first data))
					 (apply #'vector (rest (mapcar #'first data)))
					 (apply #'vector 
									(mapcar #'read-from-string (loop :for row :in (rest data)
																								:append (rest row)))))))
