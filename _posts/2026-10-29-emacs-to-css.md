---
layout: post
author: Jacob Garby
tags: code emacs
title: Converting an Emacs Theme to CSS for Jekyll
---

{% raw %}

> Tl;dr: I wrote an Emacs script to translate an Emacs theme into a CSS stylesheet that Jekyll syntax highlighting understands.
> For your convenience, here are a few stylesheets that I generated in this way, which you can download and use in your own site:
> - [Leuven](/assets/css/leuven.css)
> - [Modus Operandi](/assets/css/modus-operandi.css)
> - [Modus Vivendi](/assets/css/modus-vivendi.css)
> And you can also download [the script itself](/assets/misc/emacs-scrape-theme.el)

---

To render the pages on this blog, I write a simple HTML template file plus a markdown file for each post, and then [Jekyll](https://jekyllrb.com/) takes them and produces a static HTML file for every page. In particular, Jekyll uses a library called [Rouge](https://codeberg.org/rouge-ruby/rouge) to provide syntax highlighting for markdown code blocks, like this one:

```c
#include <stdio.h>

int main(int argc, char **argv)
{
    /* Print a welcome message */
    printf("Welcome to my website :)\n");
}
```

However! Rouge doesn't _directly_ actually colour the text, but rather, it takes the code I wrote and applies specific CSS classes to different symbols based on their semantics in the code.

There are some premade themes you can download as stylesheets to colour the text, but I wanted to make my own. Specifically, I want to take any Emacs theme and convert that into a CSS stylesheet that can be used for Rouge syntax highlighting.

## CSS Classes

Every piece of text that shall be highlighted is placed in a `<span>` tag with, at least, the `.highlight` class. Additional classes are then added to override the theme's default attributes. For instance, comments generally take a `.c` tag, but can also take variations like `.cm` for a multi-line comment, or `.cd` for a doc comment.

There's no very convenient source for what all these classes are; I find that the best way is to [look at Rouge's source](https://github.com/rouge-ruby/rouge/blob/8f70612b0020b4f313abfea620f1bc0b2b4389f2/lib/rouge/token.rb#L69).

Naturally, since we want to turn an Emacs theme into this kind of format, we should write a script in Emacs itself for easy access to the theme properties. Let's begin by writing a map from Emacs face names to Rouge classes:

```elisp
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
```

## Extracting attributes

Emacs gives us a pretty nice way to inspect attributes of the currently loaded theme (or face, as they call it). `(face-attribute FACE ATTRIBUTE &optional FRAME INHERIT)` gives us the value of a particular attribute of a particular face (we can ignore the last two params), for example:

```elisp
; Evaluating this...
(face-attribute font-lock-keyword-face :foreground)
; Returns this (with modus-operandi theme loaded):
"#f31ab6"
```

And how do we know what symbol to use for `ATTRIBUTE`? Conveniently, they're all listed in `C-h o set-face-attribute`! You could probably go crazy and convert to CSS every type of attribute that Emacs supports, but I want to simplify it a bit. I'll only consider:

 - `:weight` (one of a number of symbols, see function help)
 - `:foreground` and `:background` (a colour string)
 - `:underline` (could be `t` or a colour name, but I only consider `t` (or `nil`))
 - `:slant` (could be a few things, but we only consider `italic`, `oblique`, or `normal`)
 
For the simple colour attributes, we can use the value directly in CSS (with the caveat that Emacs colours can also be colour _names_ that CSS doesn't recognise, but I'm just hoping that isn't the case for my themes, which seems to be true so far...). However, I wrote a couple of helper functions for `:weight` and `:slant` to convert from Emacs face attribute to CSS-understandable attribute:

```elisp
(defun map-weight (w)
  (pcase w
    ((or 'ultra-bold 'extra-bold 'bold 'semi-bold) "font-weight: bold;")
    ((or 'ultra-light 'extra-light 'light 'semi-light) "font-weight: lighter;")))

(defun map-slant (s)
  (pcase s
    ((or 'italic 'oblique) "font-style: italic;")))
```

## Generating a Stylesheet

All that's left now, really, is gluing these concepts together. We just need to loop over every face type we're interested in (`rouge-face-map`), and for each one, print out the CSS rules followed by the CSS attributes. To keep things clean, first we define a `face-to-css` function which prints the CSS _attributes_ (i.e. whatever should be inside the curly braces) for a given face. The inline comments should explain it enough:

```elisp
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
```

And finally, the actual loop over face types! Just a couple of extra things to mention here: we need a base CSS style for default text (highlighted but no specific type), which Emacs calls `'default`. Secondly, so that we can print commas between all the CSS selectors for a given attribute, but not after the very last one, I do this slightly ugly thing of first writing `(car classes)`, and _then_ looping over the rest. Maybe there's a better way: I'm still very much beginning to learn Emacs lisp. Lastly, I'm redirecting stdout to a new buffer (`*stylesheet*`), which gets displayed on completion. I can then easily save that buffer to wherever I want the stylesheet.

```elisp
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
```

And that's about it! Most of the time I tend to use `modus-operandi` in Emacs, so that's the one I'm using also for this site (at the moment, although it's not impossible that when you read this I'll have changed that).

{% endraw %}
