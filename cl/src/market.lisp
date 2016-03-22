(in-package :cl-user)

(defpackage market
	(:use common-lisp
				market.base)
	(:nicknames mkt)
	(:shadow open close database))

(in-package :market)

(defparameter config '(:adoptor :sqlite3 :back-end ("test.sqlite3")))
(defparameter jps (make-instance 'jpstock :db-config config))

;(find-by-id 'jpstock 'stock 0)
