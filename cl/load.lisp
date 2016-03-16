(in-package :common-lisp)

(ql:quickload '(:drakma :cl-csv	:cl-fad	:clsql :clsql-sqlite3	:mecab))
;(require 'drakma)
;(require 'cl-csv)
;(require 'cl-fad)
;(require 'clsql)
;(require 'clsql-sqlite3)
;(require 'mecab)

(compile-file (merge-pathnames #P"util.lisp" *root*))
(load (merge-pathnames #P"util.lisp" *root*))

(util.pathnames:walk-directory *lib-path*
															 #'compile-file
															 :test (lambda (x) (if (string= (pathname-type x) "lisp") t)))
(util.pathnames:walk-directory *lib-path*
															 #'load
															 :test (lambda (x) (if (string= (pathname-type x) "fasl") t)))
(util.pathnames:walk-directory *src-path*
															 #'compile-file
															 :test (lambda (x) (if (string= (pathname-type x) "lisp") t)))
(util.pathnames:walk-directory *src-path*
															 #'load
															 :test (lambda (x) (if (string= (pathname-type x) "fasl") t)))
