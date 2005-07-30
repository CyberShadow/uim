(load "./test/unittest.scm")

;; lambda
(assert-eq? "basic lambda test1" 8 ((lambda (x) (+ x x)) 4))
(define reverse-subtract
  (lambda (x y) (- y x)))
(assert-eq? "basic lambda test2" 3 (reverse-subtract 7 10))
(define add4
  (let ((x 4))
    (lambda (y) (+ x y))))
(assert-eq? "basic lambda test3" 10 (add4 6))
(assert-equal? "basic lambda test4" '(3 4 5 6) ((lambda x x) 3 4 5 6))
(assert-equal? "basic lambda test5" '(5) ((lambda (x y . z) z) 3 4 5))
(assert-equal? "basic lambda test6" '(5 6) ((lambda (x y . z) z) 3 4 5 6))
(assert-equal? "basic lambda test7" 1 ((lambda (x . y) x) 1))
(assert-equal? "basic lambda test8" '() ((lambda (x . y) y) 1))
(assert-equal? "basic lambda test9" 1 ((lambda (x y . z) x) 1 2))
(assert-equal? "basic lambda test10" 2 ((lambda (x y . z) y) 1 2))
(assert-equal? "basic lambda test11" '() ((lambda (x y . z) z) 1 2))

;; cond
(assert-equal? "basic cond test1" 'greater (cond ((> 3 2) 'greater)
						 ((< 3 2) 'less)))
(assert-equal? "basic cond test2" 'equal (cond ((> 3 3) 'greater)
					       ((< 3 3) 'less)
					       (else 'equal)))
(assert-equal? "basic cond test3" #t (cond ((> 3 2))
					   ((< 3 4) 'less)
					   (else 'equal)))
(assert-equal? "basic cond test4" 2 (cond ((assv 'b '((a 1) (b 2))) => cadr)
					  (else #f)))
(assert-equal? "basic cond test5" 'greater1 (cond ((> 3 2) 'greater0 'greater1)
						  (else #f)))

;; case
(assert-eq? "basic case check1" 'case1 (case 1
					 ((1) 'case1)
					 ((2) 'case2)))

(assert-eq? "basic case check2" 'case2 (case 2
					 ((1) 'case1)
					 ((2) 'case2)))

(assert-eq? "basic case check3" #t (case (* 2 3)
			      ((2 3 4 7)   #f)
			      ((1 4 6 8 9) #t)))

(assert-eq? "basic case else"  'caseelse (case 3
					   ((1) 'case1)
					   ((2) 'case2)
					   (else
					    'caseelse)))

;; and
(assert-eq? "and test 1" #t (and (= 2 2) (> 2 1)))
(assert-eq? "and test 2" #f (and (= 2 2) (< 2 1)))
(assert-equal? "and test 3" '(f g) (and 1 2 'c '(f g)))
(assert-equal? "and test 4" #t (and))

;; or
(assert-eq? "or test1" #t (or (= 2 2) (> 2 1)))
(assert-eq? "or test2" #t (or (= 2 2) (< 2 1)))
(assert-eq? "or test3" #f (or #f #f #f))
(assert-equal? "or test4" '(b c) (or (memq 'b '(a b c))
				     (/ 3 0)))

;; let
(assert-eq? "basic let test1" 0 (let ((n 0))
				 n))
(assert-eq? "basic let test2" 1 (let ((n 0))
				  (set! n 1)))
(assert-eq? "basic let test3" 1 (let ((n 0))
				  (set! n (+ n 1))))
(assert-eq? "basic let test4" 3 (let ((n1 2)
				      (n2 1))
				  (+ n1 n2)))
(define count
  (let ((n 0))
    (lambda ()
      (set! n (+ n 1)))))

(assert-eq? "lexical scope test1" 1 (count))
(assert-eq? "lexical scope test2" 2 (count))

(define a 3)
(define (lexical-test)
  (let ((a 1))
    (assert-eq? "lexical scope test3" 1 a)
    (let* ((a 2))
      (assert-eq? "lexical scope test4" 2 a))
    (assert-eq? "lexical scope test5" 1 a)))
(lexical-test)

;; let*
(assert-eq? "basic let* test1" 70 (let ((x 2) (y 3))
				    (let* ((x 7)
					   (z (+ x y)))
				      (* z x))))

;; letrec
(assert-eq? "basic letrec test1" #t (let ((even?
					   (lambda (n)
					     (if (zero? n)
						 #t
						 (odd? (- n 1)))))
					  (odd?
					   (lambda (n)
					     (if (zero? n)
						 #f
						 (even? (- n 1))))))
				      (even? 88)))

;; begin
(define x 0)
(assert-eq? "basic begin test1" 6 (begin
				    (set! x 5)
				    (+ x 1)))
(assert-eq? "basic begin test2" 0 (begin
				    0))
(assert-eq? "basic begin test3" 1 (begin
				    0
				    1))
(assert-eq? "basic begin test4" 1 (begin
				    (define n 0)
				    (set! n 1)))
;; do
(assert-equal? "do test1" '#(0 1 2 3 4) (do ((vec (make-vector 5))
					     (i 0 (+ i 1)))
					    ((= i 5) vec)
					  (vector-set! vec i i)))
(assert-equal? "do test2" 25 (let ((x '(1 3 5 7 9)))
			       (do ((x x (cdr x))
				    (sum 0 (+ sum (car x))))
				   ((null? x) sum))))

(define (expt-do x n)
  (do ((i 0 (+ i 1))
       (y 1))
      ((= i n) y)
    (set! y (* x y))))
(assert-eq? "do test3" 1024 (expt-do 2 10))

(total-report)
