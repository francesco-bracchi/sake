(define-task init ()
  (make-directory (current-build-directory)))

(define-task clean (init)
  (delete-file (current-build-directory)))

(define-task compile-lib (init)
  (gambit-compile-files
   files: (fileset test: (f-and (ends-with? "sakelib.scm") (newer-than? ".o1")))
   output: (string-append (current-build-directory) "sakelib.o1")))

(define-task compile-exe (init)
  (if ((newer-than? "") (string-append (current-source-directory) "sake.scm"))
      (gambit-compile-file
       (string-append (current-source-directory) "sake.scm")
       output: (string-append (current-build-directory) "sake")
       options: "-exe")))

(define-task compile (compile-exe compile-lib)
  '(compile all))

(define-task includes (init)
  (copy-files (fileset dir: (current-source-directory) test: (f-and (ends-with? "#.scm") regular?))
              (current-build-directory)))

(define-task install (compile includes)
  (make-directory "~~sake")
  (make-directory "~~sake/sources")

  (delete-file "~~sake/sakelib.o1")
  (delete-files (fileset dir: "~~sake/" test: (ends-with? "#.scm")))
  (delete-file "~~/bin/sake")
  
  (copy-file (string-append (current-build-directory) "sakelib.o1") "~~sake/sakelib.o1")
  (copy-files (fileset dir: (current-source-directory) test: (f-and (ends-with? "#.scm") regular?)) "~~sake/")
  (copy-file (string-append (current-build-directory) "sake") "~~/bin/sake")
  
  (copy-files (fileset dir: (current-source-directory) test: (ends-with? ".scm"))
              "~~sake/sources/"))
