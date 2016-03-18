;;;(eval-when (:compile-toplevel)
;;;	(ql:quickload '(:clsql :clsql-sqlite3))
;;;	(require 'crawl)
;;;	(require 'market.database))

(in-package :dbi)

(def-view-class value ()
	((open
		:initarg :open
		:type float)
	 (high
		:initarg :high
		:type float)
	 (low
		:initarg :low
		:type float)
	 (close
		:initarg :close
		:type float)
	 (volume
		:initarg :volume
	 :type integer)
	 (adjusted
		:initarg :adjusted
		:type float) ))

(def-view-class stock (value)
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


