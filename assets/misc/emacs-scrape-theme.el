(defvar rouge-face-map
  '((font-lock-comment-face       "c" "ch" "cd" "cm" "cpf" "c1" "cs")
    (font-lock-doc-face           "sd")
    (font-lock-string-face        "s" "s1" "s2" "sb" "sc" "sh" "sx" "sa" "dl")
    (font-lock-regexp-face        "sr")
    (font-lock-escape-face        "se")
    (font-lock-keyword-face       "k" "kd" "kn" "kp" "kr" "kv" "ow")
    (font-lock-builtin-face       "nb" "bp")
    (font-lock-function-name-face "nf" "fm" "nt")
    (font-lock-variable-name-face "nv" "vc" "vg" "vi")
    (font-lock-property-name-face "na")
    (font-lock-type-face          "kt" "nc" "nn" "ne")
    (font-lock-constant-face      "no" "kc" "ss" "nl")
    (font-lock-number-face        "m" "mi" "mf" "mh" "mo" "mb" "mx" "il")
    (font-lock-preprocessor-face  "cp" "nd")
    (font-lock-warning-face       "err")))

(defun map-weight (w)
  (pcase w
    ((or 'ultra-bold 'extra-bold 'bold 'semi-bold) "font-weight: bold;")
    ((or 'ultra-light 'extra-light 'light 'semi-light) "font-weight: lighter;")))

(defun map-slant (s)
  (pcase s
    ((or 'italic 'oblique) "font-style: italic;")))

(defun face-to-css (face)
  "Produce a string of ';'-separated CSS rules from a face."
  (let (rules)            ; Build up the 'rules' list..
                          ; Each item in this list is one CSS attribute. The rest
                          ; of this function just goes over each attribute type
                          ; and converts from Emacs form to CSS form.
    (let ((fg (face-attribute face :foreground)))
      (when (stringp fg)  ; Sometimes a face won't have a foreground or background
                          ; defined, in which case skip it. Then it will fall back
                          ; to the default style.
        (push (format "color: %s;" fg) rules)))
    (let ((bg (face-attribute face :background)))
      (when (stringp bg)
        (push (format "background-color: %s;" bg) rules)))
    (let ((css-weight (map-weight (face-attribute face :weight))))
                          ; `:weight' and `:slant' use the helper functions above.
      (when (stringp css-weight)
        (push css-weight rules)))
    (let ((css-slant (map-slant (face-attribute face :slant))))
      (when (stringp css-slant)
        (push css-slant rules)))
    (when (eq (face-attribute face :underline) t)
                          ; Simply check if this attribute is set.
      (push "text-decoration: underline;" rules))
    (apply #'concat (nreverse rules))))

(defun scrape-current-theme ()
  "Scrape the current theme, writing CSS stylesheet to stdout"
  (interactive)

  (let ((standard-output (get-buffer-create "*stylesheet*")))
    (princ (format ".highlight {%s}\n" (face-to-css 'default))) ; Default rule for all highlighted text
                          
    (dolist (entry rouge-face-map) ; Specific rule for each face
      (let ((face (car entry)) (classes (cdr entry)))
        (princ (format ".highlight .%s" (car classes)))
        (dolist (class (cdr classes)) (princ (format ",\n.highlight .%s" class)))
        (princ (format "\n{%s}\n" (face-to-css face))))))

  (display-buffer "*stylesheet*"))
