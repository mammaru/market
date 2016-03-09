(in-package :cl-user)
(provide market-utils)

(defpackage :market-utils
	(:use
	 :common-lisp
	 :drakma
	 :cl-csv)
	(:export
	 :with-gensyms
	 :download-file
	 :today
	 :with-download-csv))
(in-package :market-utils)

(defmacro with-gensyms ((&rest names) &body body)
	`(let ,(loop for n in names collect `(,n (gensym)))
		 ,@body))

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
	(multiple-value-bind (sec min hour d m y)
			(get-decoded-time)
		(concatenate 'string (princ-to-string y) "-" (princ-to-string m) "-" (princ-to-string d))))

(defmacro with-download-csv (uri file-name &optional (data-sym :data) &body body)
	(progn
		(download-file uri file-name)
		(setf cl-csv:*default-external-format* :sjis)
		`(let ((,data-sym ,(cl-csv:read-csv file-name :trim-outer-whitespace t)))
			 ,@body)
		(cl-fad:delete-directory-and-files file-name)))
