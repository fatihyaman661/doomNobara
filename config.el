;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `or g-directory'. It must be set before org loads!
(setq org-directory "/media/gamedisk/documents/org-directory")
(setq org-noter-notes-search-path '("/media/gamedisk/documents/noterNotesSearchPath"))


;;windmove moves
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

;; enable word-wrap (almost) everywhere
(setq global-visual-line-mode t)


;;Maximise window upon startup
;;(setq initial-frame-alist '((top . 1) (left . 1) (width . 114) (height . 32)))
;;(add-to-list 'initial-frame-alist '(maximized))


(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))


;;;;;;;Package activation;;;;;;;



(use-package ivy
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) "))
(use-package ivy-rich
  :config
  (ivy-rich-mode 1))
(use-package all-the-icons
  :if (display-graphic-p))
(use-package all-the-icons-ivy-rich
  :config
  (all-the-icons-ivy-rich-mode 1))
(use-package anzu
  :config
  (global-anzu-mode +1)
  (global-set-key [remap query-replace] 'anzu-query-replace)
  (global-set-key [remap query-replace-regexp] 'anzu-query-replace-regexp))
(use-package company)
(use-package company-statistics
  :config
  (company-statistics-mode 1))
(use-package counsel)
(use-package crux)
(use-package drag-stuff
  :config
  (drag-stuff-global-mode t)
  (drag-stuff-define-keys))
(use-package emojify)
(use-package emojify-logos)
(use-package flycheck)
;; Eglot is scoped to gdscript only; every other language uses Doom's lsp-mode.
;; `global-flycheck-eglot-mode' used to hijack flycheck everywhere, which
;; suppressed ruff diagnostics in Python buffers.
(use-package! flycheck-eglot
  :hook (gdscript-mode . flycheck-eglot-mode))
(use-package goto-line-preview
  :init
  (global-set-key [remap goto-line] 'goto-line-preview))
(use-package helm)
(use-package highlight-indentation
  :config
  (highlight-indentation-mode +1))
(use-package hydra)
(use-package magit-delta)
(use-package magit-section)
(use-package major-mode-hydra)
(use-package mode-icons
  :config
  (mode-icons-mode 1))
(use-package popup)
(use-package pretty-hydra)
(use-package rainbow-mode
  :config
  (rainbow-mode +1))
(use-package swiper)
(use-package transient)
(use-package undo-fu
  :config
  (undo-fu-session-global-mode t))
(use-package smartparens
  :config
  (smartparens-mode +1))
(use-package undo-fu-session)
(use-package vundo)
(use-package gdscript-mode
  :hook (gdscript-mode . eglot-ensure)
  :hook (gdscript-mode . company-mode))
(use-package pdf-tools)
(use-package xenops
  :config
  (setq xenops-reveal-on-entry t))
(use-package! iedit
  :defer
  :config
  (set-face-background 'iedit-occurrence "Magenta")
  :bind
  ("C-;" . iedit-mode))
(use-package annotate)
(use-package! org-roam-bibtex
  :after org-roam
  :config
  (require 'org-ref)) ; optional: if using Org-ref v2 or v3 citation links
(use-package! websocket
    :after org-roam)
(use-package! org-roam-ui
    :after org-roam ;; or :after org
;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
;;         a hookable mode anymore, you're advised to pick something yourself
;;         if you don't care about startup time, use
;;    :hook (after-init . org-roam-ui-mode)
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))
(add-hook 'c++-mode-hook #'dtrt-indent-mode)
(setq compilation-ask-about-save nil)
(use-package! matlab-mode
  :config
  (setq matlab-indent-level 4)
  (add-to-list 'auto-mode-alist '("\\.m\\'" . matlab-mode)))


(defun my/matlab-shell-toggle ()
  "Toggle between MATLAB script and the shell."
  (interactive)
  (if (get-buffer "*MATLAB*")
      (if (string= (buffer-name) "*MATLAB*")
          (delete-window)
        (let ((w (get-buffer-window "*MATLAB*")))
          (if w
              (select-window w)
            (split-window-sensibly)
            (other-window 1)
            (switch-to-buffer "*MATLAB*"))))
    (matlab-shell)))

;; Bind it to a key, for example:
(map! :leader
      :desc "Toggle MATLAB Shell" "m s" #'my/matlab-shell-toggle)
(map! :after matlab
      :map matlab-mode-map
      "C-c C-v" #'matlab-shell-describe-variable
      "C-c C-h" #'matlab-shell-help-choose)
(after! lsp-mode
  (setq lsp-matlab-server-command 
        '("node" "/usr/local/apps/matlabls/out/index.js")))

(use-package! casual-calc
  :after calc
  :bind (:map calc-mode-map
         ("C-o" . casual-calc-tmenu)
         :map calc-alg-map
         ("C-o" . casual-calc-tmenu)))


;;;;;Key Bindings;;;;


(global-set-key (kbd "C-s") 'swiper-isearch)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "M-y") 'counsel-yank-pop)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "<f2> j") 'counsel-set-variable)
(global-set-key (kbd "C-x b") 'ivy-switch-buffer)
(global-set-key (kbd "C-c v") 'ivy-push-view)
(global-set-key (kbd "C-c V") 'ivy-pop-view)
(global-set-key (kbd "M-_") 'undo-fu-only-redo)
(map! "M-g g" #'avy-goto-line)
(map! "M-g M-g" #'avy-goto-line)

(setq lsp-dart-sdk-dir "/media/gamedisk/linux_programs/flutter/bin/cache/dart-sdk")
(setq lsp-dart-flutter-sdk "/media/gamedisk/linux_programs/flutter")
(setq flutter-sdk-path "/media/gamedisk/linux_programs/flutter")

;;Latex related
(setq +latex-viewers '(pdf-tools))
(setq lsp-tex-server 'texlab)
(add-hook 'LaTeX-mode-hook #'xenops-mode)
(map! :map LaTeX-mode-map "TAB" #'cdlatex-tab)

;;Disable drag-stuff in org-mode
(add-hook 'org-mode-hook (lambda () (drag-stuff-mode -1)))



;:godot related
(setq gdscript-godot-executable "/media/gamedisk/Program Files/flatpak/app/org.godotengine.Godot/current/active/export/bin/org.godotengine.Godot")
(defun lsp--gdscript-ignore-errors (original-function &rest args)
  "Ignore the error message resulting from Godot not replying to the `JSONRPC' request."
  (if (string-equal major-mode "gdscript-mode")
      (let ((json-data (nth 0 args)))
        (if (and (string= (gethash "jsonrpc" json-data "") "2.0")
                 (not (gethash "id" json-data nil))
                 (not (gethash "method" json-data nil)))
            nil ; (message "Method not found")
          (apply original-function args)))
    (apply original-function args)))
;; Runs the function `lsp--gdscript-ignore-errors` around `lsp--get-message-type` to suppress unknown notification errors.
(advice-add #'lsp--get-message-type :around #'lsp--gdscript-ignore-errors)

;;Add the lisp server directory
(add-to-list 'load-path (expand-file-name "~/.cargo/bin" user-emacs-directory))

(add-hook 'prog-mode-hook #'company-mode)

(setq auto-save-default t
      make-backup-files t)


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.



;;; ────────────────────────────────────────────────────────────────────────────
;;; Python
;;; ────────────────────────────────────────────────────────────────────────────
;; Module line: (python +lsp +pyright +tree-sitter +uv)
;; External tooling (all already installed):
;;   basedpyright  - type checking / completion / refactoring   (pipx)
;;   ruff          - linting + formatting + import sorting      (dnf)
;;   debugpy       - DAP debugger backend                       (pipx)
;;   uv            - venv + dependency management               (dnf)

;; Doom's +pyright flag pulls in lsp-pyright, which drives stock pyright by
;; default. basedpyright is a strict superset: inlay hints, more lint rules,
;; no telemetry.
;;
;; This MUST be a top-level setq, not `(after! lsp-pyright ...)'. lsp-pyright
;; registers its server dependency with a backquote-comma:
;;
;;   (lsp-dependency 'pyright `(:system ,(concat lsp-pyright-langserver-command
;;                                              "-langserver")) ...)
;;
;; so the value is baked in at *load* time. Setting it in `after!' runs after
;; that form, leaving the dependency pointing at the nonexistent
;; "pyright-langserver"; `lsp-package-path' then returns nil, the priority-2
;; pyright client fails to launch, and lsp-mode silently falls back to the
;; priority -2 ruff server -- so you get ruff lints but no type checking.
;; A defcustom does not overwrite a value already set, so setting it here (well
;; before lsp-mode requires lsp-pyright) is safe and also makes the custom
;; settings register under the correct "basedpyright.*" keys.
(setq lsp-pyright-langserver-command "basedpyright")

;; Belt and braces: if lsp-pyright somehow loaded before the setq above, the
;; dependency is already wrong. Re-register it explicitly.
(after! lsp-pyright
  (lsp-dependency 'pyright '(:system "basedpyright-langserver")))

(after! lsp-mode
  ;; File watchers choke on site-packages/.venv and burn through the inotify
  ;; limit. basedpyright indexes on its own, so dropping them costs nothing.
  (setq lsp-enable-file-watchers nil
        lsp-idle-delay 0.3)
  (dolist (re '("[/\\\\]\\.venv\\'"
                "[/\\\\]\\.mypy_cache\\'"
                "[/\\\\]\\.ruff_cache\\'"
                "[/\\\\]\\.pytest_cache\\'"
                "[/\\\\]__pycache__\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories re)))

;; Run ruff *alongside* the LSP rather than instead of it: basedpyright reports
;; type errors, ruff reports style and bug-pattern lints. flycheck only runs a
;; chained checker when its :modes match, so this is a no-op outside Python.
;;
;; NOTE: the `lsp' checker does not exist yet when lsp-mode loads. lsp-mode
;; creates it lazily in `lsp-diagnostics-lsp-checker-if-needed', which runs only
;; once a server actually attaches to a buffer. Calling
;; `flycheck-add-next-checker' any earlier signals "lsp is not a valid syntax
;; checker" -- and because `lsp!' runs on python-ts-mode-local-vars-hook, that
;; error aborted LSP startup for Python entirely. Chain it from
;; lsp-diagnostics-mode instead, guarded so it is only added once.
(add-hook! 'lsp-diagnostics-mode-hook
  (defun +my/python-chain-ruff-after-lsp-h ()
    (when (and (flycheck-valid-checker-p 'lsp)
               (flycheck-valid-checker-p 'python-ruff)
               (not (cl-find 'python-ruff
                             (flycheck-checker-get 'lsp 'next-checkers)
                             :key (lambda (c) (if (consp c) (cdr c) c)))))
      (flycheck-add-next-checker 'lsp '(warning . python-ruff)))))

;; Formatting: ruff, on save, Python only. The :editor format module is enabled
;; without +onsave, so apheleia stays off everywhere else (LaTeX and MATLAB keep
;; their current behaviour).
(after! apheleia
  (setf (alist-get 'python-mode apheleia-mode-alist)    '(ruff-isort ruff)
        (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff)))

(add-hook 'python-base-mode-hook #'apheleia-mode)

(add-hook! 'python-base-mode-hook
  (defun +my/python-setup-h ()
    (setq-local fill-column 88          ; ruff's default line length
                tab-width 4
                indent-tabs-mode nil)))

(after! python
  ;; Silences the "can't guess python-indent-offset" noise on odd files.
  (setq python-indent-guess-indent-offset-verbose nil))

;; Debugging: SPC o d opens the dap hydra; dap-debug picks the debugpy template.
(after! dap-mode
  (require 'dap-python)
  (setq dap-python-debugger 'debugpy))

;; Testing lives on the localleader, courtesy of the python module:
;;   SPC m t a  all tests      SPC m t f  tests for this file
;;   SPC m t t  test at point  SPC m t r  repeat last run
;;   SPC m t p  pytest dispatch (transient menu)
;; venv handling: uv-mode activates a project's .venv automatically, and the
;; :tools direnv module picks up .envrc for anything uv doesn't cover.
