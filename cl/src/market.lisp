(in-package :cl-user)
(load (merge-pathnames "load.lisp" *src-path*))

(cond ((string= *environment* "development")
			 (defparameter *db-config* `(:adoptor :sqlite3 :back-end (,(concatenate 'string (namestring *data-path*) "test.sqlite3")))) ))

;(shadow 'update)
(use-package :market.base)


(make-instance 'jpstock :db-config *db-config*)
(update (make-instance 'jpstock :db-config *db-config*) (make-instance 'k-db))

;(find-by-id 'jpstock 'stock 0)
