(##namespace ("sake#"))

(include "~~/lib/gambit#.scm")
(include "sake#.scm")

(define (extension=? ext)
  (ends-with? ext))

(define (ends-with? end)
  (lambda (name)
    (and (>= (string-length name) end)
         (string=? (substring name (- (string-length name) (string-length name)) (string-length name))
                   end))))

(define (newer-than? ext #!key 
                     (dir (current-build-directory)))
  (lambda (name)
    (let((name0 (string-append 
                 dir
                 (path-strip-extension (path-strip-directory name))
                 ext)))
      (or (not (file-exists? name0))
          (>= (time->seconds (file-last-modification-time name))
              (time->seconds (file-last-modification-time name0)))))))

(define (directory? name)
  (eq? (file-type name) 'directory))

(define (regular? name)
  (eq? (file-type name) 'regular))

(define (f-and . ts?)
  (lambda (name)
    (let f-and ((ts ts?))
      (or (null? ts)
          (and ((car ts) name)
               (f-and (cdr ts)))))))

(define (f-or . ts?)
  (lambda (name)
    (let f-or ((ts ts?))
      (and (pair? ts)
           (or ((car ts) name)
               (f-or (cdr ts)))))))

(define (shift fn)
  (lambda ts?
    (lambda (name)
      (apply fn (map t? name)))))
    
(define f-not (shift not))

(define (any? name) #t)
(define (none? name) #f)

(define (fileset #!key 
                 (dir (current-directory))
                 (test any?)
                 (recur #t))
  (let fileset ((fs (directory-files dir))
                (rs '()))
    (if (null? fs) (reverse rs)
        (let*((f (car fs))
              (fs (cdr fs))
              (t (file-type f)))
          (fileset (if (test f) (cons f rs) rs)
                   (if (and recur (directory? f)) (append fs (directory files f))))))))


(define (delete-file file #!key (recursive #t))
  (and (file-exists? file)
       (let((type (file-type file)))
         (cond
          ((eq? type 'regular) (delete-file file))
          ((eq? type 'symlink) (delete-file file))
          ((and (eq? type 'directory) recursive)
           (for-each delete-file (filesert dir: file))
           (delete-directory file))))))
          
(define (make-directory dir)
  (let((dir0 (path-strip-trailing-directory-separator dir)))
    (if (file-exists? dir0) #t
        (begin
          (make-directory (path-directory dir0))
          (create-directory dir0)))))
   
(define (delete-files files #!key (recursive #t))
  (for-each (lambda (file) (delete-file recursive: recursive))
            files))

(define (copy-files files dest)
  (for-each (lambda (file) (copy-file file dest))
            files))

(define (read-file file)
  (call-with-input-file file
    (lambda (in) (read-line in #f))))

(define (read-files files)
  (call-with-output-string ""
    (lambda (out)
      (for-each (lambda (file) (display (read-file file) out))
                files))))

(define (append-files files dest)
  (call-with-output-file dest
    (lambda (out)
      (for-each (lambda (file) (display (read-file file) out))
                files))))

