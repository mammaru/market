(in-package :cl-user)

(defpackage market
	(:use common-lisp
				market.base)
	(:nicknames mkt)
	(:shadow open close update))

(in-package :market)

(defparameter db-config '(:adoptor :sqlite3 :back-end ("test.sqlite3")))

(market.base:update (make-instance 'jpstock :db-config db-config))

;(find-by-id 'jpstock 'stock 0)
