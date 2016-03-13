(in-package :common-lisp)

(defpackage crawl
	(:use common-lisp
				drakma)
	(:nicknames cl-crwl)
	(:export parse
					 scrape
					 define-spider
					 crawl))

(in-package :crawl)

(defmacro with-gensyms (syms &body body)
	`(let ,(mapcar #'(lambda (s) `(,s (gensym))) syms)
		 ,@body))

(defclass spider ()
	((root-url
		:initform (error "Must specify root url")
		:accessor root-url
		:type 'string)
	 (default-encoding)
	 (sleep-time
		:initarg :sleep
		:initform 5
		:accessor sleep-time
		:type 'number)
	 (text
		:initform nil
		:accessor fetched-doc
		:type 'string) ))

(defgeneric fetch (spider url)
	(:documentation "fetch web by http"))

(defgeneric parse (spider)
	(:documentation "parse html"))

(defgeneric scrape (spider)
	(:documentation "fetch and parse html"))

(defmethod fetch (spider url)
	(with-slots ((doc text)) spider
		(setf doc (string (drakma:http-request url))) ))

(defmethod parse (spider)
	(with-slots ((doc text)) spider
		(values doc nil) ))

(defmethod scrape (spider)
	(with-slots ((root root-url) (st sleep-time)) spider
		(let (results)
			(labels ((recursive-scrape (url)
								 (progn
									 (fetch spider url)
									 (multiple-value-bind (result next-url) (parse spider)
										 (cons result results)
										 (if next-url
												 (progn
													 (sleep st)
													 (recursive-scrape next-url))
												 results)))))
				(recursive-scrape root) ))))

(defmacro define-spider (sp-name (document sp-root-url &key sleep) &body body)
	(with-gensyms (sp)
		`(progn
			 (defclass ,sp-name (spider)
				 ((root-url
					 :initform ,sp-root-url
					 :accessor root-url
					 :type 'string)
					,(if sleep
							 `(sleep-time
								 :initarg :sleep
								 :initform ,sleep
								 :accessor sleep-time
								 :type 'number) )))
			 (defmethod parse ((,sp ,sp-name))
				 (with-slots ((,document text)) ,sp
					 ,@body) ))))


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
