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

(defparameter *src/lib-path* (merge-pathnames #P"lib/" *src-path*))
(compile-file (merge-pathnames #P"util.lisp" *root*))
(load (merge-pathnames #P"util.lisp" *root*))

(util.pathnames:walk-directory *src/lib-path* #'compile-file)
(util.pathnames:walk-directory *src/lib-path* #'load)
(util.pathnames:walk-directory *src-path* #'compile-file)
(util.pathnames:walk-directory *src-path* #'load)
