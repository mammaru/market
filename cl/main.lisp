(in-package :cl-user)

(defparameter *environment* "development")
(defvar *root* (truename "./"))
(defvar *data-path* (merge-pathnames #P"data/" *root*))
(defvar *src-path* (merge-pathnames #P"src/" *root*))

;;;(compile-file (merge-pathnames #P"market.lisp" *src-path*))
(load (merge-pathnames #P"market.lisp" *src-path*))

;;;(use-package 'cl-mkt)
