(in-package :common-lisp)

(defparameter *root* (truename "./"))
(defparameter *src-path* (merge-pathnames #P"src/" *root*))
(defparameter *data-path* (merge-pathnames #P"data/" *root*))

(load "load.lisp")

