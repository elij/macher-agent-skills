(macher-agent-make-tool macher-agent-replace-own-buffer-tool
    "Replace the contents of the agent's current buffer."
  :category "editing"
  :args '(("content" . "string"))
  :command-fn
  (lambda (payload _context _root)
    (let ((new-content (plist-get payload :content)))
      (erase-buffer)
      (insert new-content)
      (format "SUCCESS: Buffer '%s' replaced." (buffer-name))))
  :success-fn
  (lambda (output) output))
