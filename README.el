(require 'use-package-ensure) ;; Load use-package-always-ensure
(setq use-package-always-ensure t) ;; Always ensures that a package is installed
(setq package-archives '(("melpa" . "https://melpa.org/packages/") ;; Sets default package repositories
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/"))) ;; For Eat Terminal
(package-initialize)

(defun dysthesis/nixos-p ()
  "Return t if operating system is NixOS, nil otherwise."
  (string-match-p "NixOS" (shell-command-to-string "uname -v")))

(defun dysthesis/nixos/get-emacs-build-date ()
  "Return NixOS Emacs build date."
  (string-match "--prefix.*emacs.*\\([[:digit:]]\\{8\\}\\)" system-configuration-options)
  (string-to-number (match-string 1 system-configuration-options)))

;; Run this before the elpaca.el is loaded. Before the installer in your init.el is a good spot.
(when (dysthesis/nixos-p) (setq elpaca-core-date (list (dysthesis/nixos/get-emacs-build-date))))

(use-package general
  :ensure t
  :after (evil)
  :demand t
  :config
  (general-evil-setup)
  ;; Set up 'SPC' as the leader key
  (general-create-definer start/leader-keys
    :states '(normal insert visual motion emacs)
    :keymaps 'override
    :prefix "SPC"           ;; Set leader key
    :global-prefix "C-SPC") ;; Set global leader key

  (start/leader-keys
    "." '(find-file :wk "Find file")
    "TAB" '(comment-line :wk "Comment lines")
    "p" '(:keymap projectile-command-map
                  :package projectile
                  :wk "Projectile command map"))

  (start/leader-keys
    "f" '(:ignore t :wk "Find")
    "f c" '((lambda () (interactive) (find-file "~/.config/emacs/README.org")) :wk "Edit emacs config")
    "f r" '(consult-recent-file :wk "Recent files")
    "f f" '(consult-fd :wk "Fd search for files")
    "f g" '(consult-ripgrep :wk "Ripgrep search in files")
    "f l" '(consult-line :wk "Find line")
    "f i" '(consult-imenu :wk "Imenu buffer locations"))

  (start/leader-keys
    "b" '(:ignore t :wk "Buffer Bookmarks")
    "b b" '(consult-buffer :wk "Switch buffer")
    "b k" '(kill-this-buffer :wk "Kill this buffer")
    "b i" '(ibuffer :wk "Ibuffer")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer")
    "b j" '(consult-bookmark :wk "Bookmark jump"))

  (start/leader-keys
    "d" '(:ignore t :wk "Dired")
    "d v" '(dired :wk "Open dired")
    "d j" '(dired-jump :wk "Dired jump to current"))

  (start/leader-keys
    "e" '(:ignore t :wk "Eglot Evaluate")
    "e e" '(eglot-reconnect :wk "Eglot Reconnect")
    "e f" '(eglot-format :wk "Eglot Format")
    "e l" '(consult-flymake :wk "Consult Flymake")
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e r" '(eval-region :wk "Evaluate elisp in region"))

  (start/leader-keys
    "g" '(:ignore t :wk "Git")
    "g g" '(magit-status :wk "Magit status"))

  (start/leader-keys
    "h" '(:ignore t :wk "Help") ;; To get more help use C-h commands (describe variable, function, etc.)
    "h q" '(save-buffers-kill-emacs :wk "Quit Emacs and Daemon")
    "h r" '((lambda () (interactive)
              (load-file "~/.config/emacs/init.el"))
            :wk "Reload Emacs config"))

  (start/leader-keys
    "s" '(:ignore t :wk "Show")
    "s e" '(eat :wk "Eat terminal"))

  (start/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t t" '(visual-line-mode :wk "Toggle truncated lines (wrap)")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")))

(use-package evil 
  :ensure t
  :init
  (setq evil-respect-visual-line-mode t) ;; respect visual lines

  (setq evil-search-module 'isearch) ;; use emacs' built-in search functionality.

  (setq evil-want-C-u-scroll t) ;; allow scroll up with 'C-u'
  (setq evil-want-C-d-scroll t) ;; allow scroll down with 'C-d'

  (setq evil-want-integration t) ;; necessary for evil collection
  (setq evil-want-keybinding nil)

  (setq evil-split-window-below t) ;; split windows created below
  (setq evil-vsplit-window-right t) ;; vertically split windows created to the right

  (setq evil-want-C-i-jump nil) ;; hopefully this will fix weird tab behaviour

  (setq evil-undo-system 'undo-redo) ;; undo via 'u', and redo the undone change via 'C-r'; only available in emacs 28+.
  :config
  (evil-mode 1))

(global-unset-key (kbd "C-j"))
(global-set-key (kbd "C-h") #'evil-window-left)
(global-set-key (kbd "C-j") #'evil-window-down)
(global-set-key (kbd "C-k") #'evil-window-up)
(global-set-key (kbd "C-l") #'evil-window-right)

(use-package evil-collection ;; evilifies a bunch of things
  :ensure t
  :after evil
  :init
  (setq evil-collection-outline-bind-tab-p t) ;; '<TAB>' cycles visibility in 'outline-minor-mode'
  ;; If I want to incrementally enable evil-collection mode-by-mode, I can do something like the following:
  ;; (setq evil-collection-mode-list nil) ;; I don't like surprises
  ;; (add-to-list 'evil-collection-mode-list 'magit) ;; evilify magit
  ;; (add-to-list 'evil-collection-mode-list '(pdf pdf-view)) ;; evilify pdf-view
  :config
  (evil-collection-init))

(use-package evil-commentary
  :ensure t
  :after evil
  :config
  (evil-commentary-mode)) ;; globally enable evil-commentary

(use-package evil-surround
  :ensure t
  :after evil
  :config
  (global-evil-surround-mode 1)) ;; globally enable evil-surround

(use-package evil-goggles
  :ensure t
  :after evil
  :config
  (evil-goggles-mode)

  ;; optionally use diff-mode's faces; as a result, deleted text
  ;; will be highlighed with `diff-removed` face which is typically
  ;; some red color (as defined by the color theme)
  ;; other faces such as `diff-added` will be used for other actions
  (evil-goggles-use-diff-faces))

(use-package avy
  :ensure t
  :init
  (defun dysthesis/avy-action-insert-newline (pt)
    (save-excursion
      (goto-char pt)
      (newline))
    (select-window
     (cdr
      (ring-ref avy-ring 0))))
  (defun dysthesis/avy-action-kill-whole-line (pt)
    (save-excursion
      (goto-char pt)
      (kill-whole-line))
    (select-window
     (cdr
      (ring-ref avy-ring 0))))
  (defun dysthesis/avy-action-embark (pt)
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t) ;; adds an avy action for embark
  :general
  (general-def '(normal motion)
    "s" 'evil-avy-goto-char-timer
    "f" 'evil-avy-goto-char-in-line
    "gl" 'evil-avy-goto-line ;; this rules
    ";" 'avy-resume)
  :config
  (setf (alist-get ?. avy-dispatch-alist) 'dysthesis/avy-action-embark ;; embark integration
        (alist-get ?i avy-dispatch-alist) 'dysthesis/avy-action-insert-newline
        (alist-get ?K avy-dispatch-alist) 'dysthesis/avy-action-kill-whole-line)) ;; kill lines with avy

(use-package emacs
  :demand t
  :ensure nil
  :init
  (setq-default fill-column 80)
  (setq pixel-scroll-precision-large-scroll-height 40.0)
  (setq pixel-scroll-precision-mode 1)
  (setq enable-recursive-minibuffers t)
  (setq backup-by-copying t)
  (setq sentence-end-double-space nil)
  (setq frame-inhibit-implied-resize t) ;; useless for a tiling window manager
  (setq show-trailing-whitespace t) ;; self-explanatory
  (defalias 'yes-or-no-p 'y-or-n-p) ;; life is too short 
  (setq indent-tabs-mode nil) ;; no tabs
  ;; keep backup and save files in a dedicated directory
  (setq backup-directory-alist
        `((".*" . ,(concat user-emacs-directory "backups")))
        auto-save-file-name-transforms
        `((".*" ,(concat user-emacs-directory "backups") t)))
  (setq create-lockfiles nil) ;; no need to create lockfiles
  (set-charset-priority 'unicode) ;; utf8 everywhere
  (setq locale-coding-system 'utf-8
        coding-system-for-read 'utf-8
        coding-system-for-write 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-selection-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)
  (setq default-process-coding-system '(utf-8-unix . utf-8-unix))
  (global-set-key (kbd "<escape>") 'keyboard-escape-quit) ;; escape quits everything
  ;; Don't persist a custom file
  (setq custom-file (make-temp-file "")) ; use a temp file as a placeholder
  (setq custom-safe-themes t)            ; mark all themes as safe, since we can't persist now
  (setq enable-local-variables :all)     ; fix =defvar= warnings
  (setq delete-by-moving-to-trash t) ;; use trash-cli rather than rm when deleting files.
  ;; less noise when compiling elisp
  (setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))
  (setq native-comp-async-report-warnings-errors nil)
  (setq load-prefer-newer t)
  (show-paren-mode t)

  ;; Hide commands in M-x which don't work in the current mode
  (setq read-extended-command-predicate #'command-completion-default-include-p))

(set-face-attribute 'default nil :font "JBMono Nerd Font" :height 130)
(set-fontset-font t nil (font-spec :size 20 :name "JBMono Nerd Font"))
(setq-default line-spacing 0.2)
(custom-theme-set-faces
 'user
 '(variable-pitch ((t (:family "SF Pro Display" :height 130))))
 '(fixed-pitch ((t ( :family "JBMono Nerd Font" :height 130)))))

(add-to-list 'face-font-rescale-alist '("SF Pro Display" . 1.2))

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar
(column-number-mode)
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
(global-visual-line-mode t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package poet-theme
  :ensure t
  :demand t
  :config
  (load-theme 'poet-dark-monochrome t))

(use-package solaire-mode
  :ensure t
  :config
  (solaire-global-mode +1))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 40)
  (doom-modeline-bar-width 4)
  (doom-modeline-persp-name t)
  (doom-modeline-persp-icon t))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :ensure t
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(use-package olivetti
  :ensure t
  :config
  (defun dysthesis/org-mode-setup ()
    (org-indent-mode)
    (olivetti-mode)
    (display-line-numbers-mode 0)
    (olivetti-set-width 90))
  (add-hook 'org-mode-hook 'dysthesis/org-mode-setup))

(use-package mixed-pitch
  :ensure t
  :hook
  ;; You might want to enable it only in org-mode or both text-mode and org-mode
  ((org-mode) . mixed-pitch-mode)
  ((markdown-mode) . mixed-pitch-mode)
  :config
  (setq mixed-pitch-face 'variable-pitch)
  (setq mixed-pitch-fixed-pitch-faces
        (append mixed-pitch-fixed-pitch-faces
                '(org-table
                  org-code
                  org-property-value
                  org-block
                  org-block-begin-line
                  org-block-end-line
                  org-meta-line
                  org-document-info-keyword
                  org-tag
                  org-time-grid
                  org-todo
                  org-done
                  org-agenda-date
                  org-date
                  org-drawer
                  org-modern-tag
                  org-modern-done
                  org-modern-label
                  org-scheduled
                  org-scheduled-today
                  neo-file-link-face
                  org-scheduled-previously))))

(use-package ligature
  :ensure t
  :config
  ;; Enable the "www" ligature in every possible major mode
  (ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pitch' face supports it
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                       "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                       "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                       "\\\\" "://"))
  ;; Enables ligature checks globally in all buffers.  You can also do it
  ;; per mode with `ligature-mode'.
  (global-ligature-mode t))

(use-package hl-todo
  :ensure t
  :hook (prog-mode . hl-todo-mode)
  :custom (hl-todo-keyword-faces '(("TODO" warning bold)
                                   ("FIXME" error bold)
                                   ("HACK" font-lock-constant-face)
                                   ("NOTE" success bold)
                                   ("REVIEW" font-lock-keyword-face bold)
                                   ("DEPRECATED" font-lock-doc-face bold))))

(use-package rainbow-mode
  :ensure t
  :hook org-mode prog-mode)

(use-package indent-bars
  :ensure t
  :custom
  (indent-bars-color '(highlight :face-bg t :blend 0.225))
  (indent-bars-no-descend-string t)
  (indent-bars-treesit-support t)
  (indent-bars-treesit-wrap '((rust arguments parameters)))
  (indent-bars-treesit-scope '((;; rust
                                rust trait_item impl_item 
                                macro_definition macro_invocation 
                                struct_item enum_item mod_item 
                                const_item let_declaration 
                                function_item for_expression 
                                if_expression loop_expression 
                                while_expression match_expression 
                                match_arm call_expression 
                                token_tree token_tree_pattern 
                                token_repetition
                                ;; C/C++
                                c argument_list parameter_list
                                init_declarator parenthesized_expression)))
  (indent-bars-treesit-ignore-blank-lines-types '("module"))
  (indent-bars-prefer-character t)
  (indent-bars-treesit-scope '((python function_definition class_definition for_statement
                                       if_statement with_statement while_statement)))
  :hook ((prog-mode yaml-mode) . indent-bars-mode)
  :config (require 'indent-bars-ts))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(savehist-mode) ;; Enables save history mode

(use-package vertico-posframe
  :ensure t
  :after vertico
  :config (vertico-posframe-mode 1))

(use-package marginalia
  :ensure t
  :after vertico
  :init
  (marginalia-mode))

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  :hook
  ('marginalia-mode-hook . 'nerd-icons-completion-marginalia-setup))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (orderless-matching-styles
   '(orderless-literal
     orderless-prefixes
     orderless-initialism
     orderless-regexp
     orderless-flex                       ; Basically fuzzy finding
     ;; orderless-strict-leading-initialism
     ;; orderless-strict-initialism
     ;; orderless-strict-full-initialism
     ;; orderless-without-literal          ; Recommended for dispatches instead
     ))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package corfu
  ;; Optional customizations
  :ensure t
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-auto-prefix 2)          ;; Minimum length of prefix for auto completion.
  (corfu-popupinfo-mode t)       ;; Enable popup information
  (corfu-popupinfo-delay 0.2)    ;; Lower popupinfo delay to 0.5 seconds from 2 seconds
  (corfu-separator ?\s)          ;; Orderless field separator, Use M-SPC to enter separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin
  (completion-ignore-case t)
  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)
  (corfu-preview-current nil) ;; Don't insert completion without confirmation
  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :init (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package cape
  :ensure t
  :after corfu
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  ;; The functions that are added later will be the first in the list

  ;;(add-to-list 'completion-at-point-functions #'cape-dabbrev) ;; Complete word from current buffers
  ;;(add-to-list 'completion-at-point-functions #'cape-dict) ;; Dictionary completion
  (add-to-list 'completion-at-point-functions #'cape-file) ;; Path completion
  (add-to-list 'completion-at-point-functions #'cape-elisp-block) ;; Complete elisp in Org or Markdown mode
  (add-to-list 'completion-at-point-functions #'cape-keyword) ;; Keyword/Snipet completion

  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev) ;; Complete abbreviation
  ;;(add-to-list 'completion-at-point-functions #'cape-history) ;; Complete from Eshell, Comint or minibuffer history
  ;;(add-to-list 'completion-at-point-functions #'cape-line) ;; Complete entire line from current buffer
  ;;(add-to-list 'completion-at-point-functions #'cape-elisp-symbol) ;; Complete Elisp symbol
  ;;(add-to-list 'completion-at-point-functions #'cape-tex) ;; Complete Unicode char from TeX command, e.g. \hbar
  ;;(add-to-list 'completion-at-point-functions #'cape-sgml) ;; Complete Unicode char from SGML entity, e.g., &alpha
  ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345) ;; Complete Unicode char using RFC 1345 mnemonics
  )

;; Configure Tempel
(use-package tempel
  :ensure t
  ;; Require trigger prefix before template name when completing.
  ;; :custom
  ;; (tempel-trigger-prefix "<")

  :bind (("M-+" . tempel-complete) ;; Alternative tempel-expand
         ("M-*" . tempel-insert)
	 (:map tempel-map
	       ([backtab] . tempel-previous)
	       ([tab] . tempel-next)))
  :init

  ;; Setup completion at point
  (defun tempel-setup-capf ()
    ;; Add the Tempel Capf to `completion-at-point-functions'.
    ;; `tempel-expand' only triggers on exact matches. Alternatively use
    ;; `tempel-complete' if you want to see all matches, but then you
    ;; should also configure `tempel-trigger-prefix', such that Tempel
    ;; does not trigger too often when you don't expect it. NOTE: We add
    ;; `tempel-expand' *before* the main programming mode Capf, such
    ;; that it will be tried first.
    (setq-local completion-at-point-functions
                (cons #'tempel-expand
                      completion-at-point-functions)))

  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf)

  ;; Optionally make the Tempel templates available to Abbrev,
  ;; either locally or globally. `expand-abbrev' is bound to C-x '.
  ;; (add-hook 'prog-mode-hook #'tempel-abbrev-mode)
  ;; (global-tempel-abbrev-mode)
  )

;; Optional: Add tempel-collection.
;; The package is young and doesn't have comprehensive coverage.
(use-package tempel-collection
  :ensure t
  :after tempel)

(use-package consult
  :ensure t
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))

  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  ;; (consult-customize
  ;; consult-theme :preview-key '(:debounce 0.2 any)
  ;; consult-ripgrep consult-git-grep consult-grep
  ;; consult-bookmark consult-recent-file consult-xref
  ;; consult--source-bookmark consult--source-file-register
  ;; consult--source-recent-file consult--source-project-recent-file
  ;; :preview-key "M-."
  ;; :preview-key '(:debounce 0.4 any))

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
   ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
   ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
   ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
   ;;;; 4. projectile.el (projectile-project-root)
  (autoload 'projectile-project-root "projectile")
  (setq consult-project-function (lambda (_) (projectile-project-root)))
   ;;;; 5. No project support
  ;; (setq consult-project-function nil)
  )

(use-package smartparens
  :ensure smartparens  ;; install the package
  :hook (prog-mode text-mode markdown-mode) ;; add `smartparens-mode` to these hooks
  :general
  ("M-h" 'sp-backward-slurp-sexp)
  ("M-l" 'sp-forward-slurp-sexp)
  ("M-H" 'sp-backward-barf-sexp)
  ("M-L" 'sp-forward-barf-sexp)
  ("M-r" '(sp-rewrap-sexp :wk "Change wrapping parentheses"))
  ("C-M-t" 'sp-transpose-sexp)
  :config
  ;; load default config
  (require 'smartparens-config))

(use-package eldoc-box
  :ensure t
  :after (eldoc eglot)
  :config (add-hook 'eglot-managed-mode-hook #'eldoc-box-hover-mode t))

(defvar +lsp--default-read-process-output-max nil)
(defvar +lsp--default-gcmh-high-cons-threshold nil)
(defvar +lsp--optimization-init-p nil)

(define-minor-mode +lsp-optimization-mode
  "Deploys universal GC and IPC optimizations for `lsp-mode' and `eglot'."
  :global t
  :init-value nil
  (if (not +lsp-optimization-mode)
      (setq-default read-process-output-max +lsp--default-read-process-output-max
                    gcmh-high-cons-threshold +lsp--default-gcmh-high-cons-threshold
                    +lsp--optimization-init-p nil)
    ;; Only apply these settings once!
    (unless +lsp--optimization-init-p
      (setq +lsp--default-read-process-output-max (default-value 'read-process-output-max)
            +lsp--default-gcmh-high-cons-threshold (default-value 'gcmh-high-cons-threshold))
      (setq-default read-process-output-max (* 1024 1024))
      ;; REVIEW LSP causes a lot of allocations, with or without the native JSON
      ;;        library, so we up the GC threshold to stave off GC-induced
      ;;        slowdowns/freezes. Doom uses `gcmh' to enforce its GC strategy,
      ;;        so we modify its variables rather than `gc-cons-threshold'
      ;;        directly.
      (setq-default gcmh-high-cons-threshold (* 2 +lsp--default-gcmh-high-cons-threshold))
      (gcmh-set-high-threshold)
      (setq +lsp--optimization-init-p t))))

(use-package eglot
  :defer t
  :ensure nil
  :hook
  (prog-mode . (lambda ()
                 (unless (derived-mode-p 'emacs-lisp-mode 'lisp-mode 'makefile-mode 'snippet-mode)
                   (eglot-ensure))))
  (eglot-managed-mode . +lsp-optimization-mode)
  :custom
  (eglot-sync-connect 1)
  (eglot-autoshutdown t)
  ;; NOTE: We disable eglot-auto-display-help-buffer because :select t in
  ;;   its popup rule causes eglot to steal focus too often.
  (eglot-auto-display-help-buffer nil)
  :general
  (start/leader-keys
   "c" '(:ignore t :which-key "Code")
   "c <escape>" '(keyboard-escape-quit :which-key t)
   "c r" '(eglot-rename :which-key "Rename")
   "c a" '(eglot-code-actions :which-key "Actions"))
  :config
  (with-eval-after-load 'eglot
    (dolist (mode '((nix-mode . ("nixd"))
                    ((rust-ts-mode rust-mode) . ("rust-analyzer"
                                                 :initializationOptions (:check (:command "clippy"))))))
      (add-to-list 'eglot-server-programs mode)))
  (add-hook 'prog-mode-hook
            (lambda ()
              (add-hook 'before-save-hook 'eglot-format nil t))))

(use-package consult-eglot
  :ensure t
  :after (eglot consult)
  :general
  (start/leader-keys
	     "c s" '(consult-eglot-symbols :wk "Code Symbols")))

(use-package flymake
  :ensure nil
  :after (consult eglot)
  :general
  (start/leader-keys
   :keymaps 'flymake-mode-map
   "el" '(consult-flymake :wk "List errors")) ;; depends on consult
  :hook
  (prog-mode . flymake-mode)
  (flymake-mode . (lambda () (or (ignore-errors flymake-show-project-diagnostics)
                                 (flymake-show-buffer-diagnostics))))
  :custom
  (flymake-no-changes-timeout nil)
  :general
  (general-nmap "en" 'flymake-goto-next-error)
  (general-nmap "ep" 'flymake-goto-prev-error))

(use-package aggressive-indent
  :ensure t
  :config
  (global-aggressive-indent-mode 1)
  (add-to-list 'aggressive-indent-excluded-modes 'html-mode))

(use-package tree-sitter
  :ensure t
  :hook
  (prog-mode . global-tree-sitter-mode))
(use-package tree-sitter-langs
  :ensure t)
(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package evil-textobj-tree-sitter
  :ensure t
  :after (evil tree-sitter)
  :config
  ;; bind `function.outer`(entire function block) to `f` for use in things like `vaf`, `yaf`
  (define-key evil-outer-text-objects-map "f" (evil-textobj-tree-sitter-get-textobj(  "function.outer" )))
  ;; bind `function.inner`(function block without name and args) to `f` for use in things like `vif`, `yif`
  (define-key evil-inner-text-objects-map "f" (evil-textobj-tree-sitter-get-textobj(  "function.inner" )))
  (define-key evil-inner-text-objects-map "i" (evil-textobj-tree-sitter-get-textobj(  "parameter.inner" )))
  (define-key evil-outer-text-objects-map "i" (evil-textobj-tree-sitter-get-textobj(  "parameter.outer" )))
  ;; You can also bind multiple items and we will match the first one we can find
  (define-key evil-outer-text-objects-map "a" (evil-textobj-tree-sitter-get-textobj ("conditional.outer" "loop.outer")))
  )

(use-package projectile
  :ensure t
  :diminish projectile-mode
  :config (projectile-mode)
  :init
  (when (file-directory-p "~/Documents/Projects")
    (setq projectile-project-search-path '("~/Documents/Projects")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package transient
  :ensure t)
(use-package magit
  :ensure t
  :after (transient)
  :general ("C-x g" 'magit))

(use-package diff-hl
  :ensure t
  :demand t
  :custom
  (vc-git-diff-switches '("--histogram"))
  (diff-hl-flydiff-delay 0.5)
  (diff-hl-update-async t)
  (diff-hl-show-staged-changes nil)
  (diff-hl-draw-borders nil)
  :hook (vc-dir-mode . turn-on-diff-hl-mode)
  :hook (diff-hl-mode . diff-hl-flydiff-mode)
  :hook (elpaca-after-init . global-diff-hl-mode)
  :config
  (if (fboundp 'fringe-mode) (fringe-mode '8))
  (setq-default fringes-outside-margins t)
;; from https://github.com/jidibinlin/.emacs.d/blob/d5332b2a7877126e83dc3dc0c94e1c66dd5446c0/lisp/init-vc.el#L56C2-L91C69
  (defun dysthesis/pretty-diff-hl-fringe (&rest _)
    (let* ((scale (if (and (boundp 'text-scale-mode-amount)
  						   (numberp text-scale-mode-amount))
  				      (expt text-scale-mode-step text-scale-mode-amount)
  				    1))
  		   (spacing (or (and (display-graphic-p) (default-value 'line-spacing)) 0))
  		   (h (+ (ceiling (* (frame-char-height) scale))
  					(if (floatp spacing)
  				     (truncate (* (frame-char-height) spacing))
  				   spacing)))
  		   (w (min (frame-parameter nil (intern (format "%s-fringe" diff-hl-side)))
  					  16))
  		   (_ (if (zerop w) (setq w 16))))

      (define-fringe-bitmap 'diff-hl-bmp-middle
  		(make-vector
  		 h (string-to-number (let ((half-w (1- (/ w 2))))
  						       (concat (make-string half-w ?1)
  									      (make-string (- w half-w) ?0)))
  							    2))
  		nil nil 'center)))
  
  (advice-add #'diff-hl-define-bitmaps
  			     :after #'dysthesis/pretty-diff-hl-fringe)
  
  (defun dysthesis/diff-hl-type-at-pos-fn (type _pos)
    'diff-hl-bmp-middle)
  
  (setq diff-hl-fringe-bmp-function #'dysthesis/diff-hl-type-at-pos-fn)
  (defun dysthesis/diff-hl-fringe-pretty(_)
    (set-face-attribute 'diff-hl-insert nil :background 'unspecified :inherit nil)
    (set-face-attribute 'diff-hl-delete nil :background 'unspecified :inherit nil)
    (set-face-attribute 'diff-hl-change nil :background 'unspecified :inherit nil))
  (add-to-list 'after-make-frame-functions
  			      #'dysthesis/diff-hl-fringe-pretty)
  (add-to-list 'enable-theme-functions #'dysthesis/diff-hl-fringe-pretty)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

(use-package git-timemachine
  :ensure t
  :hook (evil-normalize-keymaps . git-timemachine-hook))

(use-package rust-mode
  :ensure t
  :custom
  (rust-format-on-save t)
  (treesit-language-available-p 'rust)
  ;; (rust-mode-treesitter-derive t)
  :hook
  (rust-mode . eglot-ensure)
  (rust-mode . eldoc-mode)
  (rust-mode . (lambda () (setq indent-tabs-mode nil)))
  ;; prettify symbols
  (rust-mode . (lambda () (prettify-symbols-mode))))
  (use-package cargo
    :ensure t)

(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'"
  :hook (nix-mode . eglot-ensure))

(use-package haskell-mode :ensure t)

(use-package zig-mode
  :ensure t
  :after eglot
  :custom (zig-format-on-save 1)
  :hook
  (zig-mode . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs '(zig-mode . ("/usr/bin/zls"
 												   :initializationOptions (:zig_exe_path (executable-find "zig")))))
  (if (>= emacs-major-version 28)
      (add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)
    (progn
      (defun colorize-compilation-buffer ()
     	(let ((inhibit-read-only t))
   		 (ansi-color-apply-on-region compilation-filter-start (point))))
      (add-hook 'compilation-filter-hook 'colorize-compilation-buffer))))

(use-package citar
  :ensure t
  :demand t
  :custom
  (citar-bibliography '("~/Documents/Org/Library.bib"))
  :hook
  ((org-mode LaTeX-mode) . citar-capf-setup)
  :general
  ("C-c o" 'citar-open)
  ("C-c b" 'org-cite-insert))

(defun my-citar-org-open-notes (key entry)
  (let* ((bib (string-join (list my/bibtex-directory key ".bib")))
         (org (string-join (list my/bibtex-directory key ".org")))
         (new (not (file-exists-p org))))
    (funcall citar-file-open-function org)
    (when (and new (eq (buffer-size) 0))
      (insert (format template
                      (assoc-default "title" entry)
                      user-full-name
                      user-mail-address
                      bib
                      (with-temp-buffer
                        (insert-file-contents bib)
                        (buffer-string))))
      (search-backward "|")
      (delete-char 1))))

(setq-default citar-open-note-function 'my-citar-org-open-notes)

(use-package org
  :ensure nil
  :after citar
  :general
  ("C-c c" 'org-capture)
  ("S-RET" 'org-open-at-point)
  :custom
  (org-directory "~/Documents/Org/")
  (org-archive-location (concat org-directory "archive.org::* From =%s="))
  (org-preview-latex-default-process 'dvisvgm)
  (org-highlight-latex-and-related '(latex script entities))
  (org-cite-global-bibliography citar-bibliography)
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  :config
  
  (plist-put org-format-latex-options :foreground "White")
  (plist-put org-format-latex-options :background nil)
  (plist-put org-format-latex-options :scale 0.65))
  (require 'org-indent)

(defun dysthesis/agenda ()
  (interactive)
  (org-agenda nil "o"))

(use-package org-agenda
  :ensure nil
  :after org evil
  :general ("C-c a" 'dysthesis/agenda)
  :custom
  (org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "PROG(p)" "|" "DONE(d)" "|" "CANCEL(c)")))
  (org-agenda-sorting-strategy
   '((urgency-up deadline-up priority-down effort-up)))
  (org-agenda-start-day "0d")
  (org-agenda-skip-scheduled-if-done t)
  (org-agenda-skip-deadline-if-done t)
  (org-agenda-include-deadlines t)
  (org-agenda-block-separator nil)
  (org-agenda-files (directory-files-recursively (concat org-directory "GTD/") "\\.org$"))
  (setq org-refile-targets '(("~/Org/GTD/gtd.org" :maxlevel . 2)
                             ("~/Org/GTD/someday.org" :maxlevel . 2)
                             ("~/Org/GTD/tickler.org" :maxlevel . 2)
                             ("~/Org/GTD/routine.org" :maxlevel . 2)
                             ("~/Org/GTD/reading.org" :maxlevel . 2))))

(defun dysthesis/mark-inbox-todos ()
  "Mark entries in the agenda whose category is inbox for future bulk action."
  (let ((entries-marked 0)
        (regexp "inbox")  ; Set the search term to inbox
        category-at-point)
    (save-excursion
      (goto-char (point-min))
      (goto-char (next-single-property-change (point) 'org-hd-marker))
      (while (re-search-forward regexp nil t)
        (setq category-at-point (get-text-property (match-beginning 0) 'org-category))
        (if (or (get-char-property (point) 'invisible)
                (not category-at-point))  ; Skip if category is nil
            (beginning-of-line 2)
          (when (string-match-p regexp category-at-point)
            (setq entries-marked (1+ entries-marked))
            (call-interactively 'org-agenda-bulk-mark))))
      (unless entries-marked
        (message "No entry matching 'inbox'.")))))

(defun dysthesis/org-agenda-process-inbox-item ()
  "Process a single item in the org-agenda."
  (org-with-wide-buffer
   (org-agenda-set-tags)
   (org-agenda-priority)

   ;; Get the marker for the current headline
   (let* ((hdmarker (org-get-at-bol 'org-hd-marker))
          (category (completing-read "Category: " '("University" "Home" "Tinkering" "Read"))))
     ;; Switch to the buffer of the actual Org file
     (with-current-buffer (marker-buffer hdmarker)
       (goto-char (marker-position hdmarker))
       ;; Set the category property
       (org-set-property "CATEGORY" category))

   (call-interactively 'dysthesis/my-org-agenda-set-effort)
   (org-agenda-refile nil nil t))))

(defvar dysthesis/org-current-effort "1:00"
  "Current effort for agenda items.")
(defun dysthesis/my-org-agenda-set-effort (effort)
  "Set the effort property for the current headline."
  (interactive
   (list (read-string (format "EFFORT [%s]: " dysthesis/org-current-effort) nil nil dysthesis/org-current-effort)))
  (setq dysthesis/org-current-effort effort)
  (org-agenda-check-no-diary)
  (let* ((hdmarker (or (org-get-at-bol 'org-hd-marker)
                       (org-agenda-error)))
         (buffer (marker-buffer hdmarker))
         (pos (marker-position hdmarker))
         (inhibit-read-only t)
         newhead)
    (org-with-remote-undo buffer
      (with-current-buffer buffer
        (widen)
        (goto-char pos)
        (org-fold-show-context 'agenda)
        (funcall-interactively 'org-set-effort nil dysthesis/org-current-effort)
        (end-of-line 1)
        (setq newhead (org-get-heading)))
      (org-agenda-change-all-lines newhead hdmarker))))

(defun dysthesis/bulk-process-entries ()
  ;; (let ())
  (if (not (null org-agenda-bulk-marked-entries))
      (let ((entries (reverse org-agenda-bulk-marked-entries))
            (processed 0)
            (skipped 0))
        (dolist (e entries)
          (let ((pos (text-property-any (point-min) (point-max) 'org-hd-marker e)))
            (if (not pos)
                (progn (message "Skipping removed entry at %s" e)
                       (cl-incf skipped))
              (goto-char pos)
              (let (org-loop-over-headlines-in-active-region) (funcall 'dysthesis/org-agenda-process-inbox-item))
              ;; `post-command-hook' is not run yet.  We make sure any
              ;; pending log note is processed.
              (when (or (memq 'org-add-log-note (default-value 'post-command-hook))
                        (memq 'org-add-log-note post-command-hook))
                (org-add-log-note))
              (cl-incf processed))))
        (org-agenda-redo)
        (unless org-agenda-persistent-marks (org-agenda-bulk-unmark-all))
        (message "Acted on %d entries%s%s"
                 processed
                 (if (= skipped 0)
                     ""
                   (format ", skipped %d (disappeared before their turn)"
                           skipped))
                 (if (not org-agenda-persistent-marks) "" " (kept marked)")))))

(defun dysthesis/org-process-inbox ()
  "Called in org-agenda-mode, processes all inbox items."
  (interactive)
  (dysthesis/mark-inbox-todos)
  (dysthesis/bulk-process-entries))

(setq org-log-done 'time
      org-log-into-drawer t
      org-log-state-notes-insert-after-drawers nil)
(defun log-todo-next-creation-date (&rest ignore)
  "Log NEXT creation time in the property drawer under the key 'ACTIVATED'"
  (when (and (string= (org-get-todo-state) "NEXT")
             (not (org-entry-get nil "ACTIVATED")))
    (org-entry-put nil "ACTIVATED" (format-time-string "[%Y-%m-%d]"))))
(add-hook 'org-after-todo-state-change-hook #'log-todo-next-creation-date)

(defun dysthesis/org-inbox-capture ()
  "Capture a task in agenda mode."
  (interactive)
  (org-capture nil "i"))
(defun dysthesis/org-capture-todo ()
  (interactive)
  (org-capture nil "tt"))
(defun dysthesis/org-capture-todo-with-deadline ()
  (interactive)
  (org-capture nil "td"))
(defun dysthesis/org-capture-todo-with-schedule ()
  (interactive)
  (org-capture nil "ts"))

(mapcar (lambda
          (keymap)
          (apply 'define-key org-mode-map (car keymap) (cadr keymap)))
        '(("i" 'org-agenda-clock-in)
         ("r" 'dysthesis/org-process-inbox)
         ("R" 'org-agenda-refile)))

(use-package org-super-agenda
  :ensure t
  :after org-agenda
  :custom
  (org-super-agenda-keep-order t) ;; do not re-sort entries when grouping
  (org-agenda-custom-commands
   '(("o" "Overview"
      ((agenda "" ((org-agenda-span 'day)
                   (org-super-agenda-groups
                    '((:name "Today"
                             :time-grid t
                             :deadline today
                             :scheduled today
                             :order 0)
                      (:habit t
                              :order 1)
                      (:name "Overdue"
                             :deadline past
                             :scheduled past
                             :order 2)
                      (:name "Upcoming"
                             :and (:deadline future
                                             :priority>= "B")
                             :and (:scheduled future
                                              :priority>= "B")
                             :order 3)
                      (:discard (:anything t))))))
       (alltodo "" ((org-agenda-overriding-header "")
                    (org-super-agenda-groups
                     '((:name "Ongoing"
                              :todo "PROG"
                              :order 0)
                       (:name "Up next"
                              :todo "NEXT"
                              :order 1)
                       (:name "Waiting"
                              :todo "WAIT"
                              :order 2)
                       (:name "Important"
                              :priority "A"
                              :order 3)
                       (:name "Inbox"
                              :file-path "inbox"
                              :order 4)
                       (:name "University"
                              :category "University"
                              :tag ("university"
                                    "uni"
                                    "assignment"
                                    "exam")
                              :order 5)
                       (:name "Tinkering"
                              :category "Tinkering"
                              :tag ("nix"
                                    "nixos"
                                    "voidlinux"
                                    "neovim"
                                    "gentoo"
                                    "emacs"
                                    "tinker")
                              :order 6)
                       (:name "Reading list"
                              :category "Read"
                              :tag "read"
                              :order 6)))))))))
  :config (let ((inhibit-message t))
            (org-super-agenda-mode)))

(use-package doct
  :ensure t
  :commands (doct)
  :init
  (setq org-capture-templates
        (doct '((" Todo"
                 :keys "t"
                 :prepend t
                 :file "GTD/inbox.org"
                 :headline "Tasks"
                 :type entry
                 :template ("* TODO %? %{extra}")
                 :children ((" General"
                             :keys "t"
                             :extra "")
                            ("󰈸 With deadline"
                             :keys "d"
                             :extra "\nDEADLINE: %^{Deadline:}t")
                            ("󰥔 With schedule"
                             :keys "s"
                             :extra "\nSCHEDULED: %^{Start time:}t")))
                ("Bookmark"
                 :keys "b"
                 :prepend t
                 :file "bookmarks.org"
                 :type entry
                 :template "* TODO [[%:link][%:description]] :bookmark:\n\n"
                 :immediate-finish t)))))

(defun +org/dwim-at-point (&optional arg)
  "Do-what-I-mean at point.

If on a:
- checkbox list item or todo heading: toggle it.
- citation: follow it
- headline: cycle ARCHIVE subtrees, toggle latex fragments and inline images in
  subtree; update statistics cookies/checkboxes and ToCs.
- clock: update its time.
- footnote reference: jump to the footnote's definition
- footnote definition: jump to the first reference of this footnote
- timestamp: open an agenda view for the time-stamp date/range at point.
- table-row or a TBLFM: recalculate the table's formulas
- table-cell: clear it and go into insert mode. If this is a formula cell,
  recaluclate it instead.
- babel-call: execute the source block
- statistics-cookie: update it.
- src block: execute it
- latex fragment: toggle it.
- link: follow it
- otherwise, refresh all inline images in current tree."
  (interactive "P")
  (if (button-at (point))
      (call-interactively #'push-button)
    (let* ((context (org-element-context))
           (type (org-element-type context)))
      ;; skip over unimportant contexts
      (while (and context (memq type '(verbatim code bold italic underline strike-through subscript superscript)))
        (setq context (org-element-property :parent context)
              type (org-element-type context)))
      (pcase type
        ((or `citation `citation-reference)
         (org-cite-follow context arg))

        (`headline
         (cond ((memq (bound-and-true-p org-goto-map)
                      (current-active-maps))
                (org-goto-ret))
               ((and (fboundp 'toc-org-insert-toc)
                     (member "TOC" (org-get-tags)))
                (toc-org-insert-toc)
                (message "Updating table of contents"))
               ((string= "ARCHIVE" (car-safe (org-get-tags)))
                (org-force-cycle-archived))
               ((or (org-element-property :todo-type context)
                    (org-element-property :scheduled context))
                (org-todo
                 (if (eq (org-element-property :todo-type context) 'done)
                     (or (car (+org-get-todo-keywords-for (org-element-property :todo-keyword context)))
                         'todo)
                   'done))))
         ;; Update any metadata or inline previews in this subtree
         (org-update-checkbox-count)
         (org-update-parent-todo-statistics)
         (when (and (fboundp 'toc-org-insert-toc)
                    (member "TOC" (org-get-tags)))
           (toc-org-insert-toc)
           (message "Updating table of contents"))
         (let* ((beg (if (org-before-first-heading-p)
                         (line-beginning-position)
                       (save-excursion (org-back-to-heading) (point))))
                (end (if (org-before-first-heading-p)
                         (line-end-position)
                       (save-excursion (org-end-of-subtree) (point))))
                (overlays (ignore-errors (overlays-in beg end)))
                (latex-overlays
                 (cl-find-if (lambda (o) (eq (overlay-get o 'org-overlay-type) 'org-latex-overlay))
                             overlays))
                (image-overlays
                 (cl-find-if (lambda (o) (overlay-get o 'org-image-overlay))
                             overlays)))
           (+org--toggle-inline-images-in-subtree beg end)
           (if (or image-overlays latex-overlays)
               (org-clear-latex-preview beg end)
             (org--latex-preview-region beg end))))

        (`clock (org-clock-update-time-maybe))

        (`footnote-reference
         (org-footnote-goto-definition (org-element-property :label context)))

        (`footnote-definition
         (org-footnote-goto-previous-reference (org-element-property :label context)))

        ((or `planning `timestamp)
         (org-follow-timestamp-link))

        ((or `table `table-row)
         (if (org-at-TBLFM-p)
             (org-table-calc-current-TBLFM)
           (ignore-errors
             (save-excursion
               (goto-char (org-element-property :contents-begin context))
               (org-call-with-arg 'org-table-recalculate (or arg t))))))

        (`table-cell
         (org-table-blank-field)
         (org-table-recalculate arg)
         (when (and (string-empty-p (string-trim (org-table-get-field)))
                    (bound-and-true-p evil-local-mode))
           (evil-change-state 'insert)))

        (`babel-call
         (org-babel-lob-execute-maybe))

        (`statistics-cookie
         (save-excursion (org-update-statistics-cookies arg)))

        ((or `src-block `inline-src-block)
         (org-babel-execute-src-block arg))

        ((or `latex-fragment `latex-environment)
         (org-latex-preview arg))

        (`link
         (let* ((lineage (org-element-lineage context '(link) t))
                (path (org-element-property :path lineage)))
           (if (or (equal (org-element-property :type lineage) "img")
                   (and path (image-type-from-file-name path)))
               (+org--toggle-inline-images-in-subtree
                (org-element-property :begin lineage)
                (org-element-property :end lineage))
             (org-open-at-point arg))))

        ((guard (org-element-property :checkbox (org-element-lineage context '(item) t)))
         (org-toggle-checkbox))

        (`paragraph
         (+org--toggle-inline-images-in-subtree))

        (_
         (if (or (org-in-regexp org-ts-regexp-both nil t)
                 (org-in-regexp org-tsr-regexp-both nil  t)
                 (org-in-regexp org-link-any-re nil t))
             (call-interactively #'org-open-at-point)
           (+org--toggle-inline-images-in-subtree
            (org-element-property :begin context)
            (org-element-property :end context))))))))

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (with-eval-after-load 'evil-org
    (define-key org-mode-map (kbd "<normal-state> RET") '+org/dwim-at-point))
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(setq org-hide-emphasis-markers t)
(use-package org-appear
  :ensure t
  :config ; add late to hook
  (add-hook 'org-mode-hook 'org-appear-mode))

(use-package org-modern
  :ensure t
  :config
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (org-indent-mode)
  (dolist (face '(window-divider
		      window-divider-first-pixel
		      window-divider-last-pixel))
	(face-spec-reset-face face)
	(set-face-foreground face (face-attribute 'default :background)))
  (set-face-background 'fringe (face-attribute 'default :background))
  (setq org-hide-emphasis-markers t)
  (setq  org-modern-list
  	 '((45 . "•")
             (43 . "◈")
             (42 . "➤")))
  (setq org-modern-fold-stars '((" 󰫈 " . " 󰫈 ") (" 󰫇 " . " 󰫇 ") (" 󰫆 " . " 󰫆 ") (" 󰫅 " . " 󰫅 ") (" 󰫄 " . " 󰫄 ") (" 󰫃 " . " 󰫃 ")))
  (setq org-modern-block-name
  	'((t . t)
            ("src" "»" "«")
            ("example" "»–" "–«")
            ("quote" "" "")
            ("export" "⏩" "⏪")))
  (setq org-modern-block-fringe 6)
  (setq org-agenda-tags-column 0
  	org-agenda-block-separator ?─
  	org-agenda-time-grid
  	'((daily today require-timed)
            (800 1000 1200 1400 1600 1800 2000)
            " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
  	org-agenda-current-time-string
  	"⭠ now ─────────────────────────────────────────────────")
    (setq org-modern-todo-faces
  	'(("WAIT"
             :inverse-video t
             :inherit +org-todo-onhold)
            ("NEXT"
             :inverse-video t
             :foreground "#89b4fa")
            ("PROG"
             :inverse-video t
             :foreground "#a6e3a1")
            ("TODO"
             :inverse-video t
             :foreground "#fab387")))
  (setq org-ellipsis " ↪")
  (global-org-modern-mode)
  (setq org-pretty-entities t))

(setq org-ellipsis " ↪")

(setq org-modern-keyword
	'((t . t)
          ("title" . "𝙏 ")
          ("filetags" . "󰓹 ")
          ("auto_tangle" . "󱋿 ")
          ("subtitle" . "𝙩 ")
          ("author" . "𝘼 ")
          ("email" . #(" " 0 1 (display (raise -0.14))))
          ("date" . "𝘿 ")
          ("property" . "☸ ")
          ("options" . "⌥ ")
          ("startup" . "⏻ ")
          ("macro" . "𝓜 ")
          ("bind" . #(" " 0 1 (display (raise -0.1))))
          ("bibliography" . " ")
          ("print_bibliography" . #(" " 0 1 (display (raise -0.1))))
          ("cite_export" . "⮭ ")
          ("print_glossary" . #("ᴬᶻ " 0 1 (display (raise -0.1))))
          ("glossary_sources" . #(" " 0 1 (display (raise -0.14))))
          ("include" . "⇤ ")
          ("setupfile" . "⇚ ")
          ("html_head" . "🅷 ")
          ("html" . "🅗 ")
          ("latex_class" . "🄻 ")
          ("latex_class_options" . #("🄻 " 1 2 (display (raise -0.14))))
          ("latex_header" . "🅻 ")
          ("latex_header_extra" . "🅻⁺ ")
          ("latex" . "🅛 ")
          ("beamer_theme" . "🄱 ")
          ("beamer_color_theme" . #("🄱 " 1 2 (display (raise -0.12))))
          ("beamer_font_theme" . "🄱𝐀 ")
          ("beamer_header" . "🅱 ")
          ("beamer" . "🅑 ")
          ("attr_latex" . "🄛 ")
          ("attr_html" . "🄗 ")
          ("attr_org" . "⒪ ")
          ("call" . #(" " 0 1 (display (raise -0.15))))
          ("name" . "⁍ ")
          ("header" . "› ")
          ("caption" . "☰ ")
          ("results" . "🠶")))

(defface busy-1  '((t :foreground "black" :background "#eceff1")) "")
(defface busy-2  '((t :foreground "black" :background "#cfd8dc")) "")
(defface busy-3  '((t :foreground "black" :background "#b0bec5")) "")
(defface busy-4  '((t :foreground "black" :background "#90a4ae")) "")
(defface busy-5  '((t :foreground "white" :background "#78909c")) "")
(defface busy-6  '((t :foreground "white" :background "#607d8b")) "")
(defface busy-7  '((t :foreground "white" :background "#546e7a")) "")
(defface busy-8  '((t :foreground "white" :background "#455a64")) "")
(defface busy-9  '((t :foreground "white" :background "#37474f")) "")
(defface busy-10 '((t :foreground "white" :background "#263238")) "")
(defadvice calendar-generate-month
    (after highlight-weekend-days (month year indent) activate)
  "Highlight weekend days"
  (dotimes (i 31)
    (let* ((org-files org-agenda-files)
           (date (list month (1+ i) year))
           (count 0))
      (dolist (file org-files)
        (setq count (+ count (length (org-agenda-get-day-entries file date)))))
      (cond ((= count 0) ())
            ((= count 1) (calendar-mark-visible-date date 'busy-1))
            ((= count 2) (calendar-mark-visible-date date 'busy-2))
            ((= count 3) (calendar-mark-visible-date date 'busy-3))
            ((= count 4) (calendar-mark-visible-date date 'busy-4))
            ((= count 5) (calendar-mark-visible-date date 'busy-5))
            ((= count 6) (calendar-mark-visible-date date 'busy-6))
            ((= count 7) (calendar-mark-visible-date date 'busy-7))
            ((= count 8) (calendar-mark-visible-date date 'busy-8))
            ((= count 9) (calendar-mark-visible-date date 'busy-9))
            (t  (calendar-mark-visible-date date 'busy-10)))
      )))

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/Documents/Org/Roam/"))
  (org-roam-complete-everywhere t)
  (org-roam-buffer-window-parameters '((no-delete-other-windows . t)))
  (org-roam-link-use-custom-faces 'everywhere)
  (org-roam-capture-templates
   '(("d" " Default" plain
      "%?"
      :if-new (file+head "${slug}.org"
                         "#+title: ${title}\n#+filetags: :new:\n#+STARTUP: latexpreview")
      :immediate-finish t
      :unnarrowed t)
     ("i" "󰆼 Index note" plain
      "%?"
      :if-new (file+head "${slug}.org"
                         "#+title: ${title}\n#+filetags: :new:index:")
      :immediate-finish t
      :unarrowed t)
     ("e" "󰖟 Elfeed" plain
      "%?"
      :target (file+head "Elfeed/${slug}.org"
                         "#+title: ${title}\n#+filetags: :new:article:rss:\n#+STARTUP: latexpreview"
                         ;;"#+filetags: :article:rss:\n"
                         )
      :unnarrowed t)
     ("l" "󰙨 Literature note" plain
      "%?"
      :target
      (file+head
       "%(expand-file-name (or citar-org-roam-subdir \"\") org-roam-directory)/Literature/${citar-citekey}.org"
       "#+title: ${note-title}.\n#+filetags: :new:\n#+created: %U\n#+last_modified: %U\n#+STARTUP: latexpreview\n#+url: ${citar-howpublished}\n\n* Annotations\n:PROPERTIES:\n:Custom_ID: ${citar-citekey}\n:NOTER_DOCUMENT: ${citar-file}\n:NOTER_PAGE: \n:END:\n\n")
      :unnarrowed t)
     ("d" " Idea" plain "%?"
      :if-new
      (file+head "${slug}.org" "#+title: ${title}\n#+filetags: :idea:new:\n#+STARTUP: latexpreview\n")
      :immediate-finish t
      :unnarrowed t)))
  (org-roam-dailies-capture-templates
   '(("d" "default" entry "* %<%H:%M> %?"
      :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))
  (org-roam-dailies-directory "Daily/")
  :general
  ("C-c n" '(:ignore t
                     :wk "Org-roam"))
  ("C-c n l" '(org-roam-buffer-toggle
               :wk "Toggle org-roam buffer"))
  ("C-c n f" '(org-roam-node-find
               :wk "Find org-roam node"))
  ("C-c n d" '(:keymap org-roam-dailies-map
                       :package org-roam
                       :wk "Org-roam dailies"))
  ("C-c n i" '(org-roam-node-insert
               :wk "Insert org-roam node"))
  ("C-c n c" '(org-roam-capture
               :wk "Capture into org-roam node"))
  ("C-c n t" '(org-roam-tag-add :wk "Add tag to current org-roam node"))
  ("C-c n a" '(org-roam-alias-add :wk "Add alias to current org-roam node"))
  ;; Dailies
  :config
  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol))

(use-package citar-org-roam
  :ensure t
  :after (citar org-roam)
  :custom
  (citar-org-roam-capture-template-key "l")
  (citar-org-roam-note-title-template "${author} - ${title}")
  (citar-org-roam-template-fields
   '((:citar-title . ("title"))
     (:citar-author . ("author" "editor"))
     (:citar-date . ("date" "year" "issued"))
     (:citar-pages . ("pages"))
     (:citar-type . ("=type="))
     (:citar-file . ("file"))
     (:citar-howpublished . ("howpublished"))))
  :config (citar-org-roam-mode 1))

(use-package org-roam-timestamps
  :ensure t
  :after org-roam
  :config (org-roam-timestamps-mode))

(use-package org-roam-ui
  :ensure t
  :after org-roam
  ;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
  ;;         a hookable mode anymore, you're advised to pick something yourself
  ;;         if you don't care about startup time, use
  ;;  :hook (after-init . org-roam-ui-mode)
  :custom
  (org-roam-ui-sync-theme t)
  (org-roam-ui-follow t)
  (org-roam-ui-update-on-save t)
  (org-roam-ui-open-on-start t)
  (org-roam-ui-custom-theme
   '((bg-alt . "#0f0f0f")
     (bg . "#000000")
     (fg . "#ffffff")
     (fg-alt . "#cdd6f4")
     (red . "#f38ba8")
     (orange . "#fab387")
     (yellow ."#f9e2af")
     (green . "#a6e3a1")
     (cyan . "#94e2d5")
     (blue . "#89b4fa")
     (violet . "#8be9fd")
     (magenta . "#f5c2e7"))))

(use-package org-ref
  :ensure t
  :config
  (setq
   org-ref-get-pdf-filename-function
   (lambda (key) (car (bibtex-completion-find-pdf key)))
   org-ref-default-bibliography '("~/Documents/Org/Library.bib") 
   ;;org-ref-bibliography-notes "~/Org/Roam/Literature/bibnotes.org"
   org-ref-pdf-directory "~/Documents/Org/Library/files"
   org-ref-note-title-format "* %y - %t\n :PROPERTIES:\n  :Custom_ID: %k\n  :NOTER_DOCUMENT: %F\n :ROAM_KEY: cite:%k\n  :AUTHOR: %9a\n  :JOURNAL: %j\n  :YEAR: %y\n  :VOLUME: %v\n  :PAGES: %p\n  :DOI: %D\n  :URL: %U\n :END:\n\n"
   org-ref-notes-directory "~/Documents/Org/Roam/Literature/"
   org-ref-notes-function 'orb-edit-notes)

  (setq
   bibtex-completion-notes-path org-ref-notes-directory
   bibtex-completion-bibliography org-ref-default-bibliography
   bibtex-completion-library-path "~/Documents/Org/Library/files/"
   bibtex-completion-pdf-field "file"
   bibtex-completion-notes-template-multiple-files
   (concat
    "#+TITLE: ${title}\n"
    "#+ROAM_KEY: cite:${=key=}\n"
    "* TODO Notes\n"
    ":PROPERTIES:\n"
    ":CUSTOM_ID: ${=key=}\n"
    ":NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")\n"
    ":AUTHOR: ${author-abbrev}\n"
    ":JOURNAL: ${journaltitle}\n"
    ":DATE: ${date}\n"
    ":YEAR: ${year}\n"
    ":DOI: ${doi}\n"
    ":URL: ${url}\n"
    ":END:\n\n")))

(use-package org-noter
  :ensure t
  :after (:any org pdf-view)
  :config
  (setq
   ;; Please stop opening frames
   org-noter-always-create-frame nil
   ;; I want to see the whole file
   org-noter-hide-other nil
   ;; Everything is relative to the main notes file
   org-noter-notes-search-path (list org-directory)))

(use-package org-auto-tangle
  :ensure t
  :defer t
  :hook (org-mode . org-auto-tangle-mode))

(use-package org-fragtog
  :ensure t
  :after org
  :config
  (add-hook 'org-mode-hook 'org-fragtog-mode))

(add-to-list 'org-latex-packages-alist
             '("" "tikz" t))

(eval-after-load "preview"
  '(add-to-list 'preview-default-preamble "\\PreviewEnvironment{tikzpicture}" t))

(use-package vterm
  :ensure t)

(setq TeX-engine 'luatex)

(setq-default shell-file-name (executable-find "dash"))

(use-package envrc
  :ensure t
  :hook (after-init-hook . envrc-global-mode))

(use-package async
  :ensure t
  :config
  (autoload 'dired-async-mode "dired-async.el" nil t)
  (dired-async-mode 1))

(use-package ob-async
  :ensure t)

(use-package undo-fu
  :ensure t
  :config
  (global-unset-key (kbd "C-z"))
  (global-set-key (kbd "C-z")   'undo-fu-only-undo)
  (global-set-key (kbd "C-S-z") 'undo-fu-only-redo))

(use-package undo-fu-session
  :ensure t
  :config
  (undo-fu-session-global-mode))

(use-package evil
  :init
  (setq evil-undo-system 'undo-fu))

(use-package vundo
  :ensure t
  :custom (vundo-glyph-alist vundo-unicode-symbols))

(setenv "PATH" (concat "/home/demiurge/.nix-profile/bin:/home/demiurge/.local/bin:" (getenv "PATH")))
(setq exec-path (append '("/home/demiurge/.nix-profile/bin"
			  "/home/demiurge/.local/bin")
			exec-path))

;;(use-package elpaca
;;  :init
;;  (setf (alist-get 'remote (alist-get 'gnu-devel elpaca-menu-elpas)) "https://git.savannah.gnu.org/git/emacs/elpa.git/")
;;  (elpaca-update-menus #'elpaca-menu-gnu-devel-elpa))
;;(elpaca-wait)

(use-package gcmh
  :ensure t
  :config (gcmh-mode 1))
