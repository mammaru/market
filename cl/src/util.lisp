(in-package :common-lisp)
;;;(provide market.utils)

(defpackage utils
	(:use common-lisp
				drakma
				cl-csv)
	(:export with-gensyms
					 download-file
					 today
					 with-download-csv))

(in-package :utils)

(defmacro with-gensyms (syms &body body)
	`(let ,(mapcar #'(lambda (s) `(,s (gensym))) syms)
		 ,@body))

;;;(defmacro with-gensyms ((&rest names) &body body)
;;;	`(let ,(loop for n in names collect `(,n (gensym)))
;;;		 ,@body))

(defun download-file (uri filename)
  (with-open-file (out filename
											 :direction :output
											 :if-exists :supersede
											 :element-type '(unsigned-byte 8))
    (with-open-stream (input (http-request uri :want-stream t :connection-timeout nil))
      (loop :for b := (read-byte input nil -1)
				 :until (minusp b)
				 :do (write-byte b out)))))

(defun today ()
	(labels ((n-to-0n (n)
						 (if (and (< n 10) (> n 0))
								 (concatenate 'string "0" (write-to-string n))
								 (write-to-string n))))
		(multiple-value-bind (sec min hour d m y) (get-decoded-time)
			(values (concatenate 'string (write-to-string y) "-" (n-to-0n m) "-" (n-to-0n d))
							(concatenate 'string (n-to-0n hour) ":" (n-to-0n min) ":" (n-to-0n sec)) ))))

(defun now ()
	(labels ((n-to-0n (n)
						 (if (and (< n 10) (> n 0))
								 (concatenate 'string "0" (write-to-string n))
								 (write-to-string n))))
		(multiple-value-bind (sec min hour d m y)	(get-decoded-time)
			(values	(concatenate 'string (n-to-0n hour) ":" (n-to-0n min) ":" (n-to-0n sec))
							(concatenate 'string (write-to-string y) "-" (n-to-0n m) "-" (n-to-0n d)) ))))


(defmacro with-download-csv (uri file-name &optional (data-sym :data) &body body)
	(progn
		(download-file uri file-name)
		(setf cl-csv:*default-external-format* :sjis)
		`(let ((,data-sym ,(cl-csv:read-csv file-name :trim-outer-whitespace t)))
			 ,@body)
		(cl-fad:delete-directory-and-files file-name)))
