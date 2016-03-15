;;;(eval-when (:compile-toplevel)
;;;	(ql:quickload '(:clsql :clsql-sqlite3))
;;;	(require 'crawl)
;;;	(require 'market.database))

(in-package :market.dbi)


(clsql:def-view-class names()
	((code
		:db-kind :join
		:db-info (:join-class stocks :home-key code :foreign-key code)
		:accessor code
		:initarg :code
		:type integer
		:db-constraints (:not-null :unique :primary-key))
	 (name
		:accessor name
		:initarg :name
		:type string)))

(clsql:def-view-class stocks()
	((id 
		:accessor id
		:initarg :id
		:type integer
		:db-kind :key 
		:db-constraints (:not-null :unique :primary-key))
	 (date
		:accessor date
		:initarg :date
		:type date)
	 (code
		:db-kind :join
		:db-info (:join-class names :home-key code :foreign-key code)
		:accessor code
		:initarg :code
		:type integer
		:db-constraints :not-null)
	 (market-id
		:db-kind :join
		:db-info (:joinclass market-names :home-key market-id :foreign-key id)
		:accessor market-id
		:initarg :market-id
		:type integer)
	 (open
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
		:type float)))
