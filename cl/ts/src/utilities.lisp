(in-package :clts-user)

(defun square-matrix-p (m)
  "Checking whether matrix is square or not. If square, returns dimension of matrix."
  (check-type m matrix-like)
  (if (reduce #'= (matrix-dimensions m)) (ncols m) nil))
  ;(let ((dim-row (nrows m)) (dim-col (ncols m)))
       ;(if (= (nrows m) (ncols m)) dim-row nil)))

(defun cholesky-decomposition (m)
  "Returns lower triangular matrix that squared to be original matrix.
   Augument matrix must be positive-semidefinitite."
  (if (square-matrix-p m)
	  (let* ((dim (square-matrix-p m)) (L (zeros dim dim)) (s 0))
		(dotimes (i dim)
		  (do ((j 0 (1+ j)))
			  ((= j i))
			(setf s (Mref m i j))
			(do ((k 0 (1+ k)))
				 ((= k j) (setf (Mref L i j) (/ s (Mref L j j))))
			   (decf s (* (Mref L i k) (Mref L j k))) ))
		  (setf s (Mref m i i))
		  (do ((k 0 (1+ k)))
			  ((= k i) (setf (Mref L i i) (sqrt s)))
			(decf s (expt (Mref L i k) 2)) ))
		L)
	  (error "Augument must be square matrix") ))

(defun multivariate-normal (sigma &optional mu)
  (let ((Q (cholesky-decomposition sigma)) (z (rand (square-matrix-p sigma) 1)))
	(if mu (M+ mu (M* Q z)) (M* Q z)) ))

