(in-package :cl-user)

(ql:quickload '(:drakma :cl-csv :clsql :clsql-sqlite3	:mecab))

(compile-file (merge-pathnames #P"util.lisp" *root*))
(load (merge-pathnames #P"util.lisp" *root*))

;;;(load-all *lib-path*)
(util:load-all *src-path* :compile t :priority-files '("spider.lisp"))
