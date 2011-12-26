(define current-build-directory 
  (make-parameter 
   (string-append (current-directory) "build")))

(define current-source-directory 
  (make-parameter 
   (string-append (current-directory) "sources")))

(define current-project-name
  (make-parameter
   (path-strip-directory
    (path-strip-trailing-directory-separator))))

(define current-module-name
  (make-parameter (current-project-name)))