(define (reduce f i l)
  (let reduce ((i i) (l l))
    (if (null? l) i
        (reduce (f i (car l)) (cdr l)))))

(define current-build-directory 
  (make-parameter 
   (string-append (current-directory) "build/")))

(define current-source-directory 
  (make-parameter 
   (string-append (current-directory) "sources/")))

(define current-project-name
  (make-parameter
   (path-strip-directory
    (path-strip-trailing-directory-separator (current-directory)))))

(define current-module-name
  (make-parameter (current-project-name)))

(define (log type . message)
  (display "*** ")
  (display type)
  (display " -- ")
  (for-each print message)
  (newline))

(define (info . message)
  (apply log (cons "INFO" message)))

(define (warn . message)
  (apply log (cons "WARNING" message)))

(define (err . message)
  (apply log (cons "ERROR" message))
  (apply error (cons "sake error" message)))

(define (sake #!key 
              (dir (current-directory))
              (file "sakefile.scm")
              (task 'all))
  (info "entering directory " dir)
  (eval `(begin
           (##namespace (,(string-append (symbol->string (gensym 'sakefile)) "#")))
           (##include "~~lib/gambit#.scm")
           (##include "~~sake/sakelib#.scm")
           (include ,(string-append dir file))
	   (with-exception-catcher
	    (lambda (ex)
	      (if (unbound-global-exception? ex) 
		  (err ,(string-append "task '" (symbol->string task) "' not found in " file))
		  (raise ex)))
	    (lambda () (task-run ,task)))))
  (info "exiting directory " dir))
  
