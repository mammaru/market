(in-package :clts-user)

;;
;; Classes
;;
(defclass dataframe ()
  ((data
	:initarg :data
	:initform "must be specified data."
	:accessor data
	:documentation "a set of observed data")
   (index
	:accessor index
	:documentation "number of data points")
   (dimension
	:accessor dimension
	::documentation "dimension of each data")))

(defclass time-series-model ()
  ((parameters
	:initarg :data
	:accessor data
	:documentation "time series observation data")
   (transision
	:initarg :dimension
	:type integer
	:reader dimension
	:documentation "dimension of each step observation for time series model")))

(defclass vector-auto-regressive-model (time-series-model)
  ((dimension
	:initarg :dimension
	:initform (error "Must be specified dimension of observation at each time points by :dimension")
	:accessor dimension)
   (transition-matrix
	:initarg :A
	:accessor A
	:documentation "transition matrix or coefficient")
   (error-mean
	:initarg :mu
	:documentation "mean of error")
   (error-variance-matrix
	:initarg :sigma
	:accessor sigma
	:documentation "variance matrix of error")
   (values
	:reader v
	:documentation "generated values by vector-auto-regressive-model")))

(defclass auto-regressive-model (vector-auto-regressive-model)
  ((coefficient
	:initarg :coefficient
	:documentation "coefficient of regression at each step")
   (dimension
	:reader dimension
	:initform 1)
   (time-points
	:initarg :time-points
	:documentation "total number of time-series data")))

(defclass state-space-model (time-series-model)
  ((dimension
	:initarg :obs-dim
	:initform (error "Must supply dimension of observation as :obs-dim"))
   (system-dimension
	:initarg :sys-dim
	:initform (error "Must supply dimension of system as :sys-dim"))
   (initial-mean-of-system
	:initarg :x0mean
	:initform (rand dimension 0))
   (initial-variance-of-system
	:initarg :x0var)
   (system-values
	:initform 0)
   (observation-values
	:initform 0)))

;;
;; Methods
;;
(defmethod initialize-instance :after ((model vector-auto-regressive-model) &key)
  (let ((dim (slot-value model 'dimension)))
	(setf (slot-value model 'transition-matrix) (rand dim dim))
	(setf (slot-value model 'error-mean) (zeros dim 1))
	(setf (slot-value model 'error-variance-matrix) (eye dim dim))
	(setf (slot-value model 'values) (list (multivariate-normal (eye dim dim))))))

;; TODO: closure is better?
(defgeneric transition (model values)
  (:documentation "one-step-transition of each time series model."))

;(defmethod transition ((model vector-auto-regressive-model))
;  (with-slots ((dim dimension) (A transition-matrix) (E error-matrix) (v values)) model
;	  (let ((past-value (last v)))
;		(setf v (cons (last v) (M+ (M* A past-value) (multivariate-normal E)))) )))

;(defmethod transition ((model state-space-model))
;  (with-slots (dim dimension) model
;	))

(defmethod sparse-vector-auto-regression ((model vector-auto-regressive-model))
  (with-slots (dim dimension) model
	))


(defun make-linear-transition (a e)
  #'(lambda (x)
	  (progn
		(setf x (M+ (M* a x) (multivariate-normal e)))
		x)))

(defun make-time-series (initial-values transition-function)
  (let ((v initial-values))
	#'(lambda ()
		(setf v (transition-function v)) )))




;; junk scripts
(defparameter *tmp* (zeros 10 10))
(M* *tmp* (rand 10 10))
*tmp*
(transpose-matrix *tmp*)
(check-type *tmp* matrix-like)
;(assert (= (nrows *tmp*) (ncols *tmp*)))
(cholesky-decomposition *tmp*)
;(disassemble 'make-linear-transition)


(defmacro make-transition(name &body equation)
  `(setf ,name
		 (lambda (x) ,@equation) ))

;(macroexpand-1 '(make-transition linear (zeros 5 1)
;			   (M+ (M* (eye 5 5) x) (multivariate-normal (eye 5 5))) ))

;(defun make-linear-transition (a e)
;  #'(lambda (x)
;	  (progn
;		(setf x (M+ (M* a x) (multivariate-normal e)))
;		x)))

(defclass time-series-model ()
  ((variables :initarg :variables
			  :accessor v
			  :documentation "variables of each series of model")
   (parameters :initarg :params
			   :accessor params
			   :documentation "parameters of time series model") ))

(defclass variable-of-model ()
  ((name :initarg :name
		 :initform (error "must be specified variable's name")
		 :accessor name
		 :type string
		 :documentation "name of a variable")
   (dimension :initarg :dimension
			  ;:initform (error "must be specified dimension of variable")
			  :accessor dim
			  :type integer
			  :documentation "dimension of variable") ))

(defclass parameter-of-model ()
  ((name :initarg :name
		 :initform (error "must be specified parameter's name")
		 :accessor name
		 :type string
		 :documentation "name of a parameter")
   (value :initarg :value
		  ;:initform (error "must be specified parameter' value")
		  :accessor value
		  ::documentation "value of parameter") ))

(defclass vector-auto-regressive-model (time-series-model)
  ((variables :initarg :vars
			  :initform (error "Must be specified variables"))
   (parameters :initarg :params
			   :initform (make-parameters)) ))

(defmethod initialize-instance :after ((model vector-auto-regressive-model) &key)
  (with-slots ((v variables) (params parameters)) model
	(with-slots ((x0 initial-value)
				 (A transition-matrix)
				 (sigma error-variance)) params
	  (let ((dim (slot-value v 'dimension)))
		(setf x0 (rand dim 1))
		(setf A (rand dim dim))
		(setf sigma (eye dim dim)) ))))

(defmethod transition ((model vector-auto-regressive-model) values)
  (with-slots ((params parameters)) model
	(with-slots ((x0 initial-value)
				 (A transition-matrix)
				 (sigma error-variance)) params
	  (if values
		  (M+ (M* A values) (multivariate-normal sigma))
		  (M+ (M* A x0) (multivariate-normal sigma)) ))))

(defun as-keyword (symbol)
  (intern (string symbol) :keyword))

(defun slot->class-slot (spec)
  (let ((name (first spec)))
	`(,name :initarg ,(as-keyword name) :accessor ,name)))

(defmacro with-spec (vars-params model &body body)
  (destructuring-bind (vars params) vars-params
	`(with-slots ((v variables) (p parameters)) ,model
	   (with-slots ,(mapcar #'(lambda (x) `(,x ,(name x))) vars) v
		 (with-slots ,(mapcar #'(lambda (x) `(,x ,(name x))) params) p
		   ,@body) ))))


(defmacro deftransition (model-instance-name transitions)
  `(defmethod transition (model ,model-instance-name)))


; macro definition
(defmacro define-time-series-model (name (&rest args) &body details)
  (destructuring-bind (variables parameters transitions) ((cdr (assoc :variables details))
														  (cdr (assoc :parameters details))
														  (cdr (assoc :transitions details)))
	`(let (,(mapcar #'(lambda (spec)
						`(,(first spec)
						   (make-instance variable-of-model :name ,(second spec)) ))
					variables)
		   ,(mapcar #'(lambda (spec)
						`(,(first spec)
						   (make-instance parameter-of-model :name ,(second spec)) ))
					parameters)
			(var-names ,(mapcar #'(lambda (spec) (first spec)) variables))
			(param-names ,(mapcar #'(lambda (spec) (first spec)) parameters)))

	   ; define class and methods
	   (defclass ,name (time-series-model)
		 ((variables :initform ,var-names
					 :accessor variables)
		  (parameters :initform ,param-names
					  :accessor parameters) ))
	   (defmethod initialize-instance :after ((model ,name) &rest dims)
				  (with-spec ((,var-names) (,param-names)) model
					(let ((dim ))
					  (setf x0 (rand dim 1))
					  (setf A (rand dim dim))
					  (setf sigma (eye dim dim)) )))
	   (defmethod transition ((model ,name) values)
		 (with-spec (() (,param-names)) model
		   (if values ,transitions ))))))



(define-time-series-model vector-auto-regressive-model ()
  (:variables ((x value 5)))
  (:parameters ((A transition-matrix (rand 5 5))
				(sigma error-variance (eye 5 5))
				(x0 initial-value (rand 5 1)) ))
  (:transitions ((M+ (M* A x) (multivariate-normal sigma)))) )

(define-time-series-model state-space-model ()
  (:variables ((system x 5)
			   (observation y 5) ))
  (:parameters ((transition-matrix F)
				(system-noise-variance Q)
				(observation-matrix G)
				((observation-noise-variance R))
				(initial-system x0) ))
  (:transitions (((M+ (M* F x) (multivariate-normal Q)))
				 ((M+ (M* H x) (multivariate-normal R))))) )



; yet another approach...
(defmacro make-time-series-model (name (&rest initial-values) &body equations)
  `(let (,(mapcar #'(lambda (k v) `(,k ,v)) initial-values))
	 (labels transition ()
			 ,@equations)))
