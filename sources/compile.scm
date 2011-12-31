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

