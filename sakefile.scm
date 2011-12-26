(load "~~sake/filesets")

(define-task init ()
  (make-directory (current-build-directory)))

(define-task clean (init)
  (delete-files (fileset dir: (current-build-directory)))
  (delete-file (current-build-directory)))

(define-task compile-to-c (init)
  (compile-files-to-c))

(define-task link (compile-to-c)
  (link-files
   files: (list "src/common.scm"
                "src/compile.scm"
                "src/filesets.scm"
                "src/tasks.scm")))

(define-task compile (compile-to-c)
  (compile-files)
  (compile-files files: "build/sake.c" exe: #t))

(define-task make-include (init)
  (append-files
   (fieldset test: (ends-with? "#.scm"))
   dest: (string-append (current-build-directory) "/" (current-module-name) "#.scm")))

(define-task install (compile)
  (copy-files 
   files: (fieldset dir: (current-build-directory)
                    test: (f-or (extension=? ".o")
                                (ends-with? "#.scm")))
   dest: (string-append "~~" (current-project-name) "/" (current-module-name))))
