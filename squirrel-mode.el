;;; squirrel-mode.el --- mode for editing Squirrel code

;; Author: Hideaki Takei
;; Created: Dec 2008
;; Keywords: languages

;;; Commentary:

;; Provides fairly minimal font-lock and indentation support for
;; editing Squirrel code.


;;; Code:


;;;###autoload
(add-to-list 'auto-mode-alist '("\\.nut\\'" . squirrel-mode))

(defvar squirrel-mode-hook nil)

(defvar squirrel-mode-map
  (let ((squirrel-mode-map (make-sparse-keymap)))
    (define-key squirrel-mode-map "{" 'squirrel-electric-brace)
    (define-key squirrel-mode-map "}" 'squirrel-electric-brace)
    (define-key squirrel-mode-map ":" 'squirrel-electric-colon)
    (define-key squirrel-mode-map "\C-c\C-o" 'squirrel-insert-block)
    squirrel-mode-map)
  "Keymap for Squirrel major mode")

(defvar squirrel-indent-level 4
  "Number of columns for a unit of indentation in Squirrel mode.")

(defconst squirrel-font-lock-keywords
  (list
   '("\\<\\(base\\|break\\|case\\|catch\\|clone\\|continue\\|const\\|default\\|delete\\|else\\|enum\\|extends\\|for\\|foreach\\|function\\|if\\|in\\|local\\|null\\|resume\\|return\\|switch\\|this\\|throw\\|try\\|typeof\\|while\\|yield\\|constructor\\|instanceof\\|true\\|false\\|static\\)\\>" . font-lock-builtin-face)
   '("\\<\\(class\\)\\s-+\\(\\w+\\)\\>" (1 font-lock-keyword-face) (2 font-lock-type-face))
   '("\\<\\(function\\)\\s-+\\(\\w+\\)\\>" (1 font-lock-keyword-face) (2 font-lock-function-name-face))
   ))

(defvar squirrel-mode-syntax-table
  (let ((squirrel-mode-syntax-table (make-syntax-table)))
    (modify-syntax-entry ?_ "w" squirrel-mode-syntax-table)
    (modify-syntax-entry ?/ ". 124b" squirrel-mode-syntax-table)
    (modify-syntax-entry ?* ". 23" squirrel-mode-syntax-table)
    (modify-syntax-entry ?\n "> b" squirrel-mode-syntax-table)
    squirrel-mode-syntax-table)
  "Syntax table for squirrel-mode")



(defun squirrel-electric-brace (arg)
  (interactive "P")
  (insert-char last-command-char 1)
  (squirrel-indent-line)
  (if (looking-back "^\\s *")
      (forward-char)
    (delete-char -1)
    (self-insert-command (prefix-numeric-value arg))))

(defun squirrel-electric-colon (arg)
  (interactive "P")
  (insert-char ?: 1)
  (squirrel-indent-line))


(defun squirrel-insert-block ()
  (interactive)
  (insert-char ?{ 1)
  (squirrel-indent-line)
  (newline)
  (newline)
  (insert-char ?} 1)
  (squirrel-indent-line)
  (forward-line -1)
  (squirrel-indent-line))


(defun squirrel-indent-line ()
  "Indent current line as squirrel code"
  (interactive)
  (let ((pos0 (point)) (pos1 (point)))
    (save-excursion
      (beginning-of-line)
      (let ((state (syntax-ppss)) level (indent-old 0) indent-new prev-level)
    (if (nth 8 state)
        () ;; Inside string or comment: do nothing
      (setq prev-level (squirrel-continuation-indent-level))
      (if prev-level
          (indent-line-to (+ prev-level squirrel-indent-level)) ;; continuation line
        (setq level (nth 0 state)) ;; get nest level
        (if (looking-at "\\s-*\\(}\\|\\]\\|)\\)")
        (setq level (1- level))
          (if (looking-at "\\s-*\\(case\\|default\\)")
          (setq level (1- level))))
        (indent-line-to (* squirrel-indent-level (max 0 level))))
      (setq pos1 (point)))))
    (if (> pos1 pos0)
    (goto-char pos1))))


(defun squirrel-continuation-indent-level ()
  (save-excursion
    (while (forward-comment -1))
    (if (looking-back ")")
    (condition-case nil
        (progn
          (goto-char (scan-sexps (point) -1))
          (if (looking-at "(")
          (progn
            (while (forward-comment -1))
            (if (looking-back "\\<\\(if\\|catch\\|while\\|for\\|foreach\\)")
            (current-indentation)))))
      (error nil))
      (if (looking-back "\\<\\(else\\|try\\|in\\|instanceof\\|typeof\\)")
      (current-indentation)
    (if (looking-back "\\(\\+\\+\\|--\\)")
        ()
      (if (looking-back "[-+=~!/*%<>^|&?]")
          (current-indentation)))))))



;;;###autoload
(defun squirrel-mode ()
  "Major mode for editing Squirrel script"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table squirrel-mode-syntax-table)
  (use-local-map squirrel-mode-map)
  (set (make-local-variable 'font-lock-defaults) '(squirrel-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'squirrel-indent-line)
  (set (make-local-variable 'comment-start) "// ")
  (set (make-local-variable 'comment-end) "")
  (set (make-local-variable 'parse-sexp-ignore-comments) t)

  (setq major-mode 'squirrel-mode)
  (setq mode-name "Squirrel")
  (run-hooks 'squirrel-mode-hook))

(provide 'squirrel-mode)
