(in-package :common-lisp)

(defparameter *root* (truename "./"))
(defparameter *lib-path* (merge-pathnames #P"lib/" *root*))
(defparameter *src-path* (merge-pathnames #P"src/" *root*))
(defparameter *data-path* (merge-pathnames #P"data/" *root*))

(compile-file "load.lisp")
(load "load.lisp")
