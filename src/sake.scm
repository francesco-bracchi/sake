(namesapce ("sake#"))
(##include "~~/lib/gambit#.scm")

(define (sake name)
  (run-task (eval name)))

(define (assc e es)
  (let assc ((es es))
  (cond
   ((null? es) #f)
   ((equal? (car es) e) es)
   (else (assc (cdr es))))))

(define (get-parameter p #!optional (default #f))
  (cond
   ((assc p (command-line)) => cadr)
   (else default)))

(define (get-task default)
  (let last ((lst (command-line)))
    (cond
     ((null? lst) default)
     ((null? (cdr lst)) (car lst))
     ((char=? (string-ref (car lst) 0) "-") (last (cddr lst)))
     (else (last (cdr lst))))))

(define *directory* #f)

(define *file* #f)

(define (load-all-files dir)
  (for-each (lambda (file) (load (path-strip-extension (string-append dir "/" file))))
            (directory-files dir)))

(define (init)
  (load "~~contrib/sake/tasks")
  (eval `(include "~~contrib/sake/tasks#.scm"))
  (load-all-files)
  (load (string-append *directory* "/" *file*)))
  
(define *help* #<<end-of-help
sake [-file <sake-file>] [<initial-task>]
sake -help

sake is an utility like make for scheme.
<sake-file> is the file containing tasks description (defaults to sake-file.scm)
<initial-task> is the entry point task, (defaults to make)
end-of-help
)

(define (main) 
  (if (get-parameter "-help") 
      (display help)
      (begin
        (set! *file* (get-parameter "-file" "sakefile.scm"))
        (set! *initial-task* (get-task "build"))
        (init)
        (run-task *initial-task*))))

(main)