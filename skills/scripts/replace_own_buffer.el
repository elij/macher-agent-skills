(macher-agent-make-tool macher-agent-replace-own-buffer-tool
    "Replace the contents of the agent's current buffer."
  :category "execution"
  :args (list (list :name "content" :type 'string :description "The new content to insert into the buffer"))
  :command-fn
  (lambda (payload _context _root)
    (let* ((new-content (plist-get payload :content))
           (target-buf (current-buffer))
           (hook-sym (make-symbol "macher-agent--one-shot-replace")))

      (fset hook-sym
            (lambda (_beg _end)
              (when (buffer-live-p target-buf)
                (with-current-buffer target-buf
                  (let ((inhibit-read-only t))
                    (erase-buffer)
                    (insert new-content)
                    (when (fboundp 'gptel-prompt-prefix-string)
                      (insert "\n\n" (gptel-prompt-prefix-string)))
                    (goto-char (point-max)))
                  (remove-hook 'gptel-post-response-functions hook-sym t)))))

      (add-hook 'gptel-post-response-functions hook-sym t t)

      (format "SUCCESS: Buffer '%s' scheduled for replacement upon turn completion." (buffer-name target-buf))))
  
  :success-fn
  (lambda (output) output))
