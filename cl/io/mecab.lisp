(use-package :sb-alien)

(load-shared-object "/usr/local/lib/libmecab.dylib")

(define-alien-routine "mecab_new2" (* t) (param c-string))
(define-alien-routine "mecab_sparse_tostr" c-string (mecab (* t)) (text c-string))
(define-alien-routine "mecab_destroy" void (mecab (* t)))

;;;;;;;;
;;;; wrapper
(defvar *mecab*)

(defun mecab-parse (text &optional (*mecab* *mecab*))
  (mecab-sparse-tostr *mecab* text))

(defmacro with-mecab ((&optional (option "")) &body body)
  `(let ((*mecab* (mecab-new2 ,option)))
      (unwind-protect
           (progn ,@body)
         (mecab-destroy *mecab*))))
