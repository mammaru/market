(eval-when (:compile-toplevel :load-toplevel)
	(ql:quickload '(:drakma :jp :cl-ppcre)))

(in-package :common-lisp)

(defpackage crawl
	(:use common-lisp
				drakma)
	(:nicknames cl-crwl)
	(:export parse
					 scrape
					 define-spider
					 with-scrape
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
		:type 'string)
	 (jp
		:initform nil
		:initarg :jp
		:type 'boolean)))

(defgeneric fetch (spider url)
	(:documentation "fetch web by http"))

(defgeneric parse (spider)
	(:documentation "parse html"))

(defgeneric scrape (spider)
	(:documentation "fetch and parse html"))

(defmethod fetch (spider url)
	(with-slots ((doc text)) spider
		(setf doc (jp:decode (drakma:http-request url :force-binary t) :guess)) ))

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
										 (setf results (cons result results))
										 (if next-url
												 (progn
													 (sleep st)
													 (recursive-scrape next-url)))
										 results) )))
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

(defmacro with-scrape ((data) sp-name &body body)
	(with-gensyms (sp)
		`(let* ((,sp (make-instance ',sp-name)) (,data (scrape ,sp)))
			 ,@body) ))

(defmacro with-crawl ((data root-url &key (depth 1) sleep) &body body) 
	(with-gensyms (sp)
		`(progn
			 (define-spider ,sp (doc ,root-url ,@(if sleep `(:sleep ,sleep)))
				 ,@body)
			 (with-scrape)

(defgeneric crawl (crawler)
	(:documentation "crawl web"))

(defmethod crawl (crawler)
	nil)
