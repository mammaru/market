(in-package :cl-user)

(defparameter *root* (truename "./"))

(require 'drakma)
(require 'cl-csv)
(require 'cl-fad)
(require 'clsql)
(require 'clsql-sqlite3)
(require 'mecab)
;(use-package :mecab)

(defparameter *src* (merge-pathnames *root* #P"src/"))
(load (merge-pathnames *root* "util.lisp")

