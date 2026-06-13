(macher-agent-make-tool macher-agent-eval-elisp-tool
    "Evaluate Emacs Lisp code to perform math, string manipulation, or data generation."
  :category "compute"
  :args '((:name "code" :type string :description "The Emacs Lisp code to evaluate. The final form will be returned to you."))
  :command-fn (lambda (payload)
                (let* ((code (plist-get payload :code))
                       (temp-file (make-temp-file "macher-eval-"))
                       (wrapped-code (format ";; -*- lexical-binding: t -*-\n(princ (condition-case err (progn %s) (error (error-message-string err))))" code))
                       (result nil))
                  
                  (with-temp-file temp-file
                    (insert wrapped-code))
                  
                  (unwind-protect
                      (with-temp-buffer
                        (call-process (expand-file-name invocation-name invocation-directory)
                                      nil t nil "-Q" "--batch" "-l" temp-file)
                        (setq result (string-trim (buffer-string))))
                    (delete-file temp-file))
                  
                  (make-macher-agent-lisp-result-response
                   :payload (format "EVALUATION RESULT:\n%s" result)))))
