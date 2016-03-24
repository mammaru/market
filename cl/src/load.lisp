(in-package :cl-user)
(defvar *src/lib-path* (merge-pathnames #P"lib/" *src-path*))

(eval-when (:compile-toplevel :load-toplevel :execute)
	(ql:quickload '(:cl-annot :drakma :cl-csv :clsql :clsql-sqlite3	:mecab)))

(load (merge-pathnames #P"util.lisp" *src/lib-path*))
(load (merge-pathnames #P"spider.lisp" *src/lib-path*))

(load (merge-pathnames #P"base.lisp" *src-path*))
(util:load-all (merge-pathnames #P"migrate/" *src-path*) :compile t)

;;;(load (merge-pathnames #P"mecab.lisp" *src-path*))
