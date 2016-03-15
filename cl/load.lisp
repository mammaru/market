(in-package :common-lisp)

(ql:quickload '(:drakma
								:cl-csv
								:cl-fad
								:clsql
								:clsql-sqlite3
								:mecab))
;(require 'drakma)
;(require 'cl-csv)
;(require 'cl-fad)
;(require 'clsql)
;(require 'clsql-sqlite3)
;(require 'mecab)

(defparameter *src/lib* (merge-pathnames #P"lib/" *src*))
(compile-file (merge-pathnames #P"util.lisp" *root*))
(load (merge-pathnames #P"util.lisp" *root*))

(util.pathnames:walk-directory *src/lib* #'compile-file)
(util.pathnames:walk-directory *src/lib* #'load)
(util.pathnames:walk-directory *src* #'compile-file)
(util.pathnames:walk-directory *src* #'load)
