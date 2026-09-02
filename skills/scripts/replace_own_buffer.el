;;; replace_own_buffer.el --- Replace current buffer content tool -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'subr-x)
(require 'macher-agent-tools)
(require 'macher-agent-core)

(setq macher-agent-replace-own-buffer-tool
      (gptel-make-tool
       :name "replace_own_buffer"
       :description "Replace the contents of the agent's current buffer."
       :category "execution"
       :include nil
       :args '((:name "content"
                      :type "string"
                      :description "The new content to insert into the buffer"))
       :async t
       :function (macher-agent-with-presentation-context (content)
                   (let* ((native-fn (get 'macher-agent-replace-own-buffer-tool 'ptc-function))
                          (root (or (and context (macher-agent-context-project-root context))
                                    default-directory)))
                     (funcall native-fn content context root)))))

(put 'macher-agent-replace-own-buffer-tool 'ptc-function
     (lambda (content _context _root)
       (let* ((target-buf (current-buffer))
              (new-content (or content ""))
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

         (format "SUCCESS: Buffer '%s' scheduled for replacement upon turn completion."
                 (buffer-name target-buf)))))
