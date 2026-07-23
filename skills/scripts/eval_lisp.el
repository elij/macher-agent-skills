(macher-agent-make-tool macher-agent-eval-elisp-tool
                        "Evaluate Emacs Lisp code to perform maths operations, string manipulation, or data generation."
                        :category "compute"
                        :args '((:name "code" :type string :description "The Emacs Lisp code to evaluate. The final form will be returned to you."))
                        :command-fn (lambda (payload _context _root)
                                      (let* ((code (plist-get payload :code))
                                             (expression (condition-case nil
                                                             (car (read-from-string (format "(progn %s)" code)))
                                                           (error nil)))
                                             (result (if expression
                                                         (condition-case err
                                                             (let ((res (macher-agent-sandbox-run expression '(cons list string-to-list substring emacs-version
                                                                                                                    expt string-upcase string= string< random format
                                                                                                                    string-match string-to-number number-to-string
                                                                                                                    int-to-string make-vector vector make-list append
                                                                                                                    not identity reverse nreverse sort delete delq nconc
                                                                                                                    assoc assq rassoc rassq copy-sequence split-string
                                                                                                                    replace-regexp-in-string upcase downcase capitalize
                                                                                                                    plist-get plist-put plist-member error signal
                                                                                                                    make-symbol intern intern-soft match-string
                                                                                                                    match-beginning match-end make-string string
                                                                                                                    char-to-string aset make-hash-table puthash gethash
                                                                                                                    remhash sin cos tan asin acos atan cl-reduce
                                                                                                                    cl-position car-safe cdr-safe atom evenp oddp
                                                                                                                    message))))
                                                               (format "%S" res))
                                                           (error (error-message-string err)))
                                                       "ERROR: Failed to parse code.")))
                                        (make-macher-agent-lisp-result-response
                                         :payload (format "EVALUATION RESULT:\n%s" result)))))
