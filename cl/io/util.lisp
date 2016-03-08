(provide 'util)

(defpackage util (:use common-lisp drakma) (:export download-file))
(in-package util)

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


(defmacro scrape ((uri) &body body)
	`(,@body))
