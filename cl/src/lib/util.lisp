(eval-when (:compile-toplevel :load-toplevel :execute)
	(ql:quickload '(:drakma :cl-csv	:cl-fad)))

(in-package :cl-user)

(defpackage util
	(:use common-lisp
				drakma
				cl-csv
				cl-fad)
	(:shadow compile)
	(:export with-gensyms
					 download-file
					 today
					 with-download-csv
					 load-all))

(in-package :util)

(defmacro with-gensyms (syms &body body)
	`(let ,(mapcar #'(lambda (s) `(,s (gensym))) syms)
		 ,@body))

(defun load-all (dir-name &key compile priority-files)
	(print compile)
	(print priority-files)
	(if compile
			(progn
				(if priority-files
						(mapcar #'compile-file (mapcar (lambda (x) (merge-pathnames dir-name x)) priority-files)))
				(walk-directory dir-name
												#'compile-file
												:test (lambda (x) (if (string= (pathname-type x) "lisp") t)) )))
	(if priority-files
			(mapcar #'load (mapcar (lambda (x) (merge-pathnames dir-name x)) priority-files)))
	(walk-directory dir-name
									#'load
									:test (lambda (x) (if (string= (pathname-type x) "fasl") t)) ))

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
						 (if (and (< n 10) (>= n 0))
								 (concatenate 'string "0" (write-to-string n))
								 (write-to-string n))))
		(multiple-value-bind (sec min hour d m y) (get-decoded-time)
			(values (concatenate 'string (write-to-string y) "-" (n-to-0n m) "-" (n-to-0n d))
							(concatenate 'string (n-to-0n hour) ":" (n-to-0n min) ":" (n-to-0n sec)) ))))

(defmacro with-download-csv (uri (data-sym &key (encoding :utf-8)) &body body)
					(with-gensyms (file-name)
						`(progn
							 (download-file ,uri ,file-name)
							 (setf cl-csv:*default-external-format* ,encoding)
							 (let ((,data-sym (cl-csv:read-csv ,file-name :trim-outer-whitespace t)))
								 ,@body)
							 (cl-fad:delete-directory-and-files ,file-name))))
