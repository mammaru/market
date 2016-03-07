(provide 'database)

(defpackage database (:use common-lisp) (:export database store))
(in-package database)

(defclass database ()
	((type
		:initarg :type)))

(defgeneric store (database)
	(:documentation "store data into database"))

(defclass file (database)
	((path
		:initarg :path
		:initform (error "Must be supply a path of file")
		::accessor path)))


(defmethod store ((database file))
	)
