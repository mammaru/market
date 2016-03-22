(in-package :cl-user)

(ql:quickload '(:cl-annot :drakma :cl-csv :clsql :clsql-sqlite3	:mecab))

(compile-file (merge-pathnames #P"util.lisp" *root*))
(load (merge-pathnames #P"util.lisp" *root*))

(util:load-all *lib-path* :compile t)

(load (merge-pathnames #P"base.lisp" *src-path*))
(util:load-all (merge-pathnames #P"migrate/" *src-path*) :compile t)
;(util:load-all *src-path* :compile t :priority-files '("base.lisp"))
(load (merge-pathnames #P"mecab.lisp" *src-path*))
(load (merge-pathnames #P"market.lisp" *src-path*))
