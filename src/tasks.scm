(##namespace ("sake#"))
(include "~~/lib/gambit#.scm")

(define-structure task
  name
  (description unprintable:)
  (depends read-only: unprintable:)
  (handler read-only: unprintable:)
  (executed? unprintable: init: #f))

(define (task-force-run task)
  ((task-handler task))
  (task-executed?-set! task #t)
  #t)

(define (task-run task)
  (or (task-executed? task)
      (and
       (map task-run (task-depends task))
       (task-force-run task))))

;; bound dynamically to the local task
(define current-task (make-parameter #f))

;; bound to task that have to be run as a default task
(define main-task (make-parameter #f))
