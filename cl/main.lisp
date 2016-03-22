(in-package :cl-user)

(defparameter *environment* "development")

(defparameter *root* (truename "./"))
(defparameter *data-path* (merge-pathnames #P"data/" *root*))
(defparameter *lib-path* (merge-pathnames #P"lib/" *root*))
(defparameter *src-path* (merge-pathnames #P"src/" *root*))



(compile-file "load.lisp")
(load "load.lisp")

;(use-package 'cl-mkt)
