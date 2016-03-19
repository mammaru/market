(in-package :cl-user)
(ql:quickload :cls)

(defpackage :common-lisp-time-series-user
  (:documentation "demo of how to put serious work should be placed in
    a similar package elsewhere for reproducibility.  This hints as to
    what needs to be done for a user- or analysis-package.")
  (:nicknames :clts-user)
  (:use :common-lisp ; always needed for user playgrounds!
        :lisp-matrix ; we only need the packages that we need...
        :common-lisp-statistics
        :cl-variates
        :lisp-stat-data-examples) ;; this ensures access to a data package
  (:shadowing-import-from :lisp-stat
      ;; This is needed temporarily until we resolve the dependency and call structure. 
      call-method call-next-method

      expt + - * / ** mod rem abs 1+ 1- log exp sqrt sin cos tan
      asin acos atan sinh cosh tanh asinh acosh atanh float random
      truncate floor ceiling round minusp zerop plusp evenp oddp 
      < <= = /= >= > > ;; complex
      conjugate realpart imagpart phase
      min max logand logior logxor lognot ffloor fceiling
      ftruncate fround signum cis

      <= float imagpart)
  (:shadowing-import-from :lisp-matrix :rand)

  (:export summarize-data
		   summarize-results
		   this-data
		   this-report
		   :vector-auto-regressive-model
		   :state-space-model))


(defpackage :kalman
  (:use :clts-user))

(defpackage :particle
  (:use :clts-user))
