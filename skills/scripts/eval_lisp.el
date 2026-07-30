(macher-agent-make-tool
    macher-agent-eval-lisp-tool
    "Evaluate an Emacs Lisp code expression to perform mathematics operations, \
string manipulation, or data generation."
  :category "execution"
  :args
  '((:name "script"
           :type string
           :description "The Emacs Lisp code to evaluate."))
  :command-fn
  (lambda (payload _context _root)
    (if-let* ((script (plist-get payload :script)))
        (make-macher-agent-ptc-response
         :payload script
         :primitives
         '(
           nreverse sort delete delq nconc plist-put aset puthash remhash
           error signal message random emacs-version))
      (error "No script provided for Emacs Lisp evaluation"))))
