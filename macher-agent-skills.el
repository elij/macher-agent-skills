;;; macher-agent-skills.el --- Agent Skills parsing and resolution -*- lexical-binding: t -*-

;; Author: Elijah Charles
;; Version: 0.4.6
;; Package-Requires: ((emacs "29.1") (gptel "0.9.0") (macher "0.5.0"))
;; Keywords: convenience, gptel, llm, macher
;; URL: https://github.com/elij/macher-agent
;; SPDX-License-Identifier: GPL-3.0-or-later

(require 'macher-agent-api)

(defvar macher-agent-skills-directory
  (file-name-directory (or load-file-name buffer-file-name)))

(add-to-list 'macher-agent-skill-directories macher-agent-skills-directory)

(macher-agent-initialize-skills)

(provide 'macher-agent-skills)
