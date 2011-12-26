(define (compile-files-to-c
         #!key
         (options '())
         (output (current-build-directory))
         (module-name (current-module-name))
         (files (fileset test: (f-and (extension=? ".scm") 
                                      (f-not (ends-with? "#.scm")) 
                                      (newer-than? ".c")))))
  (for-each
   (lambda (name) 
     (compile-file-to-c name options: options output: output module-name: module-name))
   files))

(define (link-files 
         #!key
         (incremental #t)
         (output (string-append (current-build-directory) "/" (current-module-name) "_.c"))
         (base "~~lib/_gambc.c")
         (warnings? #t)
         (files (fileset test: (extension=? ".c")
                         dir:  (current-build-directory))))
  (if incremental
      (link-incremental files base: base output: output warnings?: warnings?)
      (link-flat output: output warnings?: warnings?)))

(define (compile-files 
         #!key
         (files (fileset test: (f-and (newer-than? ".o") (ends-with? "_.c"))))
         (options '())
         (output (current-build-directory))
         (cc-options "")
         (ld-options-prelude "")
         (ld-options ""))
  (for-each (lambda (file) 
              (compile-file file options output cc-options ld-options-prelude ld-options))
            files))

(define (include-files
         #!key
         (files (fileset test: (ends-with? "#.scm") dir: (current-build-directory)))
         (dest (string-append (current-build-dir) "/" (current-module-name) "#.scm")))
  (append-files files dest))
