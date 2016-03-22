(in-package :clts-user)

(defmacro defnode (name &body body)
  `(defun transition))

(defmacro defmodel (name &body body)
  `(progn
	 (dolist (variable ,@body)
	   (defnode variable
		   (:transition )))
	 ',name))
	 


(defmodel xssm
	((observation
	  :from ((observation linear))
	  :to ((observation linear))
	  :dimension 50)
	 (system
	  :from ((system linear) (external-modulation linear))
	  :to ((system linear) (observation linear))
	  :dimension 10)
	 (external-modulation
	  :from ((external-modulation linear))
	  :to ((system linear) (external-modulation))
	  :dimension 1)))
