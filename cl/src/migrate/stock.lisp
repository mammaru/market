;;;(eval-when (:compile-toplevel)
;;;	(ql:quickload '(:clsql :clsql-sqlite3))
;;;	(require 'crawl)
;;;	(require 'market.database))

(in-package :market.base)
(annot:enable-annot-syntax)

@export
(define-spider k-db (doc "http://k-db.com/?p=all&download=csv")
	(cl-csv:read-csv doc :trim-outer-whitespace t))


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


(define-data-class jpstock (stock company industry market)
	(k-db (data)
				(let ((date (caar data))
							(dat (cddr data))
							(st-attr '("code" "date" "open" "high" "low" "close" "volume" "adjusted")))
					(dolist (d dat)
						(let ((st (list (nth 0 d) date (nth 4 d) (nth 5 d) (nth 6 d) (nth 7 d) (nth 8 d) (nth 7 d))))
							(save stock st) )))))

@export
(defmethod update ((db jpstock))
	(with-slots ((con connection)) db
		(with-scrape k-db (data)
			(let ((date (caar data))
						;(attr (cadr data))
						(dat (cddr data))
						(st-attr '("code" "date" "open" "high" "low" "close" "volume" "adjusted")))
				(dolist (d dat)
					(let ((st (list (nth 0 d) date (nth 4 d) (nth 5 d) (nth 6 d) (nth 7 d) (nth 8 d) (nth 7 d))))
						(insert-records :into "stock"
														:attributes st-attr
														:values st
														:database con) ))))))

@export
(defmethod find-by-code ((db jpstock) code)
	(with-slots ((con connection) (data cache-data)) db
		(let ((stmt (concatenate 'string "select dating_id, code, open, high, low, close from prices where code = " (write-to-string code))))
			(pprint stmt)
			(setf data (query stmt :database con))
			data )))

