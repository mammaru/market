(in-package :common-lisp)

(defparameter *root* (truename "./"))
(defparameter *src* (merge-pathnames #P"src/" *root*))
(defparameter *data* (merge-pathnames #P"data/" *root*))

(load "load.lisp")

