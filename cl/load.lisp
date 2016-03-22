(in-package :cl-user)

(ql:quickload '(:cl-annot :drakma :cl-csv :clsql :clsql-sqlite3	:mecab))

(compile-file (merge-pathnames #P"util.lisp" *root*))
(load (merge-pathnames #P"util.lisp" *root*))

;;;(load-all *lib-path*)
(util:load-all *src-path* :compile t :priority-files '("spider.lisp" "base.lisp" "stock.lisp"))
