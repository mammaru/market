;;;(eval-when (:compile-toplevel)
;;;	(ql:quickload '(:clsql :clsql-sqlite3))
;;;	(require 'crawl)
;;;	(require 'market.database))

(in-package :mktbase)

(def-view-class stock (price-movement)
	((id
		:initarg :id
		:db-kind :key
		:type integer
		:db-constraints :not-null)
	 (date
		:initarg :date
		:type date))
	(:base-table stock))

(def-view-class company ()
	((code
		:db-kind :key
		:initarg :code
		:type integer
		:db-constraints :not-null)
	 (name
		:initarg :name
		:type (varchar 100))
	 (stock-id
		:initarg :market-id
		:type integer)
	 (stock
		:accessor company-stock
		:db-kind :join
		:db-info (:join-class stock
							:home-key stock-id
							:foreign-key id
							:set t)) ))

(def-view-class industry ()
	((id
		:db-kind :key
		:initarg :id
		:type integer
		:db-constraints :not-null)
	 (type
		:initarg :type
		:type (varchar 100))
	 (company-code
		:initarg :company-code
		:type integer)
	 (company
		:accessor industry-company
		:db-kind :join
		:db-info (:join-class company
							:home-key company-code
							:foreign-key code
							:set t)) ))

(def-view-class market ()
	((id
		:db-kind :key
		:initarg :id
		:type integer
		:db-constraints :not-null)
	 (name
		:initarg :name
		:type (varchar 100))
	 (industry-id
		:initarg :industry-id
		:type integer)
	 (industry
		:accessor market-industry
		:db-kind :join
		:db-info (:join-class industry
							:home-key industry-id
							:foreign-key id
							:set nil)) ))


(define-data-class jpstock (stock company industry market) ())

(defmethod store ((db jpstock))
	(with-slots ((con connection) (data cache-data)) db
		(let ((tbl-name (car data)) (attr (cadr data)) (dat (cddr data)))
			(dolist (d dat)
				(insert-records :into tbl-name
												:attributes attr
												:values d
												:database con) ))))

(defmethod find-by-code ((db jpstock) code)
	(with-slots ((con connection) (data cache-data)) db
		(let ((stmt (concatenate 'string "select dating_id, code, open, high, low, close from prices where code = " (write-to-string code))))
			(pprint stmt)
			(setf data (query stmt :database con))
			data )))
