(require 'generic)
(define-generic-mode 'ul-mode
  ;; comment-list
  '("%" ("/*" . "*/"))
  ;; keyword-list
  '(
    "defgrammar"
    "defdim"
    "dims"
    "args"
    "defattrstype"
    "defentrytype"
    "deflabeltype"
    "deftype"
    "useprinciple"
    "usedim"
    "output"
    "useoutput"
    "defclass"
    "useclass"
    "defentry"
    "dim"
    ;;
    "defprinciple"
    "constraints"
    ;; types
    "set"
    "iset"
    "tuple"
    "list"
    "valency"
    "card"
    "vec"
    "constraint"
    "int"
    "ints"
    "string"
    "bool"
    "ref"
    "label"
    "tv"
    ;;
    "node"
    ;; constraints
    "equal"
    "notequal"
    "include"
    "exclude"
    "subseteq"
    "disjoint"
    "notdisjoint"
    ;;
    "let"
    "exists"
    "existsone"
    "forall"
    "in"
    "notin"
    "intersect"
    "union"
    "minus"
    "edge"
    "dom"
    "domeq"
    "word"
    ;; aspects
    "attrs"
    "entry"
    ;;
    "top"
    "bot"
    "infty"
    )
  ;; font-lock-list
  '("{" "}" "(" ")" "*" "&" "|" "@" "\\[" "\\]" "<" ">" "\\$" "\\." "_" "\\^" "!" "?" "+" "#" ":" "=" "~" "/")
  ;; auto-mode-list
  '("\\.ul$")
  ;; function-list
  nil)
