(macher-agent-make-tool
 macher-agent-replace-own-buffer-tool
 "Directly overwrite your own conversation buffer with new content. Use this to commit the results of a context \
compaction."
 :category "execution"
 :args
 '((
    :name "content"
    :type string
    :description "The complete text to replace your current buffer with. Ensure you include any pending \
instructions at the bottom."))

 :command-fn
 (lambda (payload _context _root)
   (let* ((content (plist-get payload :content))
          (target-buf (current-buffer))
          (hook-sym (make-symbol "macher-agent--one-shot-replace")))

     (fset hook-sym
           (lambda (_beg _end)
             (when (buffer-live-p target-buf)
               (with-current-buffer target-buf
                 (let ((inhibit-read-only t))
                   (erase-buffer)
                   (insert content)
                   (insert "\n\n" (gptel-prompt-prefix-string))
                   (goto-char (point-max)))
                 (remove-hook 'gptel-post-response-functions hook-sym t)))))

     (add-hook 'gptel-post-response-functions hook-sym t t)

     (buffer-name target-buf)))

 :success-fn
 (lambda (raw-buf-name _payload)
   (format "SYSTEM: Operation acknowledged for buffer '%s'. Your buffer will be overwritten immediately upon \
turn completion."
           raw-buf-name)))
