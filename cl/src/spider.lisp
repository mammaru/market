(in-package :common-lisp)

(defpackage crawl
	(:use common-lisp
				drakma)
	(:nicknames cl-crwl)
	(:export spider
					 parse
					 scrape
					 crawl))

(in-package :crawl)

(defclass spider ()
	((name
		:initarg :name
		:initform (error "Must specify name")
		:accessor name)
	 (root-url
		:initarg :root-url
		:initform (error "Must specify root url")
		:accessor root-url)
	 (parser
		:initarg :parser
		:initform #'(lambda (doc) doc)
		:accessor parser
		:type 'lambda)
	 (recursive?
		:initarg :recursive?
		:initform nil
		:accessor recursive?)
	 (sleep-time
		:initarg :sleep-time
		:initform 5
		:accessor sleep-time
		:type 'number)))

(defgeneric fetch (spider url)
	(:documentation "fetch web by http"))

(defgeneric parse (spider doc)
	(:documentation "parse html"))

(defgeneric scrape (spider)
	(:documentation "fetch and parse html"))

(defmethod fetch (spider url)
	(drakma:http-request url :want-stream t))

(defmethod parse (spider doc)
	(with-slots ((parser parser)) spider
		(funcall parser doc) ))

(defmethod scrape (spider)
	(with-slots ((root root-url) (r-flag recursive?) (sleep-time sleep-time)) spider
		(if r-flag
				(let (results)
					(labels ((recursive-scrape (url)
										 (multiple-value-bind (result next-url) (parse spider (fetch spider url))
											 (cons result results)
											 (if next-url
													 (progn
														 (sleep sleep-time)
														 (recursive-scrape next-url))
													 results) )))
						(recursive-scrape root) ))
				(parse (fetch root)) )))

(defclass crawler ()
	((spider
		:initarg :spider
		:initform nil
		:accessor spider
		:type 'spider)))

(defgeneric crawl (crawler)
	(:documentation "crawl web"))

(defmethod crawl (crawler)
	nil)
