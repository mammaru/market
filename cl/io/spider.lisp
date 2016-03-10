(in-package :common-lisp)

(defpackage spider
	(:use common-lisp
				drakma)
	(:nicknames cl-spdr)
	(:export parse
					 scrape
					 crawl))

(in-package :spider)

(defclass spider ()
	((name
		:initarg :name
		:initform (error "Must specify name")
		:accessor name)
	 (root
		:initarg :root-url
		:initform (error "Must specify root url")
		:accessor root)
	 (sleep-time
		:initarg :sleep-time
		:initform 3
		:reader sleep-time
		:accessor sleep-time
		:type 'number)))

(defgeneric parse (spider)
	(:documentation "parse html"))

(defgeneric scrape (spider)
	(:documentation "fetch and parse html"))

(defgeneric crawl (spider)
	(:documentation "crawl web"))

(defmethod scrape (spider)
	(sleep (slot-value spider 'sleep-time)))

(defmethod crawl (spider)
	nil)
