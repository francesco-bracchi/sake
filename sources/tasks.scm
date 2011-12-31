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
      (begin
       (map task-run (task-depends task))
       (begin
         (info "enter into task " (task-name task))
         (task-force-run task)
         (info "exit from task " (task-name task))
         #t))))

;; bound dynamically to the local task
(define current-task (make-parameter #f))

;; bound to task that have to be run as a default task
(define main-task (make-parameter #f))
