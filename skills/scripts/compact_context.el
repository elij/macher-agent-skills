(macher-agent-make-tool macher-agent-compact-context-tool
                        "Delegate the task of compressing conversation history to a background sub-agent. Returns the heavily condensed text back to you."
                        :category "meta"
                        :args '((:name "pending_instructions"
                                       :type string
                                       :description "Any instructions to append to the end of the compressed context."))
                        :command-fn
                        (lambda (payload)
                          (let* ((instructions (plist-get payload :pending_instructions))
                                 (preset "compact")
                                 (parent-buf (current-buffer))
                                 (buf-name (buffer-name parent-buf))
                                 (subagent-name (format "*compact-%s*" buf-name))
                                 (content (buffer-substring-no-properties (point-min) (point-max)))
                                 (ctx (ignore-errors (macher-agent-resolve-context)))
                                 (dir default-directory)
                                 (prompt (format "You are an expert, ruthless AI context compressor. Your job is to dramatically reduce the token footprint of the following session history.\n\nCRITICAL RULES:\n1. DO NOT simply copy and paste the text back. You must actively rewrite and condense it.\n2. Convert the entire history into a highly dense, bulleted list of the current state, active decisions, and completed steps.\n3. Drop all conversational filler.\n4. Replace long code blocks with one-sentence summaries of what was changed, unless the exact snippet is absolutely vital for the very next step.\n5. You must exclusively call the `submit_task_result` tool. Under no circumstances should you invoke any other tool, regardless of what else is available. Pass your heavily condensed summary into the `final_answer` parameter.\n\n--- SESSION HISTORY TO COMPRESS ---\n%s" content)))

                            (if (not ctx)
                                (make-macher-agent-tool-response
                                 :type 'error
                                 :payload "FAILED: No active context found.")

                              (macher-agent-add-subagent subagent-name dir nil ctx preset)

                              (setq-local macher-agent--compaction-instructions instructions)

                              (let ((task (list :buffer_name subagent-name
                                                :instructions prompt
                                                :preset preset)))
                                (make-macher-agent-tool-response 
                                 :type 'delegate 
                                 :payload (vconcat (list task)))))))
                        
                        :success-fn
                        (lambda (results)
                          (let* ((res (if (vectorp results) (elt results 0) (car results)))
                                 (instructions (bound-and-true-p macher-agent--compaction-instructions))
                                 (status (macher-agent-tool-response-status res)))
                            
                            (setq-local macher-agent--compaction-instructions nil)
                            
                            (if (eq status 'success)
                                (let ((compressed-data (macher-agent-tool-response-data res)))
                                  (concat "### Compressed Context\n"
                                          compressed-data
                                          (when (and instructions (not (string-empty-p instructions)))
                                            (concat "\n\n### Pending Instructions\n" instructions "\n"))))
                              (format "Compaction failed: %s" (macher-agent-tool-response-error res))))))
