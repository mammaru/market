;;;(eval-when (:compile-toplevel)
;;;	(ql:quickload '(:drakma :cl-csv :cl-fad)))

(in-package :common-lisp)

(defpackage util
	(:use common-lisp
				drakma
				cl-csv
				cl-fad)
	(:export with-gensyms
					 download-file
					 today
					 now
					 with-download-csv))

(in-package :util)

(defmacro with-gensyms (syms &body body)
	`(let ,(mapcar #'(lambda (s) `(,s (gensym))) syms)
		 ,@body))

;;;(defmacro with-gensyms ((&rest names) &body body)
;;;	`(let ,(loop for n in names collect `(,n (gensym)))
;;;		 ,@body))

(defun download-file (uri filename)
  (with-open-file (out filename
											 :direction :output
											 :if-exists :supersede
											 :element-type '(unsigned-byte 8))
    (with-open-stream (input (http-request uri :want-stream t :connection-timeout nil))
      (loop :for b := (read-byte input nil -1)
				 :until (minusp b)
				 :do (write-byte b out)))))

(defun today ()
	(labels ((n-to-0n (n)
						 (if (and (< n 10) (>= n 0))
								 (concatenate 'string "0" (write-to-string n))
								 (write-to-string n))))
		(multiple-value-bind (sec min hour d m y) (get-decoded-time)
			(values (concatenate 'string (write-to-string y) "-" (n-to-0n m) "-" (n-to-0n d))
							(concatenate 'string (n-to-0n hour) ":" (n-to-0n min) ":" (n-to-0n sec)) ))))

(defun now ()
	(labels ((n-to-0n (n)
						 (if (and (< n 10) (>= n 0))
								 (concatenate 'string "0" (write-to-string n))
								 (write-to-string n))))
		(multiple-value-bind (sec min hour d m y)	(get-decoded-time)
			(values	(concatenate 'string (n-to-0n hour) ":" (n-to-0n min) ":" (n-to-0n sec))
							(concatenate 'string (write-to-string y) "-" (n-to-0n m) "-" (n-to-0n d)) ))))


(defmacro with-download-csv (uri (data-sym &key (encoding :utf-8)) &body body)
					(with-gensyms (file-name)
						`(progn
							 (download-file ,uri ,file-name)
							 (setf cl-csv:*default-external-format* ,encoding)
							 (let ((,data-sym (cl-csv:read-csv ,file-name :trim-outer-whitespace t)))
								 ,@body)
							 (cl-fad:delete-directory-and-files ,file-name))))


;;;
;;; utilities for pathname
;;;
(defpackage util.pathnames
	(:use common-lisp)
	(:export component-present-p
					 directory-pathname-p
					 pathname-as-directory
					 directory-wildcard
					 list-directory
					 file-exists-p
					 pathname-as-file
					 walk-directory))

(in-package :util.pathnames)

(defun component-present-p (value)
  (and value (not (eql value :unspecific))))

(defun directory-pathname-p (p)
  (and
   (not (component-present-p (pathname-name p)))
   (not (component-present-p (pathname-type p)))
   p))

(defun pathname-as-directory (name)
  (let ((pathname (pathname name)))
		(when (wild-pathname-p pathname)
			(error "Can't reliably convert wild oathnames."))
		(if (not (directory-pathname-p name))
				(make-pathname
				 :directory (append (or (pathname-directory pathname) (list :relative))
														(list (file-namestring pathname)))
				 :name nil
				 :type nil
				 :defaults pathname)
				pathname)))

(defun directory-wildcard (dirname)
  (make-pathname
   :name :wild
   :type #-clisp :wild #+clisp nil
   :defaults (pathname-as-directory dirname)))

(defun list-directory (dirname)
  (when (wild-pathname-p dirname)
		(error "Can only list concrete directory names."))
  (let ((wildcard (directory-wildcard dirname)))
	
		#+(or sbcl cmu lispworks)
		(directory wildcard)

		#+openmcl
		(directory wildcard :directories t)

		#+allegro
		(directory wildcard :directories-are-files nil)

		#+clisp
		(nconc
		 (directory wildcard)
		 (directory (clisp-subdirectories-wildcard wildcard)))

		#-(or sbcl cmu lispworks openmcl allegro clisp)
		(error "list-directory not implemented.")))

#+clisp
(defun clisp-subdirectories-wildcard (wildcard)
  (make-pathname
   :directory (append (pathname-directory wildcard) (list :wild))
   :name nil
   :type nil
   :defaults wildcard))

(defun file-exists-p (pathname)
  #+(or sbcl lispworks openmcl)
  (probe-file pathname)

  #+(or allegro cmu)
  (or (probe-file (pathname-as-directory pathname))
			(probe-file pathname))

  #+clisp
  (or (ignore-errors
				(probe-file (pathname-as-file pathname)))
			(ignore-errors
				(let ((directory-form (pathname-as-directory pathname)))
					(when (ext:probe-directory directory-form)
						directory-form))))

  #-(or sbcl cmu lispworks openmcl allegro clisp)
  (error "file-exists-p not implemented."))

(defun pathname-as-file (name)
  (let ((pathname (pathname name)))
		(when (wild-pathname-p pathname)
			(error "Can't reliably convert wild pathnames."))
		(if (directory-pathname-p name)
				(let* ((directory (pathname-directory pathname))
							 (name-and-type (pathname (first (last directory)))))
					(make-pathname
					 :directory (butlast directory)
					 :name (pathname-name name-and-type)
					 :type (pathname-type name-and-type)
					 :defaults pathname))
				pathname)))

(defun walk-directory (dirname fn &key directories (test (constantly t)))
  (labels
			((walk (name)
				 (cond
					 ((directory-pathname-p name)
						(when (and directories (funcall test name))
							(funcall fn name))
						(dolist (x (list-directory name)) (walk x)))
					 ((funcall test name) (funcall fn name)))))
		(walk (pathname-as-directory dirname))))
