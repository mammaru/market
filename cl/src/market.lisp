(in-package :cl-user)
(load (merge-pathnames "load.lisp" *src-path*))

(cond ((string= *environment* "development")
			 (defparameter *db-config* `(:adoptor :sqlite3 :back-end (,(concatenate 'string (namestring *data-path*) "test.sqlite3")))) ))

;(shadow 'update)
;(use-package :market.base)


(let ((jps (make-instance 'jpstock :db-config *db-config*)) (kdb (make-instance 'k-db)))
	(update jps kdb)
	(find-by-id jps "stock" 0))


