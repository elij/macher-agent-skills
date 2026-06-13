(macher-agent-make-tool macher-agent-replace-own-buffer-tool
                        "Directly overwrite your own conversation buffer with new content. Use this to commit the results of a context compaction."
                        :category "meta"
                        :args '((:name "content"
                                       :type string
                                       :description "The complete text to replace your current buffer with. Ensure you include any pending instructions at the bottom."))
                        :command-fn
                        (lambda (payload)
                          (let ((content (plist-get payload :content))
                                (parent-buf (current-buffer)))
                            
                            (with-current-buffer parent-buf
                              (let ((inhibit-read-only t))
                                (erase-buffer)
                                (insert content)
                                (goto-char (point-max))))
                            
                            (make-macher-agent-lisp-result-response
                             :payload "SYSTEM: Your buffer has been overwritten successfully."))))
