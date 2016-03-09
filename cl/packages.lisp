(in-package :cl-user)

(defpackage database
	(:use
	 :common-lisp)
	(:export
	 :database
	 :store))

(defpackage market
	(:use
	 :common-lisp
	 :util
	 :cl-fad)
	(:export update stock))

