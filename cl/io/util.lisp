(require 'drakma)

(provide 'util)

(defpackage util
	(:use common-lisp)
	(:export download-file))

(in-package util)

(defun download-file (filename uri)
  (with-open-file (out filename
											 :direction :output
											 :if-exists :supersede
											 :element-type '(unsigned-byte 8))
    (with-open-stream (input (drakma:http-request uri :want-stream t :connection-timeout nil))
      (loop :for b := (read-byte input nil -1)
				 :until (minusp b)
				 :do (write-byte b out)))))
