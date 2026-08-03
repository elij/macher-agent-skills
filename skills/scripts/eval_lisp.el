(macher-agent-make-tool macher-agent-eval-lisp-tool
    "Evaluate a simple Emacs Lisp expression."
  :category "execution"
  :args (list (list :name "expression" :type 'string :description "The Emacs Lisp expression to evaluate"))
  :command-fn
  (lambda (payload _context _root)
    (let* ((expr-string (plist-get payload :expression))
           (expr (car (read-from-string expr-string)))
           (eval-result (eval expr t)))
      (format "%S" eval-result)))
  :success-fn
  (lambda (output)
    (concat "Result: " output)))
