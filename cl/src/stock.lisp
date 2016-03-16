;;;(eval-when (:compile-toplevel)
;;;	(ql:quickload '(:clsql :clsql-sqlite3))
;;;	(require 'crawl)
;;;	(require 'market.database))

(in-package :cl-mkt)

(clsql:def-view-class value ()
	((open
		:accessor open
		:initarg :open
		:type float)
	 (high
		:accessor high
		:initarg :high
		:type float)
	 (low
		:accessor low
		:initarg :low
		:type float)
	 (close
		:accessor close
		:initarg :close
		:type float)
	 (volume
		:accessor volume
		:initarg :volume
	 :type integer)
	 (adjusted
		:accessor adjusted
		:initarg :adjusted
		:type float) ))

(clsql:def-view-class market ()
	((id
		;;;:accessor id
		:initarg :id
		:type integer
		:db-constraints (:not-null :unique :primary-key))
	 (name
		;;;:accessor market-name
		:initarg :name
		:type (varchar 100)) ))

(clsql:def-view-class industry ()
	((id
		;;;:accessor id
		:initarg :id
		:type integer
		:db-constraints (:not-null :unique :primary-key))
	 (type
		;;;:accessor industry-type
		:initarg :type
		:type (varchar 100))) )

(clsql:def-view-class company ()
	((code
		;;;:accessor code
		:initarg :code
		:type integer
		:db-constraints (:not-null :unique :primary-key))
	 (name
		;;;:accessor name
		:initarg :name
		:type (varchar 100))
	 (market-id
		:initarg :market-id
		:type integer)
	 (market
		:accessor stock-market
		:db-kind :join
		:db-info (:join-class market
							:home-key market-id
							:foreign-key id
							:set nil))
	 (industry-id
		:initarg :industry-id
		:type integer)
	 (industry
		:accessor stock-industry
		:db-kind :join
		:db-info (:join-class industry
							:home-key industry-id
							:foreign-key id
							:set nil)) ))

(clsql:def-view-class stock (value)
	((date
		:accessor date
		:initarg :date
		:type date)
	 (company-code
		:db-kind :join
		;;;:accessor company-code
		:initarg :code
		:type integer
		:db-constraints :not-null)
	 (company
		:accessor stock-company
		:db-kind :join
		:db-info (:join-class company
							:home-key company-code
							:foreign-key code
							:set nil) )))
