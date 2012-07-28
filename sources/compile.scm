(define gambit-compiler (make-parameter (path-expand "~~/bin/gsc")))

(define c-compiler (make-parameter "gcc"))

(define (gambit-compile-file
         name 
         #!key 
         (output (current-build-directory)) 
         (options ""))
  (info "compiling " name)
  (shell-command
   (string-append (gambit-compiler) " -o " output " " options " " name)))

(define (gambit-compile-files
         #!key
         (files (fileset test: (f-and (extension=? ".scm") 
                                      (f-not (ends-with? "#.scm")) 
                                      (newer-than? ".c"))))
         (output (current-build-directory))
         (options ""))
  (for-each
   (lambda (name) (gambit-compile-file name output: output options: options))
   files))

(define (c-compile-file
         name 
         #!key 
         (output (current-build-directory)) 
         (options ""))
  (shell-command
   (string-append (c-compiler) " -o" output " " options " " name)))

(define (c-compile-files
         #!key
         (files (fileset test: (f-and (extension=? ".scm") 
                                      (f-not (ends-with? "#.scm")) 
                                      (newer-than? ".c"))))
         (output (current-build-directory))
         (options ""))
  (for-each
   (lambda (name) (c-compile-file output: output options: options))
   files))

(define (include-files
         #!key
         (files (fileset test: (ends-with? "#.scm") output: (current-build-directory)))
         (dest (string-append (current-build-directory)  (current-module-name) "#.scm")))
  (append-files files dest))

(define (list->escaped-string l)
  (define (flatten x:xs)
    (let* ((result (cons '() '())) (last-elt result))
      (define (f x:xs)
        (cond
         ((null? x:xs)
          result)
         ((pair? (car x:xs))
          (f (car x:xs)) (f (cdr x:xs)))
         (else
          (set-cdr! last-elt (cons (car x:xs) '()))
          (set! last-elt (cdr last-elt))
          (f (cdr x:xs)))))
      (f x:xs)
      (cdr result)))
  (apply
   string-append
   (flatten
    (letrec ((map-to-strings
              (lambda (l #!optional front)
                (let* ((rest
                        (lambda ()
                          (cons (map-to-strings (car l))
                                (if (null? (cdr l))
                                    (map-to-strings (cdr l))
                                    (map-to-strings (cdr l) " ")))))
                       (next
                        (cond
                         ((null? l) (list ")"))
                         ((not (pair? l)) (object->string l))
                         ((pair? (car l))
                          (list "(" (rest)))
                         (else
                          (rest)))))
                  (if front
                      (list front next)
                      next)))))
      (map-to-strings l "(")))))

(define (gambit-eval-here code)
  (let ((code-string (list->escaped-string code)))
    (info "sake eval: ")
    (pp code)
    (shell-command
     (string-append (gambit-compiler) " -e '" code-string "'"))))

(define (gambit-eval code-string)
  (info "eval: " code-string)
  (shell-command
   (string-append (gambit-compiler) " -e '" code-string "'")))
